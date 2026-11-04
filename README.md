# Offline cert-manager GitHub Actions bundle

**Important:** Kubernetes v1.37.1 is *not officially supported/tested* by cert-manager v1.21.3 as of 2026-11-04. Use a test cluster first; don't classify this as a fully supported production pair.

## GitHub repository layout

```
.github/workflows/cert-manager-offline.yml
scripts/push-images.sh
scripts/install-offline.sh
README.md
```

1. Create a GitHub repository and commit these files to the default branch (e.g. main).
2. Open **Actions → cert-manager offline bundle → Run workflow** and enter `v1.21.3`.
3. When **chart** and **images** jobs pass, download all six separate Actions artifacts: one chart/metadata artifact plus five image artifacts.
4. Extract the six downloaded artifact ZIPs into directories named exactly as the artifacts, inside a common folder `downloads/`. (Do not merge the content of separate image artifacts.)
5. Copy `downloads/` and the scripts to an offline staging machine with Docker, Helm and kubectl (and access to the private registry and cluster respectively).
6. Verify transport checksums; do not treat the computed SHA256 as proof of upstream publisher authenticity. Verify trusted provenance/signatures separately.
7. Log in to the private registry with `docker login REGISTRY_HOST:PORT` before pushing.
8. Push images and then install:

```bash
REGISTRY='repo.example.local:5000/jetstack' bash scripts/push-images.sh downloads
REGISTRY='repo.example.local:5000/jetstack' bash scripts/install-offline.sh downloads
```

**Important:** all Kubernetes nodes (including control plane as applicable) must trust the internal registry's TLS CA and have pull credentials configured (e.g. per-namespace imagePullSecret and service accounts or node-level configuration). Pushing images does not by itself grant cluster pull access. Confirm the image repositories and tags in `offline-values.yaml` match the pushed tags.

**Architecture:** `linux/amd64` only. For ARM64 nodes, change the workflow's platform and save an appropriate image for those nodes.

**Air-gapped ACME:** the HTTP-01 solver image is included, but public ACME issuers such as Let's Encrypt still require network reachability and public challenge access. Internal CA, Vault, or other issuers may be more appropriate if air-gapped.

Official docs: https://cert-manager.io/docs/installation/helm/ and https://cert-manager.io/docs/releases/
