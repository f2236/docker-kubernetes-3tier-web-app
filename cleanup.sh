#!/bin/bash

# Cleanup Docker Compose
echo "Stopping and removing Docker Compose services..."
docker-compose down -v

# Cleanup Kubernetes
echo "Deleting Kubernetes deployment..."
kubectl delete namespace todolist

echo "Cleanup completed!"
