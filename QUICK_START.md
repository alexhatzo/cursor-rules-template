# Quick Start

## Setup New Project

```bash
cd /path/to/your-project
cursor-rules
```

Done! Orchestrated workflow enabled.

## What This Means

The agent you speak to will:
1. Break your request into Beads issues
2. Spawn subagents (one per issue)
3. Monitor Agent Mail for coordination
4. Integrate results

## Architecture

```
You → Orchestrator
       ↓
    Beads Issues
       ↓
    Subagents (have full tool access)
       ↓
    Complete Work
```

## What Gets Installed

```
your-project/
├── .cursor/rules/orchestrated-workflow.mdc  (1 rule, 65 lines)
└── AGENTS.md
```

## Example

**You:** "Add authentication"

**Orchestrator:**
```bash
bd create "Auth schema" --priority=1
bd create "Auth API" --priority=2
bd create "Login UI" --priority=2

Task(prompt="Work on bd-101...")
Task(prompt="Work on bd-102...")
```

**Each subagent:**
- Registers with Agent Mail
- Reserves files
- Uses Serena for code search
- Completes work
- Closes issue & reports

## Key Answers

**Q: Too many rules?**
No! Just ONE rule (65 lines).

**Q: Do subagents have tool access?**
YES! Full access to Beads, Agent Mail, Serena.

**Q: How do subagents know what to do?**
The orchestrated-workflow.mdc rule applies to them too (alwaysApply: true).

## Activate Alias

```bash
source ~/.zshrc
```

Then:
```bash
cursor-rules  # Use anywhere
```
