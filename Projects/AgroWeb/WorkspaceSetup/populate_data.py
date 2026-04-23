"""
AgroWeb Unified Data Population Script
=====================================
This script populates both Users and Products services with realistic sample data.
It can be used standalone or called from the main run_all.bat workflow.

Features:
- Populates 5 Colombian users with complete profiles, plus an admin user
- Populates 12 products with realistic pricing and descriptions  
- Smart service availability checking before attempting population
- Graceful error handling and detailed progress reporting
- Can handle partial service availability (populate only available services)
"""

import requests
import json
import sys
import os
from datetime import date, datetime
from typing import Dict, List

# API Configuration
# These URLs must match the actual service endpoints
USERS_BASE_URL = "http://127.0.0.1:5001"      # Users service endpoint
PRODUCTS_BASE_URL = "http://127.0.0.1:5000"   # Products service endpoint
TIMEOUT = 10  # HTTP request timeout in seconds

# Sample users data
# These are realistic Colombian users with complete profiles that meet validation requirements
# All users are 18+ years old and have unique documents and emails
sample_users = [
    {
        # User 0: ADMIN
        "firstName": "Admin", "middleName": "Admin", "surName1": "Admin", "surName2": "Admin",
        "bornDate": "1980-01-01", "department": "Cundinamarca", "municipality": "Bogotá",
        "trail": "Calle 123 #45-67", "email": "admin@agroweb.com", "typeDocument": "CC",
        "numberDocument": "1111111111", "phoneNumber": "3001234567", "hashPassword": "adminpass", 
        "username": "admin", "userType": "admin"
    },
    {
        # User 1: Juan from Bogotá - Basic user with standard data
        "firstName": "Juan", "middleName": "Carlos", "surName1": "Pérez", "surName2": "González",
        "bornDate": "1990-05-15", "department": "Cundinamarca", "municipality": "Bogotá",
        "trail": "Calle 123 #45-67", "email": "juan.perez@email.com", "typeDocument": "CC",
        "numberDocument": "1234567890", "phoneNumber": "3001234567", "hashPassword": "password123", 
        "username": "juanperez", "userType": "seller"
    },
    {
        # User 2: María from Medellín - Represents Antioquia region
        "firstName": "María", "middleName": "Elena", "surName1": "Rodríguez", "surName2": "López",
        "bornDate": "1985-08-22", "department": "Antioquia", "municipality": "Medellín",
        "trail": "Carrera 50 #30-20", "email": "maria.rodriguez@email.com", "typeDocument": "CC",
        "numberDocument": "9876543210", "phoneNumber": "3109876543", "hashPassword": "securepass456",
        "username": "mariarodriguez", "userType": "buyer"
    },
    {
        # User 3: Carlos from Cali - Represents Valle del Cauca region
        "firstName": "Carlos", "middleName": "Andrés", "surName1": "Martínez", "surName2": "Silva",
        "bornDate": "1992-12-03", "department": "Valle del Cauca", "municipality": "Cali",
        "trail": "Avenida 6N #25-30", "email": "carlos.martinez@email.com", "typeDocument": "CC",
        "numberDocument": "5555666777", "phoneNumber": "3205556677", "hashPassword": "mypassword789",
        "username": "carlosmartinez", "userType": "buyer"
    },
    {
        # User 4: Ana from Bucaramanga - Represents Santander region
        "firstName": "Ana", "middleName": "Lucía", "surName1": "Gómez", "surName2": "Vargas",
        "bornDate": "1988-03-18", "department": "Santander", "municipality": "Bucaramanga",
        "trail": "Calle 45 #22-15", "email": "ana.gomez@email.com", "typeDocument": "CC",
        "numberDocument": "1111222333", "phoneNumber": "3151112223", "hashPassword": "anapass321",
        "username": "anagomez", "userType": "seller"
    },
    {
        # User 5: Diego from Barranquilla - Represents Caribbean coast (Atlántico)
        "firstName": "Diego", "middleName": "Fernando", "surName1": "Herrera", "surName2": "Castro",
        "bornDate": "1995-07-09", "department": "Atlántico", "municipality": "Barranquilla",
        "trail": "Carrera 84 #76-40", "email": "diego.herrera@email.com", "typeDocument": "CC",
        "numberDocument": "4444555666", "phoneNumber": "3004445556", "hashPassword": "diegopass654",
        "username": "diegoherrera", "userType": "seller"
    }
]

