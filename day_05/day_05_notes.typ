#import "brand.typ": *

#show: branded-doc.with(
  title: "Day 5: Context Engineering Failure Modes",
  subtitle: "A Comprehensive Taxonomy of How Context Windows Fail",

  version: "v2.0",
  doc-type: "guide",
)

#outline(title: "Contents", indent: auto)
#pagebreak()

= Overview

Context engineering is the discipline of designing, curating, and managing the information that flows into an LLM's context window. When done well, the model receives exactly the right information at the right time, producing accurate, relevant responses. When done poorly, failures emerge that are often misdiagnosed because engineers treat "bad context" as a single problem.

Recent research and production experience @breunig2025howcontextsfail @stackone2025agentsuicide @redis2026overflow have identified at least eight distinct failure modes, each with a different root cause, detection signal, and mitigation strategy. Applying the wrong fix (e.g., pruning context to solve what is actually a poisoning issue) wastes effort and may make the problem worse.

This guide defines all eight failure modes, compares them side-by-side, groups them by category, and provides actionable mitigation strategies for each.

#pagebreak()

= Failure Mode Taxonomy

The eight failure modes fall into three natural categories based on their primary mechanism: volume problems (too much), quality problems (wrong content), and structural problems (right content, wrong arrangement).

#branded-table(
  caption: [The eight context failure modes grouped by category.],
  (
    [*Category*],
    [*Failure Mode*],
    [*One-Line Definition*],
    [*Risk Level*],
  ),
  (
    [Volume],
    [Context Bloat],
    [Too much information overwhelms the model's attention],
    [Medium],
  ),
  (
    [Volume],
    [Token Budget Mismanagement],
    [Context segments compete for limited space with no allocation policy],
    [Medium],
  ),
  (
    [Quality],
    [Context Rot],
    [Once-accurate context has gone stale over time],
    [High],
  ),
  (
    [Quality],
    [Context Poisoning],
    [Incorrect or adversarial information injected into context],
    [Critical],
  ),
  (
    [Quality],
    [Context Clash],
    [Contradictory information coexists in the same context],
    [High],
  ),
  (
    [Structural],
    [Context Distraction],
    [Accumulated history causes the model to repeat past actions instead of reasoning freshly],
    [High],
  ),
  (
    [Structural],
    [Context Confusion],
    [Irrelevant content triggers wrong tool calls or off-topic responses],
    [Medium],
  ),
  (
    [Structural],
    [Context Drift],
    [Model gradually loses track of the original intent over long interactions],
    [High],
  ),
)

The following sections examine each failure mode in depth. They are ordered by category: volume first, then quality, then structural.

#pagebreak()

= Volume Failures

Volume failures occur when the amount of information in the context window is mismanaged. The content may be accurate and well-structured, but there is simply too much of it, or the available space is allocated poorly.

== Context Bloat

Context bloat occurs when the context window is filled with more information than the model can effectively process @inkeep2025agentsfail. The information may all be technically relevant, but the sheer volume dilutes the model's attention across too many tokens, causing it to miss the details that matter most.

#figure(
  image("illustrations/img_sec_04_context_bloat.jpg", width: 85%),
  caption: [Context bloat: the model drowns in an ocean of marginally relevant information.],
) <fig-bloat>

Common sources include retrieval pipelines that return too many chunks without reranking or deduplication, system prompts that grow unchecked as features are added, full conversation histories appended without summarization, and tool outputs that dump raw data (entire API responses, full database rows) instead of extracted answers.

#warning[
  RAG systems are particularly susceptible to bloat. A naive "retrieve top-20" strategy can fill half the context window with marginally relevant passages, leaving little room for the actual query and instructions.
]

Bloated contexts produce recognizable patterns: responses become generic and surface-level, the model fails to follow specific instructions that are present but buried in the context, latency increases as token counts approach the window limit, and costs rise proportionally with token usage.

*Steps to avoid context bloat:*

