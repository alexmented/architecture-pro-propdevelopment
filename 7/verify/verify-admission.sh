#!/bin/bash

set -e

# Определяем директорию, где находится скрипт
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Applying namespace..."
kubectl apply -f "$SCRIPT_DIR/../01-create-namespace.yaml"
kubectl label namespace audit-zone pod-security.kubernetes.io/enforce=restricted
kubectl label namespace audit-zone pod-security.kubernetes.io/audit=restricted
kubectl label namespace audit-zone pod-security.kubernetes.io/warn=restricted

echo -e "\n--- VERIFYING POD SECURITY ADMISSION ---"

# Test insecure manifests
echo -e "\nTesting insecure manifests (should be DENIED)..."

if ! kubectl apply -f "$SCRIPT_DIR/../insecure-manifests/01-privileged-pod.yaml" 2>&1 | grep -q 'forbidden'; then
    echo -e "${RED}✗ FAILED: Privileged pod was not denied.${NC}"
else
    echo -e "${GREEN}✓ PASSED: Privileged pod was denied as expected.${NC}"
fi

if ! kubectl apply -f "$SCRIPT_DIR/../insecure-manifests/02-hostpath-pod.yaml" 2>&1 | grep -q 'forbidden'; then
    echo -e "${RED}✗ FAILED: HostPath pod was not denied.${NC}"
else
    echo -e "${GREEN}✓ PASSED: HostPath pod was denied as expected.${NC}"
fi

if ! kubectl apply -f "$SCRIPT_DIR/../insecure-manifests/03-root-user-pod.yaml" 2>&1 | grep -q 'forbidden'; then
    echo -e "${RED}✗ FAILED: Root user pod was not denied.${NC}"
else
    echo -e "${GREEN}✓ PASSED: Root user pod was denied as expected.${NC}"
fi

# Test secure manifests
echo -e "\nTesting secure manifests (should be ALLOWED)..."

if ! kubectl apply -f "$SCRIPT_DIR/../secure-manifests/01-secure.yaml"; then
    echo -e "${RED}✗ FAILED: Secure pod 1 could not be applied.${NC}"
else
    echo -e "${GREEN}✓ PASSED: Secure pod 1 was applied successfully.${NC}"
    kubectl delete -f "$SCRIPT_DIR/../secure-manifests/01-secure.yaml"
fi

if ! kubectl apply -f "$SCRIPT_DIR/../secure-manifests/02-secure.yaml"; then
    echo -e "${RED}✗ FAILED: Secure pod 2 could not be applied.${NC}"
else
    echo -e "${GREEN}✓ PASSED: Secure pod 2 was applied successfully.${NC}"
    kubectl delete -f "$SCRIPT_DIR/../secure-manifests/02-secure.yaml"
fi

if ! kubectl apply -f "$SCRIPT_DIR/../secure-manifests/03-secure.yaml"; then
    echo -e "${RED}✗ FAILED: Secure pod 3 could not be applied.${NC}"
else
    echo -e "${GREEN}✓ PASSED: Secure pod 3 was applied successfully.${NC}"
    kubectl delete -f "$SCRIPT_DIR/../secure-manifests/03-secure.yaml"
fi
