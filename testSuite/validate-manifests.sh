#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RENDERED_DIR="$REPO_ROOT/challenges/rendered"

echo "Repo root: $REPO_ROOT"
echo "Rendered manifests: $RENDERED_DIR"
echo

echo "Running kubeconform..."
kubeconform \
  -strict \
  -kubernetes-version 1.28.0 \
  "$RENDERED_DIR"/*.yaml

echo
echo "Running kube-linter..."
kube-linter lint "$RENDERED_DIR"

echo
echo "Running server-side dry run..."
kubectl apply --dry-run=server -f "$RENDERED_DIR"

echo
echo "All tests passed"
