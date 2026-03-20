# TodoList Application Containerization & Deployment Guide

## Project Overview
This guide covers the complete containerization and deployment process for a TodoList application built with:
- **Frontend**: React.js
- **Backend**: Node.js (Express.js)
- **Database**: MySQL

## Table of Contents
1. [Docker Containerization](#docker-containerization)
2. [Docker Compose Setup](#docker-compose-setup)
3. [Kubernetes Deployment](#kubernetes-deployment)
4. [Prerequisites](#prerequisites)

---

## Prerequisites

### For Docker & Docker Compose
- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Docker Compose v1.29+
- Git

### For Kubernetes
- kubectl CLI
- Kubernetes cluster (Minikube for local testing, or cloud providers like AKS, EKS, GKE)
- Docker images pushed to a registry or available locally

---

## TASK 1: Docker Containerization

### 1.1 Backend Dockerfile
Located at: `server/Dockerfile`

**Features:**
- Multi-stage build for optimal image size
- Node.js 18 Alpine Linux base image
- Health checks included
- Environment variables support
- Proper dependency management

**Build the backend image:**
```bash
cd server
docker build -t todolist-backend:latest .
```

**Run the backend container:**
```bash
docker run -d \
  --name todolist-backend \
  -p 8080:8080 \
  -e DB_HOST=mysql \
  -e DB_USER=todouser \
  -e DB_PASSWORD=todopassword \
  -e DB_NAME=todolist \
  todolist-backend:latest
```

### 1.2 Frontend Dockerfile
Located at: `client/Dockerfile`

**Features:**
- Multi-stage build (builder + production)
- Optimized production server using `serve`
- Node.js 18 Alpine Linux base image
- Minimal runtime image size

**Build the frontend image:**
```bash
cd client
docker build -t todolist-frontend:latest .
```

**Run the frontend container:**
```bash
docker run -d \
  --name todolist-frontend \
  -p 3000:3000 \
  -e REACT_APP_API_URL=http://localhost:8080 \
  todolist-frontend:latest
```

### 1.3 Verify Container Execution
Check if containers are running:
```bash
# List all containers
docker ps

# View container logs
docker logs todolist-backend
docker logs todolist-frontend

# Test backend
curl http://localhost:8080/

# Open frontend in browser
# Navigate to: http://localhost:3000
```

---

## TASK 2: Multi-Container Setup using Docker Compose

Located at: `docker-compose.yml`

### 2.1 Services Defined

**MySQL Service:**
- Image: mysql:8.0
- Port: 3306 (mapped from host)
- Volume: `mysql-data` named volume for persistent storage
- Health checks: Every 10 seconds with 10 retries
- Environment variables: DB credentials from `.env` file

**Backend Service:**
- Build from: `./server/Dockerfile`
- Port: 8080 (mapped from host)
- Depends on: MySQL (waits for health check)
- Environment: DB connection details
- Health checks: HTTP endpoint monitoring

**Frontend Service:**
- Build from: `./client/Dockerfile`
- Port: 3000 (mapped from host)
- Depends on: Backend service
- Environment: API URL configuration
- Restart policy: unless-stopped

### 2.2 Setup and Configuration

**Create `.env` file:**
```bash
# Copy the example
cp .env.example .env

# Edit the .env file with your credentials
DB_USER=todouser
DB_PASSWORD=todopassword
DB_NAME=todolist
```

### 2.3 Start Docker Compose Services

**Start all services:**
```bash
docker-compose up -d
```

**View service status:**
```bash
docker-compose ps
```

**View logs:**
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f mysql
docker-compose logs -f backend
docker-compose logs -f frontend
```

**Stop services:**
```bash
docker-compose down
```

**Stop and remove volumes:**
```bash
docker-compose down -v
```

### 2.4 Networking

Docker Compose creates an automatic bridge network (`todolist-network`) where:
- Services communicate using service names as hostnames
- Backend connects to MySQL using: `mysql:3306`
- Frontend connects to Backend using: `http://backend:8080`

---

## TASK 3: Kubernetes Deployment

Located in: `k8s/` directory

### 3.1 Kubernetes YAML Files Overview

| File | Purpose |
|------|---------|
| `01-namespace.yaml` | Create isolated namespace `todolist` |
| `02-configmap.yaml` | Store non-sensitive configuration |
| `03-secret.yaml` | Store sensitive data (passwords) |
| `04-persistent-storage.yaml` | Create PV and PVC for database |
| `05-mysql-deployment.yaml` | MySQL deployment with 1 replica |
| `06-backend-deployment.yaml` | Backend deployment with 3 replicas |
| `07-frontend-deployment.yaml` | Frontend deployment with 3 replicas |
| `08-hpa.yaml` | Horizontal Pod Autoscaler for both apps |

### 3.2 Prerequisites

1. **Kubernetes Cluster Setup:**
   ```bash
   # For local testing with Minikube
   minikube start
   
   # Or use Docker Desktop's Kubernetes
   # Enable Kubernetes in Docker Desktop settings
   ```

2. **Build and Tag Images:**
   ```bash
   # Build images
   docker build -t todolist-backend:latest ./server
   docker build -t todolist-frontend:latest ./client
   
   # If using Docker Desktop, images are automatically available
   # For Minikube, load images into the cluster:
   minikube image load todolist-backend:latest
   minikube image load todolist-frontend:latest
   ```

### 3.3 Deploy to Kubernetes

**Option 1: Deploy all manifests manually**
```bash
# Create namespace
kubectl apply -f k8s/01-namespace.yaml

# Create config and secrets
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secret.yaml

# Create persistent storage
kubectl apply -f k8s/04-persistent-storage.yaml

# Deploy MySQL (waits for PVC)
kubectl apply -f k8s/05-mysql-deployment.yaml

# Deploy backend (waits for MySQL)
kubectl apply -f k8s/06-backend-deployment.yaml

# Deploy frontend
kubectl apply -f k8s/07-frontend-deployment.yaml

# Configure autoscaling
kubectl apply -f k8s/08-hpa.yaml
```

**Option 2: Deploy using script**
```bash
chmod +x deploy-k8s.sh
./deploy-k8s.sh
```

### 3.4 Verify Kubernetes Deployment

**Check resources:**
```bash
# Switch to todolist namespace
kubectl config set-context --current --namespace=todolist

# View all resources
kubectl get all

# View detailed information
kubectl get pods -o wide
kubectl get svc
kubectl get pvc
kubectl get hpa
```

**View logs:**
```bash
# Backend logs
kubectl logs -f deployment/backend -n todolist

# Frontend logs
kubectl logs -f deployment/frontend -n todolist

# MySQL logs
kubectl logs -f deployment/mysql -n todolist
```

**Access the application:**

```bash
# For Minikube
minikube service frontend-service -n todolist

# For Docker Desktop & local clusters
kubectl port-forward svc/frontend-service 3000:3000 -n todolist

# Then open: http://localhost:3000
```

---

## TASK 4: Persistent Storage

### 4.1 PersistentVolume (PV)

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/data/mysql
```

**Features:**
- 10GB storage capacity
- ReadWriteOnce access mode (single node)
- Retain policy: data persists after PVC deletion

### 4.2 PersistentVolumeClaim (PVC)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

**Features:**
- Requests 10GB from available PVs
- Automatically binds to matching PV
- Named volume used by MySQL container

### 4.3 Verify Persistent Storage

```bash
# Check PV status
kubectl get pv

# Check PVC status
kubectl get pvc -n todolist

# Describe PVC to see binding details
kubectl describe pvc mysql-pvc -n todolist

# Check data persistence
kubectl exec -it deployment/mysql -n todolist -- \
  mysql -u todouser -ptodopassword -D todolist -e "SELECT * FROM todos;"

# The data will persist even after pod deletion
kubectl delete pod <mysql-pod-name> -n todolist
# Pod will be recreated and data remains in PVC
```

### 4.4 Manual Storage Directory Setup (for Minikube)

```bash
# SSH into Minikube
minikube ssh

# Create the directory
sudo mkdir -p /mnt/data/mysql
sudo chmod 777 /mnt/data/mysql
```

---

## TASK 5: Application Scaling

### 5.1 Horizontal Pod Autoscaler (HPA)

Located in: `k8s/08-hpa.yaml`

**Backend HPA Configuration:**
```yaml
minReplicas: 2
maxReplicas: 5
CPU Target: 70% utilization
Memory Target: 80% utilization
```

**Frontend HPA Configuration:**
```yaml
minReplicas: 2
maxReplicas: 5
CPU Target: 70% utilization
Memory Target: 80% utilization
```

### 5.2 Check HPA Status

```bash
# View HPA status
kubectl get hpa -n todolist

# Detailed HPA information
kubectl describe hpa backend-hpa -n todolist
kubectl describe hpa frontend-hpa -n todolist

# Watch autoscaling in real-time
kubectl get hpa -n todolist -w
```

### 5.3 Test Autoscaling

**Generate load to trigger scaling:**
```bash
# Port forward to the backend service
kubectl port-forward svc/backend-service 8080:8080 -n todolist

# In another terminal, generate load
# Install Apache Bench or use curl in a loop
ab -n 10000 -c 100 http://localhost:8080/

# Or use a simple bash loop
for i in {1..1000}; do curl http://localhost:8080/ &; done
```

**Monitor scaling:**
```bash
# Watch pods being created
kubectl get pods -n todolist -w

# Monitor HPA metrics
kubectl top pods -n todolist
kubectl top nodes
```

---

## Resource Requests & Limits

### Backend
- **Requests**: CPU 250m, Memory 256Mi
- **Limits**: CPU 500m, Memory 512Mi

### Frontend
- **Requests**: CPU 100m, Memory 128Mi
- **Limits**: CPU 200m, Memory 256Mi

### MySQL
- **Requests**: CPU 250m, Memory 256Mi
- **Limits**: CPU 500m, Memory 512Mi

---

## Environment Variables

### Backend
- `DB_HOST`: MySQL service hostname
- `DB_USER`: Database user
- `DB_PASSWORD`: Database password
- `DB_NAME`: Database name
- `PORT`: Server port (default: 8080)
- `NODE_ENV`: production/development

### Frontend
- `REACT_APP_API_URL`: Backend API URL

---

## Health Checks

### Liveness Probe
- Ensures container is running
- Restarts container if check fails
- Backend: HTTP GET to `/` on port 8080
- Frontend: HTTP GET to `/` on port 3000
- MySQL: mysqladmin ping

### Readiness Probe
- Ensures container is ready to receive traffic
- Removes pod from load balancer if check fails
- Used for health monitoring during startup

---

## Cleanup & Troubleshooting

### Docker Compose Cleanup
```bash
# Stop and remove containers
docker-compose down

# Stop containers and remove volumes
docker-compose down -v

# Remove images
docker rmi todolist-backend:latest
docker rmi todolist-frontend:latest
```

### Kubernetes Cleanup
```bash
# Delete entire namespace (removes all resources)
kubectl delete namespace todolist

# Or delete specific resources
kubectl delete -f k8s/
```

### Troubleshooting

**Pod not starting:**
```bash
kubectl describe pod <pod-name> -n todolist
kubectl logs <pod-name> -n todolist
```

**Database connection issues:**
```bash
# Test MySQL connectivity
kubectl exec -it <backend-pod> -n todolist -- \
  mysql -h mysql-service -u todouser -ptodopassword -D todolist

# Check MySQL service
kubectl get svc mysql-service -n todolist
```

**PVC not binding:**
```bash
kubectl describe pvc mysql-pvc -n todolist
kubectl describe pv mysql-pv
```

**HPA not scaling:**
```bash
# Check metrics server
kubectl get deployment metrics-server -n kube-system

# Install metrics server if missing (Minikube)
minikube addons enable metrics-server
```

---

## Production Deployment Considerations

1. **Image Registry**: Push images to Docker Hub, AWS ECR, or Azure ACR
2. **Ingress Controller**: Use Nginx Ingress for external access
3. **SSL/TLS**: Configure certificates for HTTPS
4. **Secrets Management**: Use HashiCorp Vault or cloud provider secrets
5. **Monitoring**: Implement Prometheus + Grafana
6. **Logging**: Use ELK Stack or cloud-native logging
7. **Database Backups**: Configure automated backup strategies
8. **Network Policies**: Restrict pod-to-pod communication
9. **RBAC**: Configure role-based access control
10. **Resource Quotas**: Define namespace resource limits

---

## Quick Reference Commands

```bash
# Docker
docker build -t <image>:<tag> .
docker run -d --name <container> <image>
docker-compose up -d
docker-compose logs -f

# Kubernetes
kubectl apply -f <file.yaml>
kubectl get <resource> -n <namespace>
kubectl describe <resource> <name> -n <namespace>
kubectl logs <pod> -n <namespace>
kubectl delete <resource> <name> -n <namespace>
kubectl port-forward <pod> <local-port>:<container-port> -n <namespace>

# Minikube
minikube start
minikube stop
minikube delete
minikube ssh
minikube service <service-name> -n <namespace>
```

---

## Support & Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [MySQL Docker Image](https://hub.docker.com/_/mysql/)
- [Node.js Docker Image](https://hub.docker.com/_/node)
- [React Best Practices](https://react.dev/)
