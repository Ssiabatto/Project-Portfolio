# AgroWeb - Guí3. **Verificar estado:**
   - `Ctrl+Shift+P` → "Tasks: Run Task" → "🔍 Verificar Estado"

4. **Ejecutar Prometheus nativo:**
   - `Ctrl+Shift+P` → "Tasks: Run Task" → "📊 Prometheus Nativo"
   - **Nota:** Si Prometheus no está en `C:\prometheus\`, ver sección "📊 Prometheus Nativo" para configurar ruta

5. **Ejecutar tests de integración:**
   - `Ctrl+Shift+P` → "Tasks: Run Task" → "🧪 Tests Integración - [Servicio]"

6. **Acceder:** http://localhost:5173 Ejecución

## Inicio Rápido

### Método 1: VS Code (Recomendado)

1. **Abrir proyecto:**
   ```bash
   # Doble clic en:
   proyecto.code-workspace
   ```

2. **Ejecutar sistema completo:**
   - `Ctrl+Shift+P` → "Tasks: Run Task" → "🚀 Sistema Completo (Entornos Aislados)"

3. **Verificar estado:**
   - `Ctrl+Shift+P` → "Tasks: Run Task" → "� Verificar Estado"

4. **Acceder:** http://localhost:5173

### Método 2: Scripts Manuales

```bash
# 1. Setup inicial (una vez)
setup.bat

# 2. Ejecutar sistema completo
run_all.bat

# 3. Servicios individuales
start_productos.bat       # API Productos + Infraestructura (REQUIERE Anaconda/Miniconda)
start_usuarios.bat        # API Usuarios (REQUIERE MongoDB)
start_frontend.bat        # Solo Frontend React
start_mongodb.bat         # Gestión específica de MongoDB

# 4. Gestión de datos
clear_and_populate.bat    # Limpiar y poblar ambas bases de datos (Cassandra + MongoDB)

# 5. Monitoreo y pruebas
check_status.bat          # Verificación completa incluyendo MongoDB

