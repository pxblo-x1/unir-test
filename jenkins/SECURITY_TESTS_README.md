# Security Tests Stage - Setup and Troubleshooting

## Overview

The Security Tests stage performs comprehensive security analysis including:

1. **Dependency Security (Safety)** - Scans Python dependencies for known vulnerabilities
2. **Static Code Analysis (Bandit)** - Security-focused analysis of Python code
3. **Code Quality (Pylint)** - General code quality and potential security issues
4. **SonarQube Analysis** - Comprehensive code quality and security analysis
5. **Container Security (Trivy)** - Docker image vulnerability scanning

## Setup Requirements

### 1. SonarQube Configuration

SonarQube runs as part of the Jenkins docker-compose setup and requires authentication.

**Initial Setup:**
```bash
# Start Jenkins and SonarQube
cd jenkins/
./sonarqube.sh start

# Configure SonarQube authentication
./setup-sonarqube-token.sh
```

**Manual Token Setup:**
1. Open SonarQube: http://localhost:9000
2. Login: admin/admin
3. Go to: Administration > Security > Users
4. Click "Tokens" for admin user
5. Generate token named "jenkins-pipeline"
6. Update `sonar-project.properties` with the new token

### 2. Docker Socket Access

The Trivy container security scanner requires access to the Docker socket to scan images.

## Common Issues and Solutions

### Issue 1: SonarQube Authentication Failed
```
ERROR Not authorized. Please check the properties sonar.login and sonar.password.
```

**Solution:**
1. Run the token setup script: `./jenkins/setup-sonarqube-token.sh`
2. Or manually create a new token in SonarQube UI
3. Update the `sonar.login` property in `sonar-project.properties`

### Issue 2: Trivy Cannot Find Docker Image
```
FATAL Fatal error: unable to find the specified image "calculator-app:latest"
```

**Solution:**
- Ensure the calculator-app:latest image exists in Docker
- Run `docker images | grep calculator-app` to verify
- The Build stage should create this image before Security Tests

### Issue 3: SonarQube Not Ready
```
SonarQube no está disponible
```

**Solution:**
1. Wait for SonarQube to fully initialize (can take 2-3 minutes)
2. Check SonarQube logs: `./sonarqube.sh logs`
3. Verify SonarQube status: `./sonarqube.sh status`

## Generated Reports

The Security Tests stage generates the following reports:

- `results/safety_report.json` - Dependency vulnerabilities (JSON)
- `results/safety_report.txt` - Dependency vulnerabilities (text)
- `results/bandit_report.json` - Code security issues (JSON)
- `results/bandit_report.txt` - Code security issues (text)
- `results/pylint_result.txt` - Code quality analysis
- `results/trivy_report.json` - Container vulnerabilities (JSON)
- `results/trivy_report.txt` - Container vulnerabilities (text)
- `results/security_summary.html` - Consolidated HTML report

## Accessing Reports

1. **Jenkins UI**: Reports are archived as artifacts and published as HTML reports
2. **SonarQube Dashboard**: http://localhost:9000 (comprehensive analysis)
3. **Local Files**: Check the `results/` directory in the workspace

## Performance Notes

- First run may take longer due to:
  - Trivy vulnerability database download (~65MB)
  - SonarQube initialization
  - Tool installation in containers
- Subsequent runs are faster as images are cached

## Disabling Security Tests

To skip security tests:

1. **Branch-based**: Only runs on `main`/`master` branches by default
2. **Parameter-based**: Set `RUN_SECURITY_TESTS=false` in Jenkins job parameters
3. **Comment out**: Comment the entire Security Tests stage in Jenkinsfile

## Security Tools Documentation

- **Safety**: https://pyup.io/safety/
- **Bandit**: https://bandit.readthedocs.io/
- **Pylint**: https://pylint.readthedocs.io/
- **SonarQube**: https://docs.sonarqube.org/
- **Trivy**: https://trivy.dev/
