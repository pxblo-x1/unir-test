#!/bin/bash

# Script de verificación del entorno Jenkins
# Verifica que todos los componentes estén funcionando correctamente

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "=================================================="
echo "🔍 VERIFICACIÓN DEL ENTORNO JENKINS"
echo "=================================================="
echo ""

# Verificar Docker
log_info "Verificando Docker..."
if docker info > /dev/null 2>&1; then
    log_success "Docker está funcionando"
    docker --version
else
    log_error "Docker no está funcionando"
    exit 1
fi

echo ""

# Verificar contenedores
log_info "Verificando contenedores de Jenkins..."
if docker compose ps | grep -q "jenkins-server"; then
    JENKINS_STATUS=$(docker compose ps jenkins-server | tail -n 1 | awk '{print $4}')
    if [[ "$JENKINS_STATUS" == "Up" ]]; then
        log_success "Jenkins Server está ejecutándose"
    else
        log_warning "Jenkins Server no está en estado Up: $JENKINS_STATUS"
    fi
else
    log_warning "Jenkins Server no encontrado"
fi

if docker compose ps | grep -q "jenkins-agent"; then
    AGENT_STATUS=$(docker compose ps jenkins-agent | tail -n 1 | awk '{print $4}')
    if [[ "$AGENT_STATUS" == "Up" ]]; then
        log_success "Jenkins Agent está ejecutándose"
    else
        log_warning "Jenkins Agent no está en estado Up: $AGENT_STATUS"
    fi
else
    log_warning "Jenkins Agent no encontrado"
fi

echo ""

# Verificar conectividad
log_info "Verificando conectividad..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|403"; then
    log_success "Jenkins Web UI es accesible en http://localhost:8080"
else
    log_warning "Jenkins Web UI no responde en http://localhost:8080"
fi

echo ""

# Verificar puertos
log_info "Verificando puertos..."
if netstat -an | grep -q ":8080.*LISTEN"; then
    log_success "Puerto 8080 está en uso (Jenkins Web)"
else
    log_warning "Puerto 8080 no está en uso"
fi

if netstat -an | grep -q ":50000.*LISTEN"; then
    log_success "Puerto 50000 está en uso (Jenkins Agent)"
else
    log_warning "Puerto 50000 no está en uso"
fi

echo ""

# Verificar volúmenes
log_info "Verificando volúmenes de Docker..."
if docker volume ls | grep -q "jenkins_jenkins_home"; then
    log_success "Volumen jenkins_home existe"
    VOLUME_SIZE=$(docker volume inspect jenkins_jenkins_home | jq -r '.[0].Mountpoint' | xargs du -sh 2>/dev/null | cut -f1 || echo "N/A")
    echo "  Tamaño: $VOLUME_SIZE"
else
    log_warning "Volumen jenkins_home no encontrado"
fi

echo ""

# Verificar archivos de configuración
log_info "Verificando archivos de configuración..."
CONFIG_FILES=(
    "docker-compose.yml"
    "Jenkinsfile"
    ".env"
    "jenkins-config/jenkins.yaml"
    "jenkins-config/plugins.txt"
)

for file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        log_success "✓ $file"
    else
        log_error "✗ $file (no encontrado)"
    fi
done

echo ""

# Verificar logs de Jenkins
log_info "Verificando logs recientes de Jenkins..."
if docker logs jenkins-server --tail 5 2>/dev/null | grep -q "Jenkins is fully up and running"; then
    log_success "Jenkins está completamente inicializado"
elif docker logs jenkins-server --tail 10 2>/dev/null | grep -q "ERROR"; then
    log_warning "Se encontraron errores en los logs de Jenkins"
    echo "Últimos logs:"
    docker logs jenkins-server --tail 5
else
    log_info "Jenkins podría estar todavía inicializándose"
fi

echo ""

# Verificar espacio en disco
log_info "Verificando espacio en disco..."
DISK_USAGE=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
if [[ $DISK_USAGE -lt 80 ]]; then
    log_success "Espacio en disco suficiente (${DISK_USAGE}% usado)"
else
    log_warning "Poco espacio en disco (${DISK_USAGE}% usado)"
fi

echo ""

# Verificar imagen de la aplicación
log_info "Verificando imagen de la aplicación..."
if docker images | grep -q "calculator-app"; then
    log_success "Imagen calculator-app existe"
    IMAGE_SIZE=$(docker images calculator-app:latest --format "table {{.Size}}" | tail -1)
    echo "  Tamaño: $IMAGE_SIZE"
else
    log_warning "Imagen calculator-app no encontrada (ejecuta 'make build')"
fi

echo ""

# Resumen final
echo "=================================================="
echo "📊 RESUMEN DE VERIFICACIÓN"
echo "=================================================="

TOTAL_CHECKS=8
PASSED_CHECKS=0

# Contar checks pasados (simplificado)
docker info > /dev/null 2>&1 && ((PASSED_CHECKS++))
docker compose ps jenkins-server | grep -q "Up" && ((PASSED_CHECKS++))
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|403" && ((PASSED_CHECKS++))
netstat -an | grep -q ":8080.*LISTEN" && ((PASSED_CHECKS++))
[[ -f "docker-compose.yml" ]] && ((PASSED_CHECKS++))
[[ -f "Jenkinsfile" ]] && ((PASSED_CHECKS++))
docker volume ls | grep -q "jenkins_jenkins_home" && ((PASSED_CHECKS++))
[[ $DISK_USAGE -lt 80 ]] && ((PASSED_CHECKS++))

PERCENTAGE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

if [[ $PERCENTAGE -ge 80 ]]; then
    log_success "Verificación completada: $PASSED_CHECKS/$TOTAL_CHECKS checks pasados ($PERCENTAGE%)"
    echo ""
    echo "🎉 El entorno Jenkins está listo para usar!"
    echo "Accede a: http://localhost:8080"
elif [[ $PERCENTAGE -ge 60 ]]; then
    log_warning "Verificación parcial: $PASSED_CHECKS/$TOTAL_CHECKS checks pasados ($PERCENTAGE%)"
    echo ""
    echo "⚠️  El entorno tiene algunas advertencias, pero debería funcionar"
else
    log_error "Verificación fallida: $PASSED_CHECKS/$TOTAL_CHECKS checks pasados ($PERCENTAGE%)"
    echo ""
    echo "❌ El entorno necesita configuración adicional"
    echo "Ejecuta: ./setup.sh init"
fi

echo ""
echo "Para más información, ejecuta: ./setup.sh help"
