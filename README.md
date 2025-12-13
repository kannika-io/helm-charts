# Kannika Helm Charts

This repository contains the source of the Helm charts used by Kannika.

Charts are published at [https://quay.io/repository/kannika](https://quay.io/repository/kannika).


## Umbrella chart values

An umbrella chart is a Helm chart that includes multiple subcharts.
This repository contains merged `values.yaml` files for umbrella charts for easy reference.

| Product | Values |
|---------|--------|
| Kannika Armory | ./charts/armory/values.yaml |
