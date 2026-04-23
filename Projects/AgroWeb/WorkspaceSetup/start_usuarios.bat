@echo off
REM AgroWeb - Servicio de Usuarios

title AgroWeb - API Usuarios  
echo ===================================
echo  👥 API USUARIOS (Puerto 5001)
echo ===================================
echo.

echo [1/2] Verificando dependencias...
cd "..\Serv_Usuarios"

REM Verificar MongoDB
echo   🍃 Verificando MongoDB...
mongod --version >nul 2>&1
if errorlevel 1 (
    echo   ❌ MongoDB no encontrado
    echo   💡 Instala MongoDB Community Server
    echo   💡 Asegúrate de que mongod esté en PATH
    pause
    exit /b 1
)

REM Verificar conexión a MongoDB
echo   🔌 Verificando conexión a MongoDB...
python -c "from pymongo import MongoClient; client = MongoClient('localhost', 27017); client.admin.command('ping'); print('✅ MongoDB conectado'); client.close()" 2>nul
if errorlevel 1 (
    echo   ⚠️ MongoDB no responde en puerto 27017
    echo   💡 Inicia MongoDB service o ejecuta: mongod
    echo   🔄 ¿Continuar de todos modos? (s/n):
    set /p choice="> "
    if /i "!choice!" NEQ "s" (
        echo   ✅ Inicia MongoDB y vuelve a intentar
        pause
        exit /b 1
    )
) else (
    echo   ✅ MongoDB conectado
)

REM Verificar dependencias Python
echo   📦 Verificando dependencias Python...
pip show flask >nul 2>&1
if errorlevel 1 (
    echo   📦 Instalando dependencias Flask...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo   ❌ Error instalando dependencias
        pause
        exit /b 1
    )
)
echo   ✅ Dependencias listas

echo.
echo [2/2] Iniciando API Usuarios...
echo   🚀 Ejecutando en puerto 5001
echo   🍃 Conectando a MongoDB (localhost:27017)
echo   📋 Base de datos: Serv_Usuarios
echo   📊 Swagger UI: http://localhost:5001/swagger
python app.py

if errorlevel 1 (
    echo.
    echo ❌ Error iniciando API Usuarios
    echo 💡 Posibles soluciones:
    echo   1. Verifica que puerto 5001 esté libre
    echo   2. Verifica que MongoDB esté ejecutándose
    echo   3. Ejecuta: pip install -r requirements.txt
    echo   4. Verifica la conexión: python -c "from pymongo import MongoClient; MongoClient('localhost', 27017).admin.command('ping')"
    pause
)