# Sample products data
# This catalog represents a realistic AgroWeb marketplace with Colombian agricultural products
# Products are categorized and include pricing, stock levels, and detailed descriptions
# Some products are marked as out of stock (stock: 0) to test inventory features
sample_products = [
    {
        # Vegetable 1: Lettuce - High-demand leafy green, bestseller with good stock
        "name": "Lechuga",
        "category": "Verduras",
        "price": 6000,  # Price in Colombian pesos
        "unit": "Unidad / 500g",
        "imageUrl": "http://localhost:5000/static/catalog/lechuga.avif",
        "stock": 10,  # Available units
        "origin": "Cundinamarca",  # Colombian department of origin
        "description": "Lechuga fresca y crujiente, ideal para ensaladas.",
        "isActive": True,  # Product is active and visible
        "user_id": "1234567890",  # Associated user for ownership
        "originalPrice": None,  # No discount applied
        "isOrganic": True,  # Organic product
        "isBestSeller": True,  # Popular product
        "freeShipping": False,  # Regular shipping applies
    },
    {
        # Vegetable 2: Broccoli - Nutritious vegetable with good availability
        "name": "Brocoli",
        "category": "Verduras",
        "price": 5000,
        "unit": "500g",
        "imageUrl": "http://localhost:5000/static/catalog/brocoli.jpg",
        "stock": 15,
        "origin": "Boyacá",
        "description": "Brocoli fresco.",
        "isActive": True,
        "user_id": "9876543210",  # Associated user for ownership
        "originalPrice": None,
        "isOrganic": True,
        "isBestSeller": False,
        "freeShipping": False,
    },
    {
        # Tuber: Potato - Staple food with discount and free shipping
        "name": "Papa sabanera",
        "category": "Tubérculos",
        "price": 6000,
        "unit": "1kg",
        "imageUrl": "http://localhost:5000/static/catalog/papa_sabanera.jpg",
        "stock": 40,  # High stock available
        "origin": "Sogamoso",
        "description": "Papa sabanera con un sabor único.",
        "isActive": True,
        "user_id": "5555666777",  # Associated user for ownership
        "originalPrice": 7000,  # Discounted from 7000 to 6000
        "isOrganic": True,
        "isBestSeller": False,
        "freeShipping": True,  # Free shipping promotion
    },
    {
        # Fruit 1: Mango - Tropical fruit, bestseller from warm climate region
        "name": "Mango",
        "category": "Frutas",
        "price": 3000,
        "unit": "1 kg",
        "imageUrl": "http://localhost:5000/static/catalog/mango.jpg",
        "stock": 40,
        "origin": "Melgar",  # Known for tropical fruits
        "description": "Mango fresco y jugoso.",
        "isActive": True,
        "user_id": "1111222333",  # Associated user for ownership
        "originalPrice": None,
        "isOrganic": True,
        "isBestSeller": True,
        "freeShipping": False,
    },
    {
        # Fruit 2: Pineapple - Premium priced fruit, currently out of stock
        "name": "Piña",
        "category": "Frutas",
        "price": 12000,  # Higher price point
        "unit": "1kg",
        "imageUrl": "http://localhost:5000/static/catalog/pina.jpg",
        "stock": 0,  # Out of stock - tests inventory handling
        "origin": "Santander",
        "description": "Piña para la niña",  # Playful description
        "isActive": True,
        "user_id": "4444555666",  # Associated user for ownership
        "originalPrice": None,
        "isOrganic": True,
        "isBestSeller": False,
        "freeShipping": False,
    },
    {
        # Fruit 3: Strawberries - Premium berries, out of stock, bestseller
        "name": "Fresas",
        "category": "Frutas",
        "price": 4000,
        "unit": "250g",  # Smaller unit size for premium product
        "imageUrl": "http://localhost:5000/static/catalog/fresas.avif",
        "stock": 0,  # Out of stock
        "origin": "Chocontá",  # Known for strawberry cultivation
        "description": "Jugosas fresas.",
        "isActive": True,
        "user_id": "1234567890",  # Associated user for ownership
        "originalPrice": None,
        "isOrganic": False,  # Non-organic option
        "isBestSeller": True,
        "freeShipping": False,
    },
    {
        # Dairy: Eggs - Farm fresh eggs with discount and free shipping
        "name": "Huevos campesinos",
        "category": "Huevos",
        "price": 3000,
        "unit": "Docena",  # Sold by dozen
        "imageUrl": "http://localhost:5000/static/catalog/huevos_campesinos.jpeg",
        "stock": 20,
        "origin": "Buga",
        "description": "Huevos frescos de granja, ideales para el desayuno.",
        "isActive": True,
        "user_id": "9876543210",  # Associated user for ownership
        "originalPrice": 4000,  # Discounted from 4000 to 3000
        "isOrganic": True,
        "isBestSeller": False,
        "freeShipping": True,
    },
    {
        # Fruit 4: Banana - Common fruit with good availability
        "name": "Banano",
        "category": "Frutas",
        "price": 3000,
        "unit": "Racimo",  # Sold by bunch
        "imageUrl": "http://localhost:5000/static/catalog/banano.jpeg",
        "stock": 40,
        "origin": "Sibaté",
        "description": "Banano fresco.",
        "isActive": True,
        "user_id": "5555666777",  # Associated user for ownership
        "originalPrice": None,
        "isOrganic": True,
        "isBestSeller": False,
        "freeShipping": False,
    },
    {
        # Vegetable 3: Onion - Essential cooking ingredient, affordable price
        "name": "Cebolla",
        "category": "Verduras",
        "price": 2000,  # Lower price point
        "unit": "500g",
        "imageUrl": "http://localhost:5000/static/catalog/cebolla.jpg",
        "stock": 30,
        "origin": "Aquitania",
        "description": "Cebolla fresca y sabrosa, ideal para cocinar.",
        "isActive": True,
        "user_id": "4444555666",  # Associated user for ownership
        "originalPrice": None,
        "isOrganic": False,
        "isBestSeller": False,
        "freeShipping": False
    },
    {
        # Grain: Corn - Bulk product, out of stock, bestseller with free shipping
        "name": "Maiz",
        "category": "Cereales",
        "price": 6000,
        "unit": "Costal",  # Sold in sacks (bulk)
        "imageUrl": "http://localhost:5000/static/catalog/maiz.jpg",
        "stock": 0,  # Out of stock
        "origin": "Duitama",
        "description": "Maiz dulce y fresco.",
        "isActive": True,
        "user_id": "1234567890",  # Associated user for ownership
        "originalPrice": None,
        "isOrganic": True,
        "isBestSeller": True,
        "freeShipping": True
    },
    {
        # Vegetable 4: Tomato - Essential cooking ingredient with free shipping
        "name": "Tomate",
        "category": "Verduras",
        "price": 3000,
        "unit": "250g",
        "imageUrl": "http://localhost:5000/static/catalog/tomate.jpg",
        "stock": 30,
        "origin": "Ventaquemada",
        "description": "Tomate fresco.",
        "isActive": True,
        "user_id": "1111222333",  # Associated user for ownership
        "originalPrice": None,
        "isOrganic": True,
        "isBestSeller": False,
        "freeShipping": True,
    },
    {
        # Vegetable 5: Carrot - Nutritious root vegetable, premium priced, out of stock
        "name": "Zanahoria",
        "category": "Verduras",
        "price": 8000,  # Higher price point
        "unit": "500g",
        "imageUrl": "http://localhost:5000/static/catalog/zanahoria.jpg",
        "stock": 0,  # Out of stock
        "origin": "Soacha",
        "description": "Zanahoria fresca.",
        "isActive": True,
        "user_id": "9876543210",  # Associated user for ownership
        "originalPrice": None,
        "isOrganic": True,
        "isBestSeller": False,
        "freeShipping": False
    }
]

