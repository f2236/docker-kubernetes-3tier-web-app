# Docker & Kubernetes Troubleshooting Guide

## Common Issues and Solutions

### 1. Docker Issues

#### Issue: Cannot connect to Docker daemon
**Solution:**
- Windows/Mac: Ensure Docker Desktop is running
- Linux: Check Docker service: `sudo systemctl status docker`
- Start Docker: `sudo systemctl start docker`

#### Issue: Port already in use (e.g., 3000, 8080)
**Solution:**
```bash
# Find process using the port
# Windows (PowerShell)
netstat -ano | findstr :3000

# Linux/Mac
lsof -i :3000

# Kill the process using that port
# Windows
taskkill /PID <PID> /F

# Linux/Mac
kill -9 <PID>

# Or change port in docker-compose.yml
```

#### Issue: docker-compose command not found
**Solution:**
- Upgrade Docker Desktop (Docker Compose v2 is included)
- Or install separately: `pip install docker-compose`

#### Issue: Build fails with "Dockerfile not found"
**Solution:**
- Ensure Dockerfile is in the correct directory
- Check file naming (case-sensitive on Linux)
- Verify docker-compose.yml build context path

### 2. Database Connection Issues

#### Issue: Backend cannot connect to MySQL
**Symptoms:**
- "Access denied" or "Connection refused" errors
- Backend returns 500 errors
- MySQL container is running but backend fails

**Solutions:**

```bash
# 1. Check if MySQL is actually running
docker-compose ps

# 2. Verify network connectivity
docker-compose exec backend ping mysql

# 3. Check MySQL logs for errors
docker-compose logs mysql

# 4. Test MySQL directly
docker-compose exec mysql mysql -u root -p -e "SHOW DATABASES;"

# 5. Verify credentials in docker-compose.yml match db.js

# 6. Check if database exists
docker-compose exec mysql mysql -u todouser -ptodopassword todolist -e "SHOW TABLES;"
```

#### Issue: Database schema not created
**Solution:**
```bash
# Check if init.sql was executed
docker-compose exec mysql mysql -u root -p todolist -e "SELECT * FROM todos;"

# If table doesn't exist, create it manually
docker-compose exec mysql mysql -u root -p todolist -e "
CREATE TABLE IF NOT EXISTS todos (
  id VARCHAR(36) PRIMARY KEY,
  todo VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);"
```

### 3. Frontend Issues

#### Issue: Frontend shows blank page or 404
**Possible causes:**
- Backend is not accessible
- API URL is incorrect
- CORS issues

**Solutions:**
```bash
# 1. Check if frontend is running
docker-compose ps frontend

# 2. Test API accessibility from frontend container
docker-compose exec frontend wget http://backend:8080/

# 3. Check REACT_APP_API_URL environment variable
docker-compose exec frontend env | grep REACT_APP

# 4. Check browser console for errors
# Open http://localhost:3000 and check DevTools

# 5. Verify backend is responding
curl http://localhost:8080/
```

#### Issue: CORS errors in console
**Solution:**
- Verify backend has CORS enabled
- Check `cors` middleware in server/index.js
- Ensure API URL in App.js doesn't have trailing slash issues

### 4. Kubernetes Issues

#### Issue: Pods not starting or stuck in pending state
**Solutions:**
```bash
# Check pod status details
kubectl describe pod <pod-name> -n todolist

# Common causes and fixes:
# 1. Image not found - ensure images are available
docker images | grep todolist
# If missing, rebuild and load:
minikube image load todolist-backend:latest

# 2. PVC not bound
kubectl describe pvc mysql-pvc -n todolist
# Fix: Ensure PV exists and storage class is available

# 3. Insufficient resources
kubectl describe node
kubectl top nodes

# 4. Check events
kubectl get events -n todolist -w
```

#### Issue: Pods are crashing (CrashLoopBackOff)
**Solutions:**
```bash
# Check logs for errors
kubectl logs <pod-name> -n todolist

# Common causes:
# 1. Database connection failed - check MySQL pod
kubectl logs deployment/mysql -n todolist

# 2. Missing environment variables
kubectl describe deployment backend -n todolist

# 3. Application error - check logs thoroughly
kubectl logs deployment/backend -n todolist --previous
```

#### Issue: ImagePullBackOff error
**Cause:** Kubernetes cannot find the image
**Solutions:**
```bash
# For local development with Minikube:
# 1. Load images into Minikube
minikube image load todolist-backend:latest
minikube image load todolist-frontend:latest

# 2. Update imagePullPolicy in YAML
# Change: imagePullPolicy: Always
# To: imagePullPolicy: IfNotPresent

# For production with a registry:
# 1. Push images to registry
docker tag todolist-backend:latest myregistry/todolist-backend:latest
docker push myregistry/todolist-backend:latest

# 2. Update image URL in k8s YAML files
# image: myregistry/todolist-backend:latest
```

