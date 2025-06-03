#!/bin/bash
# setup-complete.sh - Script completo para configurar Jenkins con agente
# Versión: 1.0.0
# Para: Laboratorio UNIR - Pipeline Jenkins

set -e  # Exit on any error

echo "🔧 Configurando Jenkins Laboratory..."

# 1. Verificar prerequisites
echo "📋 Verificando prerequisites..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker no encontrado. Instalalo primero."; exit 1; }
if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose no encontrado."
    exit 1
fi
echo "✅ Prerequisites verificados (usando $COMPOSE_CMD)"

# 2. Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml no encontrado. Ejecuta este script desde el directorio jenkins/"
    exit 1
fi

# 3. Limpiar contenedores previos si existen
echo "🧹 Limpiando contenedores previos..."
$COMPOSE_CMD down --remove-orphans 2>/dev/null || true

# 4. Iniciar Jenkins master primero para obtener el secret
echo "📦 Iniciando Jenkins master..."
$COMPOSE_CMD up -d jenkins

# 5. Esperar que Jenkins esté listo
echo "⏳ Esperando que Jenkins esté listo..."
sleep 60

# 6. Verificar que Jenkins responda
echo "🔍 Verificando Jenkins..."
RETRIES=0
MAX_RETRIES=12
until curl -f -s http://localhost:8080/login > /dev/null 2>&1; do
    echo "   Esperando Jenkins... (intento $((RETRIES+1))/$MAX_RETRIES)"
    sleep 10
    RETRIES=$((RETRIES+1))
    if [ $RETRIES -eq $MAX_RETRIES ]; then
        echo "❌ Jenkins no responde después de $((MAX_RETRIES*10)) segundos"
        echo "🔍 Verificando logs..."
        $COMPOSE_CMD logs jenkins | tail -20
        exit 1
    fi
done
echo "✅ Jenkins está listo"

# 7. Obtener el secret del agente dinámicamente
echo "🔑 Obteniendo secret del agente..."
sleep 10  # Esperar adicional para que el agente esté configurado

# Función para obtener el secret del agente
get_agent_secret() {
    local secret=""
    local retries=0
    local max_retries=5
    
    while [ $retries -lt $max_retries ] && [ -z "$secret" ]; do
        echo "   Intentando obtener secret... (intento $((retries+1))/$max_retries)"
        
        # Método 1: Via JNLP file
        secret=$(curl -s -u "admin:admin123" "http://localhost:8080/computer/docker-agent/slave-agent.jnlp" 2>/dev/null | \
                 grep -o '<argument>[^<]*</argument>' | \
                 sed -n '2p' | \
                 sed 's/<argument>\(.*\)<\/argument>/\1/' 2>/dev/null)
        
        if [ -z "$secret" ]; then
            # Método 2: Via API JSON (fallback)
            secret=$(curl -s -u "admin:admin123" "http://localhost:8080/computer/docker-agent/config.xml" 2>/dev/null | \
                     grep -o '<secret>[^<]*</secret>' | \
                     sed 's/<secret>\(.*\)<\/secret>/\1/' 2>/dev/null)
        fi
        
        if [ -z "$secret" ]; then
            sleep 5
            retries=$((retries+1))
        fi
    done
    
    echo "$secret"
}

AGENT_SECRET=$(get_agent_secret)

if [ -n "$AGENT_SECRET" ] && [ "$AGENT_SECRET" != "placeholder" ]; then
    echo "✅ Secret obtenido: ${AGENT_SECRET:0:8}..."
    
    # 8. Actualizar el .env con el secret real
    echo "📝 Actualizando configuración con secret real..."
    if [ -f ".env" ]; then
        sed -i.bak "s/JENKINS_AGENT_SECRET=.*/JENKINS_AGENT_SECRET=$AGENT_SECRET/" .env
    else
        echo "JENKINS_AGENT_SECRET=$AGENT_SECRET" > .env
    fi
    
    # 9. Reiniciar con el secret correcto
    echo "🔄 Reiniciando con configuración completa..."
    export JENKINS_AGENT_SECRET="$AGENT_SECRET"
    $COMPOSE_CMD up -d
    
    echo "⏳ Esperando reconexión del agente..."
    sleep 30
