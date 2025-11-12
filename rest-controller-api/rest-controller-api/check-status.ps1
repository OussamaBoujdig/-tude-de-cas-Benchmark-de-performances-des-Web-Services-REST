# Quick Status Check
Write-Host "Checking Docker Services..." -ForegroundColor Cyan
Write-Host ""

# Check Docker containers
docker-compose ps

Write-Host ""
Write-Host "Testing API Endpoints..." -ForegroundColor Cyan
Write-Host ""

# Wait a bit for Jersey to fully start
Start-Sleep -Seconds 5

# Test Jersey
Write-Host "Jersey API (Port 8081):" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod "http://localhost:8081/actuator/health" -TimeoutSec 5
    Write-Host "  ✓ Health: $($response.status)" -ForegroundColor Green
    
    $items = Invoke-RestMethod "http://localhost:8081/items?page=0`&size=5" -TimeoutSec 5
    Write-Host "  ✓ Items API: $($items.totalElements) total items" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Not ready yet: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Access URLs:" -ForegroundColor Cyan
Write-Host "  API:        http://localhost:8081/items?page=0&size=10" -ForegroundColor White
Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "  Grafana:    http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host ""
