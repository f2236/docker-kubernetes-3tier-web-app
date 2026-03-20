# TodoList Application - DevOps Containerization & Deployment Project

A complete DevOps solution for containerizing and deploying a React + Node.js + MySQL Todo application using Docker, Docker Compose, and Kubernetes.

## 📋 Project Summary

This project demonstrates enterprise-grade containerization and orchestration practices by implementing:
- ✅ Docker containerization for frontend, backend, and database
- ✅ Docker Compose multi-container orchestration
- ✅ Kubernetes deployment with multiple replicas
- ✅ Persistent storage with PV and PVC
- ✅ Horizontal Pod Autoscaling (HPA)
- ✅ Complete documentation and troubleshooting guides

## 🎯 Completed Tasks

### Task 1: Docker Containerization ✅
- Created optimized Dockerfiles for backend and frontend
- Built Docker images with health checks
- Verified container execution with port mapping
- **Files**: `server/Dockerfile`, `client/Dockerfile`

### Task 2: Multi-Container Setup using Docker Compose ✅
- Configured multi-service setup with MySQL, Backend, and Frontend
- Set up container networking and service dependencies
- Implemented health checks and volume management
- **Files**: `docker-compose.yml`, `init.sql`, `.env.example`

### Task 3: Kubernetes Deployment ✅
- Created Kubernetes manifests for complete deployment
- Deployed Frontend and Backend with 3 replicas each
- Configured MySQL with 1 replica
- Set up Services and ConfigMaps
- **Files**: `k8s/01-namespace.yaml` through `k8s/07-frontend-deployment.yaml`

### Task 4: Persistent Storage ✅
- Created PersistentVolume (10GB capacity)
- Configured PersistentVolumeClaim for MySQL
- Implemented persistent data storage across pod lifecycle
- **Files**: `k8s/04-persistent-storage.yaml`

### Task 5: Application Scaling ✅
- Implemented Horizontal Pod Autoscaler for Backend (2-5 replicas)
- Implemented Horizontal Pod Autoscaler for Frontend (2-5 replicas)
- Configured CPU target (70%) and memory target (80%)
- **Files**: `k8s/08-hpa.yaml`

## 📁 Project Structure

```
todolist-react-node-mysql/
├── 📦 Docker Configuration
│   ├── server/Dockerfile              # Backend container image
│   ├── client/Dockerfile              # Frontend container image
│   ├── server/.dockerignore
│   ├── client/.dockerignore
│   ├── docker-compose.yml             # Multi-container orchestration
│   ├── .env.example                   # Environment variables template
│   └── init.sql                       # Database initialization
│
├── ☸️ Kubernetes Manifests (k8s/)
│   ├── 01-namespace.yaml              # Kubernetes namespace
│   ├── 02-configmap.yaml              # App configuration
│   ├── 03-secret.yaml                 # Credentials
│   ├── 04-persistent-storage.yaml     # PV & PVC
│   ├── 05-mysql-deployment.yaml       # MySQL pod
│   ├── 06-backend-deployment.yaml     # Backend pod
│   ├── 07-frontend-deployment.yaml    # Frontend pod
│   └── 08-hpa.yaml                    # Horizontal Pod Autoscaler
│
├── 🔧 Automation Scripts
│   ├── build-images.sh               # Bash: Build Docker images
│   ├── build-images.ps1              # PowerShell: Build Docker images
│   ├── deploy-k8s.sh                 # Bash: Deploy to Kubernetes
│   ├── deploy-k8s.ps1                # PowerShell: Deploy to Kubernetes
│   ├── cleanup.sh                    # Bash: Cleanup resources
│   ├── cleanup.ps1                   # PowerShell: Cleanup resources
│   └── Makefile                      # Convenient make commands
│
├── 📚 Documentation
│   ├── DEPLOYMENT_GUIDE.md           # Comprehensive guide (Tasks 1-5)
│   ├── TROUBLESHOOTING.md            # Problems & solutions
│   ├── STRUCTURE.md                  # Project structure details
│   └── README.md                     # This file
│
├── 📝 Application Source
│   ├── server/                       # Node.js Express backend
│   ├── client/                       # React frontend
│   └── [Additional project files]
```

## 🚀 Quick Start

