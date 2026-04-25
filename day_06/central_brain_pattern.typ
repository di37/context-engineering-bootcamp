#import "brand.typ": *

#show: branded-doc.with(
  title: "The Central Brain Pattern",
  subtitle: "Multi-Agent Orchestration via Two-Way MCP",
  version: "v1.0",
  doc-type: "guide",
)

#v(1fr)

#align(center)[
  #block(width: 85%)[
    #text(size: 20pt, weight: "bold", fill: navy)[Acknowledgment]
    #v(2pt)
    #line(length: 100%, stroke: 2pt + teal)
    #v(12pt)
    #set text(size: 12pt)
    #set par(leading: 0.9em, justify: true)
    I am deeply grateful to #link("https://www.linkedin.com/in/sreedath-panat/")[Dr.~Sreedath Panat] and #link("https://www.linkedin.com/in/raj-abhijit-dandekar-67a33118a/")[Dr.~Raj Dandekar] of *Vizuara Technologies* for creating and generously sharing their courses. This pattern was introduced during the Day 3 lecture on memory lifetimes and expanded in Day 4's MCP discussion.

    #v(8pt)
    #link("https://www.youtube.com/playlist?list=PLPTV0NXA_ZSj-E8A1DBvbWIYGxC46u-Hd")[#sym.arrow.r LLM Context Engineering Bootcamp]
  ]
]

#v(1fr)

#pagebreak()

#outline(title: "Contents", indent: auto)
#pagebreak()

= Overview

The *Central Brain pattern* is a multi-agent orchestration architecture where multiple specialized agents (each a separate, independent project) are connected through a central orchestrator via *two-way MCP (Model Context Protocol)*. The orchestrator holds the global picture of what needs to happen and when, while individual agents provide domain-specific execution. This pattern was previewed in Day 3 during the discussion of persistent memory and is formalized here because it relies fundamentally on MCP as its communication mechanism.

= Prerequisites

- Understanding of MCP architecture: client, server, three primitives, transport layers (Day 4)
- Understanding of the MCP lifecycle: initialization, normal operation, shutdown (Day 4)
- Familiarity with `CLAUDE.md` and persistent memory concepts (Days 2--3)
- Understanding of the WSCI framework, particularly ISOLATE (Day 3)

= The Problem: Isolated Agents

In a real-world organization, multiple specialized agents may exist as *separate projects* (not sub-agents, but fully independent codebases):

- *Agent 1 (Research):* Searches the web, analyzes papers, compiles findings
- *Agent 2 (Email):* Drafts and sends emails, manages inbox
- *Agent 3 (Code Review):* Reviews pull requests, checks code quality
- *Agent 4 (Data Analysis):* Queries databases, generates reports

Each agent excels at its specialty but has *no awareness of the other agents or the overall company workflow*. Agent 1 does not know when Agent 2 should send a follow-up email. Agent 3 does not know that Agent 4's report is a prerequisite for a code change.

#warning[Without orchestration, each agent operates in isolation. The user becomes the "human API," manually deciding which agent to invoke, in what order, and what context to pass between them. This is the same problem that MCP solved for tools: manual coordination does not scale.]

= Architecture: Central Brain as Orchestrator

The solution is a fifth project: a *Central Brain* that acts as the orchestrator via two-way MCP.

#figure(
  image("mermaid/mermaid_11_central_brain.png", width: 70%),
  caption: [The Central Brain pattern: five separate projects connected via two-way MCP. The orchestrator delegates but never executes.],
)

Five separate projects exist: four specialized agents and one Central Brain orchestrator. The Central Brain (Project 5) connects to each agent via *two-way MCP*, meaning communication flows in both directions. The Central Brain has *no execution tools of its own*. It cannot research, email, review code, or analyze data. Its only capabilities are (1) accessing information about each agent's status and capabilities, and (2) delegating tasks to the appropriate agent.

= Why Not Connect Agents Directly?

Individual agents lack the global context to know _when_ and _what_ to do. They only know _how_.

