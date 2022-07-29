#!/usr/bin/env bash
# Create the namespace with the specified label.
kubectl create namespaces demo
kubectl label namespaces demo tier=test

# Create the specified deployment.
kubectl create deployment nginx-alpine --image=nginx:alpine --replicas=3 --namespace=demo
kubectl label deployment nginx-alpine app=nginx tag=alpine --namespace=demo

# Expose the deployment as a service.
kubectl expose deployment nginx-alpine --namespace=demo --port=8111

# Create the config map.
kubectl create configmaps nginx-version --namespace=demo --from-literal=version=alpine
