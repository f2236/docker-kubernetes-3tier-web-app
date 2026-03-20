# Test script for TodoList Application

Write-Host "Test 1: Check ports..." -ForegroundColor Yellow
$backend = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
$frontend = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue

if ($backend) { Write-Host "✅ Backend port 8080: OK" -ForegroundColor Green }
else { Write-Host "❌ Backend port 8080: NOT RUNNING" -ForegroundColor Red }

if ($frontend) { Write-Host "✅ Frontend port 3000: OK" -ForegroundColor Green }
else { Write-Host "❌ Frontend port 3000: NOT RUNNING" -ForegroundColor Red }

Write-Host ""
Write-Host "Test 2: Backend API test..." -ForegroundColor Yellow
try {
  $response = Invoke-WebRequest http://localhost:8080/ -UseBasicParsing -TimeoutSec 5
  Write-Host "✅ Backend responding: HTTP $($response.StatusCode)" -ForegroundColor Green
} 
catch {
  Write-Host "❌ Backend not responding" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 3: Frontend test..." -ForegroundColor Yellow
try {
  $response = Invoke-WebRequest http://localhost:3000/ -UseBasicParsing -TimeoutSec 5
  Write-Host "✅ Frontend responding: HTTP $($response.StatusCode)" -ForegroundColor Green
}
catch {
  Write-Host "❌ Frontend not responding" -ForegroundColor Red
}

Write-Host ""
Write-Host "TESTING COMPLETE!" -ForegroundColor Cyan
Write-Host "Open http://localhost:3000 to test the app" -ForegroundColor Cyan