#steps(
  (title: "Implement aggressive retrieval filtering", detail: "Use reranking models (e.g., Cohere Rerank, cross-encoders) to score and prune retrieved chunks. Return the top 3 to 5, not top 20."),
  (title: "Summarize conversation history", detail: "Replace older turns with a running summary. Keep the last 2 to 3 turns verbatim and compress everything before that."),
  (title: "Extract, don't dump", detail: "When tools return data, extract only the fields the model needs. Never paste a raw 500-line JSON response into the context."),
  (title: "Audit system prompts regularly", detail: "Measure your system prompt in tokens. If it exceeds 15 to 20% of the context window, refactor it: move static reference material to retrieval, remove redundant instructions."),
)

== Token Budget Mismanagement

Token budget mismanagement is a subtler variant of bloat. The total context may not be excessively large, but the allocation across segments (system prompt, retrieved documents, conversation history, tool definitions, tool outputs) has no explicit policy, so components compete in a zero-sum game for limited space.

#figure(
  image("drawings/draw_05_token_budget_mismanagement.jpg", width: 85%),
  caption: [Token budget mismanagement: context segments compete for limited space without allocation policies.],
) <fig-budget>

This failure mode is common in systems that load hundreds of MCP tool schemas (consuming 100K+ tokens just for tool definitions), pre-load RAG context at startup before the user even asks a question (consuming 60%+ of the budget upfront), or accumulate intermediate results from sequential tool calls without pruning (30 calls at 3K tokens each consumes 90K tokens) @stackone2025agentsuicide.

#info[
  Every API call repeats the system prompt. In a 20-turn conversation, the system prompt is transmitted 20 times. A 5,000-token system prompt consumes 100,000 tokens of cumulative budget across those turns.
]

The key detection signal is that no single component looks excessive in isolation, but together they leave insufficient room for the actual task. Quality degrades not because any one piece is too large, but because nothing was budgeted.

*Steps to avoid token budget mismanagement:*

#steps(
  (title: "Define explicit token budgets per component", detail: "Allocate fixed percentages: e.g., 10% system prompt, 25% retrieved context, 40% conversation history, 15% tool definitions, 10% buffer. Enforce these programmatically."),
  (title: "Load tools dynamically", detail: "Use semantic search across tool definitions and load only the 5 to 10 tools relevant to the current query instead of exposing all 500."),
  (title: "Use memory pointers instead of raw data", detail: "Store intermediate tool results in external memory and pass only a reference and summary into the context. This can reduce token usage by 80%+."),
  (title: "Implement progressive compaction", detail: "Summarize completed milestones in long conversations. Distill architectural decisions while pruning verbose explanations."),
)

With volume under control, the next category addresses what happens when the content itself is wrong.

#pagebreak()

= Quality Failures

Quality failures occur when the information in the context is inaccurate, outdated, contradictory, or adversarial. The context window may be well-sized and well-structured, but the content it carries cannot be trusted.

== Context Rot

Context rot is the silent degradation of context quality over time @barla2025contextrot @redis2025contextrot. Unlike bloat, the amount of information may be perfectly sized, but its accuracy has decayed. The model receives stale facts, deprecated configurations, or outdated documentation and treats them as current truth.

#figure(
  image("illustrations/img_sec_07_context_rot.jpg", width: 85%),
  caption: [Context rot: once-accurate information silently decays into stale, misleading facts.],
) <fig-rot>

Context rot stems from temporal mismatches: cached embeddings generated months ago that no longer reflect the source documents, retrieval indexes that are not re-indexed when source data changes, system prompts that reference deprecated API versions or removed features, and few-shot examples that demonstrate patterns no longer supported by the codebase.

#memo(title: "Key Detection Rule")[
  If the model's answers were correct three months ago but are wrong today, and the system has not changed, context rot is the cause. The system is working as designed; the context has simply expired.
]

The hallmark of context rot is confidently wrong answers. The model does not hedge or express uncertainty because the stale context appears authoritative. Specific indicators include: the model recommends deprecated functions or APIs, answers contradict information available in recently updated sources, and timestamps embedded in retrieved content are significantly older than the query's temporal scope.

*Steps to avoid context rot:*

#steps(
  (title: "Implement TTL (time-to-live) on cached context", detail: "Set expiration times on cached retrieval results, embedding indexes, and system prompt components. Force re-fetching after the TTL expires."),
  (title: "Version and timestamp all context sources", detail: "Tag every piece of context with its source document version and last-updated timestamp. Reject or flag context older than a defined threshold."),
  (title: "Schedule regular re-indexing", detail: "Run embedding pipeline refreshes on a cadence that matches your domain's rate of change: daily for docs, hourly for pricing, real-time for compliance data."),
  (title: "Add freshness-aware retrieval", detail: "Boost recently updated documents in retrieval scoring. Penalize or exclude documents that have not been verified since a cutoff date."),
)