# 6. Detener todo
stop_all.bat
```

## 🎯 Servicios desde VS Code

- `🥕 API Productos + Infraestructura` - Cassandra + API (REQUIERE Anaconda/Miniconda)
- `👥 API Usuarios` - API simple con Flask y MongoDB
- `🌐 Solo Frontend` - React con Vite
- `🔍 Verificar Estado` - Chequeo rápido de todos los servicios
- `📊 Prometheus Nativo` - Observabilidad fuera de Docker
- `🧪 Tests Integración` - Suite completa de pruebas por servicio

**Para acceder:** `Ctrl+Shift+P` → "Tasks: Run Task" → [seleccionar servicio]

## URLs del Sistema

### URLs Principales
- **App:** http://localhost:5173
- **API Productos:** http://localhost:5000/apidocs
- **API Usuarios:** http://localhost:5001/swagger

### URLs de Observabilidad 🆕
- **Prometheus:** http://localhost:9090 (Native, use start_prometheus_native.cmd)
- **Health Check:** http://localhost:5000/health
- **Métricas:** http://localhost:5000/metrics

## Población de Datos

**API Productos + Infraestructura:**
- **REQUIERE Anaconda o Miniconda** para cassandra-driver
- **Inicia automáticamente:** Cassandra + API de Productos
- **Auto-detecta instalación** de Anaconda en ubicaciones comunes
- **Una sola ventana** para todo el stack completo de productos
- **Prometheus:** Ahora ejecuta nativamente (fuera de Docker)

**¿Por qué Anaconda es necesario?**
- ✅ **cassandra-driver** requiere compilación C++ en Windows
- ✅ **Anaconda incluye** binarios precompilados que funcionan siempre
- ✅ **pip solo** rara vez funciona sin Visual C++ Build Tools
- ✅ **Solución confiable** para desarrollo en Windows

**Ventajas de usar solo Anaconda:**
- ✅ **Simplicidad:** Una sola forma que siempre funciona
- ✅ **Orden correcto:** Infraestructura primero, luego API
- ✅ **Dependencias claras:** Todos saben qué necesitan instalar
- ✅ **Observabilidad incluida:** Métricas con Prometheus nativo

### 📊 Prometheus Nativo:

#### Configuración e Instalación:
1. **Descargar Prometheus:**
   - Ir a: https://prometheus.io/download/
   - Descargar versión Windows (prometheus-x.x.x.windows-amd64.zip)

2. **Instalar en ubicación preferida:**
   ```bash
   # Ubicaciones comunes:
   C:\prometheus\              # Ubicación por defecto
   D:\prometheus\    # Ubicación personalizada
   %USERPROFILE%\prometheus\   # En carpeta de usuario
   ```

3. **Configurar ruta en script:**
   - Editar: `Serv_GestionProductos/observability/start_prometheus_native.cmd`
   - Modificar línea 15: `set PROMETHEUS_PATH=TU_RUTA_AQUI`
   - Ejemplo: `set PROMETHEUS_PATH=D:\programas\prometheus`

#### Ejecución:
- **VS Code:** `Ctrl+Shift+P` → "Tasks: Run Task" → "📊 Prometheus Nativo"
- **Manual:** Ejecutar `start_prometheus_native.cmd`
- **Puerto:** http://localhost:9090

#### ⚙️ Personalización:
Si Prometheus está en otra ubicación, simplemente edita la variable `PROMETHEUS_PATH` en el script.

### Datos incluidos:
- **5 usuarios** colombianos (con datos completos)
- **12 productos** agrícolas (con precios y categorías)

### Formas de poblar:
- **Automático:** Al ejecutar run_all.bat, responder `s`
- **Manual:** `python populate_data.py`
- **VS Code:** `Ctrl+Shift+P` → "📊 Poblar Datos"

## 📊 Observabilidad - Monitoreo en Tiempo Real

### ¿Qué es la Observabilidad en AgroWeb?
La **observabilidad** nos permite entender cómo funciona nuestro sistema internamente viendo datos en tiempo real. Implementamos un stack completo con **Prometheus** y **Grafana** para monitorear el rendimiento, detectar errores y optimizar la experiencia del usuario.

### 🔍 Prometheus - El Recolector de Métricas
**Prometheus** funciona como un "espía digital" que observa constantemente nuestro API:

#### ¿Qué hace Prometheus?
- **Recolecta datos** cada 5 segundos del API de productos
- **Almacena métricas** en una base de datos de series temporales
- **Permite consultas** usando PromQL (lenguaje especializado)
- **Detecta patrones** y anomalías en el comportamiento

#### ¿Qué registra Prometheus?
- **📊 Peticiones HTTP:** Cuántas veces se llama cada endpoint
  - Ejemplo: `/products` llamado 150 veces en el último minuto
- **⏱️ Tiempos de respuesta:** Qué tan rápido responde cada función
  - Ejemplo: P95 de 250ms (95% de peticiones responden en <250ms)
- **❌ Códigos de error:** Qué errores ocurren y con qué frecuencia
  - Ejemplo: 5 errores 404, 2 errores 500 en la última hora
- **🎯 Distribución de tráfico:** Qué endpoints son más populares
  - Ejemplo: 60% GET /products, 30% POST /products, 10% otros

### 📈 Grafana - El Visualizador Inteligente
**Grafana** toma los datos crudos de Prometheus y los convierte en dashboards útiles:

#### ¿Qué hace Grafana?
- **Conecta a Prometheus** para obtener datos en tiempo real
- **Crea gráficos dinámicos** que se actualizan automáticamente
- **Muestra tendencias** para entender el comportamiento del sistema
- **Genera alertas** cuando algo va mal

#### Dashboard "AgroWeb - Servicio de Productos":
- **📊 Panel de Peticiones por Segundo:** 
  - Gráfico de líneas mostrando tráfico en tiempo real
  - Ayuda a identificar picos de uso
- **⏱️ Panel de Latencia P95:**
  - Histograma del tiempo de respuesta
  - Verde: <200ms, Amarillo: 200-500ms, Rojo: >500ms
- **❌ Panel de Errores HTTP:**
  - Contador de errores por tipo (4xx, 5xx)
  - Alertas automáticas si aumentan mucho
- **🎯 Panel de Distribución por Endpoint:**
  - Gráfico circular mostrando popularidad de cada función
  - Ayuda a optimizar los endpoints más usados

### 🔄 Flujo Completo de Observabilidad:
```
Usuario → Frontend → API Flask → Genera métricas → Prometheus → Grafana → Dashboards
   ↓         ↓           ↓              ↓             ↓           ↓         ↓
