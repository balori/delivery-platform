# 2. One reusable release workflow, called by each app repo

- Status: accepted
- Date: 2025

## Context

Every service needs the same release path: build image → push to GHCR with
semver+sha tags → gated deploy → wait for rollout. Copying that YAML into each
app repo guarantees drift and inconsistent gates.

## Decision

Put the pipeline in **one reusable (`workflow_call`) workflow** here in
`delivery-platform`. App repos call it with a few inputs (`image_name`,
`build_context`, `overlay`, `namespace`) — see `examples/app-caller.yml`. The
production deploy is gated by a GitHub **Environment** approval.

## Alternatives considered

| Option | Why not |
|--------|---------|
| **Copy the workflow into each repo** | Fastest to start, but N copies drift; a security fix to the deploy step has to be made N times. |
| **A published composite action** | Good for a step, but the release is a multi-job graph (build → gated deploy) that `workflow_call` models better than a single action. |
| **An external CD tool (Argo/Flux)** | The right answer for GitOps at scale, but adds a controller to run and learn; `workflow_call` reuses the CI we already have. |

## Consequences

- **Good:** one place owns build/push/deploy; app repos stay a thin caller;
  the approval gate is enforced centrally.
- **Trade-off:** callers are **coupled to this repo's contract** (input names,
  the overlay path convention). Changing an input is a breaking change for every
  caller — so the interface has to be versioned carefully (pin `@main` vs a tag).
- **Trade-off:** it's pull-request/tag-driven CD, not reconciliation-based
  GitOps — no automatic drift correction if someone `kubectl edit`s in prod.

## Revisit if

The fleet grows enough to want continuous reconciliation and drift detection —
adopt Argo CD / Flux and let this workflow only build+push.
