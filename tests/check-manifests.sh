#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root even when run from elsewhere
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_DIR="${REPO_ROOT}/challenges/templates"
POLICY_DIR="${REPO_ROOT}/tests/policies"

echo "Checking Kubernetes manifests"
echo "Manifests: ${MANIFEST_DIR}"
echo

# 1. YAML syntax
echo "==> yamllint"
if ! yamllint "${MANIFEST_DIR}"; then
  echo "ERROR: yamllint failed. Fix YAML syntax issues above."
fi
echo

# 2. Kubernetes schema validation
echo "==> kubeconform"
if ! kubeconform -strict -summary "${MANIFEST_DIR}"; then
  echo "ERROR: kubeconform failed. One or more manifests do not match the Kubernetes schema."
fi
echo

# 3. Policy checks (only if policies exist)
if [[ -d "${POLICY_DIR}" && "$(ls -A "${POLICY_DIR}")" ]]; then
  echo "==> conftest (OPA policies)"
  if ! conftest test "${MANIFEST_DIR}"; then
    echo "ERROR: conftest failed. One or more policy violations were detected."
  fi
else
  echo "==> conftest skipped (no policies found)"
fi

echo
echo "Manifest checks completed"
