# Quick Start

## Setup New Project

```bash
cd /path/to/your-project
cursor-rules
```

Done! Two-phase workflow enabled.

## What This Means

Two cursor rules installed (both `alwaysApply: false`):

1. **planner.mdc** - Invoke when planning new work
2. **orchestrated-workflow.mdc** - Invoke when executing work

## Architecture

```
You (or Linear issue LIN-XXX) → Planner (spec, Linear parent, Beads epics)
                                    ↓
                      Linear Parent  ←→  Beads Epic
                      Linear Sub-issues ←→ Beads Tasks
                                    ↓
                      Orchestrator(s) (register, reserve files)
                                    ↓
                      Subagents (update Linear → commit → close Beads)
                                    ↓
                      Orchestrator marks Linear parent Done → Push
```

## What Gets Installed

```
your-project/
├── .cursor/rules/
│   ├── planner.mdc
│   └── orchestrated-workflow.mdc
├── .cursor/agents/      # 14 custom subagents
├── .beads/              # Issue tracking
├── .openspec/           # Spec docs (if available)
├── .serena/             # Code search
└── AGENTS.md
```

## Example

**You:** "Add authentication"  *(or: "Pick up LIN-45")*

**With planner.mdc active:**
```bash
# Planner clarifies requirements, then:

# Create Linear parent (or read existing LIN-45)
save_issue(title="Add JWT Auth", team="OneOff", project="API", state="In Progress")
# → LIN-45

# Create Beads tasks + mirrored Linear sub-issues
bd create "Auth schema" --priority=1           # → bd-101
bd create "Auth API" --priority=2             # → bd-102
bd create "Login UI" --priority=2             # → bd-103
save_issue(title="Auth schema", parentId="LIN-45", description="Beads: bd-101", ...)  # → LIN-46
save_issue(title="Auth API",    parentId="LIN-45", description="Beads: bd-102", ...)  # → LIN-47
save_issue(title="Login UI",    parentId="LIN-45", description="Beads: bd-103", ...)  # → LIN-48

# Set dependencies (Beads + Linear)
bd dep add bd-102 bd-101
save_issue(id="LIN-47", blockedBy=["LIN-46"])
bd sync
# "Ready for orchestrators: bd-101"
```

**With orchestrated-workflow.mdc active:**
```bash
# Orchestrator picks up work
register_agent(...)
file_reservation_paths(..., ["db/**", "api/**"])  # Reserve for batch
Task(prompt="Work on bd-101 (Linear: LIN-46)...")
Task(prompt="Work on bd-102 (Linear: LIN-47)...")

# Each subagent does:
#   save_issue(id="LIN-4X", state="In Progress")
#   ... implement ...
#   bd close bd-10X
#   save_issue(id="LIN-4X", state="Done", description="Beads: bd-10X\n\n## Implementation\n...")

# Orchestrator after batch:
release_file_reservations(...)
git push
save_issue(id="LIN-45", state="Done")  # Epic complete
```

## Key Differences from Before

| Before | Now |
|--------|-----|
| One rule, `alwaysApply: true` | Two rules, both `alwaysApply: false` |
| No Linear integration | Linear mirrors every Beads epic and task |
| Subagents always register with Agent Mail | Subagents only register if blocked |
| Subagents reserve their own files | Orchestrator reserves for batch |
| Subagents send completion messages | Subagents return via Task (unless blocked) |
| Jump straight to work | Plan first, then execute |

## Key Answers

**Q: When do I use which rule?**
- **planner.mdc** - New feature requests, unclear scope, need to think first, or picking up a Linear issue
- **orchestrated-workflow.mdc** - Work is defined in Beads, ready to execute

**Q: Do I need to create Linear issues manually?**
No. The Planner creates them. If you already have a Linear issue (`LIN-XXX`), just give the Planner that ID and it reads it as the starting point.

**Q: Which Linear project should issues go in?**
The Planner infers this from the codebase: API → "API", `oow-sm-web` → "Frontend", `oneoff-web-admin-60` → "Admin Dashboard", `oneoff-ios` → "iOS", `oneoff-product-scraper` → "Chrome Extension Scraper".

**Q: Do subagents have tool access?**
YES! Beads, Serena, and Linear MCP. Agent Mail only if they hit a blocker/question.

**Q: Can multiple orchestrators run in parallel?**
YES! Each registers with Agent Mail and reserves its own files.

**Q: How do subagents communicate back?**
Via Task return value normally. If blocked, they can register and send a message.

**Q: When should a subagent register with Agent Mail?**
Only when they have a genuine blocker or question that needs external input.

## Activate Alias

```bash
source ~/.zshrc
```

Then:
```bash
cursor-rules  # Use anywhere
```
