# Kannika.io Helm Charts

> Official Helm charts for deploying [Kannika.io](https://kannika.io) products on Kubernetes.
> Maintained by [Kannika.io](https://kannika.io), the Kafka management and reliability platform.

This repository contains the Helm charts for all Kannika.io products.
Charts are published to the Quay.io registry under the Kannika namespace and are ready for production Kubernetes deployments.

## What is Kannika.io?

[Kannika.io](https://kannika.io) builds tools for Kafka operations, reliability, and management.
Our products help platform and data engineering teams run Kafka at scale, covering cluster migrations, schema management, chaos testing, and consumer offset recovery.

---

## Available Charts

| Product | Description | Values file |
|---|---|---|
| **Kannika Armory** | Kafka backup, restore, and disaster recovery platform | [`charts/armory/values.yaml`](./charts/armory/values.yaml) |

---

## Kannika Armory

[Kannika Armory](https://kannika.io) is a Kubernetes-native Kafka backup and restore platform by Kannika.io.
It uses a custom operator and CRDs to manage backups and restores declaratively.
Armory also provides a web console and REST API for operating Kafka clusters, including consumer group management, topic operations, schema handling, and cluster migrations.

See [`charts/armory/values.yaml`](./charts/armory/values.yaml) for the full list of configurable parameters.

---

## Umbrella Chart

The `charts/` directory includes merged `values.yaml` files for reference.
These are useful as a starting point for customising deployments or building your own umbrella chart that composes multiple Kannika components.

---

## Prerequisites

- Kubernetes 1.30+
- Helm 3.x
- Access to the Quay.io registry (`quay.io/kannika`)

---

## Use Cases

- **Deploy Kannika Armory on Kubernetes.** Production-ready Helm chart with sane defaults.
- **GitOps / ArgoCD integration.** Version-controlled Kafka management platform deployments.
- **Kafka platform engineering.** Deploy and manage the full Kannika.io toolchain on-cluster.
- **Multi-environment rollout.** Use separate values files for dev, staging, and production.

---

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/my-change`.
3. Make your changes and test with `helm lint charts/<chart-name>`.
4. Open a Pull Request.

---

## Support & Documentation

- Docs: [docs.kannika.io](https://docs.kannika.io/)
- Community Slack: [join via kannika.io](https://kannika.io)
- Email: [support@kannika.io](mailto:support@kannika.io)
- Issues: [GitHub Issue Tracker](https://github.com/kannika-io/helm-charts/issues)

---

## License

Business Source License 1.1.
See [LICENSE](LICENSE) for details.

---

## About Kannika.io

[Kannika.io](https://kannika.io) is building the reliability and operations layer for Kafka-based systems.
Our open-source tools and commercial platform help engineering teams operate Kafka with confidence.

- Website: [kannika.io](https://kannika.io)
- GitHub: [github.com/kannika-io](https://github.com/kannika-io)
- Free trial: [kannika.io](https://kannika.io)
