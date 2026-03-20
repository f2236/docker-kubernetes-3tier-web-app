# Deploy to Kubernetes using PowerShell

Write-Host "Creating namespace and deploying to Kubernetes..." -ForegroundColor Cyan

# Apply all manifests in order
Write-Host "Applying namespace..." -ForegroundColor Yellow
kubectl apply -f k8s/01-namespace.yaml

Write-Host "Applying ConfigMap..." -ForegroundColor Yellow
kubectl apply -f k8s/02-configmap.yaml

Write-Host "Applying Secret..." -ForegroundColor Yellow
kubectl apply -f k8s/03-secret.yaml

Write-Host "Applying Persistent Storage..." -ForegroundColor Yellow
kubectl apply -f k8s/04-persistent-storage.yaml

Write-Host "Applying MySQL Deployment..." -ForegroundColor Yellow
kubectl apply -f k8s/05-mysql-deployment.yaml

Write-Host "Applying Backend Deployment..." -ForegroundColor Yellow
kubectl apply -f k8s/06-backend-deployment.yaml

Write-Host "Applying Frontend Deployment..." -ForegroundColor Yellow
kubectl apply -f k8s/07-frontend-deployment.yaml

Write-Host "Applying HPA..." -ForegroundColor Yellow
kubectl apply -f k8s/08-hpa.yaml

Write-Host "Kubernetes deployment completed!" -ForegroundColor Green
Write-Host "Checking deployment status..." -ForegroundColor Cyan
kubectl get all -n todolist
