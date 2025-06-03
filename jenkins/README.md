# 🚀 Laboratorio de Jenkins Pipeline - UNIR

Este directorio contiene todos los archivos necesarios para implementar y ejecutar el laboratorio de desarrollo de pipeline de Jenkins para el proyecto FinTech Calculator.

## ✅ STATUS: JENKINS IS RUNNING SUCCESSFULLY!

### 🎯 Objetivo
Implementar un laboratorio completo de Jenkins con Docker que incluya un pipeline CICD avanzado con múltiples etapas de testing, archivado de artefactos y notificaciones.

### 🛠️ Arquitectura
- **Jenkins Master** en contenedor Docker con plugins preinstalados
- **Jenkins Agent** para ejecución distribuida
- **Pipeline CICD** con 7 etapas: Source, Build, Unit Tests, Behavior Tests, API Tests, E2E Tests, Security Tests
- **Configuración automática** via Jenkins Configuration as Code (JCasC)

### 🚀 Estado Actual
- ✅ Jenkins servidor funcionando en http://localhost:8080
- ✅ Contenedores Docker ejecutándose correctamente
- ✅ Configuración JCasC aplicada exitosamente  
- ✅ Plugins instalados y cargados
- ✅ Usuario admin configurado (admin/admin123)

## 📁 Estructura del Proyecto

```
jenkins/
├── docker-compose.yml          # Configuración Docker Compose
├── Dockerfile                  # Imagen Jenkins personalizada
├── Jenkinsfile                 # Pipeline CICD completo
├── setup.sh                   # Script de automatización
├── verify.sh                  # Script de verificación
├── .env                       # Variables de entorno
├── jenkins-config/
│   ├── jenkins.yaml           # Configuración JCasC (FIXED)
│   └── plugins.txt           # Lista de plugins
└── README.md                 # Este archivo
```

### 🏃‍♂️ Inicio Rápido

1. **Iniciar Jenkins**:
   ```bash
   cd jenkins/
   docker compose up -d
   ```

2. **Verificar estado**:
   ```bash
   docker compose ps
   docker compose logs jenkins
   ```

3. **Acceder a Jenkins**:
   - URL: http://localhost:8080
   - Usuario: `admin`
   - Contraseña: `admin123`

## 🔧 Configuración del Agente (Setup Completo)

### 📋 REPLICACIÓN EXACTA - Pasos para Otro Equipo

**⚠️ IMPORTANTE**: La configuración actual funciona con un secret específico. Para replicar exactamente:

#### **Opción A: Replicación Directa (Recomendada)**
```bash
# 1. Clonar el repositorio
git clone <repository-url>
cd jenkins/

# 2. Levantar todo el stack directamente
docker compose up -d

# 3. Esperar inicialización completa (≈60 segundos)
sleep 60

# 4. Verificar estado
docker compose ps
curl -f http://localhost:8080/login

# 5. Acceder a Jenkins
# URL: http://localhost:8080
# Usuario: admin
# Contraseña: admin123
```

**✅ Esta opción funciona porque el secret actual está incluido en el docker-compose.yml**

#### **Opción B: Configuración Paso a Paso**

1. **Clonar y Preparar el Entorno**:
   ```bash
   git clone <repository-url>
   cd jenkins/
   ```

2. **Primer Inicio (Solo Master)**:
   ```bash
   # Comentar temporalmente el servicio jenkins-agent en docker-compose.yml
   # O iniciar solo el master:
   docker compose up -d jenkins
   
   # Esperar que Jenkins esté completamente iniciado
   sleep 45
   
   # Verificar que Jenkins responde
   curl -f http://localhost:8080/login || echo "Jenkins aún no está listo"
   ```

