@echo off
REM REST API Performance Test Runner
REM This script helps run performance tests for all variants

echo ========================================
echo REST API Performance Test Runner
echo ========================================
echo.

:menu
echo Select an option:
echo 1. Setup Database (Docker)
echo 2. Generate Test Data
echo 3. Build All Variants
echo 4. Test Variant A (Jersey - Port 8081)
echo 5. Test Variant C (Spring - Port 8082)
echo 6. Test Variant D (Spring Data - Port 8083)
echo 7. Start Monitoring (Prometheus + Grafana)
echo 8. Generate JMeter Test Plans
echo 9. Exit
echo.

set /p choice="Enter your choice (1-9): "

if "%choice%"=="1" goto setup_db
if "%choice%"=="2" goto generate_data
if "%choice%"=="3" goto build_all
if "%choice%"=="4" goto test_jersey
if "%choice%"=="5" goto test_spring
if "%choice%"=="6" goto test_springdata
if "%choice%"=="7" goto start_monitoring
if "%choice%"=="8" goto generate_jmeter
if "%choice%"=="9" goto end
goto menu

:setup_db
echo.
echo Starting PostgreSQL with Docker...
cd monitoring
docker-compose up -d postgres
echo Waiting for PostgreSQL to start...
timeout /t 10 /nobreak
echo PostgreSQL started!
cd ..
pause
goto menu

:generate_data
echo.
echo Generating test data...
cd database
echo Running schema.sql...
psql -h localhost -U perfuser -d rest_api_perf -f schema.sql
echo Running generate-data.sql...
psql -h localhost -U perfuser -d rest_api_perf -f generate-data.sql
echo Data generation complete!
cd ..
pause
goto menu

:build_all
echo.
echo Building all variants...
echo.
echo [1/4] Building common module...
cd common
call mvn clean install -DskipTests
cd ..
echo.
echo [2/4] Building Variant A (Jersey)...
cd variant-a-jersey
call mvn clean package -DskipTests
cd ..
echo.
echo [3/4] Building Variant C (Spring)...
cd variant-c-spring
call mvn clean package -DskipTests
cd ..
echo.
echo [4/4] Building Variant D (Spring Data)...
cd variant-d-spring-data
call mvn clean package -DskipTests
cd ..
echo.
echo All variants built successfully!
pause
goto menu

:test_jersey
echo.
echo ========================================
echo Testing Variant A: Jersey (Port 8081)
echo ========================================
echo.
echo Starting Jersey variant...
echo Press Ctrl+C to stop the service after tests complete
echo.
cd variant-a-jersey
start "Jersey Service" cmd /k "mvn spring-boot:run"
timeout /t 30 /nobreak
echo.
echo Running JMeter tests...
cd ..\jmeter
echo.
echo [1/4] Scenario 1: READ Heavy...
call jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8081 -l ..\results\s1-jersey.jtl -e -o ..\results\s1-jersey-report
echo Waiting 2 minutes before next test...
timeout /t 120 /nobreak
echo.
echo [2/4] Scenario 2: JOIN Filter...
call jmeter -n -t scenario2-join-filter.jmx -Jhost=localhost -Jport=8081 -l ..\results\s2-jersey.jtl -e -o ..\results\s2-jersey-report
echo Waiting 2 minutes before next test...
timeout /t 120 /nobreak
echo.
echo [3/4] Scenario 3: Mixed Operations...
call jmeter -n -t scenario3-mixed.jmx -Jhost=localhost -Jport=8081 -l ..\results\s3-jersey.jtl -e -o ..\results\s3-jersey-report
echo Waiting 2 minutes before next test...
timeout /t 120 /nobreak
echo.
echo [4/4] Scenario 4: Heavy Body...
call jmeter -n -t scenario4-heavy-body.jmx -Jhost=localhost -Jport=8081 -l ..\results\s4-jersey.jtl -e -o ..\results\s4-jersey-report
echo.
echo All tests completed for Jersey!
echo Please stop the Jersey service window.
cd ..
pause
goto menu