#branded-table(
  ("Component", "Knows How", "Knows When and What"),
  ("Agent 1 (Research)", "Yes: how to search, analyze, compile", "No: when research is needed, what to research next"),
  ("Agent 2 (Email)", "Yes: how to draft and send emails", "No: when to send, what context to include"),
  ("Central Brain", "No: cannot execute any task itself", "Yes: knows overall company workflow, priorities, and task dependencies"),
  caption: [Role separation: the Central Brain knows when and what; agents know how],
)

#insight[The Central Brain holds the _global picture_: what projects are in progress, what tasks are pending, what dependencies exist. Individual agents are focused specialists. The Central Brain provides _instructions_; individual agents provide _execution_. This separation mirrors the MCP client-server split: the orchestrator (like the client) decides _what_ to do; the agents (like servers) decide _how_ to do it.]

Technically, agents _can_ be connected directly via two-way MCP. But without a central orchestrator, no single entity holds the global workflow context. Each agent would need to understand the full company picture to know when to delegate to another agent, which defeats the purpose of specialization.

= Role Separation: Instructions vs. Execution

#branded-table(
  ("Role", "Central Brain (Orchestrator)", "Specialized Agents"),
  ("Has tools for", "Information access, delegation, scheduling", "Domain-specific execution (email, research, code, data)"),
  ("Makes decisions about", "Task ordering, agent selection, workflow dependencies", "How to accomplish a specific assigned task"),
  ("Context includes", "CLAUDE.md files from all agents, global task board, company priorities", "Only its own CLAUDE.md, domain-specific databases, current assignment"),
  ("MCP role", "Acts as MCP client to each agent's MCP server", "Acts as MCP server exposing its tools to the Central Brain"),
  caption: [Central Brain vs. specialized agents: role separation],
)

= Shared Context Across Agents

Certain files are referenced across the entire multi-agent network:

- *CLAUDE.md files from each agent:* Referenced by the Central Brain to understand each agent's core philosophy, capabilities, and implementation strategy. These are persistent memory (weeks/months lifespan).
- *Shared databases:* e.g., an email agent's vector database may be queried by both the email agent and the Central Brain for different purposes.
- *Task state:* The Central Brain maintains a global understanding of which tasks are assigned, pending, or completed across all agents.

#memo[The CLAUDE.md file is the contract between an agent and the Central Brain. It tells the orchestrator: here is what I can do, here are my constraints, and here is my operating philosophy. The Central Brain reads these files to make informed delegation decisions, never needing to understand the agent's implementation details.]

= Central Brain and MCP: The Connection

The Central Brain pattern maps directly onto every MCP concept:

#branded-table(
  ("MCP Concept", "Central Brain Application"),
  ("MCP Client", "Central Brain acts as client to each agent"),
  ("MCP Server", "Each specialized agent acts as a server exposing its tools"),
  ("Three Primitives", "Agents expose tools (execute tasks), resources (CLAUDE.md, databases), and prompts (standard task templates)"),
  ("Two-way MCP", "Bidirectional: Central Brain delegates to agents; agents report status back"),
  ("Transport", "stdio if all agents are on the same machine; HTTP/SSE if distributed"),
  ("Handshake", "Central Brain discovers each agent's capabilities during initialization"),
  ("Tool selection", "Central Brain's LLM decides which agent to delegate to: the same DECIDE step from the tool life cycle"),
  caption: [Every MCP concept maps to the Central Brain pattern],
)

= Open Questions

+ *Central Brain scalability:* How does the orchestrator handle 10+ agents? Does it need its own tool selection / RAG mechanism for choosing which agent to delegate to? _Research: hierarchical orchestration with sub-orchestrators._

+ *Two-way MCP implementation:* Detailed protocol for bidirectional communication. How does state synchronization work between orchestrator and agents? _Read: MCP specification for server-to-client notifications._

+ *Multi-agent MCP topologies:* Can agents communicate with each other via MCP without a central brain (peer-to-peer)? What are the trade-offs vs. hub-and-spoke? _Explore: peer-to-peer patterns vs. hierarchical orchestration._

+ *MCP Authentication for agent networks:* How to implement secure inter-agent communication? Each agent may need different access levels. _Critical for enterprise deployments._

#brand-cta()