### 1. Docker Compose (Fastest)
```bash
# Setup environment
cp .env.example .env

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Access application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8080
```

### 2. Kubernetes (Production-Ready)
```bash
# Build Docker images
make build-images

# Load images to Minikube (if using local cluster)
minikube image load todolist-backend:latest
minikube image load todolist-frontend:latest

# Deploy to Kubernetes
make k8s-deploy

# Port forward to access
make k8s-port

# Access at http://localhost:3000
```

### 3. Using Makefile (Recommended)
```bash
# See all available commands
make help

# Build images
make build-images

# Start Docker Compose
make up

# Deploy to Kubernetes
make k8s-deploy

# View status
make k8s-status

# View logs
make k8s-logs SERVICE=backend

# Cleanup
make clean
```

## 📖 Documentation Guide

### For Understanding the Setup
1. **STRUCTURE.md** - Overview of all created files and configurations
2. **DEPLOYMENT_GUIDE.md** - Detailed step-by-step instructions for each task

### For Implementation Details
- **Docker Compose**: See DEPLOYMENT_GUIDE.md - Task 2
- **Kubernetes**: See DEPLOYMENT_GUIDE.md - Task 3
- **Persistent Storage**: See DEPLOYMENT_GUIDE.md - Task 4
- **Auto Scaling**: See DEPLOYMENT_GUIDE.md - Task 5

### For Problem Solving
- **TROUBLESHOOTING.md** - Common issues and solutions

## 🔧 Environment Variables

### Docker Compose
Located in `.env` file:
```
DB_USER=todouser
DB_PASSWORD=todopassword
DB_NAME=todolist
```

### Kubernetes
Managed through:
- **ConfigMap** (`k8s/02-configmap.yaml`) - Public configuration
- **Secret** (`k8s/03-secret.yaml`) - Sensitive data

## 📊 Application Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Internet / Browser                   │
└────────────────────────┬────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────┐
        │    Frontend (React - Port 3000) │
        │  http://localhost:3000         │
        └────────┬───────────────────────┘
                 │
                 │ HTTP Requests
                 ▼
        ┌────────────────────────────────┐
        │   Backend (Express - Port 8080) │
        │  http://localhost:8080         │
        └────────┬───────────────────────┘
                 │
                 │ SQL Queries
                 ▼
        ┌────────────────────────────────┐
        │   Database (MySQL - Port 3306)  │
        │  Persistent Storage (10GB PVC)  │
        └────────────────────────────────┘
```

## 🐳 Docker Images

### Backend Image
- **Base**: Node.js 18 Alpine
- **Size**: Optimized with .dockerignore
- **Health Check**: HTTP GET /
- **Ports**: 8080

### Frontend Image
- **Base**: Node.js 18 Alpine
- **Build**: Multi-stage (builder + production)
- **Server**: serve package for production
- **Size**: Minimal
- **Ports**: 3000

## ☸️ Kubernetes Configuration

### Resource Limits
```
Backend:   200m CPU / 512Mi Memory (limit)
Frontend:   10m CPU / 256Mi Memory (limit)
MySQL:     500m CPU / 512Mi Memory (limit)
```

### Replicas
```
Backend:  3 default (2-5 with autoscaling)
Frontend: 3 default (2-5 with autoscaling)
MySQL:    1 (single instance)
```

### Storage
```
MySQL PV:  10GB hostPath
Reclaim:   Retain (data preserved)
Access:    ReadWriteOnce (single node)
```

## 📈 Autoscaling Configuration

### Horizontal Pod Autoscaler (HPA)
- **Min Pods**: 2
- **Max Pods**: 5
- **CPU Target**: 70% utilization
- **Memory Target**: 80% utilization
- **Scale-Up**: Immediate (0s stabilization)
- **Scale-Down**: Gradual (60s stabilization)

## 🛠️ Available Commands

### Make Commands
```bash
make help              # Show all commands
make build-images     # Build Docker images
make up               # Start Docker Compose
make down             # Stop Docker Compose
make logs             # View Docker logs
make docker-clean     # Remove all Docker resources
make k8s-deploy       # Deploy to Kubernetes
make k8s-delete       # Delete Kubernetes deployment
make k8s-status       # Check deployment status
make k8s-logs         # View Kubernetes logs (SERVICE=name)
make k8s-port         # Port forward to frontend
make setup-env        # Setup .env file
make clean            # Full cleanup
```

### Direct Commands
```bash
# Docker
docker-compose up -d
docker-compose down
docker-compose logs -f
docker build -t todolist-backend:latest ./server

