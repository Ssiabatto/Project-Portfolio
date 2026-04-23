@echo off
REM AgroWeb - Detiene todos los servicios: Frontend, APIs, infraestructura completa

title Deteniendo AgroWeb
echo ===============================
echo  DETENIENDO SISTEMA COMPLETO
echo ===============================
echo.

echo [1/4] Deteniendo Frontend...
taskkill /f /im node.exe >nul 2>&1
if not errorlevel 1 (
    echo ✓ Frontend detenido
) else (
    echo - Frontend no estaba ejecutándose
)

echo.
echo [2/4] Deteniendo APIs Python...
taskkill /f /im python.exe >nul 2>&1
if not errorlevel 1 (
    echo ✓ APIs detenidas
) else (
    echo - APIs no estaban ejecutándose
)

echo.
echo [3/4] Deteniendo infraestructura (Cassandra)...
cd "..\Serv_GestionProductos"
docker-compose down >nul 2>&1
if not errorlevel 1 (
    echo ✓ Infraestructura detenida (Cassandra)
) else (
    echo - Infraestructura no estaba ejecutándose
)
cd "..\WorkspaceSetup"

echo.
echo [4/4] Liberando puertos...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5000') do taskkill /f /pid %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5001') do taskkill /f /pid %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5173') do taskkill /f /pid %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :9090') do taskkill /f /pid %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001') do taskkill /f /pid %%a >nul 2>&1
echo ✓ Puertos liberados (5000, 5001, 5173, 9090, 3001)

echo.
echo ===============================
echo  ✅ SISTEMA COMPLETAMENTE DETENIDO
echo ===============================
echo.
echo ✓ Frontend detenido
echo ✓ APIs detenidas  
echo ✓ Infraestructura detenida (Cassandra + Observabilidad)
echo ✓ Puertos liberados
echo.
echo Sistema limpio. Ejecuta run_all.bat cuando necesites.
pause
