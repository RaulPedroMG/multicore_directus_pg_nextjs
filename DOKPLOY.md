# Guía de Despliegue en Dokploy

## Introducción

Esta guía detalla el proceso para desplegar la plataforma Directus & Next.js en Dokploy. Este documento complementa las instrucciones básicas del README principal y proporciona información detallada específica para Dokploy.

## Requisitos previos

1. **Cuenta en Dokploy**: Debes tener una cuenta activa en la plataforma Dokploy.
2. **CLI de Dokploy**: Instalar y configurar la herramienta de línea de comandos de Dokploy:
   ```bash
   # Instalación
   curl -sSL https://get.dokploy.com | bash
   
   # Autenticación
   dokploy auth login
   ```
3. **Docker**: Asegúrate de tener Docker instalado localmente para pruebas.

## Archivos de configuración para Dokploy

El proyecto incluye los siguientes archivos específicos para Dokploy:

- **dokploy.yml**: Configuración principal que define servicios, recursos y rutas.
- **.env.production.example**: Plantilla para variables de entorno de producción.
- **deploy.sh**: Script para automatizar el proceso de despliegue.

## Configuración de variables de entorno

### Variables críticas

Las siguientes variables deben configurarse correctamente:

| Variable | Descripción | Recomendación |
|----------|-------------|---------------|
| DB_USER | Usuario de base de datos | Usar un nombre de usuario único |
| DB_PASSWORD | Contraseña de base de datos | Mínimo 16 caracteres, incluir caracteres especiales |
| DIRECTUS_KEY | Clave de encriptación de Directus | Generar con `openssl rand -hex 32` |
| DIRECTUS_SECRET | Secreto de Directus | Generar con `openssl rand -hex 32` |
| APP_DOMAIN | Dominio de tu aplicación Next.js | Ej: `app.tudominio.com` |
| DIRECTUS_DOMAIN | Dominio para Directus | Ej: `directus.tudominio.com` |

### Variables opcionales de recursos

Estas variables controlan los recursos asignados a cada servicio:

| Variable | Servicio | Valor predeterminado | Notas |
|----------|----------|----------------------|-------|
| DATABASE_CPU | PostgreSQL | 1 | CPU dedicada |
| DATABASE_MEMORY | PostgreSQL | 2G | Memoria en GB |
| DIRECTUS_CPU | Directus | 1 | CPU dedicada |
| DIRECTUS_MEMORY | Directus | 1.5G | Memoria en GB |
| APP_CPU | Next.js | 1 | CPU dedicada |
| APP_MEMORY | Next.js | 1G | Memoria en GB |

## Proceso de despliegue

### 1. Preparación

Crea el archivo `.env.production` con las variables requeridas:

```bash
cp .env.production.example .env.production
# Edita el archivo con tus valores reales
```

### 2. Despliegue automatizado

Utiliza el script incluido:

```bash
chmod +x deploy.sh
./deploy.sh production
```

### 3. Despliegue manual

Si prefieres el control paso a paso:

```bash
# Copiar archivos de entorno
cp .env.production database/.env
cp .env.production directus/.env
cp .env.production app/.env

# Construir y desplegar
dokploy build
dokploy deploy --env=production --confirm
```

### 4. Verificación

Comprueba el estado del despliegue:

```bash
# Ver estado general
dokploy status

# Ver logs
dokploy logs --tail=50

# Ver recursos
dokploy resources
```

## Configuración de dominio personalizado

Para configurar dominios personalizados:

1. Asegúrate de que los dominios estén definidos en las variables `APP_DOMAIN` y `DIRECTUS_DOMAIN`.
2. Añade registros DNS que apunten a la IP proporcionada por Dokploy después del despliegue.
3. Dokploy gestionará automáticamente los certificados SSL.

## Mantenimiento y actualizaciones

### Actualizaciones de código

Para actualizar tu aplicación:

1. Realiza cambios en tu código local
2. Ejecuta nuevamente el script de despliegue:
   ```bash
   ./deploy.sh production
   ```

### Respaldos de base de datos

Dokploy realiza respaldos automáticos, pero también puedes iniciarlos manualmente:

```bash
dokploy backup create --service=database
```

## Solución de problemas

### Logs específicos de servicios

```bash
# Logs de Directus
dokploy logs --service=directus

# Logs de Next.js
dokploy logs --service=app

# Logs de base de datos
dokploy logs --service=database
```

### Problemas comunes y soluciones

1. **Error de despliegue por falta de recursos**:
   - Verifica y ajusta los recursos asignados en dokploy.yml
   - Actualiza tu plan en Dokploy si es necesario

2. **Error de conexión a la base de datos**:
   - Verifica que las credenciales sean correctas
   - Comprueba que el servicio de base de datos esté en ejecución

3. **Errores en Directus**:
   - Verifica las variables KEY y SECRET
   - Asegúrate de que la conexión a la base de datos sea correcta

## Contacto y soporte

Si encuentras problemas durante el despliegue, puedes:

1. Consultar la [documentación oficial de Dokploy](https://docs.dokploy.com)
2. Abrir un ticket de soporte a través del panel de control de Dokploy
3. Contactar directamente con nuestro equipo técnico en support@example.com