== Context Poisoning

Context poisoning introduces information that is not just stale or excessive, but actively wrong @breunig2025howcontextsfail. The model consumes false, misleading, or adversarial content and produces outputs that reflect it. This is the most dangerous failure mode because it can compromise safety, security, and trust.

#figure(
  image("illustrations/img_sec_08_context_poisoning.jpg", width: 85%),
  caption: [Context poisoning: false or adversarial information infiltrates the context and corrupts outputs.],
) <fig-poisoning>

Poisoning has both accidental and adversarial origins. Accidental poisoning includes retrieval from corrupted or low-quality data sources, ingesting user-generated content without validation, and including hallucinated outputs from previous LLM calls as context for subsequent ones (hallucination cascades). Adversarial poisoning includes prompt injection attacks embedded in retrieved documents, data poisoning of retrieval corpora, and malicious manipulation of knowledge bases or tool outputs.

#danger[
  Indirect prompt injection is a form of context poisoning where an attacker embeds instructions in a document that the retrieval system surfaces into the model's context. The model then follows the attacker's instructions instead of the user's.
]

#error(title: "Hallucination Cascades")[
  When system A's LLM output becomes system B's context input, any hallucination in A becomes authoritative fact in B. This is one of the most common accidental poisoning vectors in multi-agent architectures.
]

Detection requires comparing model outputs against verified ground truth, monitoring for anomalous behavioral patterns, and auditing retrieval sources for integrity.

*Steps to avoid context poisoning:*

#steps(
  (title: "Validate retrieval sources", detail: "Maintain an allowlist of trusted data sources. Score documents by provenance and authority. Reject or sandbox content from unverified sources."),
  (title: "Implement input sanitization", detail: "Scan retrieved content for prompt injection patterns before including it in the context. Strip or escape instruction-like content from untrusted sources."),
  (title: "Add citation verification", detail: "Require the model to cite specific passages from the context. Cross-check cited passages against the original source to detect fabrication."),
  (title: "Use grounding and fact-checking layers", detail: "Add a verification step that compares critical claims in the model's output against a trusted knowledge base before returning the response to the user."),
  (title: "Isolate untrusted context", detail: "Separate trusted context (system instructions, verified data) from untrusted context (user input, retrieved web content) using clear delimiters and instruction hierarchies."),
)

== Context Clash

Context clash occurs when contradictory information coexists in the same context window. Unlike poisoning (where the bad data was never correct) or rot (where it was once correct), clash happens when multiple sources disagree with each other and the model has no principled way to resolve the conflict.

#figure(
  image("drawings/draw_09_context_clash.jpg", width: 85%),
  caption: [Context clash: contradictory sources coexist and the model cannot resolve the conflict.],
) <fig-clash>

Common causes include multi-turn conversations where the model's earlier (incorrect) response remains in the history alongside new correcting information, retrieval from multiple sources that present conflicting facts about the same topic, and tool outputs that return data inconsistent with information already in the context.

Research shows an average 39% performance drop in multistep exchanges where earlier incorrect model responses remain in context alongside corrections @breunig2025howcontextsfail. Models tend to anchor on their initial assumptions and struggle to update when contradictory information arrives later.

#warning[
  The "anchoring effect" in context clash is particularly dangerous. If the model generates an incorrect intermediate answer in turn 3, it will often defend that answer in turns 4 through 10 even when the user provides correcting information, because the original (wrong) answer is in the context history.
]

*Steps to avoid context clash:*

#steps(
  (title: "Implement context quarantine", detail: "Isolate information from different sources into separate threads or sections. Process potentially conflicting sources sequentially rather than simultaneously."),
  (title: "Add conflict detection", detail: "Before finalizing a response, scan the context for contradictory claims about the same entity or topic. Flag conflicts for explicit resolution."),
  (title: "Prune incorrect intermediate outputs", detail: "When the model or user corrects an earlier statement, remove or explicitly mark the original as superseded rather than leaving both in the history."),
  (title: "Establish source priority hierarchies", detail: "Define which sources take precedence when conflicts arise: e.g., official documentation overrides user-provided snippets, recent data overrides older data."),
)

