#!/bin/bash

# Script para obtener el secret del agente Jenkins
JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_PASS="admin123"
AGENT_NAME="docker-agent"

echo "🔑 Obteniendo secret del agente Jenkins..."

# Obtener el secret usando el método correcto
SECRET=$(curl -s -u "$JENKINS_USER:$JENKINS_PASS" "$JENKINS_URL/computer/$AGENT_NAME/slave-agent.jnlp" | grep -o '<argument>[^<]*</argument>' | head -1 | sed 's/<argument>\(.*\)<\/argument>/\1/')

if [ -z "$SECRET" ]; then
    echo "❌ Error: No se pudo obtener el secret del agente"
    echo "   Verifica que Jenkins esté ejecutándose y el agente 'docker-agent' exista"
    exit 1
fi

echo ""
echo "🎉 ¡Secret obtenido exitosamente!"
echo "========================================"
echo "$SECRET"
echo ""
echo "📝 INSTRUCCIONES:"
echo "   1. Copia el secret mostrado arriba"
echo "   2. Edita el archivo .env"
echo "   3. Reemplaza la línea JENKINS_AGENT_SECRET=_change_me_"
echo "   4. Por: JENKINS_AGENT_SECRET=$SECRET"
echo ""
echo "🔄 Después ejecuta:"
echo "   docker compose down && docker compose up -d"

# Mostrar resultado exitoso
echo ""
echo "🎉 ¡Secret obtenido exitosamente!"
echo "========================================"
echo "🔑 Secret del agente '$AGENT_NAME':"
echo "    ${SECRET}"
echo ""
echo "📋 Información del secret:"
echo "   Método: $METHOD"
echo "   Longitud: ${#SECRET} caracteres"
echo "   Preview: ${SECRET:0:8}...${SECRET: -8}"
echo ""
echo "📝 INSTRUCCIONES:"
echo "   1. Copia el secret mostrado arriba"
echo "   2. Edita el archivo .env"
echo "   3. Reemplaza la línea JENKINS_AGENT_SECRET=changeme123"
echo "   4. Por: JENKINS_AGENT_SECRET=$SECRET"
echo ""
echo "🔄 Después ejecuta:"
echo "   docker compose down && docker compose up -d"
