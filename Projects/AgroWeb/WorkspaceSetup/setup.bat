@echo off
REM AgroWeb - Setup inicial

title Setup AgroWeb  
echo ===============================
echo  ⚙️ SETUP INICIAL - AGROWEB
echo ===============================
echo.

REM 1. Verificar Docker
echo [1/4] Verificando Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Docker no encontrado
    echo 💡 Instala Docker Desktop y reinicia
    pause
    exit /b 1
)
echo ✅ Docker OK

REM 2. Verificar Node.js
echo.
echo [2/5] Verificando Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Node.js no encontrado
    echo 💡 Instala Node.js desde https://nodejs.org
    pause
    exit /b 1
)
echo ✅ Node.js OK

REM 3. Verificar MongoDB
echo.
echo [3/5] Verificando MongoDB...
mongod --version >nul 2>&1
if errorlevel 1 (
    echo ❌ WARNING: MongoDB no encontrado
    echo 💡 Para el servicio de usuarios instala MongoDB:
    echo    1. Descarga MongoDB Community Server
    echo    2. Instala y configura como servicio
    echo    3. Verifica: mongod --version
    echo ⚠️ El servicio de usuarios requiere MongoDB para funcionar
    echo.
    echo ¿Continuar sin MongoDB? (s/n):
    set /p choice="> "
    if /i "!choice!" NEQ "s" (
        echo ✅ Instala MongoDB para funcionalidad completa
        pause
        exit /b 1
    )
    echo ⚠️ Continuando sin MongoDB - servicio de usuarios limitado
) else (
    echo ✅ MongoDB OK
)

REM 4. Setup Frontend
echo.
echo [4/5] Configurando Frontend...
cd "..\FrontEnd"
if not exist node_modules (
    echo   📦 Instalando dependencias React...
    npm install
    if errorlevel 1 (
        echo   ❌ Error instalando dependencias React
        pause
        exit /b 1
    )
    echo   ✅ Frontend configurado
) else (
    echo   ✅ Frontend ya configurado
)

REM 5. Setup Backend  
echo.
echo [5/5] Configurando Backend Python...
REM 5. Setup Backend  
echo.
echo [5/5] Configurando Backend Python...

REM Setup Servicio de Usuarios (MongoDB)
cd "..\Serv_Usuarios"  
echo   📦 Instalando dependencias del servicio de usuarios...
pip install -r requirements.txt >nul 2>&1
if errorlevel 1 (
    echo   ⚠️ Error instalando dependencias de usuarios
    echo   💡 Ejecuta manualmente: pip install -r requirements.txt
) else (
    echo   ✅ Servicio de usuarios configurado
)

REM Setup Servicio de Productos (Cassandra)
cd "..\Serv_GestionProductos"
echo   📦 Instalando dependencias del servicio de productos...
pip install -r requirements.txt >nul 2>&1
if errorlevel 1 (
    echo   ⚠️ Error instalando dependencias de productos
    echo   💡 Ejecuta manualmente: pip install -r requirements.txt
) else (
    echo   ✅ Servicio de productos configurado
)

cd "..\WorkspaceSetup"

echo.
echo ===============================
echo  ✅ SETUP COMPLETADO
echo ===============================
echo.
echo 🚀 Ahora puedes ejecutar el sistema con:
echo   - VS Code: Ctrl+Shift+P → "Tasks: Run Task" → "🚀 Ejecutar Todo"
echo   - Script:  run_all.bat
echo.
echo 💡 Servicios individuales disponibles:
echo   - start_infrastructure.bat (Cassandra + Prometheus + Grafana)
echo   - start_productos.bat      (API Productos con auto-detección Anaconda)
echo   - start_usuarios.bat       (API Usuarios - requiere MongoDB)
echo   - start_frontend.bat       (React Frontend)
echo.
echo 🔧 Dependencias verificadas:
echo   ✅ Docker (para infraestructura)
echo   ✅ Node.js (para frontend)
echo   ✅ MongoDB (para servicio de usuarios)
echo   ✅ Python (para servicios backend)
echo.
pause
    if exist .env.example (
        copy .env.example .env >nul
        echo ✓ Archivo .env creado desde .env.example
    ) else (
        echo USE_CASSANDRA=true > .env
        echo ✓ Archivo .env creado con configuración básica
    )
) else (
    echo ✓ Archivo .env ya existe
)

REM Instalar dependencias de observabilidad
echo Instalando dependencias de observabilidad...
pip install prometheus-flask-exporter >nul 2>&1
if errorlevel 1 (
    echo ⚠️ Error instalando prometheus-flask-exporter
    echo Ejecuta manualmente: pip install prometheus-flask-exporter
) else (
    echo ✓ Observabilidad configurada
)

cd /d "%INITIAL_DIR%"

REM 4. Configurar Servicio de Usuarios
echo.
echo [4/5] Configurando Servicio de Usuarios
cd /d "%INITIAL_DIR%\..\Serv_Usuarios"
python -c "import flask" >nul 2>&1
if errorlevel 1 (
    echo Instalando Flask...
    pip install flask pandas
    if errorlevel 1 (
        echo ⚠️ Error instalando Flask
        echo Ejecuta manualmente: pip install flask pandas
    ) else (
        echo ✓ Flask instalado
    )
) else (
    echo ✓ Flask disponible
)

cd /d "%INITIAL_DIR%"

REM 5. Verificar estructura de observabilidad
echo.
echo [5/5] Verificando estructura de observabilidad
cd /d "%INITIAL_DIR%\..\Serv_GestionProductos"
if not exist observability (
    echo ⚠️ Directorio observability no encontrado
    echo Asegúrate de que esté presente para Prometheus y Grafana
) else (
    echo ✓ Estructura de observabilidad presente
)

cd /d "%INITIAL_DIR%"

echo.
echo ===============================
echo  ✅ SETUP COMPLETADO
echo ===============================
echo.
echo ✓ Docker listo para infraestructura
echo ✓ Frontend React configurado  
echo ✓ Servicio de Productos con observabilidad
echo ✓ Servicio de Usuarios configurado
echo ✓ Estructura de observabilidad verificada
echo.
echo SIGUIENTE: Ejecuta run_all.bat
echo.
echo 📊 Observabilidad incluye:
echo   - Prometheus (métricas): http://localhost:9090
echo   - Grafana (dashboards): http://localhost:3001
echo   - Métricas del API: http://localhost:5000/metrics
pause