#### Issue: PVC stuck in Pending
**Solutions:**
```bash
# Check PVC status
kubectl describe pvc mysql-pvc -n todolist

# For Minikube, create the storage path
minikube ssh
sudo mkdir -p /mnt/data/mysql
sudo chmod 777 /mnt/data/mysql
exit

# Reapply the PVC
kubectl apply -f k8s/04-persistent-storage.yaml
```

#### Issue: Service cannot reach backend/frontend
**Solutions:**
```bash
# Test DNS resolution
kubectl exec -it <pod> -n todolist -- nslookup mysql-service

# Check service endpoints
kubectl get endpoints -n todolist

# Test connectivity within pod
kubectl exec -it <frontend-pod> -n todolist -- wget http://backend-service:8080/

# Check network policies
kubectl get networkpolicies -n todolist
```

#### Issue: HPA not scaling pods
**Solutions:**
```bash
# 1. Check metrics server
kubectl get deployment metrics-server -n kube-system

# For Minikube, enable metrics:
minikube addons enable metrics-server

# 2. Check HPA status
kubectl describe hpa backend-hpa -n todolist

# 3. Generate load to trigger scaling
ab -n 10000 -c 100 http://localhost:8080/

# 4. Monitor scaling
watch kubectl get hpa -n todolist
watch kubectl get pods -n todolist
```

#### Issue: Cannot execute kubectl commands
**Solutions:**
```bash
# 1. Check kubectl configuration
kubectl config get-contexts

# 2. Set current context
kubectl config use-context docker-desktop
# or
kubectl config use-context minikube

# 3. Verify cluster access
kubectl get nodes
kubectl get pods -n kube-system
```

### 5. Network Issues

#### Issue: Services cannot communicate
**Solutions:**
```bash
# Check DNS within pod
kubectl exec -it <pod> -n todolist -- nslookup <service-name>

# Test network connectivity
kubectl exec -it <pod> -n todolist -- ping <service-name>

# Check iptables rules (if using hostNetwork)
sudo iptables -L -n

# View service details
kubectl describe svc <service-name> -n todolist

# Check if service has endpoints
kubectl get endpoints -n todolist
```

#### Issue: Cannot access service from outside cluster
**Solutions:**
```bash
# For LoadBalancer service, get external IP
kubectl get svc -n todolist

# If stuck in pending, use port-forward
kubectl port-forward svc/frontend-service 3000:3000 -n todolist

# For Minikube, use minikube service
minikube service frontend-service -n todolist

# Verify firewall rules
# Windows: Check Windows Firewall settings
# Linux: Check iptables/firewalld
```

### 6. Performance Issues

#### Issue: Slow response times
**Solutions:**
```bash
# Check resource usage
kubectl top pods -n todolist
kubectl top nodes

# Check if containers are hitting limits
kubectl describe pod <pod-name> -n todolist | grep -A 5 "Limits"

# Increase resource limits in k8s YAML if needed
# Check database performance
kubectl exec -it deployment/mysql -n todolist -- \
  mysql -u todouser -ptodopassword -D todolist -e "SHOW PROCESSLIST;"
```

#### Issue: High disk usage
**Solutions:**
```bash
# Check volume usage
kubectl exec -it deployment/mysql -n todolist -- \
  df -h /var/lib/mysql

# Check PVC status
kubectl describe pvc mysql-pvc -n todolist

# If full, backup data and resize
# For hostPath, check disk space
```

### 7. Debugging Commands

#### Useful debugging commands
```bash
# Get detailed YAML of resource
kubectl get <resource> <name> -n todolist -o yaml

# Watch resources in real-time
watch kubectl get pods -n todolist

# Stream logs from all pods
kubectl logs -f deployment/<name> -n todolist

# Connect to running container
kubectl exec -it <pod> -n todolist -- /bin/sh

# Copy files from pod
kubectl cp namespace/pod:/path/to/file ./local/path

# Port forward multiple ports
kubectl port-forward pod/<pod> 8080:8080 3000:3000 -n todolist
```

### 8. Cleanup and Reset

#### Full reset
```bash
# Docker
docker-compose down -v
docker system prune -a --volumes

# Kubernetes
kubectl delete namespace todolist
kubectl delete pv mysql-pv

# Rebuild and redeploy
docker build -t todolist-backend:latest ./server
docker build -t todolist-frontend:latest ./client
make k8s-deploy
```

---

## Useful Resources

- Docker Documentation: https://docs.docker.com/
- Kubernetes Troubleshooting: https://kubernetes.io/docs/tasks/debug-application-cluster/
- MySQL Docker Issues: https://hub.docker.com/_/mysql/
- kubectl Cheat Sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
