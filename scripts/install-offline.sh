#!/usr/bin/env bash
# Usage: REGISTRY='repo.example.local:5000/jetstack' bash scripts/install-offline.sh /path/to/downloaded-artifacts
set -euo pipefail
ROOT="${1:?Pass path to extracted GitHub Actions artifacts}"
REGISTRY="${REGISTRY:?Set REGISTRY to internal registry prefix, e.g. host:port/jetstack}"
REGISTRY="${REGISTRY%/}"
CHART="$ROOT/cert-manager-chart-and-metadata"
(cd "$CHART" && sha256sum -c SHA256SUMS.txt)
cat > "$ROOT/offline-values.yaml" <<EOF
crds:
  enabled: true
image:
  repository: ${REGISTRY}/cert-manager-controller
webhook:
  image:
    repository: ${REGISTRY}/cert-manager-webhook
cainjector:
  image:
    repository: ${REGISTRY}/cert-manager-cainjector
startupapicheck:
  image:
    repository: ${REGISTRY}/cert-manager-startupapicheck
acmesolver:
  image:
    repository: ${REGISTRY}/cert-manager-acmesolver
EOF
helm upgrade --install cert-manager "$CHART/cert-manager-chart.tgz" \
  --namespace cert-manager --create-namespace \
  -f "$ROOT/offline-values.yaml" --wait --timeout 10m
kubectl get pods -n cert-manager
