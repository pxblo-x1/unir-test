# 📚 Guía Paso a Paso - Laboratorio Jenkins Pipeline

Esta guía te llevará paso a paso para completar el laboratorio de desarrollo de pipeline de Jenkins.

## 🎯 Objetivos del Laboratorio

Al finalizar este laboratorio, habrás:
- ✅ Configurado un entorno Jenkins completo con Docker
- ✅ Implementado un pipeline con múltiples etapas
- ✅ Configurado archivado de artefactos y reportes
- ✅ Implementado notificaciones por correo
- ✅ Documentado todo el proceso

## 📋 Prerrequisitos

Antes de comenzar, asegúrate de tener:
- [ ] Docker Desktop instalado y funcionando
- [ ] Git instalado
- [ ] Al menos 4GB de RAM libre
- [ ] Puertos 8080 y 50000 disponibles
- [ ] Acceso a internet para descargar imágenes Docker

## 🚀 Paso 1: Preparación del Entorno

### 1.1 Navegar al directorio Jenkins
```bash
cd jenkins
```

### 1.2 Verificar archivos necesarios
```bash
ls -la
```

Deberías ver:
- `docker-compose.yml`
- `Jenkinsfile`
- `setup.sh`
- `.env`
- `jenkins-config/`

### 1.3 Hacer scripts ejecutables
```bash
chmod +x setup.sh verify.sh
```

## 🔧 Paso 2: Inicializar Jenkins

### 2.1 Levantar el entorno
```bash
./setup.sh init
```

Este comando:
- Descarga las imágenes Docker necesarias
- Crea los contenedores de Jenkins
- Configura la red
- Muestra la contraseña inicial

### 2.2 Tomar nota de la información mostrada
```
================================================
🚀 JENKINS CONFIGURADO EXITOSAMENTE
================================================
URL: http://localhost:8080
Contraseña inicial: [ANOTA ESTA CONTRASEÑA]
================================================
```

**📝 IMPORTANTE**: Anota la contraseña inicial mostrada.

## 🌐 Paso 3: Configuración Inicial de Jenkins

### 3.1 Acceder a Jenkins
1. Abre tu navegador web
2. Ve a: `http://localhost:8080`
3. Introduce la contraseña inicial anotada anteriormente

### 3.2 Configuración del asistente
1. **Instalar plugins**:
   - Selecciona "Install suggested plugins"
   - Espera a que se instalen (puede tomar 5-10 minutos)

2. **Crear usuario administrador**:
   - Usuario: `admin`
   - Contraseña: `admin123` (o la que prefieras)
   - Nombre completo: `Administrador Jenkins`
   - Email: `admin@empresa.com`

3. **Configurar URL de Jenkins**:
   - Deja la URL por defecto: `http://localhost:8080/`
   - Click "Save and Continue"

4. **Finalizar**:
   - Click "Start using Jenkins"

## 📦 Paso 4: Preparar la Aplicación

### 4.1 Volver al directorio raíz del proyecto
```bash
cd ..
```

### 4.2 Construir la imagen Docker de la aplicación
```bash
make build
```

### 4.3 Verificar que la imagen se creó
```bash
docker images | grep calculator-app
```

## 🔗 Paso 5: Crear el Pipeline Job

### 5.1 En Jenkins, crear nuevo trabajo
1. Click en "New Item" (Nuevo Elemento)
2. Nombre: `FinTech-CICD-Pipeline`
3. Tipo: "Pipeline"
4. Click "OK"

### 5.2 Configurar el pipeline
1. **Descripción**: 
   ```
   Pipeline de CI/CD para el proyecto FinTech Calculator - Laboratorio UNIR
   ```

2. **Pipeline Configuration**:
   - Definition: "Pipeline script"
   - Copia el contenido completo del archivo `jenkins/Jenkinsfile`
   - Pégalo en el campo "Script"

3. **Configuraciones adicionales**:
   - ✅ Marcar "Discard old builds"
   - Days to keep builds: `30`
   - Max # of builds to keep: `10`

### 5.3 Guardar configuración
- Click "Save"

## ▶️ Paso 6: Ejecutar el Pipeline

### 6.1 Primera ejecución
1. En la página del job, click "Build Now"
2. Observa la ejecución en "Stage View"
3. Monitorea cada etapa:
   - Source
   - Build
   - Unit Tests
   - Behavior Tests
   - API Tests
   - E2E Tests

### 6.2 Verificar resultados
Durante la ejecución, verifica:
- [ ] Cada etapa se ejecuta correctamente
- [ ] Los logs muestran la información esperada
- [ ] No hay errores críticos

## 📊 Paso 7: Verificar Artefactos y Reportes

### 7.1 Artefactos archivados
Después de la ejecución, verifica:
1. Ve a la página del build
2. Sección "Build Artifacts"
3. Deberías ver archivos XML de resultados

### 7.2 Reportes publicados
En la página del build, busca enlaces a:
- [ ] "Unit Test Report"
- [ ] "API Test Report" 
- [ ] "E2E Test Report"
- [ ] "Coverage Report"

### 7.3 Resultados de tests
1. Click en "Test Result"
2. Verifica que se muestran los resultados de las pruebas
3. Explora los detalles de cada test

