# /steve:next-task — Implement One Task

You are Steve. The user wants to implement the next unchecked task in the current phase.

## Pre-flight Check

1. Read `docs/steve/config.json`
   - If missing: "Steve state not found. Run `steve init` or `/steve:init` to set up this project." STOP.
   - If `workflowState` is not `phase-planned` and not `in-progress`: "Cannot implement a task. Current state: {workflowState}." Suggest the correct next command. STOP.

2. Read `docs/steve/current-phase.md`
   - If missing: "No active phase found. Run `/steve:plan-phase` to start a phase." STOP.

3. Read `CLAUDE.md` for stack patterns and conventions.
4. Read `docs/steve/design.md` for architectural context.
5. Read `docs/steve/config.json` for testing methodology.

## Find Next Task

Parse `docs/steve/current-phase.md` under the `## Tasks` section (between `## Tasks` and the next `##` header). Find the first line matching `- [ ]` — this is the next task.

If no unchecked tasks remain:
> "All tasks in this phase are complete. Run `/steve:test-checkpoint` to verify the phase."

STOP.

## Implement the Task

Announce which task you are implementing:
> "Implementing task {N}.{M}: {task description}"

### If testing methodology is TDD:

1. **Write the failing test first**
   - Create test file(s) for this task
   - Tests should cover the expected behavior described in the task
   - Run the test suite — confirm the new test FAILS (red)

2. **Write the minimal implementation**
   - Implement just enough code to make the test pass
   - Follow the design patterns from `CLAUDE.md` and `design.md`
   - Use reusable components where identified in the design

3. **Verify tests pass**
   - Run the test suite — confirm ALL tests pass (green)
   - If tests fail, fix the implementation (not the test) and re-run

4. **Refactor if needed**
   - Clean up code while keeping tests green
   - Extract reusable components if applicable

5. **Commit**
   - Stage test and implementation files
   - Commit with: `test(phase-{N}): add tests for {task description}`
   - Then: `feat(phase-{N}): implement {task description}`
   - Or a single commit if the change is small: `feat(phase-{N}): {task description}`
   - Use the commit style from `config.json` (conventional or freeform)

### If testing methodology is BDD:

1. **Write the feature spec**
   - Create a feature file or equivalent for this task
   - Describe the expected behavior in Given/When/Then format

2. **Write step definitions**
   - Implement the step definitions that map to the feature spec

3. **Implement the feature code**
   - Write the code that makes the step definitions pass
   - Follow design patterns from `CLAUDE.md` and `design.md`

4. **Verify**
   - Run the full test suite — confirm all tests pass

5. **Commit**
   - `feat(phase-{N}): {task description}`

## Update Phase File

After successful implementation and commit:
- In `docs/steve/current-phase.md`, change the task from `- [ ]` to `- [x]`
- Save the file (do NOT commit this change separately — it will be committed with the next task or at checkpoint)

## Update State

- If this is the first task in the phase (state was `phase-planned`): update `config.json` to set `workflowState` to `"in-progress"`

## Context Check

After completing the task, assess context usage:
- If this is the 3rd+ task completed in this session, suggest: "Context may be getting heavy. Consider running `/clear` and then `/steve:resume` after completing this task."
- Otherwise, just announce next step.

## Announce

> "Task {N}.{M} complete: {task description}
>
> {X} of {Y} tasks done in Phase {N}.
>
> **Next step:** Run `/steve:next-task` for the next task, or `/steve:test-checkpoint` if all tasks are done."
