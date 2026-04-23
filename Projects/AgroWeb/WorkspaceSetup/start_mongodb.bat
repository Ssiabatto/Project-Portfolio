@echo off
REM AgroWeb - MongoDB Management

title AgroWeb - MongoDB Manager  
echo ===================================
echo  🍃 MONGODB MANAGER
echo ===================================
echo.

echo [1/3] Verificando MongoDB...
mongod --version >nul 2>&1
if errorlevel 1 (
    echo ❌ MongoDB no encontrado en PATH
    echo 💡 Soluciones:
    echo   1. Instala MongoDB Community Server
    echo   2. Agrega MongoDB bin al PATH del sistema
    echo   3. Reinicia terminal después de instalar
    pause
    exit /b 1
)
echo ✅ MongoDB encontrado

echo.
echo [2/3] Verificando conexión a MongoDB...
python -c "from pymongo import MongoClient; client = MongoClient('localhost', 27017, serverSelectionTimeoutMS=3000); client.admin.command('ping'); print('✅ MongoDB ya está ejecutándose y conectado'); client.close()" 2>nul
if not errorlevel 1 (
    echo ✅ MongoDB detectado ejecutándose (MongoDB Compass, servicio o manual)
    goto :mongodb_ready
)

echo 🔍 MongoDB no responde, verificando cómo iniciarlo...
echo.
echo [2b/3] Verificando estado del servicio...
sc query MongoDB >nul 2>&1
if errorlevel 1 (
    echo ⚠️ Servicio MongoDB no está instalado como servicio de Windows
    echo 💡 Iniciando MongoDB manualmente...
    echo.
    echo Creando directorio de datos...
    if not exist "C:\data\db" mkdir "C:\data\db"
    echo 🚀 Iniciando MongoDB en puerto 27017...
    echo ⚠️ MANTÉN esta ventana abierta mientras uses el sistema
    echo.
    mongod --dbpath "C:\data\db"
) else (
    echo ✅ Servicio MongoDB encontrado
    
    REM Check if service is running
    sc query MongoDB | find "RUNNING" >nul 2>&1
    if errorlevel 1 (
        echo 🔄 Iniciando servicio MongoDB...
        net start MongoDB
        if errorlevel 1 (
            echo ❌ Error iniciando servicio MongoDB
            echo 💡 Ejecutar como administrador o iniciar manualmente
            pause
            exit /b 1
        )
        echo ✅ Servicio MongoDB iniciado
    ) else (
        echo ✅ Servicio MongoDB ya está ejecutándose
    )
)

:mongodb_ready

echo.
echo [3/3] Verificación final...
timeout /t 2 /nobreak >nul
python -c "from pymongo import MongoClient; client = MongoClient('localhost', 27017, serverSelectionTimeoutMS=5000); client.admin.command('ping'); print('✅ Conexión final verificada'); client.close()" 2>nul
if errorlevel 1 (
    echo ❌ No se pudo conectar a MongoDB después del inicio
    echo 💡 Verifica que MongoDB esté ejecutándose en puerto 27017
    pause
    exit /b 1
)

echo.
echo ===================================
echo  ✅ MONGODB LISTO
echo ===================================
echo.
echo 🌐 MongoDB ejecutándose en: localhost:27017
echo 📊 Base de datos para usuarios: Serv_Usuarios
echo 📋 Colección: Usuarios
echo 🎛️ Puede estar ejecutándose via:
echo   - MongoDB Compass
echo   - Servicio de Windows  
echo   - Proceso manual
echo.
echo 💡 Comandos útiles:
echo   - Estado: check_status.bat
echo   - Poblar datos: clear_and_populate.bat
echo   - MongoDB Compass: mongodb://localhost:27017
echo.

if "%1"=="auto" (
    echo 🚀 Modo automático - continuando...
    timeout /t 2 /nobreak >nul
) else (
    pause
)