Clicks   Requests   /products    requests_total   TimeSeries   Panels   Insights
Actions  to API     /health      duration_ms      Database     Graphs   Alerts
```

### 🎯 Casos de Uso Prácticos:

#### Para Desarrolladores:
- **Debug:** "¿Por qué el API está lento?" → Ver panel de latencia
- **Optimización:** "¿Qué endpoint necesita mejorar?" → Ver distribución de tráfico
- **Testing:** "¿Funcionó mi fix?" → Comparar métricas antes/después

#### Para DevOps:
- **Monitoreo:** "¿El sistema está estable?" → Ver dashboard general
- **Alertas:** "¿Hay errores aumentando?" → Alertas automáticas
- **Capacidad:** "¿Necesitamos más recursos?" → Ver tendencias de uso

#### Para Product Managers:
- **Uso:** "¿Qué funciones usan más los usuarios?" → Ver endpoints populares
- **Performance:** "¿La app es rápida?" → Ver tiempos de respuesta
- **Problemas:** "¿Hay errores afectando usuarios?" → Ver panel de errores

### 📱 Acceso Rápido:
- **Prometheus:** http://localhost:9090 (Interface de consultas)
- **Grafana:** http://localhost:3001 (Usuario: admin, Contraseña: agroweb2025)
- **Métricas raw:** http://localhost:5000/metrics (Datos en formato Prometheus)

## Demo de Observabilidad 🆕

### Script de demostración:
```bash
# Ejecutar después de iniciar el sistema
cd Serv_GestionProductos
python generate_observability_demo.py
```

### Métricas demostradas:
- ✅ Contador de peticiones HTTP
- ✅ Latencia/tiempo de respuesta
- ✅ Errores por endpoint y código HTTP
- ✅ Dashboard en tiempo real

## 🍃 MongoDB - Base de Datos de Usuarios

### ¿Qué es MongoDB en AgroWeb?
**MongoDB** es la base de datos NoSQL que alimenta el servicio de usuarios. Almacena perfiles de usuarios, credenciales de autenticación y datos de sesión en un formato flexible y escalable.

### 🚀 Configuración Automática

Los scripts han sido mejorados para manejar MongoDB automáticamente:

#### Setup Inicial:
```bash
setup.bat  # Verifica MongoDB y guía su instalación si es necesario
```

#### Gestión de MongoDB:
```bash
start_mongodb.bat    # Inicia MongoDB como servicio o manualmente
check_status.bat     # Verifica conectividad a MongoDB (puerto 27017)
```

#### Gestión de Datos:
```bash
clear_and_populate.bat  # Limpia y puebla usuarios en MongoDB
# Para pruebas: usar IntegrationTests/ o Tasks de VS Code
```

### 📊 Estructura de Datos:

**Base de datos:** `Serv_Usuarios`  
**Colección:** `Usuarios`

**Ejemplo de documento de usuario:**
```json
{
  "_id": ObjectId("..."),
  "firstName": "Juan",
  "middleName": "Carlos", 
  "surName1": "Pérez",
  "surName2": "González",
  "bornDate": "1990-05-15",
  "department": "Cundinamarca",
  "municipality": "Bogotá",
  "trail": "Calle 123 #45-67",
  "email": "juan.perez@email.com",
  "typeDocument": "CC",
  "numberDocument": "1234567890",
  "phoneNumber": "3001234567",
  "hashPassword": "password123",
  "username": "juanperez"
}
```

### 🔧 Instalación de MongoDB:

#### Windows (Recomendado):
1. **Descarga:** [MongoDB Community Server](https://www.mongodb.com/try/download/community)
2. **Instala** como servicio de Windows
3. **Verifica:** `mongod --version` en terminal
4. **Ejecuta:** `start_mongodb.bat` para confirmar

#### Configuración Manual:
```bash
# Si no se instaló como servicio:
mongod --dbpath "C:\data\db"  # Mantener ventana abierta
```

# Requisitos Previos

- **Docker Desktop** (ejecutándose) - Para infraestructura (Cassandra, Prometheus, Grafana)
- **MongoDB Community Server** (REQUERIDO para servicio de usuarios)
  - Instalado como servicio de Windows o ejecutándose manualmente
  - Puerto 27017 disponible
- **Anaconda o Miniconda** (REQUERIDO para servicio de productos)
  - Cualquier versión reciente (2023+)
  - Con Python 3.10+ incluido
- **Node.js** con npm (para frontend React)
- **Python del sistema:** No requerido específicamente (usamos el de Anaconda)


## Solución de Problemas

**Docker no encontrado:**
- Instalar Docker Desktop
- Verificar que esté ejecutándose

**API Productos + Infraestructura falla:**
- **Si no tienes Anaconda/Miniconda instalado:**
  - Descargar Miniconda: https://docs.conda.io/en/latest/miniconda.html
  - Reiniciar terminal después de instalar
  - Ejecutar el script nuevamente
- **Si hay problemas con el entorno conda:**
  - El script crea automáticamente el entorno `agroweb` con Python 3.11
  - Solución manual: `conda create -n agroweb python=3.11 -y`
- **Errores de infraestructura:**
  - Verifica que Docker Desktop esté ejecutándose
  - Verifica que puertos 5000, 9042, 9090, 3001 estén libres

**API Usuarios o Frontend fallan:**
- Revisa sus ventanas específicas para ver errores
- API Usuarios: Verifica puerto 5001 libre
- Frontend: Ejecuta `npm install` en FrontEnd/

**Reset completo:**
```bash
stop_all.bat
setup.bat
run_all.bat
```

## 📁 Estructura de WorkspaceSetup (Integrada)

```
WorkspaceSetup/
├── 🔧 Scripts principales
│   ├── setup.bat                  # Setup inicial simplificado
│   ├── run_all.bat               # Ejecutar todo el sistema  
│   └── stop_all.bat              # Detener todos los servicios
│
├── 🎯 Scripts por servicio
│   ├── start_productos.bat       # API Productos + Infraestructura (REQUIERE Anaconda)
│   ├── start_usuarios.bat        # Solo API Usuarios
│   └── start_frontend.bat        # Solo Frontend React
│
├── 🔍 Utilidades
│   ├── check_status.bat          # Verificación rápida de estado
│   └── populate_data.py          # Población de datos de prueba
│
└── ⚙️ Configuración
    ├── proyecto.code-workspace   # Workspace de VS Code con tareas
    └── README.md                 # Esta guía
