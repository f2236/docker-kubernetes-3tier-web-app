#!/bin/bash

# Deploy to Kubernetes
echo "Creating namespace and deploying to Kubernetes..."

# Apply all manifests in order
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secret.yaml
kubectl apply -f k8s/04-persistent-storage.yaml
kubectl apply -f k8s/05-mysql-deployment.yaml
kubectl apply -f k8s/06-backend-deployment.yaml
kubectl apply -f k8s/07-frontend-deployment.yaml
kubectl apply -f k8s/08-hpa.yaml

echo "Kubernetes deployment completed!"
echo "Checking deployment status..."
kubectl get all -n todolist