def check_service(url: str, service_name: str) -> bool:
    """
    Check if a service is available and responding
    
    Args:
        url: Base URL of the service to check
        service_name: Human-readable name for logging purposes
        
    Returns:
        bool: True if service is available, False otherwise
        
    This function performs two-tier checking:
    1. Try /health endpoint (standard health check)
    2. Fallback to service-specific endpoints if /health doesn't exist
    """
    print(f"   🔍 Verificando {service_name}...")
    
    try:
        # Primary check: Try standard health endpoint
        response = requests.get(f"{url}/health", timeout=TIMEOUT)
        if response.status_code == 200:
            print(f"   ✅ {service_name} disponible")
            return True
    except:
        try:
            # Fallback check: Try service-specific endpoints
            # For products service, check /products endpoint
            # For users service, this will still try the base URL
            endpoint = url if "products" in url.lower() else f"{url}/products"
            response = requests.get(endpoint, timeout=TIMEOUT)
            
            # Accept both 200 (data exists) and 404 (service running but no data)
            if response.status_code in [200, 404]:
                print(f"   ✅ {service_name} disponible")
                return True
        except:
            pass  # Both checks failed
    
    print(f"   ❌ {service_name} no disponible")
    return False

def populate_users() -> bool:
    """
    Populate the Users service with sample user data
    
    Returns:
        bool: True if at least one user was successfully registered, False otherwise
        
    This function:
    1. Iterates through all sample users
    2. Sends POST requests to the users/register endpoint
    3. Handles registration errors gracefully
    4. Provides detailed progress feedback
    5. Returns success if any users were registered (partial success is acceptable)
    """
    print("\n👥 Poblando usuarios...")
    
    success_count = 0
    
    # Process each user in the sample data
    for user_data in sample_users:
        try:
            # Send registration request to Users API
            response = requests.post(
                f"{USERS_BASE_URL}/users/register",
                json=user_data,  # Send user data as JSON
                headers={'Content-Type': 'application/json'},
                timeout=TIMEOUT
            )
            
            # Check if registration was successful
            if response.status_code == 201:  # 201 = Created
                success_count += 1
                print(f"   ✅ {user_data['username']}")
            else:
                # Registration failed - show error details
                print(f"   ❌ {user_data['username']}: {response.text}")
                
        except Exception as e:
            # Network or other error occurred
            print(f"   ❌ {user_data['username']}: Error de conexión")
    
    # Summary of registration results
    print(f"👥 Resultado: {success_count}/{len(sample_users)} usuarios registrados")
    
    # Return True if at least one user was registered successfully
    return success_count > 0

