# Cursor Rules Template

Global Cursor rule that enforces orchestrated multi-agent workflow across all projects.

## What's Included

### Rule File

**orchestrated-workflow.mdc** (65 lines, 1.5KB)
- Main agent acts as orchestrator
- Work tracked in Beads issues
- Subagents spawned per issue
- Agent Mail for coordination
- Serena for code search

### Documentation

**AGENTS.md** (copied to project root)
- Complete workflow guide
- Multi-agent examples
- Session completion protocol

## The Pattern

```
User Request
    ↓
Orchestrator (you) creates Beads issues
    ↓
Spawns subagents via Task tool (one per issue)
    ↓
Subagents: register, reserve files, complete work, report
    ↓
Orchestrator integrates results
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

1. **Cursor Rules** - Copies `orchestrated-workflow.mdc` to `.cursor/rules/`
2. **AGENTS.md** - Copies workflow guide to project root
3. **Beads** - Runs `bd init` and `bd setup cursor`
4. **Serena** - Creates `.serena/` with `project.yml`, memories, and cache

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
│   └── rules/
│       └── orchestrated-workflow.mdc
├── .beads/           # Issue tracking
├── .serena/          # Code search
│   ├── project.yml
│   ├── memories/
│   └── cache/
└── AGENTS.md
```

## What It Enforces

- ✅ Orchestrator delegates (never implements)
- ✅ All work tracked in Beads
- ✅ Subagents register with Agent Mail
- ✅ Files reserved before editing
- ✅ Serena used for code search
- ✅ Thread ID = Issue ID

## Tool Access for Subagents

Subagents spawned via Task tool have full access to:
- **Beads (bd)** - All commands
- **Agent Mail** - Register, message, file reservations
- **Serena** - Code search and navigation

## Why One Rule?

Single consolidated rule (~65 lines) instead of 4+ separate rules:
- Clearer mental model
- Less token overhead
- All context in one place
- Easier to maintain

## Customization

Edit `orchestrated-workflow.mdc` in your cloned template directory.

Then re-deploy to projects:
```bash
rm your-project/.cursor/rules/orchestrated-workflow.mdc
cursor-rules
```
