# /steve:complete-phase — Merge, Archive, Advance

You are Steve. The user wants to complete the current phase, merge it, and advance to the next.

## Pre-flight Check

1. Read `docs/steve/config.json`
   - If missing: "Steve state not found. Run `steve init` or `/steve:init` to set up this project." STOP.
   - If `workflowState` is not `checkpoint-passed`: "Cannot complete phase. Current state: {workflowState}. Run `/steve:test-checkpoint` first." STOP.

2. Read `docs/steve/current-phase.md` for the phase summary.
3. Read `docs/steve/config.json` for `currentPhase`, `totalPhases`, `completedPhases`, and `git` settings.

## Idempotency Check

Check if `currentPhase` is already in the `completedPhases` array:
- If yes: this is a re-run (e.g., after a merge conflict). Skip the archive step. Jump directly to the merge step.
- If no: proceed normally.

## Step 1: Archive the Phase

Append to `docs/steve/completed-phases.md`:

```markdown
## Phase {N}: {Name} — Completed {YYYY-MM-DD}

### Summary
{Brief description of what was delivered — derived from the tasks}

### Tasks Completed
- {task 1 description}
- {task 2 description}
- ...
```

## Step 2: Merge the Branch

Determine the branch name: `{git.branchPrefix}-{currentPhase}-{short-name}`

### Already-Merged Detection

Check if the branch is already merged: `git branch --merged main | grep {branch-name}`
- If already merged: announce "Branch already merged into main. Advancing state." Skip to Step 3.

### Merge Confirmation

Ask the user: "Merge `{branch-name}` to main? (yes/no)"

- If **yes**:
  1. Run `git checkout main && git merge {branch-name}`
  2. If merge conflict:
     a. Announce: "Merge conflict detected. Resolving automatically..."
     b. Read the conflicting files, understand intent from both sides
     c. Resolve conflicts and stage the resolved files
     d. Run the test suite
     e. If tests fail: fix the tests/code (max 3 attempts), re-run until green
     f. If still failing after 3 attempts: "Could not auto-resolve after 3 attempts. Please review the conflicts manually." State remains `checkpoint-passed`. STOP.
     g. If tests pass: complete the merge commit
  3. After successful merge: continue to Step 3

- If **no**: leave the branch as-is, still advance state. Continue to Step 3.

## Step 3: Update State

If `currentPhase` is already in the `completedPhases` array (idempotent re-run from the check in "Idempotency Check" above): do NOT add it again and do NOT increment `currentPhase`. Skip directly to the commit and announce for the appropriate branch (final or not final) below.

If `currentPhase` is NOT in `completedPhases`: add it to the array, then continue.

Check if this is the **final phase**: `currentPhase == totalPhases`

### If final phase:
- Set `workflowState` to `"completed"`
- `currentPhase` stays at `totalPhases` (do not increment)
- Clear `docs/steve/current-phase.md` (replace with empty placeholder or delete)
- Commit:

```
git add docs/steve/completed-phases.md docs/steve/current-phase.md docs/steve/config.json
git commit -m "feat: complete final phase — project done"
```

> "All {totalPhases} phases complete. Project is done!
>
> Completed phases:
> {list of all completed phases from completed-phases.md}"

### If not final phase:
- Set `currentPhase` to `currentPhase + 1`
- Set `workflowState` to `"phase-completed"`
- Clear `docs/steve/current-phase.md` (replace with empty placeholder or delete)
- Commit:

```
git add docs/steve/completed-phases.md docs/steve/current-phase.md docs/steve/config.json
git commit -m "feat(phase-{N}): complete phase — {phase-name}"
```

> "Phase {N} complete!
>
> **Next step:** Run `/steve:plan-phase` to start Phase {N+1}.
>
> Consider running `/clear` first if you've been working for a while."
