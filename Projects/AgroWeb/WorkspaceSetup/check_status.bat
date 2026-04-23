@echo off
REM AgroWeb - Verificación rápida del estado de serviecho 🔧 Infraestructura:
echo   🍃 MongoDB (usuarios): Verificado arriba
echo   🗄️  Cassandra (productos): Puerto 9042
echo   📊 Prometheus (nativo): Puerto 9090 - start_prometheus_native.cmd
echo.
echo 🌐 APIs:
echo   🛒 Productos: Puerto 5000
echo   👥 Usuarios: Puerto 5001  
echo.
echo 🖥️ Frontend:
echo   ⚛️ React App: Puerto 5173
echo.
echo 💡 Para iniciar servicios faltantes:
echo   - Todo: run_all.bat
echo   - Individual: start_[servicio].bat
echo   - Setup inicial: setup.bat
echo   - Prometheus: Serv_GestionProductos/observability/start_prometheus_native.cmd
echo     (Configurar ruta en línea 15 si no está en C:\prometheus\)
pauseficación de Servicios
echo ===================================
echo  🔍 VERIFICANDO SERVICIOS
echo ===================================
echo.

echo 🔍 Verificando servicios...

REM Verificar MongoDB (requerido para usuarios)
echo   🍃 MongoDB (Puerto 27017):
python -c "from pymongo import MongoClient; client = MongoClient('localhost', 27017, serverSelectionTimeoutMS=2000); client.admin.command('ping'); print('     ✅ MongoDB: Funcionando (Compass/Servicio/Manual)'); client.close()" 2>nul
if errorlevel 1 (
    echo      🔶 MongoDB: No responde - Requerido para servicio de usuarios
    echo      💡 Iniciar con: start_mongodb.bat o MongoDB Compass
)

REM Verificar Prometheus
curl -s http://localhost:9090 >nul 2>&1
if errorlevel 1 (
    echo   🔶 Prometheus: No responde (puerto 9090)
) else (
    echo   ✅ Prometheus: Funcionando (http://localhost:9090)
)

REM Verificar Prometheus (nativo - puede no estar ejecutándose)
curl -s http://localhost:9090 >nul 2>&1
if errorlevel 1 (
    echo   � Prometheus: No ejecutándose (puerto 9090) - Usar start_prometheus_native.cmd
) else (
    echo   ✅ Prometheus: Funcionando (http://localhost:9090)
)

REM Verificar API Productos
curl -s http://localhost:5000/health >nul 2>&1
if errorlevel 1 (
    echo   🔶 API Productos: No responde (puerto 5000)
) else (
    echo   ✅ API Productos: Funcionando (http://localhost:5000/apidocs)
)

REM Verificar API Usuarios
echo   👥 API Usuarios (Puerto 5001):
curl -s http://localhost:5001/swagger >nul 2>&1
if errorlevel 1 (
    echo      🔶 API Usuarios: No responde - Verifica MongoDB y dependencias
) else (
    echo      ✅ API Usuarios: Funcionando (http://localhost:5001/swagger)
)

REM Verificar Frontend
curl -s http://localhost:5173 >nul 2>&1
if errorlevel 1 (
    echo   🔶 Frontend: No responde (puerto 5173)
) else (
    echo   ✅ Frontend: Funcionando (http://localhost:5173)
)

echo.
echo ================================
echo  📊 RESUMEN DE ESTADO
echo ================================
echo.
echo 🔧 Infraestructura:
echo   🍃 MongoDB (usuarios): Verificado arriba
echo   🗄️  Cassandra (productos): Puerto 9042
echo   � Prometheus: Puerto 9090  
echo   📊 Prometheus (nativo): Puerto 9090 - Ver start_prometheus_native.cmd
echo.
echo 🌐 APIs:
echo   🛒 Productos: Puerto 5000
echo   👥 Usuarios: Puerto 5001  
echo.
echo 🖥️ Frontend:
echo   ⚛️ React App: Puerto 5173
echo.
echo �💡 Para iniciar servicios faltantes:
echo   - Todo: run_all.bat
echo   - Individual: start_[servicio].bat
echo   - Setup inicial: setup.bat
pause