:test_spring
echo.
echo ========================================
echo Testing Variant C: Spring (Port 8082)
echo ========================================
echo.
echo Starting Spring variant...
echo Press Ctrl+C to stop the service after tests complete
echo.
cd variant-c-spring
start "Spring Service" cmd /k "mvn spring-boot:run"
timeout /t 30 /nobreak
echo.
echo Running JMeter tests...
cd ..\jmeter
echo.
echo [1/4] Scenario 1: READ Heavy...
call jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8082 -l ..\results\s1-spring.jtl -e -o ..\results\s1-spring-report
echo Waiting 2 minutes before next test...
timeout /t 120 /nobreak
echo.
echo [2/4] Scenario 2: JOIN Filter...
call jmeter -n -t scenario2-join-filter.jmx -Jhost=localhost -Jport=8082 -l ..\results\s2-spring.jtl -e -o ..\results\s2-spring-report
echo Waiting 2 minutes before next test...
timeout /t 120 /nobreak
echo.
echo [3/4] Scenario 3: Mixed Operations...
call jmeter -n -t scenario3-mixed.jmx -Jhost=localhost -Jport=8082 -l ..\results\s3-spring.jtl -e -o ..\results\s3-spring-report
echo Waiting 2 minutes before next test...
timeout /t 120 /nobreak
echo.
echo [4/4] Scenario 4: Heavy Body...
call jmeter -n -t scenario4-heavy-body.jmx -Jhost=localhost -Jport=8082 -l ..\results\s4-spring.jtl -e -o ..\results\s4-spring-report
echo.
echo All tests completed for Spring!
echo Please stop the Spring service window.
cd ..
pause
goto menu

:test_springdata
echo.
echo ========================================
echo Testing Variant D: Spring Data (Port 8083)
echo ========================================
echo.
echo Starting Spring Data variant...
echo Press Ctrl+C to stop the service after tests complete
echo.
cd variant-d-spring-data
start "Spring Data Service" cmd /k "mvn spring-boot:run"
timeout /t 30 /nobreak
echo.
echo Running JMeter tests...
cd ..\jmeter
echo.
echo [1/4] Scenario 1: READ Heavy...
call jmeter -n -t scenario1-read-heavy.jmx -Jhost=localhost -Jport=8083 -l ..\results\s1-springdata.jtl -e -o ..\results\s1-springdata-report
echo Waiting 2 minutes before next test...
timeout /t 120 /nobreak
echo.
echo [2/4] Scenario 2: JOIN Filter...
call jmeter -n -t scenario2-join-filter.jmx -Jhost=localhost -Jport=8083 -l ..\results\s2-springdata.jtl -e -o ..\results\s2-springdata-report
echo Waiting 2 minutes before next test...
timeout /t 120 /nobreak
echo.
echo [3/4] Scenario 3: Mixed Operations...
call jmeter -n -t scenario3-mixed.jmx -Jhost=localhost -Jport=8083 -l ..\results\s3-springdata.jtl -e -o ..\results\s3-springdata-report
echo Waiting 2 minutes before next test...
timeout /t 120 /nobreak
echo.
echo [4/4] Scenario 4: Heavy Body...
call jmeter -n -t scenario4-heavy-body.jmx -Jhost=localhost -Jport=8083 -l ..\results\s4-springdata.jtl -e -o ..\results\s4-springdata-report
echo.
echo All tests completed for Spring Data!
echo Please stop the Spring Data service window.
cd ..
pause
goto menu

:start_monitoring
echo.
echo Starting monitoring stack...
cd monitoring
docker-compose up -d prometheus grafana
echo.
echo Monitoring started!
echo Prometheus: http://localhost:9090
echo Grafana: http://localhost:3000 (admin/admin)
cd ..
pause
goto menu

:generate_jmeter
echo.
echo Generating JMeter test plans...
cd jmeter
python generate-jmx.py
echo.
echo JMeter test plans generated!
cd ..
pause
goto menu

:end
echo.
echo Exiting...
exit /b 0
