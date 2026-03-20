# Testing Guide for TodoList Docker Compose & DevOps Setup

## 🧪 TESTING DOCKER COMPOSE SETUP

### 1️⃣ TEST: Docker Compose Services Status

```bash
# Check if all services are running
docker-compose ps

# Expected output: All 3 services should have status "Up"
# - todolist-mysql
# - todolist-backend  
# - todolist-frontend
```

### 2️⃣ TEST: Check Docker Images

```bash
# List all Docker images
docker images | grep todolist

# Expected: Should see these images
# - todolist-backend:latest
# - todolist-frontend:latest
# - mysql:8.0
```

### 3️⃣ TEST: Check Networks

```bash
# List Docker networks
docker network ls

# Look for: todolist-network (created by docker-compose)
```

### 4️⃣ TEST: Check Volumes

```bash
# List Docker volumes
docker volume ls

# Expected: Should see "todolist-react-node-mysql_mysql-data"
```

---

## 🗄️ DATABASE TESTING

### 5️⃣ TEST: MySQL Connection

```bash
# Connect to MySQL container
docker-compose exec mysql mysql -u todouser -ptodopassword -D todolist -e "SELECT * FROM todos;"

# If working, shows the todos table (might be empty at first)
```

### 6️⃣ TEST: MySQL Health Check

```bash
# Check MySQL container health
docker-compose exec mysql mysqladmin ping -u todouser -ptodopassword

# Expected output: "mysqladmin: [Warning] Using a password on the command line interface can be insecure."
# Does not show error = Database is healthy
```

### 7️⃣ TEST: Database Persistence

```bash
# Check if data persists by viewing volume contents
docker volume inspect todolist-react-node-mysql_mysql-data

# Should show a Mountpoint (e.g., \\wsl$\docker-desktop\mnt\docker-desktop-disk\...)
```

---

## 🔌 BACKEND API TESTING

### 8️⃣ TEST: Backend Server Response

```bash
# Test if backend is responding
curl http://localhost:8080/

# Or in PowerShell:
Invoke-WebRequest http://localhost:8080/ -UseBasicParsing
```

### 9️⃣ TEST: Backend Logs

```bash
# View backend container logs
docker-compose logs -f backend

# Should show: "Listening on port 8080"
# Check for any errors
```

### 🔟 TEST: Backend Health Check

```bash
# Check if health check passes
docker-compose exec backend wget --quiet --tries=1 --spider http://localhost:8080/

# No output = Healthy
# Returns error = Not healthy
```

---

## 🎨 FRONTEND TESTING

### 1️1️⃣ TEST: Frontend Server Response

```bash
# Test if frontend is responding
curl http://localhost:3000/

# Or in PowerShell:
Invoke-WebRequest http://localhost:3000/ -UseBasicParsing
```

### 1️2️⃣ TEST: Frontend Logs

```bash
# View frontend container logs
docker-compose logs -f frontend

# Should show React is compiled and running
# Check for any errors
```

### 1️3️⃣ TEST: Frontend in Browser

```
Open: http://localhost:3000
- Page should load
- TodoList application interface should display
- No console errors (check browser DevTools)
```

---

## ✨ APPLICATION FUNCTIONALITY TESTING

### 1️4️⃣ TEST: Create a Todo (API Test)

```bash
# Create a new todo
curl -X POST http://localhost:8080/create \
  -H "Content-Type: application/json" \
  -d '{"todo":"Test Todo Item"}'

# Or in PowerShell:
$body = @{todo="Test Todo Item"} | ConvertTo-Json
Invoke-WebRequest -Uri http://localhost:8080/create `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body
```

### 1️5️⃣ TEST: Get All Todos (API Test)

```bash
# Get all todos
curl http://localhost:8080/

# Or in PowerShell:
Invoke-WebRequest http://localhost:8080/ -UseBasicParsing | Select-Object -ExpandProperty Content

# Should return JSON array of todos
```

### 1️6️⃣ TEST: Frontend UI Functionality

```
1. Open http://localhost:3000
2. Enter a todo item (e.g., "Buy groceries")
3. Click Add button
4. Verify todo appears in the list
5. Click Edit to modify a todo
6. Click Delete to remove a todo
```

---

## 🐳 DOCKER CONTAINER TESTING

### 1️7️⃣ TEST: Container Resource Usage

```bash
# Check container resource usage (CPU, Memory)
docker stats todolist-mysql todolist-backend todolist-frontend