With quality issues addressed, the final category covers failures in how the context is structured and attended to.

#pagebreak()

= Structural Failures

Structural failures occur when the context contains the right information in the right quantity, but the model's attention is misdirected. The content is accurate and appropriately sized, but the arrangement, positioning, or accumulation pattern causes the model to focus on the wrong things.

== Context Distraction

#figure(
  image("illustrations/img_sec_11_context_distraction.jpg", width: 85%),
  caption: [Context distraction: the model fixates on its own history instead of reasoning freshly.],
) <fig-distraction>

Context distraction occurs when a context grows so long that the model over-focuses on accumulated history, neglecting what it learned during training @breunig2025howcontextsfail @morphllm2025contextrot. Instead of synthesizing novel strategies, the model leans heavily on patterns it sees in the context and repeats past actions rather than reasoning freshly.

This failure mode is distinct from bloat. With bloat, the model cannot find the signal in the noise. With distraction, the model finds the signal but gives it too much weight, effectively becoming a pattern-matching engine over its own history rather than a reasoning system.

#info[
  Research suggests that distraction effects begin around 100K tokens for some models. The model does not fail catastrophically; it becomes incrementally more repetitive and less creative as context accumulates past this threshold.
]

Symptoms include agents that loop through the same sequence of actions repeatedly, responses that closely mirror earlier outputs even when the situation has changed, and a noticeable drop in the model's ability to generate novel approaches to problems.

*Steps to avoid context distraction:*

#steps(
  (title: "Maintain context within the distraction ceiling", detail: "Monitor accumulated context size and trigger compaction before reaching the model's effective threshold (often 60 to 70% of the window). Don't wait for hard limits."),
  (title: "Prioritize synthesis over history storage", detail: "Replace raw action logs with synthesized summaries of what was accomplished and what was learned. Preserve conclusions, discard the steps that led to them."),
  (title: "Use sub-agent isolation", detail: "Delegate complex subtasks to sub-agents that operate in fresh context windows. The parent agent receives only a concise summary (e.g., 50K tokens of work distilled to 2K)."),
  (title: "Rotate context strategically", detail: "For long-running agentic tasks, periodically create a fresh context with a distilled summary of prior work rather than continuing to append to the existing context."),
)

== Context Confusion

#figure(
  image("drawings/draw_12_context_confusion.jpg", width: 85%),
  caption: [Context confusion: irrelevant content misdirects the model's attention to the wrong tools or topics.],
) <fig-confusion>

Context confusion occurs when irrelevant content in the context is used by the model to generate a low-quality response @breunig2025howcontextsfail. The model misinterprets which pieces of context are relevant to the current query and applies the wrong information. This is closely related to the "lost in the middle" effect, where LLMs strongly favor information at the beginning and end of the context window while underweighting content in the middle @redis2026overflow.

Confusion is triggered by excessive tool definitions that create ambiguous decision points (if a human engineer cannot definitively say which tool should be used, the model certainly cannot), documents retrieved for a previous query that remain in context when a new query arrives, and similar-looking but semantically distinct pieces of information placed near each other.

#tip(title: "The Tool Confusion Test")[
  If your agent has access to more than 15 to 20 tools at once, run this test: for each common query type, ask a human which tool should be called. If the human hesitates or disagrees with others, the model will too. Reduce the tool set until each decision point is unambiguous.
]

*Steps to avoid context confusion:*

#steps(
  (title: "Implement dynamic tool loading", detail: "Rather than exposing all tools at once, use semantic matching to load only the 5 to 10 tools relevant to the current query. This reduces decision-point ambiguity."),
  (title: "Place critical information at context boundaries", detail: "Put the most important instructions and context at the beginning and end of the context window, where the model's attention is strongest. Move less critical reference material to the middle."),
  (title: "Clear stale retrieval results", detail: "When a new query arrives in a multi-turn conversation, remove or explicitly demarcate retrieval results that were fetched for previous queries."),
  (title: "Use structured context sections", detail: "Separate context into clearly labeled sections (SYSTEM INSTRUCTIONS, RETRIEVED CONTEXT, CONVERSATION HISTORY, TOOL DEFINITIONS) so the model can more easily identify which section is relevant to the current task."),
)

