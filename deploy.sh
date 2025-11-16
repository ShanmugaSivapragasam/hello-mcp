#!/bin/bash

# Production deployment script for Hello MCP Server
# Usage: ./deploy.sh [environment] [version]

set -e

ENVIRONMENT=${1:-prod}
VERSION=${2:-latest}
NAMESPACE="mcp-server"
APP_NAME="hello-mcp"

echo "🚀 Starting deployment of $APP_NAME version $VERSION to $ENVIRONMENT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    # Check if Java is installed
    if ! command -v java &> /dev/null; then
        print_error "Java is not installed"
        exit 1
    fi

    # Check if Gradle is available
    if ! command -v ./gradlew &> /dev/null; then
        print_error "Gradle wrapper not found"
        exit 1
    fi

    # Check if Docker is installed (for containerized deployment)
    if ! command -v docker &> /dev/null; then
        print_warning "Docker is not installed - skipping container build"
    fi

    print_status "Prerequisites check completed"
}

# Build application
build_application() {
    print_status "Building application..."

    # Clean and build
    ./gradlew clean build -Pprofile=$ENVIRONMENT

    if [ $? -eq 0 ]; then
        print_status "Application built successfully"
    else
        print_error "Application build failed"
        exit 1
    fi
}

# Build Docker image
build_docker_image() {
    if command -v docker &> /dev/null; then
        print_status "Building Docker image..."

        docker build -t $APP_NAME:$VERSION .
        docker tag $APP_NAME:$VERSION $APP_NAME:latest

        print_status "Docker image built successfully"
    else
        print_warning "Docker not available - skipping image build"
    fi
}

# Deploy to Kubernetes
deploy_kubernetes() {
    if command -v kubectl &> /dev/null; then
        print_status "Deploying to Kubernetes..."

        # Apply Kubernetes manifests
        kubectl apply -f k8s/namespace.yaml
        kubectl apply -f k8s/configmap.yaml
        kubectl apply -f k8s/deployment.yaml
        kubectl apply -f k8s/service.yaml
        kubectl apply -f k8s/ingress.yaml
        kubectl apply -f k8s/hpa.yaml

        # Wait for deployment to be ready
        kubectl rollout status deployment/mcp-server -n $NAMESPACE --timeout=300s

        print_status "Kubernetes deployment completed"

        # Show deployment status
        kubectl get pods -n $NAMESPACE
        kubectl get services -n $NAMESPACE
        kubectl get ingress -n $NAMESPACE

    else
        print_warning "kubectl not available - skipping Kubernetes deployment"
    fi
}

# Deploy as systemd service
deploy_systemd() {
    print_status "Deploying as systemd service..."

    # Create application user if not exists
    if ! id "mcp-server" &>/dev/null; then
        sudo useradd -r -s /bin/false mcp-server
    fi

    # Create directories
    sudo mkdir -p /opt/mcp-server/{bin,config,logs}
    sudo chown -R mcp-server:mcp-server /opt/mcp-server

    # Copy JAR file
    sudo cp build/libs/$APP_NAME-*.jar /opt/mcp-server/bin/

    # Copy production configuration
    sudo cp src/main/resources/application-prod.properties /opt/mcp-server/config/

    # Create systemd service file
    sudo tee /etc/systemd/system/mcp-server.service > /dev/null << EOF
[Unit]
Description=Hello MCP Server
After=network.target

[Service]
Type=simple
User=mcp-server
Group=mcp-server
WorkingDirectory=/opt/mcp-server
ExecStart=/usr/bin/java \\
    -Xms512m -Xmx2g \\
    -XX:+UseG1GC \\
    -XX:MaxGCPauseMillis=200 \\
    -Dspring.profiles.active=prod \\
    -Dspring.config.location=/opt/mcp-server/config/ \\
    -jar /opt/mcp-server/bin/$APP_NAME-*.jar
ExecStop=/bin/kill -TERM \$MAINPID
Restart=always
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and start service
    sudo systemctl daemon-reload
    sudo systemctl enable mcp-server
    sudo systemctl restart mcp-server

    # Check service status
    sleep 5
    sudo systemctl status mcp-server

    print_status "Systemd service deployment completed"
}

# Health check
health_check() {
    print_status "Performing health check..."

    local endpoint="http://localhost:8080/actuator/health"
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -f -s $endpoint > /dev/null; then
            print_status "Health check passed"
            return 0
        fi

        print_warning "Health check attempt $attempt/$max_attempts failed, retrying in 10 seconds..."
        sleep 10
        ((attempt++))
    done

    print_error "Health check failed after $max_attempts attempts"
    return 1
}

# Main deployment flow
main() {
    print_status "Starting deployment process..."

    check_prerequisites
    build_application
    build_docker_image

    case $ENVIRONMENT in
        "k8s"|"kubernetes")
            deploy_kubernetes
            ;;
        "systemd"|"service")
            deploy_systemd
            health_check
            ;;
        "prod"|"production")
            # Default to systemd for production
            deploy_systemd
            health_check
            ;;
        *)
            print_error "Unknown environment: $ENVIRONMENT"
            print_status "Supported environments: k8s, kubernetes, systemd, service, prod, production"
            exit 1
            ;;
    esac

    print_status "🎉 Deployment completed successfully!"
    print_status "MCP Server is now running and ready to accept connections"

    if [ "$ENVIRONMENT" != "k8s" ] && [ "$ENVIRONMENT" != "kubernetes" ]; then
        print_status "Health endpoint: http://localhost:8080/actuator/health"
        print_status "Metrics endpoint: http://localhost:9090/actuator/prometheus"
    fi
}

# Run main function
main "$@"
