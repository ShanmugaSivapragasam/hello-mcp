FROM openjdk:25-jdk-slim

# Create app user
RUN groupadd -r mcpuser && useradd -r -g mcpuser mcpuser

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

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
