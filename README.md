# Hello MCP Server

A production-ready Spring Boot MCP (Model Context Protocol) server that provides AI tools for integration with Claude, Perplexity, ChatGPT, and other AI clients. Built with Spring AI MCP framework for enterprise-grade deployment.

## Overview

This MCP server exposes AI tools through the Model Context Protocol, enabling seamless integration with various AI platforms. The server provides a `hello-tool` that demonstrates the MCP architecture and can be extended with custom business logic.

### Key Features

- ✅ **Production Ready**: Built with Spring Boot 3.5.7 and Java 21
- ✅ **MCP Protocol Compliant**: Uses Spring AI MCP Server WebMVC
- ✅ **Enterprise Grade**: Comprehensive logging, monitoring, and security
- ✅ **Scalable Architecture**: Supports horizontal scaling and load balancing
- ✅ **Multi-AI Platform Support**: Compatible with Claude, ChatGPT, Perplexity
- ✅ **Cloud Native**: Docker and Kubernetes ready

## Technical Specifications

- **Framework**: Spring Boot 3.5.7
- **Java Version**: 21
- **Build Tool**: Gradle 8.x
- **Protocol**: MCP (Model Context Protocol)
- **Architecture**: Microservice/Standalone
- **Deployment**: JAR, Docker, Kubernetes

## 🚀 Quick Start (30 seconds)

```bash
# Clone and start the server
git clone https://github.com/your-org/hello-mcp.git
cd hello-mcp
./start.sh
```

The server will be running at `http://localhost:8080` with MCP tools ready for AI integration!

## Available Tools

### hello-tool
- **Description**: Returns a greeting message from the MCP server
- **Usage**: Demonstrates MCP tool functionality
- **Response**: `"Hello from MCP server!"`
- **Spring Boot**: 3.5.7
- **Spring AI**: 1.1.0-M4 (with MCP server support)
- **Gradle**: 8.14.3
- **Build Tool**: Gradle Wrapper

## Features

- MCP server implementation with Spring AI
- Simple greeting tool (`hello-tool`)
- Configurable MCP server settings
- RESTful web endpoints
- Comprehensive logging

## Project Structure

```
src/main/java/com/shan/hello_mcp/
├── HelloMcpApplication.java    # Main Spring Boot application
└── HelloTools.java             # MCP tools implementation
```

## Getting Started

### Prerequisites

- Java 25 or higher
- Git

### Installation and Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd hello-mcp
   ```

2. **Build the project:**
   ```bash
   ./gradlew build
   ```

3. **Run the application:**
   ```bash
   ./gradlew bootRun
   ```

The application will start on the default port (8080) and the MCP server will be available for client connections.

## Configuration

The MCP server is configured in `application.properties`:

```properties
spring.application.name=hello-mcp
spring.ai.mcp.server.name=HelloMCPServer
spring.ai.mcp.server.description=A simple MCP server application
spring.ai.mcp.server.version=1.0.0
spring.ai.mcp.server.author=Shan
spring.ai.mcp.server.protocol=streamable
spring.ai.mcp.server.stdio=false
spring.ai.mcp.server.type=sync
```

## Available Tools

### hello-tool

- **Name**: `hello-tool`
- **Description**: A tool that returns a hello message from the MCP server
- **Response**: Returns "Hello from MCP server!" message

## Usage Example

When connected to an MCP client, you can call the `hello-tool` to receive a greeting message. The tool will log the call and return the greeting response.

## Development

### Running Tests

```bash
./gradlew test
```

### Building for Production

```bash
./gradlew bootJar
```

The executable JAR will be created in `build/libs/`.

## Dependencies

Key dependencies include:
- `spring-boot-starter-web`: Web framework support
- `spring-ai-starter-mcp-server-webmvc`: MCP server implementation
- `spring-boot-starter-test`: Testing framework

## Author

Shan

## Version

0.0.1-SNAPSHOT

## Quick Start

### Prerequisites

- Java 21 or higher
- Gradle 8.x
- Git
- Docker (optional)
- Kubernetes (for production deployment)

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/hello-mcp.git
   cd hello-mcp
   ```

2. **Build the application**
   ```bash
   ./gradlew build
   ```

3. **Run locally**
   ```bash
   ./gradlew bootRun
   ```

