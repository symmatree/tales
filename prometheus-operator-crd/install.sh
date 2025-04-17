#!/usr/bin/env bash
set -euxo pipefail

# Install the CRDs directly to bootstrap before we have a full system.

# This needs to agree with what we install later through KubeProm.
export VERSION=v0.81.0

#kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_alertmanagerconfigs.yaml"
#kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_alertmanagers.yaml"
#kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_podmonitors.yaml"
#kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_probes.yaml"
#kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_prometheuses.yaml"
#kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_prometheusrules.yaml"
kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_servicemonitors.yaml"
#kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_thanosrulers.yaml"
#kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_prometheusagents.yaml"
#kubectl apply --server-side -f "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${VERSION}/example/prometheus-operator-crd-full/monitoring.coreos.com_scrapeconfigs.yaml"
