#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root even when run from elsewhere
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_DIR="${REPO_ROOT}/challenges/templates"
POLICY_DIR="${REPO_ROOT}/tests/policies"

echo "🔍 Checking Kubernetes manifests"
echo "Manifests: ${MANIFEST_DIR}"
echo

# 1. YAML syntax
echo "==> yamllint"
yamllint "${MANIFEST_DIR}"
echo "✓ YAML syntax OK"
echo

# 2. Kubernetes schema validation
echo "==> kubeconform"
kubeconform -strict -summary "${MANIFEST_DIR}"
echo "✓ Kubernetes schema OK"
echo

# 3. Policy checks (only if policies exist)
if [[ -d "${POLICY_DIR}" && "$(ls -A "${POLICY_DIR}")" ]]; then
  echo "==> conftest (OPA policies)"
  conftest test "${MANIFEST_DIR}"
  echo "✓ Policy checks passed"
else
  echo "==> conftest skipped (no policies found)"
fi

echo
echo "✅ Manifest checks completed successfully"