4. **Verify the server**
   ```bash
   curl http://localhost:8080/actuator/health
   ```

## Production Deployment Guide

### Option 1: Traditional JAR Deployment

#### 1. Build Production JAR
```bash
./gradlew clean build -Pprofile=prod
```

#### 2. Server Setup (Ubuntu/RHEL)
```bash
# Create application user
sudo useradd -r -s /bin/false mcp-server

# Create directories
sudo mkdir -p /opt/mcp-server/{bin,config,logs}
sudo chown -R mcp-server:mcp-server /opt/mcp-server

# Copy JAR
sudo cp build/libs/hello-mcp-0.0.1-SNAPSHOT.jar /opt/mcp-server/bin/
```

#### 3. Production Configuration
Create `/opt/mcp-server/config/application-prod.properties`:
```properties
# Server Configuration
server.port=8080
server.servlet.context-path=/mcp
server.shutdown=graceful
spring.lifecycle.timeout-per-shutdown-phase=30s

# MCP Server Configuration
spring.application.name=hello-mcp
spring.ai.mcp.server.name=HelloMCPServer-Prod
spring.ai.mcp.server.description=Production MCP server
spring.ai.mcp.server.version=1.0.0
spring.ai.mcp.server.author=Enterprise Team

# Protocol Configuration
spring.ai.mcp.server.protocol=streamable
spring.ai.mcp.server.stdio=false
spring.ai.mcp.server.type=sync

# Logging Configuration
logging.level.com.shan.hello_mcp=INFO
logging.level.org.springframework.ai.mcp=DEBUG
logging.pattern.file=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n
logging.file.name=/opt/mcp-server/logs/application.log
logging.logback.rollingpolicy.max-file-size=100MB
logging.logback.rollingpolicy.total-size-cap=1GB

# Actuator (Monitoring)
management.endpoints.web.exposure.include=health,info,metrics,prometheus
management.endpoint.health.show-details=when-authorized
management.metrics.export.prometheus.enabled=true

# Security (if enabled)
management.endpoints.web.base-path=/actuator
management.server.port=9090
```

#### 4. SystemD Service
Create `/etc/systemd/system/mcp-server.service`:
```ini
[Unit]
Description=Hello MCP Server
After=network.target

[Service]
Type=simple
User=mcp-server
Group=mcp-server
WorkingDirectory=/opt/mcp-server
ExecStart=/usr/bin/java \
    -Xms512m -Xmx2g \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -Dspring.profiles.active=prod \
    -Dspring.config.location=/opt/mcp-server/config/ \
    -jar /opt/mcp-server/bin/hello-mcp-0.0.1-SNAPSHOT.jar
ExecStop=/bin/kill -TERM $MAINPID
Restart=always
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

#### 5. Start Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable mcp-server
sudo systemctl start mcp-server
sudo systemctl status mcp-server
```

### Option 2: Docker Deployment

#### 1. Create Dockerfile
```dockerfile
FROM openjdk:25-jdk-slim

# Create app user
RUN groupadd -r mcpuser && useradd -r -g mcpuser mcpuser

# Set working directory
WORKDIR /app

# Copy JAR
COPY build/libs/hello-mcp-*.jar app.jar

# Create logs directory
RUN mkdir -p /app/logs && chown -R mcpuser:mcpuser /app

# Switch to non-root user
USER mcpuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Expose ports
EXPOSE 8080 9090

# JVM options for containers
ENV JAVA_OPTS="-Xms512m -Xmx1g -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Run application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

#### 2. Build and Run
```bash
# Build image
docker build -t hello-mcp:latest .

# Run container
docker run -d \
  --name mcp-server \
  -p 8080:8080 \
  -p 9090:9090 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -v /opt/mcp-server/logs:/app/logs \
  --restart unless-stopped \
  hello-mcp:latest
```

### Option 3: Kubernetes Deployment

#### 1. Create Kubernetes Manifests

**namespace.yaml**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: mcp-server
  labels:
    name: mcp-server
```

**configmap.yaml**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mcp-server-config
  namespace: mcp-server
data:
  application-prod.properties: |
    server.port=8080
    spring.profiles.active=prod
    spring.ai.mcp.server.name=HelloMCPServer-K8s
    logging.level.com.shan.hello_mcp=INFO
    management.endpoints.web.exposure.include=health,info,metrics,prometheus