## 📧 Paso 8: Verificar Funcionalidad de Notificaciones

### 8.1 Simular un fallo
Para probar las notificaciones:
1. Edita el Jenkinsfile temporalmente
2. Añade un comando que falle en alguna etapa:
   ```groovy
   sh 'exit 1'  // Esto causará un fallo
   ```
3. Ejecuta el pipeline de nuevo
4. Verifica que se ejecuta la sección `post.failure`

### 8.2 Verificar logs de notificación
En los logs del build fallido, busca:
```
❌ Fallo: El pipeline FinTech-CICD-Pipeline #X ha fallado
Enviando notificación de fallo...
```

### 8.3 Restaurar el Jenkinsfile
Elimina el comando de fallo añadido anteriormente.

## 📸 Paso 9: Documentar Resultados

### 9.1 Capturas de pantalla requeridas
Toma capturas de:
1. **Stage View** del pipeline completo exitoso
2. **Página principal** del job mostrando builds
3. **Test Results** de un build exitoso
4. **Artefactos archivados**
5. **Reportes HTML** publicados
6. **Logs de ejecución** de una etapa específica
7. **Configuración del pipeline** (script del Jenkinsfile)
8. **Dashboard de Jenkins** con el job creado

### 9.2 Organizar documentación
Crea un documento con:
- Descripción del entorno configurado
- Explicación de cada etapa del pipeline
- Capturas de pantalla numeradas
- Explicación de los artefactos generados
- Descripción de las notificaciones configuradas

## 🧪 Paso 10: Pruebas Adicionales

### 10.1 Verificar robustez del pipeline
1. Ejecuta el pipeline múltiples veces
2. Verifica que es consistente
3. Comprueba que la limpieza funciona correctamente

### 10.2 Probar diferentes escenarios
- Ejecuta con diferentes parámetros (si los configuraste)
- Verifica que los timeouts funcionan
- Comprueba la gestión de errores

## 🔍 Paso 11: Verificación Final

### 11.1 Ejecutar script de verificación
```bash
cd jenkins
./verify.sh
```

### 11.2 Verificar todos los componentes
El script debe mostrar:
- ✅ Docker funcionando
- ✅ Jenkins Server ejecutándose
- ✅ Jenkins Agent conectado
- ✅ Web UI accesible
- ✅ Puertos correctos
- ✅ Volúmenes creados
- ✅ Archivos de configuración presentes

## 📋 Paso 12: Checklist Final

Antes de dar por completado el laboratorio, verifica:

### Configuración del Entorno
- [ ] Jenkins ejecutándose correctamente
- [ ] Docker funcionando sin errores
- [ ] Puertos 8080 y 50000 accesibles
- [ ] Volúmenes de Jenkins persistentes

### Pipeline Implementado
- [ ] Job "FinTech-CICD-Pipeline" creado
- [ ] Jenkinsfile con todas las etapas requeridas
- [ ] Pipeline ejecutándose sin errores críticos
- [ ] Todas las etapas completándose

### Funcionalidades Requeridas
- [ ] ✅ Etapas de Source, Build, Unit Tests, API Tests, E2E Tests
- [ ] ✅ Archivado de artefactos XML
- [ ] ✅ Publicación de reportes HTML
- [ ] ✅ Notificaciones de fallo configuradas
- [ ] ✅ Gestión adecuada de errores
- [ ] ✅ Limpieza de recursos Docker

### Documentación
- [ ] Capturas de pantalla tomadas
- [ ] Explicación de cada componente
- [ ] Documentación de problemas encontrados
- [ ] Lista de mejoras posibles

## 🎉 ¡Laboratorio Completado!

Si has llegado hasta aquí, ¡felicitaciones! Has completado exitosamente el laboratorio de Jenkins Pipeline.

### Próximos Pasos Opcionales

1. **Mejoras del Pipeline**:
   - Añadir pruebas de seguridad
   - Implementar análisis de código con SonarQube
   - Configurar despliegue automático

2. **Configuración Avanzada**:
   - Configurar agentes distribuidos
   - Implementar pipelines multibranch
   - Integrar con sistemas de notificación (Slack, Teams)

3. **Monitoreo y Métricas**:
   - Configurar métricas de Jenkins
   - Implementar dashboards de monitoreo
   - Configurar alertas de salud del sistema

## 🆘 Solución de Problemas

### Problema: Jenkins no arranca
```bash
cd jenkins
./setup.sh clean
./setup.sh init
```

### Problema: Tests fallan
```bash
cd ..
make build
cd jenkins
```

### Problema: Puerto ocupado
Edita `docker-compose.yml` y cambia el puerto:
```yaml
ports:
  - "8081:8080"  # Cambiar 8080 por 8081
```

### Problema: Falta memoria
```bash
docker system prune -f
```

## 📞 Contacto y Soporte

Para dudas sobre el laboratorio:
1. Revisa los logs con `./setup.sh logs`
2. Verifica el estado con `./verify.sh`
3. Consulta la documentación oficial de Jenkins
4. Contacta al instructor del curso

---

**¡Éxito en tu laboratorio! 🚀**
