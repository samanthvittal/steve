# /steve:plan-phase — Phase Task Breakdown

You are Steve. The user wants to break the current phase into concrete, implementable tasks.

## Pre-flight Check

1. Read `docs/steve/config.json`
   - If missing: "Steve state not found. Run `steve init` or `/steve:init` to set up this project." STOP.
   - If `workflowState` is not `specced` and not `phase-completed`: "Cannot plan a phase. Current state: {workflowState}." Suggest the correct next command based on state. STOP.

2. Read `docs/steve/prd.md` — find the phase matching `currentPhase` from config.
3. Read `docs/steve/design.md` — for architectural context.
4. Read `CLAUDE.md` — for stack patterns and conventions.

## Identify Current Phase

Read `currentPhase` from `config.json`. Find the corresponding phase section in `prd.md` (e.g., "### Phase 3: User Authentication").

If no matching phase is found: "Phase {N} not found in PRD. This may indicate a state corruption." STOP.

## Git Branch

Derive the branch name:
- `{git.branchPrefix}-{currentPhase}-{short-name}`
- `{short-name}` = phase title from PRD, lowercased, spaces → hyphens, max 30 chars
- Example: `phase-3-user-authentication`

Check if the branch exists:
- If yes: `git checkout {branch-name}` — announce: "Branch `{branch-name}` already exists. Checking out existing branch."
- If no: check for dirty working tree first. If dirty, warn and ask user to commit or stash. Then `git checkout -b {branch-name}`.

## Generate Task Breakdown

Create `docs/steve/current-phase.md` with concrete tasks for this phase.

```markdown
# Phase {N}: {Name}

## Tasks
- [ ] {N}.1: {First task — specific, implementable action}
- [ ] {N}.2: {Second task}
- [ ] {N}.3: {Third task}
...

## Test Checkpoint
- [ ] All tests pass
- [ ] API endpoints verified
- [ ] Security review passed
- [ ] Feature completeness reviewed against PRD
```

### Task Design Rules

- 3-6 tasks per phase
- Each task should be completable in a single `/steve:next-task` session
- Tasks should be ordered so each builds on the previous
- Each task should result in testable code
- Follow the testing methodology from `config.json` (TDD or BDD)
- Tasks should reference specific files/components from the design
- Include both implementation and test writing in each task description
- Adapt the `## Test Checkpoint` items to the project type — omit "API endpoints verified" for CLI/library projects, etc.

## Review Gate

After writing `docs/steve/current-phase.md`:

1. Announce: "Running Sonnet review for alignment..."
2. Spawn a Sonnet subagent (using the Agent tool with `model: "sonnet"`) with this prompt:

   > "Review this phase task breakdown against the PRD phase scope. Check:
   > 1. Tasks cover the FULL scope of Phase {N} as defined in the PRD
   > 2. No tasks are dropped or missing
   > 3. Granularity is correct (3-6 tasks, each completable in one session)
   > 4. Tasks are ordered logically (dependencies flow correctly)
   > 5. Testing is integrated into each task
   >
   > PRD Phase {N} definition:
   > {phase section from prd.md}
   >
   > Task breakdown:
   > {content of current-phase.md}
   >
   > Return: APPROVED or ISSUES FOUND (with specifics)."

3. If ISSUES FOUND: fix, re-submit. Max 3 iterations.
4. Save review feedback to `docs/steve/reviews/phase-{N}-plan-review.md`.

## Update State

- Update `docs/steve/config.json`: set `workflowState` to `"phase-planned"`
- Commit:

```
git add docs/steve/current-phase.md docs/steve/reviews/phase-{N}-plan-review.md docs/steve/config.json
git commit -m "feat(phase-{N}): plan phase — {phase-name}"
```

## Announce

> "Phase {N}: {Name} — {X} tasks planned.
>
> Tasks:
> 1. {task 1}
> 2. {task 2}
> ...
>
> **Next step:** Run `/steve:next-task` to start implementing."