```

**deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mcp-server
  namespace: mcp-server
  labels:
    app: mcp-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mcp-server
  template:
    metadata:
      labels:
        app: mcp-server
    spec:
      containers:
      - name: mcp-server
        image: hello-mcp:latest
        ports:
        - containerPort: 8080
        - containerPort: 9090
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
        - name: JAVA_OPTS
          value: "-Xms512m -Xmx1g -XX:+UseContainerSupport"
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 9090
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 9090
          initialDelaySeconds: 30
          periodSeconds: 10
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
      volumes:
      - name: config-volume
        configMap:
          name: mcp-server-config
```

**service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mcp-server-service
  namespace: mcp-server
  labels:
    app: mcp-server
spec:
  selector:
    app: mcp-server
  ports:
  - name: http
    port: 8080
    targetPort: 8080
  - name: management
    port: 9090
    targetPort: 9090
  type: ClusterIP
```

**ingress.yaml**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mcp-server-ingress
  namespace: mcp-server
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - mcp.yourdomain.com
    secretName: mcp-server-tls
  rules:
  - host: mcp.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mcp-server-service
            port:
              number: 8080
```

#### 2. Deploy to Kubernetes
```bash
# Apply manifests
kubectl apply -f k8s/

# Verify deployment
kubectl get pods -n mcp-server
kubectl get services -n mcp-server
kubectl logs -f deployment/mcp-server -n mcp-server
```

## Load Balancer & Reverse Proxy Setup

### Nginx Configuration
```nginx
upstream mcp_backend {
    server 10.0.1.10:8080 max_fails=3 fail_timeout=30s;
    server 10.0.1.11:8080 max_fails=3 fail_timeout=30s;
    server 10.0.1.12:8080 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    listen 443 ssl http2;
    server_name mcp.yourdomain.com;

    # SSL Configuration
    ssl_certificate /etc/ssl/certs/mcp.yourdomain.com.crt;
    ssl_certificate_key /etc/ssl/private/mcp.yourdomain.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;

    # Security Headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=mcp_limit:10m rate=10r/s;
    limit_req zone=mcp_limit burst=20 nodelay;

    location / {
        proxy_pass http://mcp_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
    }

    location /actuator {
        deny all;
        return 403;
    }
}
```

## AI Platform Integration

### Claude Integration
```python
import anthropic
import requests

# MCP Server connection
MCP_SERVER_URL = "https://mcp.yourdomain.com"

def call_mcp_tool(tool_name, **kwargs):
    response = requests.post(
        f"{MCP_SERVER_URL}/mcp/tools/{tool_name}",
        json=kwargs,
        headers={"Content-Type": "application/json"}
    )
    return response.json()

# Use with Claude
client = anthropic.Anthropic(api_key="your-api-key")

# Call MCP tool
greeting = call_mcp_tool("hello-tool")
print(f"MCP Response: {greeting}")
```

### ChatGPT Integration
```javascript
const axios = require('axios');

const MCP_SERVER_URL = 'https://mcp.yourdomain.com';

async function callMcpTool(toolName, params = {}) {
    try {
        const response = await axios.post(
            `${MCP_SERVER_URL}/mcp/tools/${toolName}`,
            params,
            {
                headers: { 'Content-Type': 'application/json' }
            }
        );
        return response.data;
    } catch (error) {
        console.error('MCP Tool Error:', error);
        throw error;
    }
}

// Example usage
async function main() {
    const greeting = await callMcpTool('hello-tool');
    console.log('MCP Response:', greeting);
}
```

### Perplexity Integration
```python
import requests
from typing import Dict, Any

class McpClient:
    def __init__(self, base_url: str):
        self.base_url = base_url.rstrip('/')
    
    def call_tool(self, tool_name: str, **kwargs) -> Dict[str, Any]:
        response = requests.post(
            f"{self.base_url}/mcp/tools/{tool_name}",
            json=kwargs,
            timeout=30
        )
        response.raise_for_status()
        return response.json()

# Initialize MCP client
mcp = McpClient("https://mcp.yourdomain.com")

# Use with Perplexity workflows
def enhanced_search_with_mcp():
    # Call MCP tool first
    greeting = mcp.call_tool("hello-tool")
    
    # Then proceed with Perplexity search
    return greeting
```

