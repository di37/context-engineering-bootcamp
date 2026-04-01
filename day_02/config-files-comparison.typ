#import "brand.typ": *

#show: branded-doc.with(
  title: "CLAUDE.md vs AGENTS.md vs SKILL.md",
  subtitle: "A quick-reference comparison of the three core configuration files in AI coding agents",
  category: "AGENTIC AI",
  version: "v1.0",
  doc-type: "handout",
)

= Configuration Files at a Glance

These three markdown files form the context engineering backbone of AI coding agents like Claude Code. Each serves a distinct role in shaping agent behavior, scope, and capabilities.

#branded-table(
  caption: [Core differences between CLAUDE.md, AGENTS.md, and SKILL.md],
  ("Dimension", "CLAUDE.md", "AGENTS.md", "SKILL.md"),
  (
    [*Purpose*],
    [Master project instructions --- preferences, constraints, and high-level plans for the entire project],
    [Sub-agent definitions --- what each sub-agent does, its tools, and orchestration hierarchy],
    [Skill-specific knowledge --- detailed instructions for a particular capability (e.g., frontend, writing, Typst)],
  ),
  (
    [*Scope*],
    [Global or project-wide. A global CLAUDE.md applies to _all_ projects; a local one applies to one project],
    [Per-agent or per-sub-agent. Each agent folder can have its own AGENTS.md],
    [Per-skill. Each skill folder has its own SKILL.md],
  ),
  (
    [*Who reads it*],
    [Every agent and sub-agent in the project --- always loaded into context],
    [The specific agent (and its children) defined by that file],
    [Loaded on-demand when the skill is triggered by a user prompt or agent decision],
  ),
  (
    [*Typical content*],
    [Project goals, coding style, phase plans, tool preferences, global constraints],
    [Tool access definitions, sub-agent roles, orchestration rules, context boundaries],
    [Domain preferences, framework choices, patterns, templates, step-by-step workflows],
  ),
  (
    [*Lifespan*],
    [Weeks to months --- stable foundation that rarely changes],
    [Weeks to months --- stable as long as the agent architecture stays the same],
    [Hours to days --- evolves as features and specifications change],
  ),
  (
    [*Hierarchy*],
    [Top of the hierarchy. Overridden only by more local CLAUDE.md files],
    [Mid-level. Child AGENTS.md overrides parent on conflict; both are used otherwise],
    [Leaf-level. Activated per-task, does not override CLAUDE.md or AGENTS.md],
  ),
  (
    [*Universality*],
    [Tool-specific (Claude Code). Not a cross-platform standard],
    [Emerging universal standard (Linux Foundation). Works across multiple agent frameworks],
    [Tool-specific convention. Marketplace skills (e.g., skills.sh) can be shared],
  ),
  (
    [*Analogy*],
    [Company handbook --- everyone reads it, sets the culture],
    [Team charter --- defines each team's role and how teams coordinate],
    [Job training manual --- detailed how-to for a specific task],
  ),
)

#v(12pt)

#insight[Each file operates at a different level of abstraction: CLAUDE.md sets _what_ the project is about, AGENTS.md defines _who_ does the work, and SKILL.md specifies _how_ a particular skill is executed.]

#brand-cta()
