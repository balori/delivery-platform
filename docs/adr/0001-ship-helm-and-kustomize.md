# 1. Ship both a Helm chart and Kustomize overlays

- Status: accepted
- Date: 2025

## Context

`delivery-platform` packages the deploy-tracker service for Kubernetes. Teams are
split on packaging: some standardize on Helm, others on Kustomize. This repo is
also a portfolio artifact meant to *demonstrate* both idioms.

## Decision

Provide **both**: a parameterized Helm chart (`charts/deploy-tracker`) and a
Kustomize base + `staging`/`production` overlays (`manifests/`).

## Alternatives considered

| Option | Why not |
|--------|---------|
| **Helm only** | Templating power (HPA toggle, ingress toggle, values per env), but Go-template YAML is famously hard to read/diff, and Kustomize shops reject it. |
| **Kustomize only** | Clean overlays and no templating language, but conditional resources (enable/disable an HPA or ingress) get awkward, and Helm shops want a chart. |
| **Raw manifests per env** | Duplication and drift — the thing both tools exist to prevent. |

## Consequences

- **Good:** a cluster can adopt whichever it standardizes on; the repo shows a
  real, working comparison rather than an opinion. Both are validated in CI
  (`helm lint`/`helm template`; `kubectl kustomize` on both overlays).
- **Trade-off:** **two sources of truth for the same deployment.** They can drift
  (e.g. a resource-limit change made in one and not the other). Mitigation: CI
  renders both, and this repo is small enough to keep them aligned by review.
- **Trade-off:** more surface to maintain than picking one.

## Revisit if

This were a real single-team production repo rather than a reference — then pick
**one** (the team's standard) and delete the other to remove the drift risk.