# Kubernetes
kubectl apply -f k8s/
kubectl delete namespace todolist
kubectl get all -n todolist
kubectl logs deployment/backend -n todolist
```

## ✨ Key Features

✅ **Production-Ready Configuration**
- Health checks and readiness probes
- Resource requests and limits
- Rolling updates with zero downtime
- Graceful shutdown handling

✅ **High Availability**
- Multiple replicas (3 default)
- Load balancing
- Automatic failover
- Auto-scaling based on metrics

✅ **Data Persistence**
- MySQL with persistent storage
- 10GB volume capacity
- Data survives pod restarts
- Backup-friendly PVC setup

✅ **Developer Experience**
- Makefile for common tasks
- Bash and PowerShell scripts
- Comprehensive documentation
- Troubleshooting guide

✅ **Security**
- Secrets for sensitive data
- ConfigMaps for configuration
- RBAC-ready
- Network policies support

## 🔍 Verification Checklist

After deployment, verify:
- [ ] All pods are running: `kubectl get pods -n todolist`
- [ ] Services have endpoints: `kubectl get svc -n todolist`
- [ ] PV is bound to PVC: `kubectl get pv,pvc -n todolist`
- [ ] HPA is active: `kubectl get hpa -n todolist`
- [ ] Frontend is accessible: `http://localhost:3000`
- [ ] Backend API responds: `curl http://localhost:8080/`
- [ ] Database has connection: Check backend logs
- [ ] Todos can be created and deleted

## 📚 Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Container Runtime | Docker | 20.10+ |
| Orchestration | Kubernetes | v1.24+ |
| Compose | Docker Compose | v1.29+ |
| Frontend | React | 18.1.0 |
| Backend | Express.js | 4.18.1 |
| Database | MySQL | 8.0 |
| Runtime | Node.js | 18 (Alpine) |
| Base Images | Alpine Linux | Latest |

## 📞 Support & Resources

- **Docker Docs**: https://docs.docker.com/
- **Kubernetes Docs**: https://kubernetes.io/docs/
- **Docker Compose**: https://docs.docker.com/compose/
- **kubectl Cheatsheet**: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- **Local Kubernetes**: 
  - Docker Desktop built-in Kubernetes
  - Minikube: https://minikube.sigs.k8s.io/

## 🎓 Learning Outcomes

After completing this project, you will understand:
- ✅ Docker image creation and optimization
- ✅ Multi-container orchestration with Docker Compose
- ✅ Kubernetes deployment and services
- ✅ ConfigMaps and Secrets management
- ✅ Persistent storage in Kubernetes
- ✅ Horizontal Pod Autoscaling
- ✅ Health checks and probes
- ✅ Production deployment best practices

## 📄 Files Created Summary

- **5** Kubernetes YAML manifests (namespace, config, secrets, storage, deployments, services, HPA)
- **2** Dockerfiles (backend, frontend with multi-stage builds)
- **2** .dockerignore files
- **1** docker-compose.yml
- **1** Makefile
- **6** Automation scripts (Bash and PowerShell)
- **3** Comprehensive documentation files
- **1** Database initialization script
- **1** Environment template file

**Total: 20+ configuration and documentation files**

## 🚦 Getting Started

1. **Read** DEPLOYMENT_GUIDE.md for comprehensive instructions
2. **Review** STRUCTURE.md for file details
3. **Run** `make help` to see available commands
4. **Start** with Docker Compose: `make up`
5. **Then progress** to Kubernetes: `make k8s-deploy`
6. **Consult** TROUBLESHOOTING.md if issues arise

## 📝 Notes

- All configuration files are production-ready
- Environment variables can be customized via .env
- Kubernetes assumes a cluster is available (Minikube or cloud)
- Data persists automatically with PVC setup
- Auto-scaling activation requires metrics-server

---

**Created**: March 20, 2026
**Project Status**: Complete ✅
**All Tasks**: Completed Successfully ✅

For detailed instructions, see **DEPLOYMENT_GUIDE.md**
