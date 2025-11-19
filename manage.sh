#!/bin/bash

# ==================================================
# 🚀 Entorno de Desarrollo - new_core_directus_2025
# ==================================================
#
# Uso: ./manage.sh {start|stop|restart|ps|logs|info} [entorno]

# --- Configuración ---

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SERVICES=("database" "directus" "app")

# --- Argumentos y Entorno ---

COMMAND=$1
if [[ "$2" == "" || "$2" == "database" || "$2" == "directus" || "$2" == "app" ]]; then
    ENV="dev"
else
    ENV=$2
fi

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

# --- Verificación de Docker ---

check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker no está corriendo. Por favor, inicia Docker primero."
        exit 1
    fi
}

# --- Lógica de Entorno ---

prepare_env() {
    local service_dir=$1
    local env_file="$service_dir/.env.$ENV"
    if [ -f "$env_file" ]; then
        (cd "$service_dir" && ln -sf ".env.$ENV" .env)
        return 0
    else
        print_error "Archivo de entorno '$env_file' no encontrado para el stack '$service_dir'."
        return 1
    fi
}

# --- Funciones de Orquestación ---

for_each_service() {
    local func=$1
    shift
    for service_dir in "${SERVICES[@]}"; do
        $func "$service_dir" "$@"
    done
}

for_each_service_reverse() {
    local func=$1
    shift
    for ((i=${#SERVICES[@]}-1; i>=0; i--)); do
        local service_dir=${SERVICES[i]}
        $func "$service_dir" "$@"
    done
}

# --- Comandos Principales ---

wait_for_services() {
    print_info "Esperando a que los servicios estén listos (máx 30s)..."

    # Wait for Next.js
    echo -n "   - Next.js (3037): "
    timeout=30
    while ! curl -s "http://localhost:3037" > /dev/null; do
        sleep 1; timeout=$((timeout-1));
        if [ $timeout -eq 0 ]; then
            echo -e "${YELLOW}Timeout. Puede que aún esté arrancando.${NC}"
            return
        fi
    done
    echo -e "${GREEN}✅ Listo${NC}"

    # Wait for Directus
    echo -n "   - Directus (8057): "
    timeout=30
    while ! curl -s "http://localhost:8057/server/health" > /dev/null; do
        sleep 1; timeout=$((timeout-1));
        if [ $timeout -eq 0 ]; then
            echo -e "${YELLOW}Timeout. Puede que aún esté arrancando.${NC}"
            return
        fi
    done
    echo -e "${GREEN}✅ Listo${NC}"

    # Check Postgres
    echo -n "   - PostgreSQL (5437): "
    if docker exec postgres pg_isready -U postgres -d directus_db > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Listo${NC}"
    else
        echo -e "${YELLOW}⚠️ No se pudo verificar.${NC}"
    fi
}

start() {
    print_message "Iniciando entorno de desarrollo en modo '$ENV'..."

    VOLUME_NAME="database_postgres_data"
    if docker volume ls -q | grep -q "^${VOLUME_NAME}$"; then
        IS_FRESH_INSTALL=false
        print_info "El volumen de la base de datos ya existe. Realizando un inicio rápido."
    else
        IS_FRESH_INSTALL=true
        print_info "El volumen de la base de datos no existe. Se realizará una configuración completa."
    fi

    print_info "Levantando contenedores..."
    for_each_service prepare_env
    for_each_service service_up

    wait_for_services

    if [ "$IS_FRESH_INSTALL" = true ]; then
        print_message "Aplicando snapshot del esquema automáticamente..."
        ./scripts/apply-snapshot.sh

        print_message "Reiniciando Directus para refrescar permisos..."
        (cd directus && docker compose restart)
    fi

    show_info
}

service_up(){
    local service_dir=$1
    (cd "$service_dir" && docker compose up -d --build --remove-orphans)
}

stop() {
    print_message "Deteniendo entorno de desarrollo..."
    for_each_service prepare_env
    for_each_service_reverse service_down
    print_message "✅ Entorno detenido."
}

service_down() {
    local service_dir=$1
    (cd "$service_dir" && docker compose down)
}

restart() {
    print_message "Reiniciando entorno de desarrollo..."
    stop
    start
}

ps() {
    print_message "Estado de los contenedores (Modo: '$ENV'):"
    for_each_service prepare_env
    for_each_service service_ps
}

service_ps() {
    local service_dir=$1
    print_info "--- Stack de $service_dir ---"
    (cd "$service_dir" && docker compose ps)
}

logs() {
    local log_service_name=$2
    if [ -z "$log_service_name" ]; then
        print_error "Debes especificar el stack: ${SERVICES[*]}"
        echo "Uso: $0 logs <stack>"
        exit 1
    fi
    for_each_service prepare_env
    for_each_service service_logs "$log_service_name"
}

service_logs() {
    local service_dir=$1
    local log_service_name=$2
    if [ "$service_dir" == "$log_service_name" ]; then
        print_info "Mostrando logs para el stack '$service_dir'... (Presiona Ctrl+C para salir)"
        (cd "$service_dir" && docker compose logs -f)
    fi
}

show_info() {
    echo
    print_message "🎉 ¡Entorno de desarrollo ('$ENV') en ejecución!"
    echo
    echo -e "${BLUE}📱 Accede a tus servicios:${NC}"
    echo -e "   • Next.js App:    ${GREEN}http://localhost:3037${NC}"
    echo -e "   • Directus CMS:   ${GREEN}http://localhost:8057${NC}"
    echo -e "   • pgAdmin:        ${GREEN}http://localhost:5057${NC}"
    echo
    echo -e "${BLUE}👤 Credenciales de acceso (modo '$ENV'):${NC}"
    echo -e "   • Directus:       (ver tu .env.dev)"
    echo -e "   • pgAdmin:        (ver tu .env.dev)"
    echo
}

# --- Procesador de Comandos ---

check_docker

case "$COMMAND" in
    start|up)
        start
        ;;
    stop|down)
        stop
        ;;
    restart)
        restart
        ;;
    ps)
        ps
        ;;
    logs)
        logs "$@"
        ;;
    info)
        show_info
        ;;
    *)
        echo "Uso: $0 {start|stop|restart|ps|logs|info} [entorno]"
        echo "  Comandos:"
        echo "    start|up      - Inicia todos los stacks (ej: start prod)"
        echo "    stop|down     - Detiene todos los stacks"
        echo "    restart     - Reinicia todos los stacks"
        echo "    ps          - Muestra el estado de los contenedores"
        echo "    logs        - Muestra los logs de un stack (ej: logs directus)"
        echo "    info        - Muestra la información de acceso"
        echo
        echo "  Entorno: dev (por defecto), prod, etc."
        exit 1
esac

exit 0
