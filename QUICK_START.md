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
You → Planner (spec & epics)
       ↓
    Beads Issues (with dependencies)
       ↓
    Orchestrator(s) (register, reserve files)
       ↓
    Subagents (stateless workers)
       ↓
    Results returned → Push
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

**You:** "Add authentication"

**With planner.mdc active:**
```bash
# Planner clarifies requirements, then:
bd create "Auth schema" --priority=1
bd create "Auth API" --priority=2
bd create "Login UI" --priority=2
bd dep add bd-103 bd-102  # UI depends on API
bd sync
# "Ready for orchestrators: bd-101, bd-102"
```

**With orchestrated-workflow.mdc active:**
```bash
# Orchestrator picks up work
register_agent(...)
file_reservation_paths(..., ["db/**", "api/**"])  # Reserve for batch
Task(prompt="Work on bd-101...")
Task(prompt="Work on bd-102...")
# Subagents complete, return results
release_file_reservations(...)
git push
```

## Key Differences from Before

| Before | Now |
|--------|-----|
| One rule, `alwaysApply: true` | Two rules, both `alwaysApply: false` |
| Subagents always register with Agent Mail | Subagents only register if blocked |
| Subagents reserve their own files | Orchestrator reserves for batch |
| Subagents send completion messages | Subagents return via Task (unless blocked) |
| Jump straight to work | Plan first, then execute |

## Key Answers

**Q: When do I use which rule?**
- **planner.mdc** - New feature requests, unclear scope, need to think first
- **orchestrated-workflow.mdc** - Work is defined, ready to execute

**Q: Do subagents have tool access?**
YES! Beads and Serena. Agent Mail only if they hit a blocker/question.

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
