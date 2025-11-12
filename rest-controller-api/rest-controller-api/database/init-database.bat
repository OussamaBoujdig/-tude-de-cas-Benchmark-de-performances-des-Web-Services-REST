@echo off
REM Database initialization script for Windows

echo ========================================
echo Database Initialization
echo ========================================
echo.

echo Creating schema...
psql -h localhost -U perfuser -d rest_api_perf -f schema.sql

if %ERRORLEVEL% NEQ 0 (
    echo Error creating schema!
    pause
    exit /b 1
)

echo.
echo Schema created successfully!
echo.
echo Generating test data (2000 categories + 100000 items)...
echo This may take 30-60 seconds...
echo.

psql -h localhost -U perfuser -d rest_api_perf -f generate-data.sql

if %ERRORLEVEL% NEQ 0 (
    echo Error generating data!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Database initialization complete!
echo ========================================
echo.
echo Verifying data...
psql -h localhost -U perfuser -d rest_api_perf -c "SELECT 'Categories: ' || COUNT(*) FROM category; SELECT 'Items: ' || COUNT(*) FROM item;"

pause
