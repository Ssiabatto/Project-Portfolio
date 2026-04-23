@echo off
REM AgroWeb - API Productos + Infraestructura

title API Productos + Infraestructura
echo =======================================
echo  🥕 API PRODUCTOS + INFRAESTRUCTURA
echo =======================================
echo.

echo [1/3] Inicializando y activando entorno conda 'agroweb'...
call conda init cmd.exe >nul 2>&1
call conda activate agroweb
if errorlevel 1 (
    echo ❌ Entorno 'agroweb' no encontrado
    echo 💡 Ejecuta: conda create -n agroweb python=3.9 -y
    echo 💡 Luego: conda activate agroweb ^&^& pip install -r requirements.txt
    pause
    exit /b 1
)
echo ✅ Entorno conda activado

echo.
echo [2/3] Iniciando infraestructura (Cassandra solamente)...
cd "..\Serv_GestionProductos"
docker-compose up -d
if errorlevel 1 (
    echo ❌ Error iniciando infraestructura
    echo 💡 Verifica que Docker esté ejecutándose
    pause
    exit /b 1
)
echo ✅ Infraestructura iniciada
echo   ⏳ Esperando que Cassandra esté listo (30s)...
timeout /t 30 /nobreak >nul

echo.
echo [3/3] Iniciando API Productos (puerto 5000)...
echo   🌐 API Docs: http://localhost:5000/apidocs
echo   📊 Métricas: http://localhost:5000/metrics
echo   📊 Prometheus: Usar start_prometheus_native.cmd (observability/)
echo.
python app.py

pause
