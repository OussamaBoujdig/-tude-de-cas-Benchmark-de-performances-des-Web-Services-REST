@echo off
REM Quick start script for Docker

echo ========================================
echo REST API Performance - Docker Launcher
echo ========================================
echo.

:menu
echo Select a variant to start:
echo.
echo 1. Jersey (Variant A) + Monitoring
echo 2. Spring (Variant C) + Monitoring
echo 3. Spring Data (Variant D) + Monitoring
echo 4. All Variants + Monitoring
echo 5. Show Status
echo 6. Stop All
echo 7. Exit
echo.

set /p choice="Enter your choice (1-7): "

if "%choice%"=="1" goto jersey
if "%choice%"=="2" goto spring
if "%choice%"=="3" goto springdata
if "%choice%"=="4" goto all
if "%choice%"=="5" goto status
if "%choice%"=="6" goto stop
if "%choice%"=="7" goto end
goto menu

:jersey
echo.
echo Starting Jersey (Variant A) with Monitoring...
docker-compose --profile jersey --profile monitoring up -d
echo.
echo Waiting for services to start...
timeout /t 30 /nobreak
echo.
echo Jersey is running!
echo   API: http://localhost:8081/items?page=0^&size=10
echo   Health: http://localhost:8081/actuator/health
echo   Prometheus: http://localhost:9090
echo   Grafana: http://localhost:3000 (admin/admin)
echo.
pause
goto menu

:spring
echo.
echo Starting Spring (Variant C) with Monitoring...
docker-compose --profile spring --profile monitoring up -d
echo.
echo Waiting for services to start...
timeout /t 30 /nobreak
echo.
echo Spring is running!
echo   API: http://localhost:8082/items?page=0^&size=10
echo   Health: http://localhost:8082/actuator/health
echo   Prometheus: http://localhost:9090
echo   Grafana: http://localhost:3000 (admin/admin)
echo.
pause
goto menu

:springdata
echo.
echo Starting Spring Data (Variant D) with Monitoring...
docker-compose --profile springdata --profile monitoring up -d
echo.
echo Waiting for services to start...
timeout /t 30 /nobreak
echo.
echo Spring Data is running!
echo   API: http://localhost:8083/items?page=0^&size=10
echo   Health: http://localhost:8083/actuator/health
echo   Prometheus: http://localhost:9090
echo   Grafana: http://localhost:3000 (admin/admin)
echo.
pause
goto menu

:all
echo.
echo Starting ALL Variants with Monitoring...
echo WARNING: This will use significant resources!
docker-compose --profile all up -d
echo.
echo Waiting for services to start...
timeout /t 60 /nobreak
echo.
echo All services are running!
echo   Jersey: http://localhost:8081
echo   Spring: http://localhost:8082
echo   Spring Data: http://localhost:8083
echo   Prometheus: http://localhost:9090
echo   Grafana: http://localhost:3000
echo.
pause
goto menu

:status
echo.
echo Docker Services Status:
echo.
docker-compose ps
echo.
pause
goto menu

:stop
echo.
echo Stopping all services...
docker-compose down
echo.
echo All services stopped!
echo.
pause
goto menu

:end
echo.
echo Goodbye!
exit /b 0