3. **Configurar el Agente Jenkins** (si se desea usar agente distribuido):
   
   **Paso 3.1: Obtener el Secret del Agente**
   ```bash
   # Usar el script incluido para obtener el secret
   chmod +x get-agent-secret.sh
   ./get-agent-secret.sh
   
   # O manualmente:
   curl -s -u "admin:admin123" "http://localhost:8080/computer/docker-agent/slave-agent.jnlp" | \
   grep -o '<argument>[^<]*</argument>' | sed -n '1p' | sed 's/<argument>\(.*\)<\/argument>/\1/'
   ```

   **Paso 3.2: Actualizar docker-compose.yml**
   ```bash
   # Reemplazar el JENKINS_SECRET en docker-compose.yml con el secret obtenido
   # Actual: JENKINS_SECRET=dedd5d7d59f3812cbff90e7c80cccd52edb713d699bce74572ea47050ebc6546
   # Nuevo: JENKINS_SECRET=<tu-nuevo-secret>
   ```

   **Paso 3.3: Reiniciar con Agente**
   ```bash
   # Reiniciar todo el stack
   docker compose down
   docker compose up -d
   
   # Verificar que el agente se conecta
   docker compose logs jenkins-agent
   ```

4. **Verificación Final**:
   ```bash
   # Verificar estado de nodos
   curl -s -u "admin:admin123" "http://localhost:8080/computer/api/json" | \
   python3 -c "import sys,json; data=json.load(sys.stdin); print('\n'.join([f'{c[\"displayName\"]}: {\"ONLINE\" if not c[\"offline\"] else \"OFFLINE\"}' for c in data['computer']]))"
   ```

### 🏆 Configuración Actual Funcionando

**Secret del agente actual**: `dedd5d7d59f3812cbff90e7c80cccd52edb713d699bce74572ea47050ebc6546`

**Estado verificado**:
- ✅ Jenkins Master: http://localhost:8080 (admin/admin123)
- ✅ Docker Compose: jenkins-server + jenkins-agent
- ✅ Agente conectado y disponible
- ✅ Pipeline configurado con `agent any` (funciona en master)

### ⚠️ Notas Importantes para Replicación

1. **El secret del agente cambia**: Cada vez que se reinicia Jenkins, se genera un nuevo secret para el agente.

2. **Configuración automática**: Si prefieres simplicidad, usa solo el master con `agent any` en el Jenkinsfile (recomendado para laboratorios).

3. **Puertos requeridos**: Asegúrate de que los puertos 8080 y 50000 estén disponibles.

4. **Docker socket**: El setup requiere acceso al socket de Docker (`/var/run/docker.sock`).

### 🔄 Setup Simplificado (Recomendado)

Para mayor simplicidad y evitar problemas con agentes:

1. **Usar solo el Master**:
   ```bash
   # El Jenkinsfile ya está configurado con 'agent any'
   # Esto ejecuta todo en el contenedor master que tiene Docker CLI
   ```

2. **Remover agente del docker-compose** (opcional):
   ```yaml
   # Comentar o eliminar la sección jenkins-agent en docker-compose.yml
   # para un setup más simple
   ```

### 📋 Próximos Pasos Después del Setup

1. **Crear el Job del Pipeline**:
   - Crear nuevo Pipeline Job
   - Configurar Git repository
   - Usar Jenkinsfile del proyecto

2. **Configurar Agent** (opcional):
   - Agregar nodo agent si es necesario
   - Configurar etiquetas y ejecutores

3. **Ejecutar Pipeline**:
   - Trigger manual del pipeline
   - Verificar ejecución de todas las etapas
   - Revisar artefactos y reportes

## 🔧 Comandos Disponibles

El script `setup.sh` proporciona los siguientes comandos:

```bash
./setup.sh init          # Inicializar y levantar Jenkins
./setup.sh stop          # Detener Jenkins
./setup.sh restart       # Reiniciar Jenkins
./setup.sh status        # Mostrar estado de contenedores
./setup.sh logs          # Mostrar logs en tiempo real
./setup.sh clean         # Limpiar todo el entorno
./setup.sh plugins       # Instalar plugins adicionales
./setup.sh sample-job    # Crear configuración de job de ejemplo
./setup.sh help          # Mostrar ayuda
```

## 📊 Monitoreo y Debugging

