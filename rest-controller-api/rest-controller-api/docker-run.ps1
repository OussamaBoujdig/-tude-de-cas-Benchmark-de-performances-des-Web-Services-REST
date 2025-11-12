# Docker Run Script for REST API Performance Testing
# PowerShell script to easily manage Docker containers

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("jersey", "spring", "springdata", "all", "monitoring", "stop", "clean", "status")]
    [string]$Action = "menu"
)

function Show-Menu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  REST API Performance - Docker Manager" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Start Jersey (Variant A) + Monitoring" -ForegroundColor Green
    Write-Host "2. Start Spring (Variant C) + Monitoring" -ForegroundColor Green
    Write-Host "3. Start Spring Data (Variant D) + Monitoring" -ForegroundColor Green
    Write-Host "4. Start ALL Variants + Monitoring" -ForegroundColor Yellow
    Write-Host "5. Start Monitoring Only" -ForegroundColor Magenta
    Write-Host "6. Show Status" -ForegroundColor White
    Write-Host "7. Stop All Services" -ForegroundColor Red
    Write-Host "8. Clean Everything (Remove volumes)" -ForegroundColor Red
    Write-Host "9. Exit" -ForegroundColor Gray
    Write-Host ""
}

function Start-Jersey {
    Write-Host "Starting Jersey (Variant A) with Monitoring..." -ForegroundColor Green
    docker-compose --profile jersey --profile monitoring up -d
    Wait-ForService -Port 8081 -Name "Jersey"
    Show-ServiceInfo -Variant "Jersey" -Port 8081
}

function Start-Spring {
    Write-Host "Starting Spring (Variant C) with Monitoring..." -ForegroundColor Green
    docker-compose --profile spring --profile monitoring up -d
    Wait-ForService -Port 8082 -Name "Spring"
    Show-ServiceInfo -Variant "Spring" -Port 8082
}

function Start-SpringData {
    Write-Host "Starting Spring Data (Variant D) with Monitoring..." -ForegroundColor Green
    docker-compose --profile springdata --profile monitoring up -d
    Wait-ForService -Port 8083 -Name "Spring Data"
    Show-ServiceInfo -Variant "Spring Data" -Port 8083
}

function Start-All {
    Write-Host "Starting ALL Variants with Monitoring..." -ForegroundColor Yellow
    Write-Host "WARNING: This will use significant resources!" -ForegroundColor Red
    docker-compose --profile all up -d
    Start-Sleep -Seconds 60
    Show-AllServices
}

function Start-Monitoring {
    Write-Host "Starting Monitoring Stack (Prometheus + Grafana)..." -ForegroundColor Magenta
    docker-compose --profile monitoring up -d
    Start-Sleep -Seconds 10
    Write-Host ""
    Write-Host "Monitoring started!" -ForegroundColor Green
    Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor Cyan
    Write-Host "  Grafana: http://localhost:3000 (admin/admin)" -ForegroundColor Cyan
}

function Wait-ForService {
    param(
        [int]$Port,
        [string]$Name
    )
    
    Write-Host "Waiting for $Name to be ready..." -ForegroundColor Yellow
    $maxAttempts = 30
    $attempt = 0
    
    while ($attempt -lt $maxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$Port/actuator/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Host "$Name is ready!" -ForegroundColor Green
                return $true
            }
        } catch {
            # Service not ready yet
        }
        
        $attempt++
        Write-Host "  Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
    }
    
    Write-Host "WARNING: $Name may not be fully ready" -ForegroundColor Red
    return $false
}

