@echo off
REM AgroWeb - Frontend React con Vite

title AgroWeb - Frontend
echo ===================================
echo  🌐 FRONTEND REACT (Puerto 5173)
echo ===================================
echo.

echo [1/2] Verificando dependencias...
cd "..\FrontEnd"

if not exist node_modules (
    echo   📦 Instalando dependencias npm...
    npm install
    if errorlevel 1 (
        echo   ❌ Error instalando dependencias
        echo   💡 Verifica que Node.js esté instalado
        pause
        exit /b 1
    )
)
echo   ✅ Dependencias npm listas

echo.
echo [2/2] Iniciando servidor de desarrollo...
echo   🚀 Ejecutando Vite en puerto 5173
echo   🌐 La app se abrirá en: http://localhost:5173
npm run dev

if errorlevel 1 (
    echo.
    echo ❌ Error iniciando Frontend
    echo 💡 Posibles soluciones:
    echo   1. Verifica que puerto 5173 esté libre
    echo   2. Ejecuta: npm install
    echo   3. Verifica que las APIs estén ejecutándose
    pause
)