def clear_products() -> bool:
    """
    Clear existing products from the database before populating new ones
    
    Returns:
        bool: True if clearing was successful or no products existed, False if error
        
    This function attempts to clear existing products to avoid duplicates when populating.
    It uses a robust approach:
    1. Get all products via API to check what exists
    2. Access database infrastructure directly for efficient bulk deletion
    3. Provide clear feedback and guidance if clearing fails
    """
    print("   🗑️ Limpiando productos existentes con TRUNCATE...")
    try:
        # Add the Products service to Python path for infrastructure access
        products_service_path = os.path.abspath("../Serv_GestionProductos")
        if products_service_path not in sys.path:
            sys.path.insert(0, products_service_path)
        from Infrastructure.cassandra_connection import get_cassandra_connection
        print("   � Conectando a Cassandra...")
        conn = get_cassandra_connection()
        session = conn.get_session()
        keyspace = conn.keyspace
        session.execute(f"TRUNCATE {keyspace}.products")
        print("   ✅ Tabla 'products' truncada exitosamente.")
        return True
    except Exception as e:
        print(f"   ❌ Error al truncar la tabla products: {str(e)}")
        return False

def populate_products() -> bool:
    """
    Populate the Products service with sample product data
    
    Returns:
        bool: True if at least one product was successfully created, False otherwise
        
    This function:
    1. Attempts to clear existing products to avoid duplicates
    2. Iterates through all sample products
    3. Sends POST requests to the products endpoint
    4. Handles creation errors gracefully
    5. Provides detailed progress feedback with product numbers
    6. Returns success if any products were created (partial success is acceptable)
    
    The products include a variety of Colombian agricultural products with:
    - Different categories (vegetales, frutas, lácteos, hierbas, tubérculos, cereales)
    - Various stock levels (including some out-of-stock items)
    - Different price points and promotional features
    - Realistic origins from Colombian departments
    """
    print("\n📦 Poblando productos...")
    
    # Optional: Clear existing products to avoid duplicates
    clear_products()
    
    success_count = 0
    
    # Process each product in the sample data
    for i, product_data in enumerate(sample_products, 1):
        try:
            # Send product creation request to Products API
            response = requests.post(
                f"{PRODUCTS_BASE_URL}/products",
                json=product_data,  # Send product data as JSON
                headers={'Content-Type': 'application/json'},
                timeout=TIMEOUT
            )
            
            # Check if product creation was successful
            if response.status_code == 201:  # 201 = Created
                success_count += 1
                print(f"   ✅ [{i:2d}/{len(sample_products)}] {product_data['name']}")
            else:
                # Product creation failed - show error details
                print(f"   ❌ [{i:2d}/{len(sample_products)}] {product_data['name']}: {response.text}")
                
        except Exception as e:
            # Network or other error occurred
            print(f"   ❌ [{i:2d}/{len(sample_products)}] {product_data['name']}: Error de conexión")
    
    # Summary of creation results
    print(f"📦 Resultado: {success_count}/{len(sample_products)} productos creados")
    
    # Return True if at least one product was created successfully
    return success_count > 0