function Show-ServiceInfo {
    param(
        [string]$Variant,
        [int]$Port
    )
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "$Variant is running!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "API Endpoints:" -ForegroundColor Cyan
    Write-Host "  Health: http://localhost:$Port/actuator/health" -ForegroundColor White
    Write-Host "  Items: http://localhost:$Port/items?page=0&size=10" -ForegroundColor White
    Write-Host "  Categories: http://localhost:$Port/categories?page=0&size=10" -ForegroundColor White
    Write-Host ""
    Write-Host "Monitoring:" -ForegroundColor Cyan
    Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
    Write-Host "  Grafana: http://localhost:3000 (admin/admin)" -ForegroundColor White
    Write-Host ""
    Write-Host "Test with curl:" -ForegroundColor Yellow
    Write-Host "  curl http://localhost:$Port/items?page=0&size=10" -ForegroundColor Gray
    Write-Host ""
}

function Show-AllServices {
    Write-Host ""
    Write-Host "All services started!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Variants:" -ForegroundColor Cyan
    Write-Host "  Jersey: http://localhost:8081" -ForegroundColor White
    Write-Host "  Spring: http://localhost:8082" -ForegroundColor White
    Write-Host "  Spring Data: http://localhost:8083" -ForegroundColor White
    Write-Host ""
    Write-Host "Monitoring:" -ForegroundColor Cyan
    Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
    Write-Host "  Grafana: http://localhost:3000" -ForegroundColor White
    Write-Host ""
}

function Show-Status {
    Write-Host "Docker Services Status:" -ForegroundColor Cyan
    Write-Host ""
    docker-compose ps
    Write-Host ""
    
    Write-Host "Testing endpoints..." -ForegroundColor Yellow
    
    # Test each port
    $ports = @(
        @{Name="PostgreSQL"; Port=5432},
        @{Name="Jersey"; Port=8081},
        @{Name="Spring"; Port=8082},
        @{Name="Spring Data"; Port=8083},
        @{Name="Prometheus"; Port=9090},
        @{Name="Grafana"; Port=3000}
    )
    
    foreach ($service in $ports) {
        $result = Test-NetConnection -ComputerName localhost -Port $service.Port -WarningAction SilentlyContinue -InformationLevel Quiet
        if ($result) {
            Write-Host "  ✓ $($service.Name) (Port $($service.Port)): " -NoNewline -ForegroundColor Green
            Write-Host "RUNNING" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $($service.Name) (Port $($service.Port)): " -NoNewline -ForegroundColor Red
            Write-Host "STOPPED" -ForegroundColor Red
        }
    }
    Write-Host ""
}

function Stop-All {
    Write-Host "Stopping all services..." -ForegroundColor Red
    docker-compose down
    Write-Host "All services stopped!" -ForegroundColor Green
}

function Clean-All {
    Write-Host "WARNING: This will remove all containers, volumes, and data!" -ForegroundColor Red
    $confirm = Read-Host "Are you sure? (yes/no)"
    
    if ($confirm -eq "yes") {
        Write-Host "Cleaning everything..." -ForegroundColor Red
        docker-compose down -v
        Write-Host "Cleanup complete!" -ForegroundColor Green
    } else {
        Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    }
}

# Main execution
if ($Action -ne "menu") {
    switch ($Action) {
        "jersey" { Start-Jersey }
        "spring" { Start-Spring }
        "springdata" { Start-SpringData }
        "all" { Start-All }
        "monitoring" { Start-Monitoring }
        "status" { Show-Status }
        "stop" { Stop-All }
        "clean" { Clean-All }
    }
    exit
}

# Interactive menu
while ($true) {
    Show-Menu
    $choice = Read-Host "Select an option (1-9)"
    
    switch ($choice) {
        "1" { Start-Jersey; pause }
        "2" { Start-Spring; pause }
        "3" { Start-SpringData; pause }
        "4" { Start-All; pause }
        "5" { Start-Monitoring; pause }
        "6" { Show-Status; pause }
        "7" { Stop-All; pause }
        "8" { Clean-All; pause }
        "9" { 
            Write-Host "Goodbye!" -ForegroundColor Cyan
            exit 
        }
        default { 
            Write-Host "Invalid option!" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}
