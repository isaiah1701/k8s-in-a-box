# Kubernetes Manifest Tests

The purpose of these tests is to quickly check that Kubernetes manifest files are valid and sane before they are used or applied.

They are intended to catch common mistakes early, such as broken YAML, invalid Kubernetes fields, or unsafe configuration, without requiring a running Kubernetes cluster.

---

## What Is Tested

The tests run against Kubernetes manifest files located in:

challenges/templates/

The following checks are performed:

- YAML syntax validation  
  Ensures all manifest files are valid YAML.

- Kubernetes schema validation  
  Ensures manifests conform to Kubernetes API schemas, including correct fields, versions, and structure.

- Basic policy checks (optional)  
  If policy files exist under tests/policies/, they are applied to enforce simple standards such as required metadata or safe container configuration.

---

## How to Run

From the repository root, run:

tests/check-manifests.sh

This command can be run locally during development or as part of a CI pipeline.

---

## Expected Output

If all checks pass, the script completes successfully and prints confirmation messages.

If any check fails, the script exits immediately with a non-zero status code.

Errors clearly indicate which file failed and why, making issues easy to identify and fix. This behaviour allows the script to be used safely in CI pipelines where failures should block merges.

---

## Required Tools

The following tools must be installed on the system running the tests:

- yamllint – checks YAML syntax  
- kubeconform – validates Kubernetes schemas  
- conftest – runs policy checks (only required if policy files exist)

---

## Why This Exists

Kubernetes manifests are configuration rather than executable code.

This test suite ensures configuration remains correct, consistent, and safe, and prevents broken or unsafe manifests from reaching a Kubernetes cluster.
