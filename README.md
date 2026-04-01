# LLM Context Engineering Bootcamp

Comprehensive notes and visual resources from the [LLM Context Engineering Bootcamp](https://www.youtube.com/playlist?list=PLPTV0NXA_ZSj-E8A1DBvbWIYGxC46u-Hd) by [Vizuara AI Labs](https://context-engineering.vizuara.ai/). A 10-session hands-on workshop (8 lectures + 2 mega build sessions) taught by Dr. Sreedath Panat (PhD, MIT), Dr. Raj Dandekar (PhD, MIT), and Dr. Rajat Dandekar (PhD, Purdue).

## What Is Context Engineering?

Context engineering is the discipline of designing, assembling, and managing everything that flows into a large language model's context window to maximize output quality. It goes beyond single-turn prompt engineering to encompass system prompts, memory, retrieval, tool definitions, conversation history, and multi-agent coordination.

## Bootcamp Contents

> Notes marked with :white_check_mark: are complete. Notes marked with :construction: are in progress.

| # | Session | Topics | Status |
|---|---------|--------|--------|
| 1 | [**Introduction to LLM Context Engineering**](day_01/) | Prompts vs. context engineering, LLM OS analogy (Karpathy), six elements of context, context rot, lost-in-the-middle effect | :white_check_mark: [PDF](day_01/day_01_notes.pdf) |
| 2 | [**System Prompts & CLAUDE.md**](day_02/) | System prompts at the "right altitude", CLAUDE.md / AGENTS.md / skill.md, iterative construction, few-shot example selection | :white_check_mark: [PDF](day_02/day_02_notes.pdf) |
| 3 | [**RAG from Scratch**](day_03/) | WSCI framework, RAG pipeline end-to-end, chunking strategies, hybrid retrieval (dense + BM25 + RRF), cross-encoder reranking | :white_check_mark: [PDF](day_03/day_03_notes.pdf) |
| 4 | **Tools, Function Calling & MCP** | Tool schema design, Model Context Protocol (MCP), JIT instructions, ReAct agent loop | :construction: In progress |
| 5 | **COMPRESS & ISOLATE** | Compression techniques (summarization, clearing, trimming, hierarchical), auto-compaction, multi-agent isolation, token budgets | :construction: In progress |
| 6 | **Memory Architectures** | Episodic / semantic / procedural memory, windowing & summarization strategies, memory decay, cross-session persistence | :construction: In progress |
| 7 | **Production Patterns** | PRP workflow, Shopify case study (JIT at scale), evaluation harnesses, LLM-as-judge, production anti-patterns | :construction: In progress |
| 8 | **Capstone** | Full-stack agent (RAG + tools + memory + compression), three-phase guided build, evaluation & strategy playbook | :construction: In progress |
| 9 | **Mega Build Session I** | 3-hour guided project build with Dr. Raj Dandekar | :construction: In progress |
| 10 | **Mega Build Session II** | 3-hour guided project build with Dr. Rajat Dandekar | :construction: In progress |

## Repository Structure

```
context-engineering-bootcamp/
├── README.md
├── day_01/
│   ├── day_01_notes.typ          # Typst source
│   ├── day_01_notes.pdf          # Compiled PDF
│   ├── brand.typ                 # Shared branding template
│   ├── references.bib            # Bibliography
│   ├── illustrations/            # Slide captures and figures
│   └── mermaid/                  # Mermaid diagram sources + renders
├── day_02/
│   ├── day_02_notes.typ
│   ├── day_02_notes.pdf
│   ├── brand.typ
│   ├── references.bib
│   ├── config-files-comparison.* # Platform config file comparison
│   ├── illustrations/
│   └── mermaid/
└── day_03/
    ├── day_03_notes.typ
    ├── day_03_notes.pdf
    ├── brand.typ
    ├── references.bib
    ├── mteb_leaderboard.*        # MTEB embedding model leaderboard data
    ├── illustrations/
    ├── mermaid/
    └── drawings/                 # Hand-drawn diagrams (retrieval, RAG patterns)
```

## Prerequisites

- Basic familiarity with Python
- An API key from Anthropic, OpenAI, or Google Gemini
- Conceptual understanding of LLMs and next-token prediction
- For Day 3: familiarity with vectors, cosine similarity, and a Hugging Face access token

## Notes Format

Each day's notes are available in two formats:

| Format | Description |
|--------|-------------|
| `.pdf` | Compiled document with all illustrations and diagrams embedded |
| `.typ` | [Typst](https://typst.app/) source — compile with `typst compile day_XX_notes.typ` |

## Acknowledgments

All lecture content is from the [LLM Context Engineering Bootcamp](https://www.youtube.com/playlist?list=PLPTV0NXA_ZSj-E8A1DBvbWIYGxC46u-Hd) YouTube series. These notes are personal study materials created while following the course.
