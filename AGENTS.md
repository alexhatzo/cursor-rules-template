# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Two-Phase Workflow

This project uses a **planner → orchestrator** workflow:

1. **Planner** - Fleshes out specs, creates Beads epics with dependencies
2. **Orchestrator(s)** - Pick up ready work, delegate to subagents, coordinate

```
User Request
    ↓
Planner (flesh out spec with user)
    ↓
Create Beads Epics (issues + dependencies)
    ↓
Orchestrator(s) pick up ready work
    ↓
Reserve files for batch → Spawn subagents in parallel
    ↓
Subagents complete work → Return results
    ↓
Release reservations → Push → Next batch
```

## Available Custom Subagents

This project includes 14 specialized subagents in `.cursor/agents/`. Invoke explicitly with `/name` syntax or let the orchestrator delegate automatically based on the description.

| Subagent | Purpose |
|----------|---------|
| `/ai-engineer` | LLM integrations, RAG systems, prompt pipelines, vector search |
| `/backend-architect` | RESTful APIs, microservices, database schemas, scalability |
| `/cloud-architect` | AWS/Azure/GCP infrastructure, Terraform, cost optimization |
| `/code-reviewer` | Code quality, security review, maintainability analysis |
| `/composer` | Integration validation, API contract alignment, cross-component compatibility |
| `/data-engineer` | ETL/ELT pipelines, data warehouses, Spark, streaming |
| `/debugger` | Root cause analysis, error investigation, stack trace analysis |
| `/deployment-engineer` | CI/CD pipelines, Docker, Kubernetes, GitHub Actions |
| `/frontend-developer` | React components, state management, accessibility, responsive design |
| `/prompt-engineer` | LLM prompt optimization, prompt patterns, system prompts |
| `/python-pro` | Advanced Python, decorators, async/await, testing, optimization |
| `/api-security-audit` | API security audits, auth vulnerabilities, injection attacks |
| `/splitter-agent` | Task decomposition, multi-agent workflow planning |
| `/ui-ux-designer` | User research, wireframes, design systems, accessibility |

**Note:** Subagents inherit the parent model by default. They have full tool access and can be run in parallel for independent tasks.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:

   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```

5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**

- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

<!-- bv-agent-instructions-v1 -->

---

## Beads Workflow Integration

This project uses [beads_viewer](https://github.com/Dicklesworthstone/beads_viewer) for issue tracking. Issues are stored in `.beads/` and tracked in git.

### Essential Commands

```bash
# View issues (launches TUI - avoid in automated sessions)
bv

