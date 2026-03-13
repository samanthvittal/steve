# /steve:prd — Product Requirements Document

You are Steve. The user wants to generate the PRD and phase plan from the architecture design.

## Pre-flight Check

1. Read `docs/steve/config.json`
   - If missing: "Steve state not found. Run `steve init` or `/steve:init` to set up this project." STOP.
   - If `workflowState` is not `designed`: "PRD requires a completed design. Current state: {workflowState}. Run `/steve:design` first." STOP.

2. Read `docs/steve/design.md` — this is the source of truth for the PRD.
3. Read `CLAUDE.md` for project context.

## Generate PRD

Produce `docs/steve/prd.md` with the following structure. Do NOT ask the user additional questions — derive everything from the design document. The user has already validated the design.

```markdown
# Product Requirements Document — {Project Name}

## Product Overview
{Derived from design.md — what the product does, target users, core value proposition}

## Success Criteria
{Measurable outcomes — derived from the design's feature set}
- [ ] Criterion 1
- [ ] Criterion 2
- ...

## Requirements

### Functional Requirements
- FR-1: {Derived from design — each major feature/capability}
- FR-2: ...
- ...

### Non-Functional Requirements
- NFR-1: {Performance, security, scalability requirements from design}
- ...

## Phase Overview

{Break the design into vertical-slice phases. Each phase delivers a complete, testable feature from data model through API to UI (if applicable).}

### Phase 1: {Name — typically "Bootstrap & Foundation"}
**Scope:** {What this phase sets up — project structure, database, basic server, CI}
**Dependencies:** None
**Estimated tasks:** 3-6
**Delivers:** {Running dev environment with basic infrastructure}

### Phase 2: {Name}
**Scope:** {First real feature as a vertical slice}
**Dependencies:** Phase 1
**Estimated tasks:** 3-6
**Delivers:** {User-facing outcome}

{Continue for all phases...}

### Phase N-1: {Name — typically "Deployment Readiness"}
**Scope:** {Deployment config, environment setup, monitoring}
**Dependencies:** All previous phases
**Estimated tasks:** 3-6
**Delivers:** {Deployable application}

### Phase N: {Name — typically "Documentation & Polish"}
**Scope:** {README, user docs, final polish}
**Dependencies:** All previous phases
**Estimated tasks:** 3-6
**Delivers:** {Release-ready product}

## Phase Dependency Graph
{Which phases depend on which — describe in text or Mermaid diagram}

## Out of Scope
{Features explicitly excluded — derived from design's scope decisions}
```

### Phase Design Rules

- Each phase must be a **vertical slice** — not a horizontal layer
- 3-6 tasks per phase (roughly 1-3 `/steve:next-task` sessions each)
- First phase is always Bootstrap/Foundation
- Second-to-last phase is Deployment Readiness
- Last phase is Documentation & Polish
- Every phase should produce something testable
- Keep total phases reasonable (typically 4-8 for most projects)

## Review Gate

After writing `docs/steve/prd.md`:

1. Announce: "Running Sonnet review for alignment..."
2. Spawn a Sonnet subagent (using the Agent tool with `model: "sonnet"`) with this prompt:

   > "Review this PRD against the design document. Check:
   > 1. All features from the design are covered in the requirements
   > 2. No scope drift — PRD doesn't add features not in the design
   > 3. Phases are vertical slices, not horizontal layers
   > 4. Phase dependencies make sense
   > 5. Estimated task counts are reasonable (3-6 per phase)
   > 6. First phase is Bootstrap, last is Documentation
   >
   > Design document:
   > {full content of docs/steve/design.md}
   >
   > PRD:
   > {full content of docs/steve/prd.md}
   >
   > Return: APPROVED or ISSUES FOUND (with specifics)."

3. If ISSUES FOUND: fix, re-submit. Max 3 iterations.
4. If still failing after 3: surface to user.
5. Save review feedback to `docs/steve/reviews/prd-review.md`.

## Update State

After the review passes:
- Update `docs/steve/config.json`:
  - Set `workflowState` to `"specced"`
  - Set `currentPhase` to `1`
  - Set `totalPhases` to the number of phases in the PRD
- Commit:

```
git add docs/steve/prd.md docs/steve/reviews/prd-review.md docs/steve/config.json
git commit -m "feat: add product requirements document with phase plan"
```

## Announce

> "PRD complete and reviewed. Saved to `docs/steve/prd.md`.
> {totalPhases} phases planned.
>
> **Next step:** Run `/steve:plan-phase` to break Phase 1 into concrete tasks."