== Context Drift

Context drift is the gradual loss of alignment between the model's focus and the original intent of the interaction @leonas2025contextdrift @logrocket2026contextproblem. Over a long conversation or coding session, the model's understanding of the goal subtly shifts as new information, corrections, and tangents accumulate in the context window.

#figure(
  image("illustrations/img_sec_13_context_drift.jpg", width: 85%),
  caption: [Context drift: the model gradually loses track of the original goal over long interactions.],
) <fig-drift>

Drift is caused by long multi-turn interactions where the original task description is pushed far from the model's attention window, incremental scope changes that each seem small but cumulatively redirect the conversation, and context window truncation in older models that silently drops earlier messages (including the original instructions) as the conversation grows.

#memo(title: "Drift vs. Distraction")[
  Context distraction makes the model repetitive (it over-focuses on history). Context drift makes the model go off-track (it loses sight of the goal). The symptoms look similar, but the fixes are different: distraction needs context compaction, drift needs goal anchoring.
]

*Steps to avoid context drift:*

#steps(
  (title: "Anchor the goal in every turn", detail: "Repeat or summarize the original task description periodically, especially at context compaction points. The goal statement should always be within the model's strong attention zone."),
  (title: "Use explicit checkpoints", detail: "At regular intervals, ask the model to restate the current goal and compare it against the original. If they diverge, correct course before continuing."),
  (title: "Implement scope-change detection", detail: "When the user requests a change that modifies the original goal, explicitly acknowledge the scope change and update the goal statement rather than letting it drift implicitly."),
  (title: "Keep original instructions in a fixed position", detail: "Place the original task description in the system prompt or at a fixed position that is not affected by conversation history growth or truncation."),
)

= The Complete Comparison

The following table provides a comprehensive side-by-side reference for all eight failure modes, useful for quick diagnosis when something goes wrong in production.

#branded-table(
  caption: [Complete comparison of all eight context engineering failure modes.],
  (
    [*Failure Mode*],
    [*Root Cause*],
    [*Primary Symptom*],
    [*Detection Signal*],
  ),
  (
    [Context Bloat],
    [Over-retrieval, no pruning],
    [Vague, generic answers],
    [Token usage near limits, rising latency],
  ),
  (
    [Token Budget\ Mismanagement],
    [No allocation policy across context segments],
    [No single segment is too large, but quality degrades],
    [Components compete; removing one improves another],
  ),
  (
    [Context Rot],
    [Stale cached data, outdated embeddings],
    [Confidently wrong answers based on old facts],
    [Answers contradict recent ground truth],
  ),
  (
    [Context Poisoning],
    [Bad data, prompt injection, hallucination cascades],
    [False claims, behavioral shifts, safety violations],
    [Outputs contradict verified facts, unexpected actions],
  ),
  (
    [Context Clash],
    [Contradictory sources coexisting in context],
    [Inconsistent or flip-flopping answers],
    [39% performance drop in multistep exchanges],
  ),
  (
    [Context Distraction],
    [Accumulated history overwhelming training knowledge],
    [Repetitive actions, loss of creativity],
    [Agent loops through same action sequence],
  ),
  (
    [Context Confusion],
    [Irrelevant content misdirecting attention],
    [Wrong tool calls, off-topic responses],
    [Model uses information from unrelated prior queries],
  ),
  (
    [Context Drift],
    [Original intent lost over long interactions],
    [Responses gradually go off-track],
    [Model's stated goal diverges from original task],
  ),
)

#pagebreak()

= Solutions: How to Avoid Each Failure Mode

The sections above describe each failure mode individually. This section consolidates the top solution for each into a single quick-reference, then presents five architectural patterns that defend against multiple failure modes simultaneously.

== Quick-Reference: One Solution Per Failure Mode

