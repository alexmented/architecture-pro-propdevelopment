#!/bin/bash
set -e
NAMESPACE=gatekeeper-system

kubectl apply -f "./01-create-namespace.yaml"

kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.15.0/deploy/gatekeeper.yaml

echo "Waiting for all Gatekeeper pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n $NAMESPACE --timeout=180s

# Применение ConstraintTemplates
echo "Applying Gatekeeper ConstraintTemplates..."
kubectl apply -f ./gatekeeper/constraint-templates/ --recursive

echo "Waiting a few seconds for Gatekeeper to process templates..."
sleep 5 # Даём Gatekeeper время на создание CRD

kubectl wait --for=condition=Established --timeout=120s crd \
  k8spspforbidprivileged.constraints.gatekeeper.sh \
  k8spsphostpath.constraints.gatekeeper.sh \
  k8spsprunasnonroot.constraints.gatekeeper.sh

kubectl apply -f ./gatekeeper/constraints/ --recursive

kubectl apply -f ./insecure-manifests/01-privileged-pod.yaml

kubectl apply -f ./insecure-manifests/02-hostpath-pod.yaml

kubectl apply -f ./insecure-manifests/03-root-user-pod.yaml
