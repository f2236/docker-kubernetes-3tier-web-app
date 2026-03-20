#!/bin/bash

# Build backend docker image
echo "Building backend Docker image..."
docker build -t todolist-backend:latest ./server

# Build frontend docker image
echo "Building frontend Docker image..."
docker build -t todolist-frontend:latest ./client

echo "Docker images built successfully!"
