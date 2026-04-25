# LinkedIn Post — Day 6: Multi-Agent Context Management

---

Day 06: Multi-Agent Context Management — All About AGENTS.md 🧠

Everyone is shipping "multi-agent systems" right now.

Almost nobody explains the two operations that actually make them work: **Compress** and **Isolate**.

And almost nobody asks the harder question:
when you split a task across 5 agents, *who decides what each agent gets to see?*

I just finished Day 06 of the Context Engineering course by Dr. Sreedath Panat and Dr. Raj Dandekar at Vizuara Technologies Private Limited — and it completely reframed how I think about agent orchestration.

What makes this different from a typical "multi-agent" tutorial: it's taught through the lens of **context engineering**. Sub-agents aren't treated as a deployment trick — they're the ISOLATE operation inside the WSCI framework (WRITE → SELECT → COMPRESS → ISOLATE). That framing turns scattered patterns into one coherent system.

So I did what I always do: I turned my learnings into detailed, illustrated notes. 📝

Here's what's inside:
🔹 The Central Brain Pattern — multiple specialized agents, each a *separate independent project*, connected through a central orchestrator via two-way MCP. The architecture that ties everything from Days 1–4 together
🔹 Two reasons compression exists: cost grows linearly with conversation turns, and quality peaks then degrades past ~80K tokens (the "lost in the middle" effect). Compression keeps you in the sweet spot
🔹 The 4 compression types ranked by safety: tool result clearing (safe, free, 100% IRR) → LLM summarization (lossy but high compression) → priority trimming (rule-based) → hierarchical compression (semantic, LLM-driven)
🔹 Information Retention Ratio (IRR) — the metric for evaluating compression quality. BiteBridge example: 1,900 tokens → 257 tokens at 90% IRR
🔹 The two-threshold system: 80% auto-compaction (graceful) + 95% emergency trimming (survival mode). Why both exist — a single LLM output can jump 79% → 89%, skipping 80% entirely
🔹 CLAUDE.md vs. agents.md — the sharpest distinction is *who reads it and when*. CLAUDE.md is the employee handbook (main agent, always loaded). agents.md is the department onboarding doc (sub-agents, lazy-loaded per directory)
🔹 The agents.md hierarchy resolves by *child precedence + ancestor accumulation*. A sub-agent in src/frontend/components/ inherits 4 levels of rules, with deeper levels winning conflicts
🔹 5 multi-agent patterns split into two concerns: coordination (Contract-First, Fan-Out/Fan-In) and context sharing (Full Isolation, Shared Base, Sequential Pipeline)
🔹 Sub-agents return findings to the orchestrator as compressed summaries (100–300 tokens) — never the full 30K-token investigation. The boundary itself is a 300× compression mechanism
🔹 OpenClaw → Claude Code is a real-world Central Brain: Gemini Flash orchestrates, Opus 4.6 executes. Two layers, two context windows, each managed independently. Telegram on EC2, laptop closed, fully remote workflow
🔹 Andrej Karpathy's Auto Research agent ran 24/7 for 2+ days without a single context failure — by adding ONE explicit `/compact` instruction to CLAUDE.md when switching experiment sandboxes

💡 Biggest takeaway? Multi-agent systems aren't about more agents — they're about smaller, focused context windows. Each sub-agent is a built-in summarizer. The orchestrator's job is to decide what each agent sees, not to do the work itself. *Knows when and what; never how.*

📺 LLM Context Engineering Bootcamp: https://www.youtube.com/playlist?list=PLPTV0NXA_ZSj-E8A1DBvbWIYGxC46u-Hd
📺 Andrej Karpathy — Auto Research: https://github.com/karpathy/nanochat
📺 OpenClaw (Pete Steinberger): https://github.com/steipete/openclaw

I'll be sharing illustrated notes for each day as I go. Follow along if you want the cliff notes version, with cartoons! 🎨

What's the most painful context-rot or multi-agent failure you've hit in production? I'd love to hear how you debugged it 👇

Dr. Sreedath Panat Dr. Raj Dandekar Andrej Karpathy Pete Steinberger