### Ver Logs en Tiempo Real
```bash
./setup.sh logs
```

### Verificar Estado de Contenedores
```bash
./setup.sh status
```

### Información de Debug
El pipeline incluye comandos automáticos de debug en caso de fallo:
- Espacio en disco disponible
- Estado de contenedores Docker
- Estado de redes Docker
- Información del sistema

## 🔧 Configuración Avanzada

### Variables de Entorno

Edita el archivo `.env` para personalizar:
- Secretos de agentes Jenkins
- Configuración SMTP para correos
- Tokens de GitHub/SonarQube
- Puertos de red

### Configuración como Código (JCasC)

El archivo `jenkins-config/jenkins.yaml` contiene:
- Configuración de seguridad
- Usuarios y permisos
- Configuración de nodos/agentes
- Configuración de plugins
- Jobs predefinidos

### Plugins Personalizados

Modifica `jenkins-config/plugins.txt` para añadir plugins adicionales.

## 🐛 Solución de Problemas

### Problema: Puerto 8080 ya en uso
```bash
# Verificar qué proceso usa el puerto
lsof -i :8080

# Cambiar puerto en docker-compose.yml
ports:
  - "8081:8080"
```

### Problema: Jenkins no arranca
```bash
# Verificar logs
docker logs jenkins-server

# Reiniciar completamente
./setup.sh clean
./setup.sh init
```

### Problema: Tests fallan
```bash
# Verificar imagen Docker
docker images calculator-app

# Rebuilder si es necesario
make build
```

### 🚀 Script de Setup Automático

Para replicar fácilmente en otro equipo, puedes usar este script:

```bash
#!/bin/bash
# setup-complete.sh - Script completo para configurar Jenkins con agente

echo "🔧 Configurando Jenkins Laboratory..."

# 1. Verificar prerequisites
echo "📋 Verificando prerequisites..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker no encontrado. Instalalo primero."; exit 1; }
command -v docker-compose >/dev/null 2>&1 || command -v docker compose >/dev/null 2>&1 || { echo "❌ Docker Compose no encontrado."; exit 1; }

# 2. Iniciar Jenkins completo (con secret preconfigurado)
echo "📦 Iniciando Jenkins Laboratory completo..."
docker compose up -d
sleep 60  # Esperar que Jenkins esté completamente listo

# 3. Verificar que Jenkins responda
echo "🔍 Verificando Jenkins..."
RETRIES=0
MAX_RETRIES=12
until curl -f -s http://localhost:8080/login > /dev/null; do
    echo "   Esperando Jenkins... (intento $((RETRIES+1))/$MAX_RETRIES)"
    sleep 10
    RETRIES=$((RETRIES+1))
    if [ $RETRIES -eq $MAX_RETRIES ]; then
        echo "❌ Jenkins no responde después de $((MAX_RETRIES*10)) segundos"
        echo "🔍 Verificando logs..."
        docker compose logs jenkins | tail -20
        exit 1
    fi
done
echo "✅ Jenkins está listo"

# 4. Verificar estado de contenedores
echo "🔍 Verificando estado de contenedores..."
docker compose ps

# 5. Verificar conexión del agente
echo "🔍 Verificando conexión del agente..."
sleep 10
AGENT_STATUS=$(curl -s -u "admin:admin123" "http://localhost:8080/computer/docker-agent/api/json" 2>/dev/null | grep -o '"offline":[^,]*' | cut -d: -f2)

if [ "$AGENT_STATUS" = "false" ]; then
    echo "✅ Agente conectado exitosamente"
elif [ "$AGENT_STATUS" = "true" ]; then
    echo "⚠️  Agente no conectado, pero Jenkins funciona con master"
    echo "🔄 Intentando reconectar agente..."
    docker compose restart jenkins-agent
    sleep 15
    AGENT_STATUS_RETRY=$(curl -s -u "admin:admin123" "http://localhost:8080/computer/docker-agent/api/json" 2>/dev/null | grep -o '"offline":[^,]*' | cut -d: -f2)
    if [ "$AGENT_STATUS_RETRY" = "false" ]; then
        echo "✅ Agente reconectado exitosamente"
    else
        echo "⚠️  Agente no conectado, pero el pipeline puede usar 'agent any' en el master"
    fi
else
    echo "⚠️  No se pudo verificar el agente, pero Jenkins está funcionando"
fi

echo ""
echo "🎉 ¡Setup completado!"
echo "📍 Jenkins URL: http://localhost:8080"
echo "👤 Usuario: admin"
echo "🔑 Contraseña: admin123"
echo ""
echo "📋 Estado de servicios:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "📋 Comandos útiles:"
echo "   docker compose ps                    # Ver estado de contenedores"
echo "   docker compose logs jenkins          # Ver logs de Jenkins"
echo "   docker compose logs jenkins-agent    # Ver logs del agente"
echo "   docker compose down                  # Detener todo"
echo "   docker compose restart jenkins-agent # Reiniciar agente si hay problemas"
echo ""
echo "🔧 Troubleshooting:"
echo "   Si el agente no se conecta: docker compose down && docker compose up -d"
echo "   El pipeline está configurado con 'agent any' y funcionará en el master"
```

