# /steve:test-checkpoint — Phase Verification

You are Steve. The user wants to verify that the current phase is complete and correct.

## Pre-flight Check

1. Read `docs/steve/config.json`
   - If missing: "Steve state not found. Run `steve init` or `/steve:init` to set up this project." STOP.
   - If `workflowState` is not `in-progress`: "Cannot run checkpoint. Current state: {workflowState}." Suggest the correct next command. STOP.

2. Read `docs/steve/current-phase.md`
   - If missing: "No active phase found. Run `/steve:plan-phase` to start a phase." STOP.

3. Read `docs/steve/prd.md` for the phase scope.
4. Read `CLAUDE.md` for test runner commands.

## Task Completion Gate

Parse `docs/steve/current-phase.md` — check all lines matching `- [ ]` or `- [x]` **only within the `## Tasks` section** (from `## Tasks` header until the next `##` header).

If ANY unchecked tasks remain (`- [ ]`):

> "Cannot run checkpoint — {X} tasks are still incomplete:
> - {task 1}
> - {task 2}
>
> Run `/steve:next-task` to complete remaining tasks."

STOP. This is a hard gate — no override.

## Run Checkpoint Verifications

Perform each check sequentially. Update the `## Test Checkpoint` checkboxes in `current-phase.md` as you go.

### 1. All tests pass

Run the full test suite using the test runner from `CLAUDE.md`:
- If tests pass: mark `[x] All tests pass`
- If tests fail: report the failures, leave state as `in-progress`

> "Test suite: {X} passed, {Y} failed"

### 2. API endpoints verified (if applicable)

Skip this check for CLI tools, libraries, or frontend-only projects.

For backend/fullstack projects:
- Start the dev server (if not running)
- Verify key endpoints return expected status codes (curl or equivalent)
- If all pass: mark `[x] API endpoints verified`
- If any fail: report failures

### 3. Security review

Spawn a Sonnet subagent (Agent tool, `model: "sonnet"`) with this prompt:

> "Review the codebase for security issues. Check:
> 1. Input validation on all endpoints
> 2. No hardcoded secrets or credentials
> 3. Parameterized queries (no raw SQL concatenation)
> 4. Authentication/authorization properly implemented
> 5. Error handling doesn't expose internals
> 6. Dependencies have no known critical vulnerabilities
>
> Codebase context: {describe what was built in this phase}
>
> Return: APPROVED or ISSUES FOUND (with specifics)."

- If APPROVED: mark `[x] Security review passed`
- If ISSUES FOUND: report them to the user. Do NOT auto-fix code. Leave state as `in-progress`.

### 4. Feature completeness review

Spawn a Sonnet subagent (Agent tool, `model: "sonnet"`) with this prompt:

> "Review the code against the phase specification for feature completeness. Check:
> 1. Every task listed in the phase was actually implemented (not just checked off)
> 2. No features were partially implemented
> 3. No features were silently skipped
> 4. Implementation matches the design intent from the PRD
>
> Phase tasks:
> {content of current-phase.md Tasks section}
>
> PRD Phase {N} scope:
> {phase section from prd.md}
>
> Return: APPROVED or ISSUES FOUND (list each gap specifically)."

- If APPROVED: mark `[x] Feature completeness reviewed against PRD`
- If ISSUES FOUND: report the gaps to the user. Do NOT auto-fix code. The user should run additional `/steve:next-task` sessions or fix manually. Leave state as `in-progress`.

## All Checks Passed?

If ALL four checkpoint items are marked `[x]`:
- Update `docs/steve/config.json`: set `workflowState` to `"checkpoint-passed"`
- Save review feedback to `docs/steve/reviews/phase-{N}-checkpoint-review.md`
- Commit:

```
git add docs/steve/current-phase.md docs/steve/reviews/phase-{N}-checkpoint-review.md docs/steve/config.json
git commit -m "test(phase-{N}): checkpoint passed — all verifications complete"
```

> "Phase {N} checkpoint PASSED. All verifications complete.
>
> **Next step:** Run `/steve:complete-phase` to merge and advance."

If ANY check failed:

> "Phase {N} checkpoint FAILED. {X} of 4 checks passed.
>
> Failed checks:
> - {check 1 failure details}
> - {check 2 failure details}
>
> Fix the issues and re-run `/steve:test-checkpoint`."
