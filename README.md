# Directus & Next.js E-commerce Platform

Este proyecto es una base sólida para una plataforma de e-commerce moderna, utilizando un backend headless (Directus) y un frontend desacoplado (Next.js). Todo el entorno está contenedorizado con Docker para un desarrollo y despliegue consistentes.

## Tech Stack

*   **Backend:** Directus (CMS Headless y Framework de API)
*   **Frontend:** Next.js (React Framework)
*   **Base de Datos:** PostgreSQL
*   **Orquestación:** Docker & Docker Compose

## Estructura del Proyecto

*   `/app`: Contiene la aplicación de frontend de Next.js.
*   `/directus`: Contiene la configuración y los archivos del CMS Directus.
*   `/database`: Contiene la configuración del servicio de la base de datos PostgreSQL y PgAdmin.
*   `manage.sh`: Script principal para gestionar todo el entorno de desarrollo.

## Servicios y Puertos

El entorno levanta los siguientes servicios, cada uno expuesto en un puerto específico en tu `localhost`:

*   **Next.js App (Frontend):** `http://localhost:3037`
*   **Directus CMS (Backend):** `http://localhost:8057`
*   **PgAdmin (Gestor de Base de Datos):** `http://localhost:5057`
*   **PostgreSQL (Base de Datos):** Se conecta en el puerto `5437` (para herramientas de base de datos).

## Uso

Este proyecto es gestionado a través del script `manage.sh`.

### Requisitos

*   Docker
*   Docker Compose

### Iniciar el Entorno

Para iniciar todos los servicios (base de datos, backend y frontend) en modo de desarrollo, ejecuta:

```bash
./manage.sh start
```

Opcionalmente, puedes especificar el entorno (`dev` o `prod`):

```bash
./manage.sh start prod
```

### Detener el Entorno

Para detener todos los servicios:

```bash
./manage.sh stop
```

### Otros Comandos

*   `./manage.sh restart`: Reinicia todos los servicios.
*   `./manage.sh ps`: Muestra el estado de los contenedores.
*   `./manage.sh logs <servicio>`: Muestra los logs de un servicio específico (ej: `logs directus`).

### Migraciones de Esquema

El proyecto incluye scripts para guardar y cargar la estructura de la base de datos (colecciones y campos):

*   **Para guardar tus cambios en la estructura:**
    ```bash
    ./scripts/create-snapshot.sh
    ```
*   **Para aplicar la estructura en un entorno nuevo:**
    ```bash
    ./scripts/apply-snapshot.sh
    ```

## Modelo de Datos (E-commerce)

El backend de Directus ha sido configurado con un modelo de datos de e-commerce que incluye:

*   **products**: Para los artículos de la tienda.
*   **categories**: Para organizar los productos.
*   **customers**: Perfiles de clientes enlazados al sistema de usuarios.
*   **orders**: Para registrar las ventas.
*   **order_items**: La tabla de unión que detalla los productos en cada pedido.

## Roles y Permisos

Se ha configurado un sistema de permisos basado en políticas para los siguientes roles:

*   **Public**: Acceso de solo lectura a productos y categorías.
*   **Customer**: Puede ver productos/categorías y gestionar su propio perfil y pedidos.
*   **Product Manager**: Puede gestionar completamente los productos y categorías.
*   **Commerce Owner**: Hereda los permisos del `Product Manager` y puede ser extendido con permisos adicionales.