# Shows: Container name, CPU%, Memory usage
# Press Ctrl+C to exit
```

### 1️8️⃣ TEST: Container Networking

```bash
# Test connectivity between containers
docker-compose exec backend ping mysql

# Expected output: PING response (containers can communicate)
```

### 1️9️⃣ TEST: Container Logs Summary

```bash
# Get all logs at once
docker-compose logs

# Or follow logs in real-time
docker-compose logs -f
```

---

## 📊 COMPLETE HEALTH CHECK

Run this complete test:

```bash
#!/bin/bash
# Complete health check script

echo "🧪 Testing TodoList Docker Compose Setup"
echo "=========================================="
echo ""

# 1. Services
echo "1️⃣ Checking Services..."
docker-compose ps
echo ""

# 2. Database
echo "2️⃣ Checking Database..."
docker-compose exec mysql mysql -u todouser -ptodopassword -D todolist -e "SELECT COUNT(*) as todos FROM todos;"
echo ""

# 3. Backend
echo "3️⃣ Checking Backend..."
curl -s http://localhost:8080/ | head -c 50
echo ""

# 4. Frontend
echo "4️⃣ Checking Frontend..."
curl -s http://localhost:3000/ | grep -o "<title>.*</title>"
echo ""

# 5. Networks
echo "5️⃣ Checking Networks..."
docker network ls | grep todolist
echo ""

# 6. Volumes
echo "6️⃣ Checking Volumes..."
docker volume ls | grep todolist
echo ""

echo "✅ All checks completed!"
```

---

## 🔍 COMMON ISSUES & QUICK FIXES

### Issue: "Cannot connect to Database"
```bash
# Test MySQL directly
docker-compose exec mysql mysql -u root -p -e "SHOW DATABASES;"

# Check credentials in docker-compose.yml
```

### Issue: "Backend not responding"
```bash
# Check backend logs
docker-compose logs backend

# Verify port mapping
netstat -ano | findstr :8080  # Windows
lsof -i :8080                  # Mac/Linux
```

### Issue: "Frontend port already in use"
```bash
# Find and kill process on port 3000
lsof -ti:3000 | xargs kill -9  # Mac/Linux

# Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

---

## 📋 TESTING CHECKLIST

- [ ] Docker Compose services all running (`docker-compose ps`)
- [ ] MySQL container is healthy (can execute queries)
- [ ] Backend responds on port 8080 (`curl http://localhost:8080`)
- [ ] Frontend loads on port 3000 (http://localhost:3000)
- [ ] Can create a todo via API or UI
- [ ] Can read todos from database
- [ ] Can update todos
- [ ] Can delete todos
- [ ] Data persists after container restart
- [ ] No errors in container logs
- [ ] Container networking works (backend → mysql)
- [ ] Volume mounting works for database

---

## 🚀 QUICK TEST COMMAND

Copy and paste this to test everything at once:

```bash
# Stop and remove old containers
docker-compose down

# Rebuild images
docker-compose build

# Start fresh
docker-compose up -d

# Wait for startup
sleep 10

# Test all services
echo "✅ Services Status:"
docker-compose ps

echo ""
echo "✅ Database Test:"
docker-compose exec mysql mysql -u todouser -ptodopassword -D todolist -e "SHOW TABLES;"

echo ""
echo "✅ Backend Test:"
curl http://localhost:8080/

echo ""
echo "✅ Frontend Test:"
curl -s http://localhost:3000/ | grep -o "<title>.*</title>"
```

---

## 📈 KUBERNETES TESTING (Next Step)

Once Docker Compose works, test Kubernetes:

```bash
# Build images for Kubernetes
docker build -t todolist-backend:latest ./server
docker build -t todolist-frontend:latest ./client

# Load images to Minikube
minikube image load todolist-backend:latest
minikube image load todolist-frontend:latest

# Deploy
kubectl apply -f k8s/

# Check status
kubectl get all -n todolist

# View logs
kubectl logs deployment/backend -n todolist
```

---

## ✅ SUCCESS INDICATORS

**Docker Compose Test Passes When:**
✅ All 3 containers show "Up" status
✅ Can execute MySQL queries
✅ Backend responds to HTTP requests
✅ Frontend loads in browser
✅ Can create/read/update/delete todos
✅ No critical errors in logs
✅ Network communication works
✅ Data persists in volume

**You're Good to Go!** 🎉