#branded-table(
  caption: [Highest-impact solution for each volume and quality failure mode.],
  (
    [*Failure Mode*],
    [*Top Solution*],
    [*How It Works*],
  ),
  (
    [Context Bloat],
    [Rerank and prune retrieval],
    [Use a cross-encoder reranker to score retrieved chunks by relevance. Return only the top 3 to 5 instead of top 20. This alone can cut context size by 75% while improving answer quality.],
  ),
  (
    [Token Budget\ Mismanagement],
    [Define explicit token budgets per segment],
    [Allocate fixed percentages to each context component (e.g., 10% system prompt, 25% retrieval, 40% history, 15% tools, 10% buffer). Enforce these limits programmatically before each API call.],
  ),
  (
    [Context Rot],
    [TTL on all cached context],
    [Set expiration times on cached retrieval results, embedding indexes, and system prompt components. Force re-fetching after expiry. Match the TTL to your domain's rate of change.],
  ),
  (
    [Context Poisoning],
    [Source validation and input sanitization],
    [Maintain an allowlist of trusted data sources. Scan retrieved content for prompt injection patterns before including it in context. Never pipe raw LLM output from one system into another without verification.],
  ),
  (
    [Context Clash],
    [Conflict detection and source priority],
    [Before finalizing a response, scan context for contradictory claims. Establish which sources take precedence (e.g., official docs override user snippets, recent data overrides old data). Remove superseded information.],
  ),
)

#branded-table(
  caption: [Highest-impact solution for each structural failure mode.],
  (
    [*Failure Mode*],
    [*Top Solution*],
    [*How It Works*],
  ),
  (
    [Context Distraction],
    [Sub-agent isolation],
    [Delegate complex subtasks to sub-agents that operate in fresh context windows. The parent agent receives only a concise summary (e.g., 50K tokens of work distilled to 2K), preventing history accumulation.],
  ),
  (
    [Context Confusion],
    [Dynamic tool loading],
    [Use semantic matching to load only the 5 to 10 tools relevant to the current query. Place critical instructions at the start and end of the context window where attention is strongest.],
  ),
  (
    [Context Drift],
    [Goal anchoring],
    [Repeat or summarize the original task description at every context compaction point. Place the goal in the system prompt or a fixed position that is unaffected by conversation growth.],
  ),
)

== Five Architectural Patterns That Prevent Multiple Failures

Individual fixes target individual failure modes. The following five architectural patterns are structural defenses that prevent entire categories of failure from occurring in the first place.

=== Pattern 1: Progressive Context Compaction

Rather than letting context grow unbounded, summarize completed work at regular intervals. Replace raw action logs and tool outputs with synthesized summaries that preserve conclusions and discard verbose steps.

#tip[
  Trigger compaction at 60% of the context window, not at the hard limit. This leaves headroom for the current task and prevents the quality cliff that occurs when context is nearly full.
]

*Prevents:* context bloat, context distraction, context drift, token budget mismanagement.

=== Pattern 2: Tiered Memory Architecture

Separate context into three tiers with different retention policies. Working memory holds the current task and the last 2 to 3 turns (always present, highest priority). Short-term memory holds the current session's summarized history (retained until compaction). Long-term memory lives in external storage (database, vector store) and is retrieved on demand. Each tier has an explicit token budget, and information flows from working memory to short-term to long-term as it ages.

*Prevents:* context bloat, token budget mismanagement, context drift.

=== Pattern 3: Context Quarantine

Isolate untrusted or potentially conflicting information into separate processing threads. Process retrieval results from different sources independently before merging. Run untrusted user input through a sanitization layer before it enters the main context. Use sub-agents for operations that might produce hallucinations, so that any errors are contained.

#warning[
  Never let one LLM's raw output flow directly into another LLM's context without a validation step. This single rule prevents hallucination cascades, the most common form of accidental context poisoning in multi-agent systems.
]

*Prevents:* context poisoning, context clash, context confusion.

=== Pattern 4: Structured Context Windowing

Organize the context into clearly labeled, positionally stable sections: system instructions at the top, tool definitions next, retrieved context in the middle, and conversation history at the bottom (most recent turns closest to the end, where attention is strongest). Use explicit delimiters between sections.

*Prevents:* context confusion, context drift, context distraction.

=== Pattern 5: Freshness-Aware Retrieval Pipeline