else
    echo "⚠️  No se pudo obtener el secret automáticamente"
    echo "   El pipeline funcionará con 'agent any' en el master"
    echo "   Para configurar el agente manualmente, ejecuta: ./get-agent-secret.sh"
fi

# 10. Verificar estado de contenedores
echo "🔍 Verificando estado de contenedores..."
$COMPOSE_CMD ps

# 11. Verificar conexión del agente
echo "🔍 Verificando conexión del agente..."
sleep 15

# Obtener estado del agente con mejor manejo de errores
AGENT_CHECK=$(curl -s -u "admin:admin123" "http://localhost:8080/computer/docker-agent/api/json" 2>/dev/null || echo '{"offline":true}')
AGENT_STATUS=$(echo "$AGENT_CHECK" | grep -o '"offline":[^,}]*' | cut -d: -f2 || echo "true")

if [ "$AGENT_STATUS" = "false" ]; then
    echo "✅ Agente conectado exitosamente"
elif [ "$AGENT_STATUS" = "true" ]; then
    echo "⚠️  Agente no conectado, intentando reconectar..."
    $COMPOSE_CMD restart jenkins-agent
    sleep 20
    
    AGENT_CHECK_RETRY=$(curl -s -u "admin:admin123" "http://localhost:8080/computer/docker-agent/api/json" 2>/dev/null || echo '{"offline":true}')
    AGENT_STATUS_RETRY=$(echo "$AGENT_CHECK_RETRY" | grep -o '"offline":[^,}]*' | cut -d: -f2 || echo "true")
    
    if [ "$AGENT_STATUS_RETRY" = "false" ]; then
        echo "✅ Agente reconectado exitosamente"
    else
        echo "⚠️  Agente no conectado, pero el pipeline puede usar 'agent any' en el master"
    fi
else
    echo "⚠️  No se pudo verificar el agente, pero Jenkins está funcionando"
fi

# 12. Mostrar resumen final
echo ""
echo "🎉 ¡Setup completado exitosamente!"
echo "========================================"
echo "📍 Jenkins URL: http://localhost:8080"
echo "👤 Usuario: admin"
echo "🔑 Contraseña: admin123"
echo ""
echo "📋 Estado de servicios:"
$COMPOSE_CMD ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || $COMPOSE_CMD ps
echo ""
if [ -n "$AGENT_SECRET" ] && [ "$AGENT_SECRET" != "placeholder" ]; then
    echo "🔑 Secret del agente configurado: ${AGENT_SECRET:0:8}...${AGENT_SECRET: -8}"
    echo "   Guardado en .env para futuras ejecuciones"
fi
echo ""
echo "📋 Comandos útiles:"
echo "   $COMPOSE_CMD ps                    # Ver estado de contenedores"
echo "   $COMPOSE_CMD logs jenkins          # Ver logs de Jenkins"
echo "   $COMPOSE_CMD logs jenkins-agent    # Ver logs del agente"
echo "   $COMPOSE_CMD down                  # Detener todo"
echo "   $COMPOSE_CMD restart jenkins-agent # Reiniciar agente si hay problemas"
echo "   ./get-agent-secret.sh              # Obtener secret del agente manualmente"
echo ""
echo "🔧 Troubleshooting:"
echo "   Si el agente no se conecta: $COMPOSE_CMD down && ./setup-complete.sh"
echo "   El pipeline está configurado con 'agent any' y funcionará en el master"
echo "   Para forzar reconfiguración: rm .env && ./setup-complete.sh"
echo ""
echo "📚 Próximos pasos:"
echo "   1. Accede a Jenkins en http://localhost:8080"
echo "   2. Crea un nuevo Pipeline Job"
echo "   3. Configura el repositorio Git del proyecto"
echo "   4. Usa el Jenkinsfile incluido en este directorio"
echo ""
echo "🚀 ¡Listo para ejecutar pipelines!"
