# Phil's Helm Charts

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/phil-mcgee)](https://artifacthub.io/packages/search?repo=phil-mcgee)

A collection of carefully curated Helm charts. Upstream provider images, tuned for production: secure by default, fully documented, schema-validated.

## Usage

```bash
helm repo add phil-mcgee https://phil-mcgee.github.io/charts
helm repo update
helm search repo phil-mcgee
```

## Charts

| Chart | Description | Version |
|-------|-------------|---------|
| [postgresql](charts/postgresql) | PostgreSQL — reliable, ACID-compliant relational database | ![Version](https://img.shields.io/badge/dynamic/yaml?url=https://phil-mcgee.github.io/charts/index.yaml&label=version&query=$.entries.postgresql[0].version) |

## Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feat/my-change`
3. Bump the chart version in `Chart.yaml` (SemVer)
4. Open a PR — CI will lint and install the changed charts against a kind cluster

## License

Each application is subject to its own respective license. Chart code is [Apache-2.0](LICENSE).
