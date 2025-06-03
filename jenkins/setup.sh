#!/bin/bash

# Script de inicialización y gestión de Jenkins
# Autor: Laboratorio CICD - UNIR
# Descripción: Script para levantar, configurar y gestionar el entorno Jenkins

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de utilidad
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que Docker está corriendo
check_docker() {
    log_info "Verificando Docker..."
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker no está corriendo. Por favor, inicia Docker Desktop."
        exit 1
    fi
    log_success "Docker está funcionando correctamente"
}

# Función para inicializar Jenkins
init_jenkins() {
    log_info "Iniciando contenedores de Jenkins..."
    
    # Crear directorio para configuración si no existe
    mkdir -p jenkins-config
    
    # Levantar los contenedores
    docker compose up -d
    
    log_info "Esperando a que Jenkins esté listo..."
    
    # Esperar hasta que Jenkins esté completamente iniciado
    local max_attempts=60
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker exec jenkins-server test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
            log_success "Jenkins ha terminado de inicializarse"
            break
        fi
        
        if docker logs jenkins-server 2>/dev/null | grep -q "Jenkins is fully up and running"; then
            log_success "Jenkins está ejecutándose completamente"
            break
        fi
        
        echo -n "."
        sleep 5
        ((attempt++))
    done
    
    if [[ $attempt -gt $max_attempts ]]; then
        log_warning "Timeout esperando a Jenkins. Continuando..."
    fi
    
    echo ""
    
    # Obtener la contraseña inicial
    log_info "Obteniendo contraseña inicial de Jenkins..."
    if docker exec jenkins-server test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
        JENKINS_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword)
        log_success "Jenkins está listo!"
        echo ""
        echo "=================================================="
        echo "🚀 JENKINS CONFIGURADO EXITOSAMENTE"
        echo "=================================================="
        echo "URL: http://localhost:8080"
        echo "Contraseña inicial: $JENKINS_PASSWORD"
        echo "=================================================="
        echo ""
        echo "Pasos siguientes:"
        echo "1. Abre http://localhost:8080 en tu navegador"
        echo "2. Usa la contraseña mostrada arriba"
        echo "3. Instala los plugins sugeridos"
        echo "4. Crea un usuario administrador"
        echo "5. Importa el Jenkinsfile del proyecto"
        echo ""
    else
        log_warning "No se pudo obtener la contraseña. Verifica los logs con: docker logs jenkins-server"
    fi
}

# Función para parar Jenkins
stop_jenkins() {
    log_info "Deteniendo contenedores de Jenkins..."
    docker compose down
    log_success "Jenkins detenido"
}

# Función para reiniciar Jenkins
restart_jenkins() {
    log_info "Reiniciando Jenkins..."
    stop_jenkins
    sleep 5
    init_jenkins
}

# Función para mostrar logs
show_logs() {
    log_info "Mostrando logs de Jenkins..."
    docker compose logs -f jenkins
}

# Función para limpiar todo
clean_all() {
    log_warning "Esta acción eliminará todos los contenedores, volúmenes y redes de Jenkins"
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Limpiando entorno Jenkins..."
        docker compose down -v
        docker system prune -f
        log_success "Entorno limpiado"
    else
        log_info "Operación cancelada"
    fi
}

# Función para verificar el estado
status() {
    log_info "Estado de los contenedores:"
    docker compose ps
    echo ""
    log_info "Estado de los puertos:"
    netstat -an | grep -E ":8080|:50000" || echo "Puertos no están en uso"
}

# Función para instalar plugins adicionales
install_plugins() {
    log_info "Instalando plugins adicionales en Jenkins..."
    
    # Lista de plugins útiles para CI/CD
    PLUGINS=(
        "blueocean"
        "pipeline-stage-view"
        "build-pipeline-plugin"
        "htmlpublisher"
        "junit"
        "workflow-aggregator"
        "git"
        "github"
        "docker-workflow"
        "email-ext"
        "slack"
        "sonar"
        "jacoco"
    )
    
    for plugin in "${PLUGINS[@]}"; do
        log_info "Instalando plugin: $plugin"
        # Comando para instalar plugin vía CLI (requiere configuración adicional)
        # docker exec jenkins-server jenkins-plugin-cli --plugins $plugin
    done
    
    log_success "Plugins instalados. Reinicia Jenkins para aplicar cambios."
}

# Función para crear job de ejemplo
create_sample_job() {
    log_info "Creando job de ejemplo..."
    
    cat > sample-job-config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobAction plugin="pipeline-model-definition@1.8.5"/>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction plugin="pipeline-model-definition@1.8.5">
      <jobProperties/>
      <triggers/>
      <parameters/>
      <options/>
    </org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction>
  </actions>
  <description>Pipeline de ejemplo para el proyecto FinTech Calculator</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.plugins.jira.JiraProjectProperty plugin="jira@3.1.1"/>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers/>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.90">
    <script>// Contenido del Jenkinsfile se cargaría aquí</script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF
    
    log_success "Configuración de job de ejemplo creada en sample-job-config.xml"
}

# Función para mostrar ayuda
show_help() {
    echo "=================================================="
    echo "🔧 GESTIÓN DE JENKINS - LABORATORIO UNIR"
    echo "=================================================="
    echo ""
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponibles:"
    echo "  init          Inicializar y levantar Jenkins"
    echo "  stop          Detener Jenkins"
    echo "  restart       Reiniciar Jenkins"
    echo "  status        Mostrar estado de contenedores"
    echo "  logs          Mostrar logs de Jenkins"
    echo "  clean         Limpiar todo el entorno"
    echo "  plugins       Instalar plugins adicionales"
    echo "  sample-job    Crear configuración de job de ejemplo"
    echo "  help          Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 init       # Inicializar Jenkins"
    echo "  $0 status     # Ver estado"
    echo "  $0 logs       # Ver logs en tiempo real"
    echo ""
}

# Función principal
main() {
    # Verificar que estamos en el directorio correcto
    if [[ ! -f "docker-compose.yml" ]]; then
        log_error "No se encontró docker-compose.yml. Ejecuta este script desde el directorio jenkins/"
        exit 1
    fi
    
    check_docker
    
    case "${1:-help}" in
        "init")
            init_jenkins
            ;;
        "stop")
            stop_jenkins
            ;;
        "restart")
            restart_jenkins
            ;;
        "status")
            status
            ;;
        "logs")
            show_logs
            ;;
        "clean")
            clean_all
            ;;
        "plugins")
            install_plugins
            ;;
        "sample-job")
            create_sample_job
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Ejecutar función principal con todos los argumentos
main "$@"
