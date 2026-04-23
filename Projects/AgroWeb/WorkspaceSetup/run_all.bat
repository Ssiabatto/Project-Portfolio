@echo off
REM AgroWeb - Ejecutar sistema completo

title AgroWeb - Sistema Completo
echo ===============================
echo  🚀 INICIANDO SISTEMA COMPLETO
echo ===============================
echo.

REM Check if conda is available
where conda >nul 2>nul
if errorlevel 1 (
    echo ❌ CONDA NO DETECTADO
    echo.
    echo 💡 Para el sistema COMPLETO:
    echo    1. Instala Anaconda/Miniconda
    echo    2. Abre 'Anaconda Prompt'
    echo    3. cd "d:\UN\2025-1\Ingesoft 2\Proyecto\WorkspaceSetup"
    echo    4. run_all.bat
    echo.
    echo 🔄 ¿Continuar sin API Productos? (s/n):
    set /p choice="> "
    if /i "!choice!" NEQ "s" (
        echo ✅ Instala Anaconda para funcionalidad completa
        pause
        exit /b 1
    )
    set SKIP_PRODUCTOS=1
) else (
    echo ✅ Conda detectado - Iniciando sistema completo
    set SKIP_PRODUCTOS=0
)

echo.
if %SKIP_PRODUCTOS%==0 (
    echo [1/3] Iniciando API Productos + Infraestructura...
    start "API Productos + Infraestructura" cmd /k "start_productos.bat"
    echo   ⏳ Esperando infraestructura (60s)...
    timeout /t 60 /nobreak >nul
) else (
    echo [1/3] ⚠️ Saltando API Productos (requiere Anaconda)
)

echo [2/3] Iniciando API Usuarios...
echo   🍃 Verificando MongoDB...
python -c "from pymongo import MongoClient; client = MongoClient('localhost', 27017, serverSelectionTimeoutMS=2000); client.admin.command('ping'); print('   ✅ MongoDB disponible'); client.close()" 2>nul
if errorlevel 1 (
    echo   ⚠️ MongoDB no disponible - API Usuarios puede fallar
    echo   💡 Inicia MongoDB service o ejecuta: mongod
    echo   🔄 ¿Continuar de todos modos? (s/n):
    set /p choice="> "
    if /i "!choice!" NEQ "s" (
        echo   ✅ Inicia MongoDB y vuelve a intentar
        pause
        exit /b 1
    )
)
start "API Usuarios" cmd /k "start_usuarios.bat"
echo   ⏳ Esperando API Usuarios (10s)...
timeout /t 10 /nobreak >nul

echo [3/3] Iniciando Frontend...
start "Frontend" cmd /k "start_frontend.bat"
echo   ⏳ Esperando Frontend (15s)...
timeout /t 15 /nobreak >nul

echo.
echo ===============================
echo  ✅ SERVICIOS INICIADOS
echo ===============================
echo.

if %SKIP_PRODUCTOS%==0 (
    echo 🌐 URLs principales:
    echo   - App Principal: http://localhost:5173
    echo   - API Productos: http://localhost:5000/apidocs
    echo   - API Usuarios:  http://localhost:5001/swagger
    echo   - Grafana:       http://localhost:3001 (admin/agroweb2025)
    echo   - Prometheus:    http://localhost:9090
) else (
    echo 🌐 URLs disponibles (modo limitado):
    echo   - App Principal: http://localhost:5173
    echo   - API Usuarios:  http://localhost:5001/swagger
)

echo.
echo 💡 Para detener todo: stop_all.bat
echo 💡 Para verificar estado: check_status.bat
echo 💡 Para poblar datos: clear_and_populate.bat

REM Open the application
timeout /t 3 /nobreak >nul
start http://localhost:5173

pause