# CLI commands for agents (use these instead)
bd ready              # Show issues ready to work (no blockers)
bd list --status=open # All open issues
bd show <id>          # Full issue details with dependencies
bd create --title="..." --type=task --priority=2
bd update <id> --status=in_progress
bd close <id> --reason="Completed"
bd close <id1> <id2>  # Close multiple issues at once
bd sync               # Commit and push changes
```

### Workflow Pattern

1. **Start**: Run `bd ready` to find actionable work
2. **Claim**: Use `bd update <id> --status=in_progress`
3. **Work**: Implement the task
4. **Complete**: Use `bd close <id>`
5. **Sync**: Always run `bd sync` at session end

### Key Concepts

- **Dependencies**: Issues can block other issues. `bd ready` shows only unblocked work.
- **Priority**: P0=critical, P1=high, P2=medium, P3=low, P4=backlog (use numbers, not words)
- **Types**: task, bug, feature, epic, question, docs
- **Blocking**: `bd dep add <issue> <depends-on>` to add dependencies

### Session Protocol

**Before ending any session, run this checklist:**

```bash
git status              # Check what changed
git add <files>         # Stage code changes
bd sync                 # Commit beads changes
git commit -m "..."     # Commit code
bd sync                 # Commit any new beads changes
git push                # Push to remote
```

### Best Practices

- Check `bd ready` at session start to find available work
- Update status as you work (in_progress → closed)
- Create new issues with `bd create` when you discover tasks
- Use descriptive titles and set appropriate priority/type
- Always `bd sync` before ending session

<!-- end-bv-agent-instructions -->

## MCP Agent Mail: Orchestrator Coordination

**Important:** Orchestrators always register with Agent Mail. Subagents only register if they have blockers/questions.

What it is

- A mail-like layer that lets orchestrators coordinate asynchronously via MCP tools and resources.
- Provides identities, inbox/outbox, searchable threads, and advisory file reservations, with human-auditable artifacts in Git.

Why it's useful

- Prevents orchestrators from stepping on each other with explicit file reservations (leases) for files/globs.
- Keeps communication out of your token budget by storing messages in a per-project archive.
- Enables coordination between multiple parallel orchestrators working on different epics.

How orchestrators use it

1. **Register identity**: call `ensure_project`, then `register_agent` using this repo's absolute path as `project_key`.
2. **Reserve files for subagents**: Before spawning a batch, call `file_reservation_paths(project_key, orchestrator_name, [all_paths...], ttl_seconds=3600, exclusive=true)` to claim all files your subagents will touch.
3. **Communicate with other orchestrators**: use `send_message(..., thread_id="bd-123")` when you need info from another orchestrator's domain.
4. **Release after batch**: `release_file_reservations(project_key, orchestrator_name)` when subagents complete.

Cross-repo coordination

- **Single project bus**: Register orchestrators under the same `project_key`. Keep reservation patterns specific (e.g., `frontend/**` vs `backend/**`).
- **Separate projects**: Use `macro_contact_handshake` or `request_contact`/`respond_contact` to link orchestrators, then message directly.

Common pitfalls

- "from_agent not registered": always `register_agent` in the correct `project_key` first.
- "FILE_RESERVATION_CONFLICT": another orchestrator has those files. Coordinate via Agent Mail or wait for expiry.

## OpenSpec Integration

This project uses [OpenSpec](https://github.com/...) for spec documentation during the planning phase.

```bash
openspec init --tools cursor    # Initialize (done by setup script)
openspec add requirement "..."  # Capture requirements
openspec add constraint "..."   # Document constraints
openspec add decision "..."     # Record decisions
```

The Planner uses OpenSpec to document what needs to be built before creating Beads issues.

## Integrating with Beads (dependency-aware task planning)

Beads provides a lightweight, dependency-aware issue database and a CLI (`bd`) for selecting "ready work," setting priorities, and tracking status.

Recommended conventions

- **Single source of truth**: Use **Beads** for task status/priority/dependencies; use **Agent Mail** for orchestrator coordination.
- **Shared identifiers**: Use the Beads issue id (e.g., `bd-123`) as the Mail `thread_id` and prefix message subjects with `[bd-123]`.
- **Reservations**: Orchestrators reserve files for ALL subagents in a batch; include issue ids in the `reason`.

Typical flow (orchestrators)

1) **Pick ready work** (Beads)
   - `bd ready --json` → identify batch of issues (highest priority, no blockers)
2) **Reserve edit surface** (Mail)
   - `file_reservation_paths(project_key, orchestrator_name, ["src/**", "tests/**"], ttl_seconds=3600, exclusive=true, reason="bd-101, bd-102, bd-103")`
3) **Spawn subagents in parallel**
   - `Task(prompt="Work on bd-101...")` for each issue
4) **Collect results**
   - Subagents return summaries via Task return value
5) **Release and push**
   - `release_file_reservations(project_key, orchestrator_name)`
   - `git push` and `bd sync`

Mapping cheat-sheet

- **Mail `thread_id`** ↔ `bd-###`
- **Mail subject**: `[bd-###] …`
- **File reservation `reason`**: `bd-101, bd-102, ...` (all issues in batch)
- **Commit messages**: include `bd-###` for traceability

---

## Planner → Orchestrator → Subagent Pattern

### Architecture

```
User Request
    ↓
Planner (flesh out spec, create epics)
    ↓
Beads Epics (issues with dependencies)
    ↓
Orchestrator(s) (pick up ready work, coordinate)
    ↓
Subagents (stateless workers, complete issues)
    ↓
Results integrated, pushed
```

### Planner Responsibilities

1. **Clarify** user request until scope is clear
2. **Document** spec in OpenSpec
3. **Create** Beads issues with proper dependencies
4. **Hand off** - `bd sync` and inform user what's ready

### Orchestrator Responsibilities

**Before Spawning:**

1. `register_agent(...)` with Agent Mail
2. `bd ready` to find work
3. `file_reservation_paths(...)` for ALL files in batch

**During Work:**

- Monitor inbox for other orchestrators
- Spawn subagents in parallel
- Collect return values

**After Batch:**

1. `release_file_reservations(...)`
2. `git push`
3. `bd sync`
4. Plan next batch

### Subagent Responsibilities

Subagents are **stateless workers by default**. They only register with Agent Mail if blocked.

**Normal flow:**
1. Use Serena for code search (not grep)
2. Complete assigned work
3. Create Beads issues for discovered work
4. Git commit with `[bd-###]` prefix
5. Close issue: `bd close bd-###`
6. Return summary to orchestrator (via Task return value)

**If blocked/questions:**
1. Register with Agent Mail: `register_agent(..., task="bd-###: blocked on X")`
2. Send message to orchestrator explaining the blocker
3. Wait for response
4. Continue normal flow after resolved

### Example Multi-Orchestrator Workflow

```
User: "Add authentication and logging"

Planner:
  - Creates auth epic: bd-101, bd-102, bd-103 (with deps)
  - Creates logging epic: bd-201, bd-202 (no deps on auth)
  - bd sync

Orchestrator A (auth):
  1. register_agent(..., task="Auth epic")
  2. file_reservation_paths(..., ["app/auth/**", "db/migrations/**"])
  3. Spawns subagents for bd-101, bd-102
  4. Waits, collects results
  5. Releases, pushes

Orchestrator B (logging) [runs in parallel]:
  1. register_agent(..., task="Logging epic")
  2. file_reservation_paths(..., ["app/logging/**", "config/**"])
  3. Spawns subagents for bd-201, bd-202
  4. Waits, collects results
  5. Releases, pushes

Both complete → User gets auth + logging
```

### Key Takeaways

- **Planner plans** - specs and creates structured work
- **Orchestrators coordinate** - register, reserve, spawn, release
- **Subagents execute** - stateless workers that return results
- **Agent Mail for coordination** - Orchestrators always registered; subagents only if blocked
- **Beads is truth** - single source for issue status and dependencies
