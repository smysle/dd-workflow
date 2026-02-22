# DD Workflow

**DesignDoc Driven Development** — an [OpenClaw](https://github.com/openclaw/openclaw) skill for structured, agent-native feature development.

Write a design doc first, then implement against it. Every non-trivial feature goes through a **design → review → implement → verify** cycle, orchestrated by AI agents.

## How It Works

```
Requirement → [Design Agent] DesignDoc → Human Review → [Implementation Agent] Code → Verify
```

| Role | What it does |
|------|-------------|
| **Orchestrator** (main agent) | Allocates IDs, spawns agents, routes reviews |
| **Design Agent** | Researches codebase, writes the DesignDoc, commits |
| **Implementation Agent** | Reads the doc, plans, implements, tests, commits |

## 6 Core Rules

1. **Plan Mode** — Research first, then plan. Never jump straight into code.
2. **Write the DesignDoc first** — Background, goals, non-goals, proposal, risks, test plan, rollback.
3. **Store per-project** — `{repo}/docs/design/NNNN-slug.md`. Don't mix projects.
4. **Commit doc before code** — Code commits reference `DD-NNNN`.
5. **Plan before executing** — Output an execution plan, then implement step-by-step.
6. **Log deviations** — Any departure from the doc must be recorded in §8.

## Install

Copy the skill into your OpenClaw workspace:

```bash
# Clone
git clone https://github.com/smysle/dd-workflow.git

# Copy to your skills directory
cp -r dd-workflow ~/.openclaw/workspace/skills/dd-workflow
```

Or add as a git submodule:

```bash
cd ~/.openclaw/workspace/skills
git submodule add https://github.com/smysle/dd-workflow.git dd-workflow
```

Restart your gateway and the skill will be auto-detected.

## What's Included

```
dd-workflow/
├── SKILL.md                  # Core rules, roles, quick-start checklist, pitfall notes
├── scripts/
│   └── allocate-dd-id.sh     # Atomic DD-ID allocator (reads/increments .next-id)
└── references/
    ├── WORKFLOW.md            # Task templates for design & implementation agents
    └── TEMPLATE.md            # 8-section DesignDoc template
```

## Quick Start

Once installed, tell your agent something like:

> "Build a user authentication system using the DD workflow"

The agent will:
1. Allocate a DD ID (`DD-0001`)
2. Spawn a design agent to write the DesignDoc
3. Ask you to review and approve
4. Spawn an implementation agent to write the code
5. Verify: build passes, tests pass, two commits (doc + code)

## Customization

All templates use variables — no hardcoded models or paths:

| Variable | Description |
|----------|-------------|
| `{design_model}` | Model for design tasks (e.g. `claude-opus-4`) |
| `{implement_model}` | Model for implementation (e.g. `codex-1`) |
| `{author_name}` / `{author_email}` | Git author for commits |
| `{workspace}` | Your OpenClaw workspace root |
| `{repo_root}` | Target project repository root |

## Battle-Tested

This workflow was developed and refined over 8+ real projects, from CLI tools to full-stack web apps. Key lessons learned are baked into the skill's pitfall notes.

## License

MIT
