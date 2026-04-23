@echo off
REM AgroWeb - Limpiar y Poblar Base de Datos

title Limpiar y Poblar Datos
echo ============================================
echo  🗑️ LIMPIAR Y POBLAR BASE DE DATOS
echo ============================================
echo.

REM Check if conda is available for Cassandra (productos)
where conda >nul 2>nul
if errorlevel 1 (
    echo ⚠️ Conda no está disponible - Saltando productos
    echo 💡 Para productos: Ejecutar desde Anaconda Prompt
    set SKIP_PRODUCTOS=1
) else (
    set SKIP_PRODUCTOS=0
)

REM Check MongoDB for usuarios
echo [1/3] Verificando MongoDB para usuarios...
python -c "from pymongo import MongoClient; client = MongoClient('localhost', 27017, serverSelectionTimeoutMS=2000); client.admin.command('ping'); print('✅ MongoDB disponible'); client.close()" 2>nul
if errorlevel 1 (
    echo ❌ MongoDB no está disponible
    echo 💡 Inicia MongoDB service o ejecuta: mongod
    set SKIP_USUARIOS=1
) else (
    echo ✅ MongoDB disponible para usuarios
    set SKIP_USUARIOS=0
)

echo.
if %SKIP_PRODUCTOS%==0 (
    echo [2/3] Limpiando productos existentes...
    cd /d "d:\UN\2025-1\Ingesoft 2\Proyecto\Serv_GestionProductos"
    call conda init cmd.exe >nul 2>&1
    call conda activate agroweb
    if errorlevel 1 (
        echo ❌ Error: No se pudo activar entorno agroweb
        set SKIP_PRODUCTOS=1
    ) else (
        echo 🔌 Conectando a Cassandra y limpiando...
        python -c "from Infrastructure.cassandra_db import CassandraDB; db=CassandraDB(); prods=db.get_all_products(); deleted=sum(1 for p in prods if db.delete_product(p['product_id'])); print(f'✅ Eliminados {deleted} productos'); db.close()"
        if errorlevel 1 (
            echo ❌ Error limpiando productos de Cassandra
            set SKIP_PRODUCTOS=1
        )
    )
) else (
    echo [2/3] ⚠️ Saltando limpieza de productos (Cassandra no disponible)
)

if %SKIP_USUARIOS%==0 (
    echo [3/3] Limpiando usuarios existentes...
    echo 🍃 Conectando a MongoDB y limpiando...
    python -c "from pymongo import MongoClient; client = MongoClient('localhost', 27017); db = client['Serv_Usuarios']; result = db['Usuarios'].delete_many({}); print(f'✅ Eliminados {result.deleted_count} usuarios'); client.close()"
    if errorlevel 1 (
        echo ❌ Error limpiando usuarios de MongoDB
        set SKIP_USUARIOS=1
    )
) else (
    echo [3/3] ⚠️ Saltando limpieza de usuarios (MongoDB no disponible)
)

echo.
echo [4/4] Poblando con datos frescos...
cd /d "d:\UN\2025-1\Ingesoft 2\Proyecto\WorkspaceSetup"
python populate_data.py

echo.
echo ✅ Proceso completado!
if %SKIP_PRODUCTOS%==0 (
    if %SKIP_USUARIOS%==0 (
        echo 🎯 Ambos servicios poblados exitosamente
    ) else (
        echo ⚠️ Solo productos poblados - MongoDB no disponible
    )
) else (
    if %SKIP_USUARIOS%==0 (
        echo ⚠️ Solo usuarios poblados - Cassandra no disponible  
    ) else (
        echo ❌ Ningún servicio poblado - Verificar infraestructura
    )
)
echo.
echo 🌐 Servicios disponibles:
echo    • Frontend: http://localhost:5173
echo    • API Productos: http://localhost:5000/apidocs
echo    • API Usuarios: http://localhost:5001/swagger
echo    • Grafana: http://localhost:3001 (admin/agroweb2025)
echo.
pause