**Uso del script**:
```bash
chmod +x setup-complete.sh
./setup-complete.sh
```

### 📦 Script de Setup Completo (Descarga Directa)

También puedes crear este script rápidamente:

```bash
# Crear script de setup
cat > setup-complete.sh << 'EOF'
#!/bin/bash
echo "🔧 Configurando Jenkins Laboratory..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker requerido"; exit 1; }
echo "📦 Iniciando Jenkins..."
docker compose up -d
sleep 60
echo "🔍 Verificando Jenkins..."
until curl -f -s http://localhost:8080/login > /dev/null; do sleep 10; done
echo "✅ Jenkins listo en http://localhost:8080(admin/admin123)"
docker compose ps
EOF

chmod +x setup-complete.sh
./setup-complete.sh
```

### 🔧 Troubleshooting Común

**Problema**: Agente no se conecta
```bash
# Solución 1: Reiniciar todo
docker compose down && docker compose up -d

# Solución 2: Usar solo master
# Editar Jenkinsfile para usar 'agent any' (ya configurado)
```

**Problema**: Puerto 8080 ocupado
```bash
# Verificar qué usa el puerto
lsof -i :8080

# Cambiar puerto en docker-compose.yml si es necesario
# ports: ["9080:8080"]
```

**Problema**: Permisos de Docker socket
```bash
# En Linux, agregar usuario al grupo docker
sudo usermod -aG docker $USER
# Reiniciar sesión
```

## 📈 Mejores Prácticas

1. **Versioning**: Usa tags específicos en lugar de `latest` en producción
2. **Secrets**: Nunca hardcodees credenciales en el Jenkinsfile
3. **Parallelización**: Considera ejecutar tests en paralelo para mejor performance
4. **Cleanup**: Siempre limpia recursos Docker después de los tests
5. **Monitoring**: Configura alertas para fallos críticos del pipeline

## 🔐 Seguridad

- Cambia las credenciales por defecto antes de usar en producción
- Configura HTTPS para Jenkins en entornos públicos
- Utiliza el plugin de roles para gestión de permisos
- Mantén Jenkins y plugins actualizados

## 📚 Recursos Adicionales

- [Documentación oficial de Jenkins](https://www.jenkins.io/doc/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Jenkins Configuration as Code](https://github.com/jenkinsci/configuration-as-code-plugin)

## 🤝 Contribución

Para contribuir a este laboratorio:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Crea un Pull Request

## 📞 Soporte

Para soporte técnico o preguntas sobre el laboratorio:
- Revisa la documentación oficial de UNIR
- Consulta los logs de Jenkins con `./setup.sh logs`
- Verifica el estado con `./setup.sh status`

---

**Desarrollado para el Laboratorio de CICD - UNIR**  
*Versión: 1.0.0*  
*Última actualización: Junio 2025*
