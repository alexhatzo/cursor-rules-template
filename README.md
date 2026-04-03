# Cursor Rules Template

Global Cursor rules that enforce a planner → orchestrator multi-agent workflow across all projects.

## What's Included

### Rule Files

**planner.mdc** - Planning phase rule
- Flesh out specs with user via OpenSpec
- Supports two entry points: pick up an existing Linear issue (`LIN-XXX`) or start fresh
- Creates a Linear parent issue (always) + Linear sub-issues mirrored to each Beads task
- Creates Beads epics (issues with dependencies) with cross-references to Linear
- Mirrors Beads dependencies as Linear `blockedBy` relations for human visibility
- Hand off structured work to orchestrators

**orchestrated-workflow.mdc** - Execution phase rule
- Orchestrators pick up ready work
- Reserve files for batch, spawn subagents in parallel
- Subagents update their Linear sub-issue to "In Progress" then "Done" (with implementation notes)
- Orchestrators mark Linear parent "Done" when all epic issues close
- Orchestrators always register; subagents only if blocked
- Subagents are stateless workers by default

Both rules have `alwaysApply: false` - invoke them explicitly when needed.

### Documentation

**AGENTS.md** (copied to project root)
- Complete workflow guide
- Multi-agent examples
- Session completion protocol

## The Pattern

```
User Request (or existing Linear issue LIN-XXX)
    ↓
Planner (flesh out spec, create Linear parent + Beads epics)
    ↓
Linear Parent Issue  ←→  Beads Epic (cross-referenced)
  └── Linear Sub-issues  ←→  Beads Tasks (cross-referenced)
    ↓
Orchestrator(s) (register, reserve, spawn)
    ↓
Subagents (stateless workers → update Linear sub-issue → return results)
    ↓
Orchestrator releases, pushes, marks Linear parent Done
```

## Setup

### One-time alias setup

Clone this repo and add to your `~/.zshrc`:

```bash
alias cursor-rules='~/path/to/cursor-rules-template/setup-cursor-rules.sh'
```

Then reload: `source ~/.zshrc`

### What the script does

`setup-cursor-rules.sh` automates full project setup:

1. **Cursor Rules** - Copies `planner.mdc` and `orchestrated-workflow.mdc` to `.cursor/rules/`
2. **AGENTS.md** - Copies workflow guide to project root
3. **Beads** - Runs `bd init` and `bd setup cursor`
4. **OpenSpec** - Runs `openspec init --tools cursor` (if available)
5. **Serena** - Creates `.serena/` with `project.yml`, memories, and cache

## Usage

```bash
cd /path/to/your-project
cursor-rules
```

Or specify the project path:

```bash
cursor-rules /path/to/your-project
```

Installs:
```
your-project/
├── .cursor/
│   ├── rules/
│   │   ├── planner.mdc
│   │   └── orchestrated-workflow.mdc
│   └── agents/           # 14 custom subagents
├── .beads/               # Issue tracking
├── .openspec/            # Spec documentation (if available)
├── .serena/              # Code search
│   ├── project.yml
│   ├── memories/
│   └── cache/
└── AGENTS.md
```

## What It Enforces

- ✅ Two-phase workflow (plan → execute)
- ✅ All work tracked in Beads with dependencies
- ✅ Every epic has a Linear parent issue (human-visible)
- ✅ Every Beads task has a mirrored Linear sub-issue with cross-reference IDs
- ✅ Linear status stays in sync throughout execution (Planner → In Progress, Subagents → Done)
- ✅ Orchestrators always register; subagents only if blocked
- ✅ Orchestrators reserve files for subagent batches
- ✅ Subagents stateless by default (return results via Task)
- ✅ Serena used for code search

## Linear Project Mapping

Issues are assigned to the Linear project matching the codebase touched:

| Codebase | Linear Project |
|---|---|
| `oneoff-api/**` | API |
| `oow-sm-web/**` | Frontend |
| `oneoff-web-admin-60/**` | Admin Dashboard |
| `oneoff-ios/**` | iOS |
| `oneoff-product-scraper/**` | Chrome Extension Scraper |

## Tool Access

**Planner:**
- OpenSpec for spec documentation
- Beads for creating issues
- Linear MCP (`get_issue`, `save_issue`) for creating parent + sub-issues

**Orchestrators:**
- Beads for issue management
- Linear MCP (`save_issue`) for marking parent Done
- Agent Mail for registration, reservations, cross-orchestrator messaging
- Serena for code search

**Subagents:**
- Beads (create/close issues)
- Serena (code search)
- Linear MCP (`save_issue`) for updating their sub-issue status and description
- Agent Mail (only if blocked/questions - register and message)

## Why Two Rules?

Separating planning from execution:
- **Planner** - Read-only exploration, spec writing, issue creation
- **Orchestrator** - Active coordination, file reservations, parallel execution

Both `alwaysApply: false` so you invoke them when needed.

## Customization

Edit the `.mdc` files in your cloned template directory.

Then re-deploy to projects:
```bash
rm your-project/.cursor/rules/planner.mdc
rm your-project/.cursor/rules/orchestrated-workflow.mdc
cursor-rules
```
