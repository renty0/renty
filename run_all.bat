@echo off
echo ===================================================
echo   Starting Rently Development Environment Services
echo ===================================================

echo Starting PostgreSQL Database (via Docker Compose)...
docker compose up -d

echo.
echo Starting Python FastAPI Recommendation API (Port 8000)...
start "FastAPI Recommendation API" cmd /k "cd renty_recommendation && .venv\Scripts\activate && uvicorn src.recommendation_api:app --port 8000"

echo.
echo Starting C# Web API (Port 5106)...
start "Rently C# Web API" cmd /k "cd Client\API\Web && dotnet run"

echo.
echo Starting Angular Frontend (Port 4200)...
start "Rently Angular Frontend" cmd /k "cd Client\Web && npm run start"

echo.
echo Starting Angular Support (Port 4202)...
start "Rently Angular Support" cmd /k "cd Client\Support && npm run start -- --port 4202"

echo.
echo Starting Angular Admin (Port 4203)...
start "Rently Angular Admin" cmd /k "cd Client\Admin && npm run start -- --port 4203"

echo.
echo ===================================================
echo   All services have been launched in separate windows.
echo   - PostgreSQL: Port 5433 (forwarded to 5432)
echo   - Python API: Port 8000 (http://localhost:8000)
echo   - C# Web API: Port 5106 (http://localhost:5106)
echo   - Angular UI: Port 4200 (http://localhost:4200)
echo   - Angular Support: Port 4202 (http://localhost:4202)
echo   - Angular Admin: Port 4203 (http://localhost:4203)
echo ===================================================
pause
