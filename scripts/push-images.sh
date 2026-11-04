#!/usr/bin/env bash
# Run on an internet-disconnected staging host with Docker and registry connectivity.
# Usage: REGISTRY='repo.example.local:5000/jetstack' bash scripts/push-images.sh /path/to/downloaded-artifacts
set -euo pipefail
ROOT="${1:?Pass path to extracted GitHub Actions artifacts}"
REGISTRY="${REGISTRY:?Set REGISTRY to internal registry prefix, e.g. host:port/jetstack}"
REGISTRY="${REGISTRY%/}"
shopt -s nullglob
count=0
for dir in "$ROOT"/image-cert-manager-*/; do
  echo "Checking $dir"
  (cd "$dir" && sha256sum -c SHA256SUMS.txt)
  src="$(cat "${dir}/source-image.txt")"
  component="${src##*/}"
  tarfile="${dir}/${component%:*}.tar"
  docker load -i "$tarfile"
  dst="${REGISTRY}/${component}"
  docker tag "$src" "$dst"
  docker push "$dst"
  printf '%s -> %s\n' "$src" "$dst"
  count=$((count+1))
done
[[ "$count" -eq 5 ]] || { echo "Expected five image artifacts, found $count" >&2; exit 1; }