Build freshness into the retrieval scoring function. Every document in the index carries a last-verified timestamp. The retrieval score combines semantic relevance with a freshness penalty: documents older than a configurable threshold are penalized or excluded entirely. Re-indexing runs on a schedule matched to the domain's rate of change.

*Prevents:* context rot, context poisoning (from stale, corrupted sources).

== The Defense Matrix

The following table maps each architectural pattern to the failure modes it prevents, making it easy to prioritize which patterns to implement first based on the failures you are experiencing.

#branded-table(
  caption: [Architectural patterns mapped to the failure modes they prevent.],
  (
    [*Pattern*],
    [*Bloat*],
    [*Budget*],
    [*Rot*],
    [*Poison*],
    [*Clash*],
    [*Distract*],
    [*Confuse*],
    [*Drift*],
  ),
  (
    [Progressive Compaction],
    [Yes], [Yes], [], [], [], [Yes], [], [Yes],
  ),
  (
    [Tiered Memory],
    [Yes], [Yes], [], [], [], [], [], [Yes],
  ),
  (
    [Context Quarantine],
    [], [], [], [Yes], [Yes], [], [Yes], [],
  ),
  (
    [Structured Windowing],
    [], [], [], [], [], [Yes], [Yes], [Yes],
  ),
  (
    [Freshness-Aware Retrieval],
    [], [], [Yes], [Yes], [], [], [], [],
  ),
)

#insight[
  No single pattern covers all eight failure modes. A production-grade system needs at least three of these five patterns working together. Start with Progressive Compaction (covers 4 modes) and Context Quarantine (covers 3 modes) for the broadest initial protection.
]

With solutions defined, the next section provides a diagnostic framework for identifying which failure mode is active when something goes wrong.

= Diagnostic Decision Framework

#figure(
  image("drawings/draw_15_diagnostic_decision_framework.jpg", width: 90%),
  caption: [Diagnostic flowchart: triage context failures from most dangerous (poisoning) to least (budget mismanagement).],
) <fig-diagnostic>

When diagnosing a context-related quality issue, work through this framework in order. The modes are ordered by severity: rule out the most dangerous first.

#decision(
  (condition: "Outputs contain false claims, safety violations, or unexpected behavioral shifts", action: "Diagnose context poisoning", reason: "Most dangerous: adversarial or hallucinated content in the context"),
  (condition: "Outputs are inconsistent or flip-flop between contradictory answers", action: "Diagnose context clash", reason: "Conflicting sources are both present and the model cannot resolve them"),
  (condition: "Answers were correct previously but are now wrong, and the system has not changed", action: "Diagnose context rot", reason: "The context has expired while the system stayed the same"),
  (condition: "Model calls wrong tools or responds to the wrong topic", action: "Diagnose context confusion", reason: "Irrelevant context is misdirecting the model's attention"),
  (condition: "Model repeats the same actions in a loop instead of progressing", action: "Diagnose context distraction", reason: "The model is pattern-matching on its own history instead of reasoning"),
  (condition: "Responses gradually go off-track over a long conversation", action: "Diagnose context drift", reason: "The original goal has been pushed out of the model's attention zone"),
  (condition: "Token usage is high and answers are vague or generic", action: "Diagnose context bloat", reason: "The model is overwhelmed by volume, not misinformation"),
  (condition: "No single segment is excessive but quality is still poor", action: "Diagnose token budget mismanagement", reason: "Context segments are competing for limited space with no allocation policy"),
)

#pagebreak()

= Key Takeaways

#info[
  Context failures are not a single problem. Eight distinct failure modes span three categories (volume, quality, structure), each requiring a different diagnostic approach and a different fix. The most common mistake is treating all context problems as bloat, when the real issue may be poisoning, clash, distraction, or drift. Diagnose before you treat.
]

Effective context engineering requires defending against all three categories simultaneously @anthropic2025contexteng @flowhunt2025contexteng. Filter aggressively and budget explicitly to prevent volume failures. Refresh regularly, validate sources, and resolve conflicts to prevent quality failures. Manage attention, isolate sub-tasks, and anchor goals to prevent structural failures. The systems that perform reliably in production are the ones that treat context as a carefully managed resource at every stage of the pipeline.

#pagebreak()

= References

#bibliography("references.bib", style: "ieee", title: none, full: true)

#brand-cta()
