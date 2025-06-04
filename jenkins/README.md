# 🚀 Laboratorio de Jenkins Pipeline - UNIR

Este directorio contiene todos los archivos necesarios para implementar y ejecutar el laboratorio de desarrollo de pipeline de Jenkins para el proyecto FinTech Calculator.

## ✅ STATUS: JENKINS IS RUNNING SUCCESSFULLY!

### 🎯 Objetivo
Implementar un laboratorio completo de Jenkins con Docker que incluya un pipeline CICD avanzado con múltiples etapas de testing, archivado de artefactos y notificaciones.

### 🛠️ Arquitectura
- **Jenkins Master** en contenedor Docker con plugins preinstalados
- **Jenkins Agent** para ejecución distribuida
- **Pipeline CICD** con 6 etapas: Source, Build, Unit Tests, Behavior Tests, API Tests, E2E Tests, Security Tests
- **Configuración automática** via Jenkins Configuration as Code (JCasC)
- **Security Tests** incluye análisis con Bandit y Pylint

### 🚀 Estado Actual
- ✅ Jenkins servidor funcionando en http://localhost:8080
- ✅ Contenedores Docker ejecutándose correctamente
- ✅ Configuración JCasC aplicada exitosamente  
- ✅ Plugins instalados y cargados
- ✅ Usuario admin configurado (admin/admin123)


### 🏃‍♂️ Inicio Rápido

1. **Iniciar Jenkins**:
   ```bash
   cd jenkins/
   docker compose up -d
   ```

2. **Acceder a Jenkins**:
   - URL: http://localhost:8080
   - Usuario: `admin`
   - Contraseña: `admin123`

3. **Obtener token del agente** (si es necesario):
   ```bash
   chmod +x get-agent-secret.sh
   ./get-agent-secret.sh
   ```

## 🎯 ¿Qué hace este laboratorio?

Este proyecto implementa un **pipeline CI/CD completo** para una aplicación calculadora Python que se ejecuta en contenedores Docker. El pipeline incluye múltiples etapas de testing con reportes y archivado de artefactos.

### 🔄 Etapas del Pipeline

1. **Source**: Clonado del código fuente desde Git
2. **Build**: Construcción de la imagen Docker de la aplicación
3. **Unit Tests**: Ejecución de pruebas unitarias con pytest
4. **Behavior Tests**: Pruebas de comportamiento con Behave (BDD)
5. **API Tests**: Pruebas de API REST con configuración multi-contenedor
6. **E2E Tests**: Pruebas end-to-end con Cypress
7. **Security Tests**: Análisis de seguridad con Bandit y Pylint

### 🏗️ Arquitectura Técnica

- **Jenkins Master**: Contenedor principal con Docker-in-Docker
- **File Copying Strategy**: Uso de `docker cp` para transferir archivos entre contenedores
- **Multi-container Testing**: Redes Docker para pruebas que requieren múltiples servicios
- **Artifact Management**: Archivado automático de reportes y resultados
- **Error Handling**: Manejo robusto de errores para evitar fallos del pipeline

### 📊 Reportes Generados

- Reportes de pruebas unitarias (JUnit XML)
- Reportes de pruebas de comportamiento (JSON)
- Reportes de pruebas API
- Reportes de pruebas E2E (Cypress)
- Reportes de seguridad (Bandit, Pylint)
- Reporte consolidado HTML

## 🔧 Configuración del Agente

Si necesitas configurar un agente Jenkins distribuido:

1. **Obtener el secret del agente**:
   ```bash
   ./get-agent-secret.sh
   ```

2. **Actualizar docker-compose.yml** con el nuevo secret si es necesario

3. **Reiniciar el stack**:
   ```bash
   docker compose down
   docker compose up -d
   ```

## 🔧 Pipeline CICD

El pipeline implementa las siguientes etapas:

### 📋 Etapas del Pipeline

1. **Source** - Checkout del código fuente
2. **Build** - Construcción de la imagen Docker de la aplicación calculator
3. **Unit Tests** - Ejecución de tests unitarios con pytest y generación de coverage
4. **Behavior Tests** - Tests de comportamiento con behave (BDD)
5. **API Tests** - Tests de API REST con requests
6. **E2E Tests** - Tests end-to-end con Cypress
7. **Security Tests** - Análisis de seguridad con Bandit y Pylint

### 🛡️ Security Tests

La etapa de Security Tests incluye:
- **Bandit**: Análisis de seguridad estático del código Python
- **Pylint**: Análisis de calidad de código y detección de problemas de seguridad
- **Reportes**: Generación de reportes en formato JSON, texto y HTML consolidado

### 📊 Reportes y Artefactos

Cada etapa genera reportes que se archivan automáticamente:
- Tests unitarios: XML JUnit, coverage HTML/XML
- Behavior tests: XML JUnit, reportes HTML
- API tests: XML JUnit, reportes HTML  
- E2E tests: XML JUnit, videos y screenshots de Cypress
- Security tests: Reportes JSON/texto de Bandit y Pylint, resumen HTML

### 🐳 Estrategia Docker-in-Docker

El pipeline utiliza una estrategia de **copia de archivos** para superar las limitaciones de Docker-in-Docker:
- Cada etapa crea contenedores temporales
- Copia el workspace al contenedor usando `docker cp`
- Ejecuta las pruebas dentro del contenedor
- Copia los resultados de vuelta al workspace
- Limpia los contenedores temporales

Esta estrategia es más robusta que el montaje de volúmenes en entornos Docker-in-Docker.

## 📋 Próximos Pasos

Una vez que Jenkins esté ejecutándose, puedes:

1. **Crear el Pipeline Job**:
   - Ir a Jenkins → New Item → Pipeline
   - Configurar Git repository URL
   - Seleccionar "Pipeline script from SCM"
   - Usar el `Jenkinsfile` incluido en el proyecto

2. **Ejecutar el Pipeline**:
   - Hacer clic en "Build Now"
   - Monitorear la ejecución de todas las etapas
   - Revisar reportes y artefactos generados

3. **Personalizar la Configuración** (opcional):
   - Modificar `jenkins-config/jenkins.yaml` para configuración avanzada
   - Agregar plugins en `jenkins-config/plugins.txt`
   - Configurar notificaciones por email o Slack

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

## 🐛 Solución de Problemas Comunes

### Jenkins no responde
```bash
# Verificar logs
docker compose logs jenkins

# Reiniciar si es necesario
docker compose restart jenkins
```

### Puerto 8080 ocupado
```bash
# Verificar qué proceso usa el puerto
lsof -i :8080

# Cambiar puerto en docker-compose.yml si es necesario
# ports: ["8081:8080"]
```

### Agente no conectado
```bash
# Obtener nuevo secret del agente
./get-agent-secret.sh

# Reiniciar servicios
docker compose down
docker compose up -d
```

### Tests fallan
```bash
# Verificar imagen de la aplicación
docker images calculator-app

# Reconstruir si es necesario
make build
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