```

### ✅ Beneficios del enfoque Anaconda-only:

- **🎯 Stack completo de productos:** Una sola ventana para API + Cassandra + Prometheus (nativo)
- **🔒 Dependencias confiables:** Anaconda garantiza que cassandra-driver funcione siempre
- **🧹 WorkspaceSetup más limpio:** Solo archivos esenciales, una opción por servicio
- **📋 Tareas VS Code simplificadas:** Sin alternativas confusas
- **🔍 Verificación integrada:** Script de estado para diagnóstico rápido
- **📖 Documentación clara:** Requisitos específicos y sin ambigüedades
- **⚡ Inicio más rápido:** Menos opciones, proceso más directo
- **🧪 Tests integrados:** Suite profesional de pruebas en IntegrationTests/

## 🧪 Tests de Integración

La carpeta `IntegrationTests/` contiene una suite profesional de pruebas:

### Ejecutar desde VS Code:
- `🧪 Tests Integración - Productos` - Pruebas específicas de productos  
- `🧪 Tests Integración - Usuarios` - Pruebas específicas de usuarios
- `🧪 Tests Integración - Completos` - Suite completa con reportes

### Ejecutar desde terminal:
```bash
cd ../IntegrationTests
pytest tests/test_product_lifecycle.py -v     # Solo productos
pytest tests/test_api_integration.py -v       # Solo usuarios  
pytest -v --tb=short --durations=10           # Suite completa
```

### Características:
- **Reportes profesionales:** PDF, HTML, JSON
- **Métricas de rendimiento:** Benchmarking automático
- **Validaciones exhaustivas:** JSON schema, business logic
- **Configuración centralizada:** University-grade documentation
