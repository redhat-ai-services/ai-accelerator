# AGENTS

## What this repo is

- Pure GitOps/Kustomize YAML repo — no application code, no unit tests. It bootstraps OpenShift clusters with Red Hat OpenShift AI (RHOAI) operators/components via ArgoCD.
- Verification = `kustomize build` of every `kustomization.yaml` plus lint checks. `documentation/overview.md` explains the folder structure.

## Repo layout (GitOps aggregation)

- `bootstrap/` — initial provisioning overlays, applied once by `./bootstrap.sh`.
- `clusters/overlays/<name>/` — main aggregation layer; each overlay (e.g. `rhoai-eus-2.25`, `rhoai-stable-3.x`, with optional `-aws-gpu` suffix) is one cluster/environment config.
- `components/` — Kustomize components: `argocd/` (Applications/ApplicationSets/Projects), `cluster-configs/`, `operators/`. Each `operators/<name>/` subfolder maps to one ArgoCD application; typical layout is `operator/` (Subscription) and `instance/` (the CR).
- `documentation/overview.md` references a `patch-application-repo-revision` folder that no longer exists — the current mechanism is the `gitops-repo-config` ConfigMap (below). Trust the code over that doc.

## Validation (CI runs all of these on every PR — run them locally first)

Mirrors `.github/workflows/validate-manifests.yaml`:

- `touch bootstrap/base/sealed-secrets-secret.yaml` then `./scripts/validate_manifests.sh` — builds every `kustomization.yaml` with `kustomize build --enable-helm`. Requires the `kustomize` binary.
- `yamllint . -f github` (dependencies in `requirements.txt`).
- `./scripts/check-kustomization-format.sh` — requires Go `yq` (`mikefarah` v4; the Python `yq` does NOT work) and `jq`.
- `./scripts/validate_git_config.sh --expected-repo=<url> --github`
- Spellcheck: `pyspelling` with `.spellcheck.yaml`; allowed words live in `.wordlist-txt` (add new product/brand terms there, then `./scripts/sort-wordlist.sh`).

## kustomization.yaml formatting is enforced (CI fails otherwise)

- `resources:`, `components:`, `bases:` lists must be alphabetically sorted; a blank line is required before major sections (`resources:`, `patches:`, `configMapGenerator:`, …).
- Fix with `./scripts/sort-kustomization-resources.sh`.

## GitOps repo/branch config — single source of truth

- Each `clusters/overlays/<name>/kustomization.yaml` sets `repoURL` + `targetRevision` in a `gitops-repo-config` `configMapGenerator`; `replacements:` propagate them into every ArgoCD Application/ApplicationSet `spec.source.*`.
- `components/argocd/apps/base/cluster-config-app-of-apps.yaml` carries the base defaults.
- `validate_git_config.sh` fails if these disagree with the expected repo. CI expects `github.repositoryUrl` — the base repo of the PR (upstream `redhat-ai-services/ai-accelerator`, branch `main`) — so don't point overlays at a fork in a PR.

## Adding/removing a RHOAI cluster version

- Requires parallel directories in `bootstrap/overlays/`, `clusters/overlays/`, `components/argocd/apps/overlays/`, and `components/operators/openshift-ai/aggregate/overlays/` (plus related instance overlays).
- Scaffold with `scripts/maintence_add_new_cluster.sh` (name is misspelled on purpose — it's the real filename): it copies an existing cluster's directories and replaces the name using `sed`. Remove with `scripts/maintence_delete_cluster.sh`.

## Bootstrap flow (needs a live, logged-in cluster)

- `./bootstrap.sh` installs the GitOps operator, applies the selected `bootstrap/overlays/<dir>`, waits, then deletes the application-controller pods (workaround for a known bug where apps don't start syncing) and prints the ArgoCD route.
- DANGER: with `-f` the script rewrites the selected overlay's `targetRevision`/`repoURL` to your current branch/remote, then COMMITS AND PUSHES. Don't pass `-f` unless that is intended. `--reset-git` reverts those local changes.
- Missing client tools are auto-downloaded into `tmp/` (excluded via `.gitignore`). Downloading `oc` requires `--ocp_version=`.

## Ignored files that look like source

- `bootstrap/base/sealed-secrets-secret.yaml` — sealed-secrets master key; must never be committed.
- `manifest*.yaml` at repo root (e.g. `manifest.yaml`) — scratch/rendered output excluded via `.gitignore`, not repo source of truth.
- `tmp/` (downloaded CLI tools) and `**/charts/` are also excluded via `.gitignore`.
