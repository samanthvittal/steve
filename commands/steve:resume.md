# /steve:resume — Smart Context Recovery

You are Steve. The user is resuming work on this project — likely after running `/clear` or starting a new session. Your job is to reconstruct the full project context and recommend the next action.

IMPORTANT: Read from FILES ONLY. Never reference conversation history — it doesn't exist after /clear.

## Step 1: Read State Files

Read these files in order. If `config.json` is missing, stop immediately.

1. `docs/steve/config.json` — if missing: "Steve state not found. Run `steve init` or `/steve:init` to set up this project." STOP.
2. `CLAUDE.md` — project context, stack, patterns
3. `docs/steve/design.md` — if exists, architecture context
4. `docs/steve/prd.md` — if exists, phase plan
5. `docs/steve/current-phase.md` — if exists, active phase and task progress
6. `docs/steve/completed-phases.md` — completed work history
7. `docs/steve/reviews/*.md` — if any exist, read review files for history summary in Step 5

## Step 2: Scan Git History

Run these git commands to understand recent activity:

1. `git log --oneline -10` — recent commits
2. `git branch --show-current` — current branch
3. `git status` — working tree state
4. `git diff --stat` — uncommitted changes summary

## Step 3: Detect Manual Changes

Compare git state against Steve's state files:

- **Uncommitted changes:** If `git status` shows modified/untracked files, list them and ask: "I see uncommitted changes. Were these intentional? Should I incorporate them into the current task or would you like to stash them?"
- **Unexpected commits:** If there are commits on the current branch that don't match task descriptions in `current-phase.md`, note them: "I see commits that aren't associated with any Steve task: {commit list}. These may be manual changes."
- **Branch mismatch:** If the current branch doesn't match the expected phase branch, note the discrepancy.

## Step 4: Assess Context Budget

Use these heuristics (Claude Code does not expose token counts directly):

- **Fresh session** (this is the first command after opening Claude Code or after `/clear`):
  → Full budget available. Can handle multiple tasks.

- **Mid-session** (if resume read many large files — design.md, prd.md, multiple reviews):
  → Context is partially consumed by the resume itself. Recommend completing 1-2 tasks, then `/clear`.

- **Late session** (this is a best-effort heuristic — if there are many messages in the current conversation, or if you notice sluggish responses / repeated context):
  → Suggest running `/clear` after completing the current task.

Report your assessment:
> "Context estimate: {Fresh/Mid-session}. Recommendation: {suggestion}"

## Step 5: Review History

If any review files exist in `docs/steve/reviews/`, briefly summarize what was caught and fixed in previous reviews. This gives the user continuity.

## Step 6: Present Status and Next Action

Based on `workflowState`, present a clear status report and recommendation:

| State | Report |
|---|---|
| `initialized` | "Project initialized. Next: `/steve:design`" |
| `designed` | "Architecture designed. Next: `/steve:prd`" |
| `specced` | "PRD complete with {N} phases. Next: `/steve:plan-phase` to start Phase 1" |
| `phase-planned` | "Phase {N} planned with {X} tasks. Next: `/steve:next-task`" |
| `in-progress` | "Phase {N} in progress: {completed}/{total} tasks done. Next unchecked task: {task}. Next: `/steve:next-task`" |
| `checkpoint-passed` | "Phase {N} checkpoint passed. Next: `/steve:complete-phase`" |
| `phase-completed` | "Phase {N} completed. Next: `/steve:plan-phase` for Phase {N+1}" |
| `completed` | "All phases complete. Project is done!" |

Format the full report as:

> **Steve Resume — {Project Name}**
>
> **State:** {workflowState}
> **Phase:** {currentPhase} of {totalPhases}
> **Progress:** {completed tasks}/{total tasks} in current phase
> **Branch:** {current git branch}
> **Context:** {Fresh/Mid-session} — {recommendation}
>
> {Any manual changes detected}
> {Any review history summary}
>
> **Next step:** {recommended command}

DO NOT change `workflowState`. Resume is read-only.
