@echo off
echo ===================================================
echo   Starting Renty Development Environment Services
echo ===================================================

echo Starting PostgreSQL Database (via Docker Compose)...
docker compose up -d

echo.
echo Starting Python FastAPI Recommendation API (Port 8000)...
start "FastAPI Recommendation API" cmd /k "cd renty_recommendation && .venv\Scripts\activate && uvicorn src.recommendation_api:app --port 8000"

echo.
echo Starting C# Web API (Port 5106)...
start "Rently C# Web API" cmd /k "cd Client\API\Web && set ASPNETCORE_ENVIRONMENT=Production && dotnet run --no-launch-profile"

echo.
echo Starting Angular Frontend (Port 4200)...
start "Rently Angular Frontend" cmd /k "cd Client\Web && npm run start -- --port 4200"

echo.
echo Starting Angular SuperAdmin Dashboard (Port 4201)...
start "Rently SuperAdmin Dashboard" cmd /k "cd Client\SuperAdmin && npm run start -- --port 4201"

echo.
echo Starting Angular Expert Dashboard (Port 4202)...
start "Rently Expert Dashboard" cmd /k "cd Client\Expert && npm run start -- --port 4202"

echo.
echo Starting Angular Support Dashboard (Port 4203)...
start "Rently Support Dashboard" cmd /k "cd Client\Support && npm run start -- --port 4203"

echo.
echo Starting Angular Admin Dashboard (Port 4204)...
start "Rently Admin Dashboard" cmd /k "cd Client\Admin && npm run start -- --port 4204"

echo.
echo ===================================================
echo   All services launched in separate windows:
echo   - Python API:          Port 8000 (http://localhost:8000)
echo   - C# Web API:          Port 5106 (http://localhost:5106)
echo   - Angular UI:          Port 4200 (http://localhost:4200)
echo   - SuperAdmin Dashboard:Port 4201 (http://localhost:4201)
echo   - Expert Dashboard:    Port 4202 (http://localhost:4202)
echo   - Support Dashboard:   Port 4203 (http://localhost:4203)
echo   - Admin Dashboard:     Port 4204 (http://localhost:4204)
echo ===================================================
pause
