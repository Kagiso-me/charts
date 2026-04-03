<div align="center">

<img src="https://raw.githubusercontent.com/helm/helm/main/docs/logos/helm.svg" width="120px" alt="Helm" />

# charts

**Production-grade Helm charts. Upstream images. Zero shortcuts.**

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/kagiso-me)](https://artifacthub.io/packages/search?repo=kagiso-me)
![License](https://img.shields.io/github/license/Kagiso-me/charts)
![GitHub last commit](https://img.shields.io/github/last-commit/Kagiso-me/charts)
![CI](https://img.shields.io/github/actions/workflow/status/Kagiso-me/charts/lint-test.yaml?label=CI&logo=github)
![Helm](https://img.shields.io/badge/Helm-3.8%2B-0F1689?logo=helm)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.23%2B-326CE5?logo=kubernetes&logoColor=white)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/Kagiso-me/charts/badge)](https://securityscorecards.dev/viewer/?uri=github.com/Kagiso-me/charts)

</div>

---

## Philosophy

Most charts get you running. These get you running *right*.

Every chart in this repository is built on the official upstream image — no custom builds, no vendored binaries, no surprises. What we do add is everything you need to run that software confidently in production:

- **Secure by default** — non-root containers, dropped capabilities, `automountServiceAccountToken: false`
- **Schema-validated** — every `values.yaml` is backed by a strict JSON Schema; bad values fail at `helm install`, not at 3am
- **Fully documented** — every value has a description; READMEs are generated from the source, never out of date
- **Honest defaults** — resource requests and limits set to real numbers, not zeros
- **Opt-in complexity** — NetworkPolicy, PodDisruptionBudget, custom config files — all there when you need them, out of the way when you don't

---

## Using this repo

```bash
helm repo add kagiso-me https://kagiso-me.github.io/charts
helm repo update
```

```bash
helm search repo kagiso-me
```

---

## Charts

| Chart | App Version | Description |
|-------|-------------|-------------|
| [postgresql](charts/postgresql) | 17.4.0 | Open source relational database. ACID-compliant, battle-tested, boring in the best possible way. |
| [redis](charts/redis) | 7.4.2 | In-memory data structure store. Cache, message broker, and streaming engine in one. |

More charts are being added. Next up: `nextcloud`, `authentik`, `immich`, `vaultwarden`, `n8n`, `wordpress`.

---

## Chart quality standard

Before a chart is published it meets every item on this list:

- [ ] Deploys cleanly with `ct install` against a live kind cluster
- [ ] Passes `helm lint` with no warnings
- [ ] `values.schema.json` rejects invalid input
- [ ] All values documented with helm-docs `## @param` comments
- [ ] Liveness, readiness, and startup probes configured
- [ ] Pod and container security contexts set
- [ ] Supports `existingSecret` for all credentials
- [ ] `nameOverride`, `fullnameOverride`, `commonLabels`, `commonAnnotations` work
- [ ] Global image registry and pull secret overrides work
- [ ] Persistence can be disabled for test environments

---

## Contributing

1. Fork, branch off `main`
2. Make your changes — bump the chart `version` in `Chart.yaml` (SemVer)
3. Open a PR — CI lints and installs the changed chart against kind automatically

Charts are released automatically when a PR merges to `main`. No manual steps.

---

## License

Chart code is [Apache-2.0](LICENSE). Each application is subject to its own respective upstream license.
