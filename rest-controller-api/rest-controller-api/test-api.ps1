# Test API Script
Write-Host "Testing REST API..." -ForegroundColor Cyan
Write-Host ""

# Wait for service to be ready
Write-Host "Waiting for Jersey API to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8081/actuator/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ Jersey API is ready!" -ForegroundColor Green
            break
        }
    } catch {
        # Service not ready yet
    }
    
    $attempt++
    Write-Host "  Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
    Start-Sleep -Seconds 2
}

if ($attempt -eq $maxAttempts) {
    Write-Host "✗ Jersey API did not start in time" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check logs with: docker logs variant-a-jersey" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Testing Endpoints" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Test 1: Health
Write-Host "1. Health Check:" -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod "http://localhost:8081/actuator/health"
    Write-Host "   Status: $($health.status)" -ForegroundColor $(if($health.status -eq "UP"){"Green"}else{"Red"})
} catch {
    Write-Host "   Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: Items
Write-Host "2. Get Items (page 0, size 10):" -ForegroundColor Cyan
try {
    $items = Invoke-RestMethod "http://localhost:8081/items?page=0&size=10"
    Write-Host "   Total Elements: $($items.totalElements)" -ForegroundColor Green
    Write-Host "   Total Pages: $($items.totalPages)" -ForegroundColor Green
    Write-Host "   Current Page: $($items.page)" -ForegroundColor Green
    Write-Host "   Items in this page: $($items.content.Count)" -ForegroundColor Green
    
    if ($items.content.Count -gt 0) {
        Write-Host ""
        Write-Host "   First item:" -ForegroundColor Yellow
        $firstItem = $items.content[0]
        Write-Host "     ID: $($firstItem.id)" -ForegroundColor White
        Write-Host "     Name: $($firstItem.name)" -ForegroundColor White
        Write-Host "     Price: $($firstItem.price)" -ForegroundColor White
        Write-Host "     Category ID: $($firstItem.categoryId)" -ForegroundColor White
    }
} catch {
    Write-Host "   Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 3: Categories
Write-Host "3. Get Categories (page 0, size 10):" -ForegroundColor Cyan
try {
    $categories = Invoke-RestMethod "http://localhost:8081/categories?page=0&size=10"
    Write-Host "   Total Elements: $($categories.totalElements)" -ForegroundColor Green
    Write-Host "   Total Pages: $($categories.totalPages)" -ForegroundColor Green
    Write-Host "   Categories in this page: $($categories.content.Count)" -ForegroundColor Green
    
    if ($categories.content.Count -gt 0) {
        Write-Host ""
        Write-Host "   First category:" -ForegroundColor Yellow
        $firstCat = $categories.content[0]
        Write-Host "     ID: $($firstCat.id)" -ForegroundColor White
        Write-Host "     Name: $($firstCat.name)" -ForegroundColor White
    }
} catch {
    Write-Host "   Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 4: Single Item
Write-Host "4. Get Single Item (ID 1):" -ForegroundColor Cyan
try {
    $item = Invoke-RestMethod "http://localhost:8081/items/1"
    Write-Host "   ID: $($item.id)" -ForegroundColor Green
    Write-Host "   Name: $($item.name)" -ForegroundColor Green
    Write-Host "   Description: $($item.description)" -ForegroundColor Green
    Write-Host "   Price: $($item.price)" -ForegroundColor Green
    Write-Host "   Quantity: $($item.quantity)" -ForegroundColor Green
} catch {
    Write-Host "   Error: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "All Tests Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access the API at:" -ForegroundColor Cyan
Write-Host "  http://localhost:8081/items?page=0&size=10" -ForegroundColor White
Write-Host ""
Write-Host "Access Grafana at:" -ForegroundColor Cyan
Write-Host "  http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host ""
Write-Host "Access Prometheus at:" -ForegroundColor Cyan
Write-Host "  http://localhost:9090" -ForegroundColor White
Write-Host ""
