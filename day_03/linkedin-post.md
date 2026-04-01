# LinkedIn Post — Day 3: RAG from Scratch

---

Day 03: RAG from Scratch — through a Context Engineering lens 🔍

Everyone says "just add RAG" to give your LLM access to documents.

Almost nobody explains the 7 stages that actually make it work.

And almost nobody asks the more important question:
where does RAG fit inside a production AI system?

I just finished Day 03 of the Context Engineering course by Dr. Sreedath Panat and Dr. Raj Dandekar at Vizuara Technologies Private Limited — and it completely reframed how I think about retrieval.

What makes this different from a typical RAG tutorial: it's taught through the lens of **context engineering**. RAG isn't treated as a standalone system — it's the SELECT operation inside the WSCI framework (WRITE → SELECT → COMPRESS → ISOLATE). That framing changes everything about how you design, debug, and scale it.

So I did what I always do: I turned my learnings into detailed, illustrated notes. 📝

Here's what's inside:
🔹 RAG is the SELECT operation in the WSCI framework — it's not a standalone tool, it's one piece of a 4-part context management system
🔹 The pipeline has two phases: offline (ingest, chunk, embed, index — runs once) and online (retrieve, rerank, generate — runs per query). Most tutorials collapse them together
🔹 Why BM25 is still the production standard over TF-IDF: term frequency saturation + document length normalization. Elasticsearch defaults to it for a reason
🔹 Anthropic's Contextual Retrieval: prepend 2–3 sentences of document-level context to every chunk before embedding → ~49% fewer retrieval failures. Combine with BM25 for 67% improvement
🔹 Dense, Sparse, and Hybrid are three independent retrieval systems. RRF is the final separate merging step — not part of hybrid
🔹 ColBERT's late interaction: per-token embeddings scored via MaxSim. Cross-encoder accuracy at bi-encoder speed
🔹 3 failure categories: retrieval failure (right chunk never surfaced), synthesis failure (right chunk, wrong answer), context window poisoning (retrieved content actively degrades the answer)
🔹 Advanced patterns: Self-RAG, Corrective RAG, Adaptive RAG, HyDE, RAPTOR — each backed by the original paper with inline citations
🔹 The context window sweet spot is 100K–200K tokens — not 1M. Filling 50–60% of a 1M token window already causes context rot. Bigger window ≠ better output
🔹 In a real-world email reply agent, a well-crafted 600–1,000 line markdown file outperformed a full RAG vector database in both speed and accuracy. RAG is not always the answer

💡 Biggest takeaway? RAG isn't a feature you bolt on. It's a context engineering decision — about what information enters the window, when, and at what quality. Most RAG failures are retrieval failures. Fix the pipeline before you fix the prompt.

📺 LLM Context Engineering Bootcamp: https://www.youtube.com/playlist?list=PLPTV0NXA_ZSj-E8A1DBvbWIYGxC46u-Hd
📺 RAG for Production: https://www.youtube.com/playlist?list=PLPTV0NXA_ZSgZdinC6o6dF_p8LQqz8vqq
📺 RAG from Scratch (Lance Martin, LangChain): https://www.youtube.com/watch?v=sVcwVQRHIc8

I'll be sharing illustrated notes for each day as I go. Follow along if you want the cliff notes version, with cartoons! 🎨

What's the most common RAG failure you've hit in production? I'd love to hear how you debugged it 👇

Dr. Sreedath Panat Dr. Raj Dandekar Lance Martin