def main():
    """
    Main population function - orchestrates the entire data population process
    
    Returns:
        bool: True if population was successful (all or partial), False if completely failed
        
    This function coordinates the complete population workflow:
    1. Display initial information about what will be populated
    2. Check availability of both services before attempting population
    3. Attempt population only for available services
    4. Provide comprehensive success/failure reporting
    5. Handle partial success scenarios gracefully
    
    The function supports three success scenarios:
    - Complete success: Both services available and populated
    - Partial success: At least one service populated successfully  
    - Failure: No services available or all population attempts failed
    """
    print("🌱 AgroWeb - Población Unificada de Datos")
    print("=" * 50)
    print(f"👥 Usuarios a crear: {len(sample_users)}")
    print(f"📦 Productos a crear: {len(sample_products)}")
    print("=" * 50)
    print("🔍 Verificando disponibilidad de servicios...")
    
    # Step 1: Check service availability before attempting population
    # This prevents unnecessary API calls and provides clear error messages
    users_available = check_service(USERS_BASE_URL, "Usuarios")
    products_available = check_service(PRODUCTS_BASE_URL, "Productos")
    
    # If no services are available, exit early with clear error message
    if not users_available and not products_available:
        print("\n❌ Ningún servicio está disponible")
        print("   Asegúrate de que las APIs estén ejecutándose antes de poblar datos")
        return False
    
    print("\n🚀 Iniciando población de datos...")
    
    # Step 2: Populate only the available services
    # This allows partial population if only one service is running
    users_success = populate_users() if users_available else False
    products_success = populate_products() if products_available else False
    
    # Step 3: Provide comprehensive results summary
    print("\n" + "=" * 50)
    print("📊 Resumen Final:")
    print(f"👥 Usuarios: {'✅ Exitoso' if users_success else '❌ Error/No disponible'}")
    print(f"📦 Productos: {'✅ Exitoso' if products_success else '❌ Error/No disponible'}")
    
    # Step 4: Determine overall success and provide appropriate messaging
    if (users_available and users_success) and (products_available and products_success):
        # Complete success: Both services were available and populated successfully
        print("\n🎉 ¡Población completa exitosa!")
        print("🌐 URLs disponibles:")
        print("   • Frontend: http://localhost:5173")
        print("   • API Productos: http://localhost:5000/swagger")
        print("   • API Usuarios: http://localhost:5001/swagger")
        print("\n✨ Los servicios están listos con datos de prueba!")
        return True
        
    elif users_success or products_success:
        # Partial success: At least one service was populated successfully
        print("\n✅ Población parcial exitosa")
        print("   Algunos servicios fueron poblados correctamente")
        return True
        
    else:
        # Complete failure: No services were populated successfully
        print("\n⚠️ Población completada con errores")
        print("   Revisa los logs anteriores para más detalles")
        return False

if __name__ == "__main__":
    """
    Script entry point - executes when run directly (not imported)
    
    This section:
    1. Calls the main population function
    2. Uses the return value to set appropriate exit codes
    3. Follows Unix convention: 0 = success, 1 = failure
    
    Exit codes help other scripts (like run_all.bat) determine if population succeeded.
    """
    success = main()
    
    # Set exit code based on population success
    # 0 = success (complete or partial), 1 = failure
    sys.exit(0 if success else 1)
