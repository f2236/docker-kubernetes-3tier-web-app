# Build Docker images for Windows
Write-Host "Building backend Docker image..." -ForegroundColor Cyan
docker build -t todolist-backend:latest ./server

Write-Host "Building frontend Docker image..." -ForegroundColor Cyan
docker build -t todolist-frontend:latest ./client

Write-Host "Docker images built successfully!" -ForegroundColor Green
