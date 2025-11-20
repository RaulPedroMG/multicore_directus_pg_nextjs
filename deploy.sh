#!/bin/bash

# ==================================================
# 🚀 Script de Despliegue para Dokploy
# ==================================================
#
# Este script automatiza el proceso de despliegue en Dokploy
# Uso: ./deploy.sh [entorno]

# --- Configuración ---

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Verificación de argumentos ---

if [ -z "$1" ]; then
    ENV="production"
    echo -e "${YELLOW}No se especificó entorno. Usando 'production' por defecto.${NC}"
else
    ENV="$1"
fi

ENV_FILE=".env.$ENV"

# --- Funciones de Utilidad ---

print_message() {
    echo -e "${GREEN}==> $1${NC}"
}

print_error() {
    echo -e "${RED}❌ Error: $1${NC}"
}

print_info() {
    echo -e "${BLUE}🔍 $1${NC}"
}

# --- Verificar requisitos ---

check_requirements() {
    print_info "Verificando requisitos para el despliegue..."

    # Verificar que dokploy esté instalado
    if ! command -v dokploy &> /dev/null; then
        print_error "dokploy no está instalado. Por favor, instálelo primero."
        exit 1
    fi

    # Verificar que el archivo de entorno exista
    if [ ! -f "$ENV_FILE" ]; then
        print_error "El archivo de entorno '$ENV_FILE' no existe."
        echo -e "Debe crear este archivo con las variables de entorno necesarias para el despliegue."
        exit 1
    }

    # Verificar que esté logueado en dokploy
    if ! dokploy auth status &> /dev/null; then
        print_error "No estás autenticado en dokploy."
        echo -e "Ejecuta 'dokploy auth login' para iniciar sesión."
        exit 1
    }
}

# --- Preparar el entorno ---

prepare_environment() {
    print_info "Preparando entorno para el despliegue en '$ENV'..."

    # Copiar archivo de entorno a las carpetas correspondientes
    cp "$ENV_FILE" ./database/.env
    cp "$ENV_FILE" ./directus/.env
    cp "$ENV_FILE" ./app/.env

    print_message "Entorno preparado correctamente."
}

# --- Construir y empaquetar la aplicación ---

build_and_package() {
    print_info "Construyendo y empaquetando la aplicación..."

    # Verificar que dokploy.yml exista
    if [ ! -f "dokploy.yml" ]; then
        print_error "No se encuentra el archivo 'dokploy.yml'."
        exit 1
    }

    # Ejecutar el comando de construcción de dokploy
    dokploy build

    if [ $? -ne 0 ]; then
        print_error "Error al construir la aplicación."
        exit 1
    }

    print_message "Aplicación construida y empaquetada correctamente."
}

# --- Desplegar en Dokploy ---

deploy_to_dokploy() {
    print_info "Desplegando en Dokploy (entorno: $ENV)..."

    # Ejecutar el comando de despliegue con confirmación
    dokploy deploy --env="$ENV" --confirm

    if [ $? -ne 0 ]; then
        print_error "Error durante el despliegue."
        exit 1
    }

    print_message "¡Despliegue completado exitosamente!"
}

# --- Verificación post-despliegue ---

verify_deployment() {
    print_info "Verificando servicios desplegados..."

    # Obtener información sobre el despliegue
    dokploy status

    print_info "Verificando logs iniciales..."
    dokploy logs --tail=50

    print_message "✅ Verificación completada."
}

# --- Ejecutar pasos del despliegue ---

print_message "Iniciando proceso de despliegue en entorno '$ENV'..."

check_requirements
prepare_environment
build_and_package
deploy_to_dokploy
verify_deployment

print_message "🎉 ¡Despliegue en Dokploy completado con éxito!"
echo -e "${BLUE}Para verificar el estado del despliegue, ejecuta: dokploy status${NC}"
echo -e "${BLUE}Para ver los logs, ejecuta: dokploy logs${NC}"

exit 0
