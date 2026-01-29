# Cursor Rules Template

Global Cursor rules that enforce a planner → orchestrator multi-agent workflow across all projects.

## What's Included

### Rule Files

**planner.mdc** - Planning phase rule
- Flesh out specs with user via OpenSpec
- Create Beads epics (issues with dependencies)
- Hand off structured work to orchestrators

**orchestrated-workflow.mdc** - Execution phase rule
- Orchestrators pick up ready work
- Reserve files for batch, spawn subagents in parallel
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
User Request
    ↓
Planner (flesh out spec, create epics)
    ↓
Beads Epics (issues + dependencies)
    ↓
Orchestrator(s) (register, reserve, spawn)
    ↓
Subagents (stateless workers, return results)
    ↓
Orchestrator releases, pushes
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
- ✅ Orchestrators always register; subagents only if blocked
- ✅ Orchestrators reserve files for subagent batches
- ✅ Subagents stateless by default (return results via Task)
- ✅ Serena used for code search

## Tool Access

**Planner:**
- OpenSpec for spec documentation
- Beads for creating issues

**Orchestrators:**
- Beads for issue management
- Agent Mail for registration, reservations, cross-orchestrator messaging
- Serena for code search

**Subagents:**
- Beads (create/close issues)
- Serena (code search)
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
