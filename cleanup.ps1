# Cleanup PowerShell script

Write-Host "Stopping and removing Docker Compose services..." -ForegroundColor Cyan
docker-compose down -v

Write-Host "Deleting Kubernetes deployment..." -ForegroundColor Cyan
kubectl delete namespace todolist

Write-Host "Cleanup completed!" -ForegroundColor Green
