# Kubernetes Manifest Test Suite

This test suite validates all rendered Kubernetes manifests before deployment.

## Scope

- Only manifests in `challenges/rendered/` are tested.
- Template files are not validated directly.
- Rendered manifests represent the deployable contract.

## What is validated

The test suite performs:

1. **Schema validation**
   - Uses `kubeconform`
   - Validates against Kubernetes v1.28 API schemas

2. **Static linting**
   - Uses `kube-linter`
   - Enforces basic security and operational best practices
   - Debug manifests may be explicitly excluded

3. **Server-side validation**
   - Uses `kubectl apply --dry-run=server`
   - Ensures manifests would be accepted by the cluster

## How to run

From the repository root:

```bash
./testSuite/validate-manifests.sh