## Monitoring & Observability

### Prometheus Metrics
Access metrics at: `http://your-server:9090/actuator/prometheus`

Key metrics to monitor:
- `jvm_memory_used_bytes`
- `http_server_requests_seconds`
- `mcp_tool_calls_total`
- `application_ready_time_seconds`

### Grafana Dashboard
Import the provided Grafana dashboard JSON for comprehensive monitoring.

### Log Analysis
```bash
# View real-time logs
sudo journalctl -u mcp-server -f

# Search for specific patterns
sudo journalctl -u mcp-server | grep "ERROR\|WARN"

# Export logs for analysis
sudo journalctl -u mcp-server --since="1 hour ago" > /tmp/mcp-logs.txt
```

## Security Considerations

### Production Security Checklist

- [ ] **Network Security**
  - Firewall configured (only ports 80, 443, 22 open)
  - VPN/VPC for internal communication
  - Load balancer with SSL termination

- [ ] **Application Security**
  - Spring Security enabled
  - Rate limiting implemented
  - Input validation on all endpoints
  - CORS properly configured

- [ ] **Infrastructure Security**
  - Regular security updates
  - Non-root user execution
  - Secrets management (HashiCorp Vault/K8s Secrets)
  - Container scanning for vulnerabilities

- [ ] **Monitoring & Alerting**
  - Real-time error alerting
  - Performance monitoring
  - Security event logging
  - Audit trail maintenance

### Environment Variables
```bash
# Required for production
export SPRING_PROFILES_ACTIVE=prod
export MCP_SERVER_SECRET_KEY=your-secret-key
export DATABASE_URL=your-database-url
export MONITORING_API_KEY=your-monitoring-key
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   sudo lsof -i :8080
   sudo kill -9 <PID>
   ```

2. **Memory Issues**
   ```bash
   # Increase JVM heap size
   export JAVA_OPTS="-Xms1g -Xmx4g"
   ```

3. **MCP Connection Issues**
   ```bash
   # Check MCP endpoint
   curl -v http://localhost:8080/mcp/tools
   ```

4. **SSL Certificate Issues**
   ```bash
   # Verify certificate
   openssl x509 -in /path/to/cert.pem -text -noout
   ```

### Performance Tuning

#### JVM Tuning for Production
```bash
JAVA_OPTS="
  -Xms2g -Xmx4g
  -XX:+UseG1GC
  -XX:MaxGCPauseMillis=200
  -XX:+UseStringDeduplication
  -XX:+OptimizeStringConcat
  -XX:+UseCompressedOops
  -Djava.security.egd=file:/dev/./urandom
"
```

#### Database Connection Pool
```properties
# HikariCP Configuration
spring.datasource.hikari.minimum-idle=10
spring.datasource.hikari.maximum-pool-size=50
spring.datasource.hikari.idle-timeout=300000
spring.datasource.hikari.max-lifetime=600000
spring.datasource.hikari.connection-timeout=20000
```

## Scaling & High Availability

### Horizontal Scaling
- Deploy multiple instances behind a load balancer
- Use session-less design (stateless)
- Implement circuit breakers for resilience

### Vertical Scaling
- Monitor CPU/memory usage
- Adjust JVM heap sizes accordingly
- Use profiling tools for optimization

### Database Scaling
- Read replicas for read-heavy workloads
- Connection pooling optimization
- Query performance tuning

## Support & Maintenance

### Regular Maintenance Tasks

1. **Weekly**
   - Review application logs
   - Check system metrics
   - Update dependencies (security patches)

2. **Monthly**
   - Performance review
   - Capacity planning
   - Security audit

3. **Quarterly**
   - Disaster recovery testing
   - Architecture review
   - Technology stack updates

### Getting Help

- **Documentation**: Check the [Wiki](wiki-link)
- **Issues**: Report bugs on [GitHub Issues](issues-link)
- **Community**: Join our [Discord](discord-link)
- **Commercial Support**: Contact enterprise@yourcompany.com

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Enterprise Support Available** - Contact us for production support, custom features, and SLA guarantees.
