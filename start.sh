#!/bin/bash

# Quick Start Script for MCP Server
# This script helps you get started quickly with the MCP Server

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}"
    echo "========================================"
    echo "   Hello MCP Server - Quick Start"
    echo "========================================"
    echo -e "${NC}"
}

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    print_step "Checking requirements..."

    # Check Java
    if command -v java &> /dev/null; then
        java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
        print_info "✅ Java found: $java_version"
    else
        print_error "❌ Java not found. Please install Java 21 or higher."
        exit 1
    fi

    # Check Gradle
    if [ -f "./gradlew" ]; then
        print_info "✅ Gradle wrapper found"
    else
        print_error "❌ Gradle wrapper not found"
        exit 1
    fi

    # Check Docker (optional)
    if command -v docker &> /dev/null; then
        print_info "✅ Docker found"
    else
        print_warning "⚠️  Docker not found (optional for containerized deployment)"
    fi
}

build_application() {
    print_step "Building the application..."

    export JAVA_HOME=${JAVA_HOME:-$(/usr/libexec/java_home -v 21 2>/dev/null || /usr/libexec/java_home)}

    ./gradlew clean build

    if [ $? -eq 0 ]; then
        print_info "✅ Build successful"
    else
        print_error "❌ Build failed"
        exit 1
    fi
}

run_application() {
    print_step "Starting the MCP Server..."

    print_info "Starting server on port 8080..."
    print_info "Press Ctrl+C to stop the server"

    export JAVA_HOME=${JAVA_HOME:-$(/usr/libexec/java_home -v 21 2>/dev/null || /usr/libexec/java_home)}

    ./gradlew bootRun
}

show_usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start     - Build and start the MCP Server (default)"
    echo "  build     - Only build the application"
    echo "  check     - Check requirements only"
    echo "  docker    - Build and run with Docker"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./start.sh              # Build and start server"
    echo "  ./start.sh build        # Only build"
    echo "  ./start.sh docker       # Use Docker"
}

run_docker() {
    print_step "Building and running with Docker..."

    if ! command -v docker &> /dev/null; then
        print_error "❌ Docker not found. Please install Docker first."
        exit 1
    fi

    # Build the application first
    build_application

    # Build Docker image
    print_info "Building Docker image..."
    docker build -t hello-mcp:latest .

    # Run container
    print_info "Starting Docker container..."
    print_info "Access the server at: http://localhost:8080"
    print_info "Health check at: http://localhost:8080/actuator/health"
    print_info "Press Ctrl+C to stop the container"

    docker run -p 8080:8080 -p 9090:9090 --name mcp-server --rm hello-mcp:latest
}

show_info() {
    print_info ""
    print_info "🎉 MCP Server is starting up!"
    print_info ""
    print_info "📋 Useful endpoints:"
    print_info "   • Application: http://localhost:8080"
    print_info "   • Health Check: http://localhost:8080/actuator/health"
    print_info "   • Metrics: http://localhost:9090/actuator/prometheus"
    print_info "   • MCP Tools: http://localhost:8080/mcp (when configured)"
    print_info ""
    print_info "🔧 Available MCP Tools:"
    print_info "   • hello-tool: Returns a greeting message"
    print_info ""
    print_info "📚 For more information:"
    print_info "   • README.md - Complete documentation"
    print_info "   • SECURITY.md - Security guidelines"
    print_info "   • ./deploy.sh - Production deployment"
    print_info ""
}

# Main execution
case "${1:-start}" in
    "start")
        print_header
        check_requirements
        build_application
        show_info
        run_application
        ;;
    "build")
        print_header
        check_requirements
        build_application
        ;;
    "check")
        print_header
        check_requirements
        print_info "✅ All requirements satisfied"
        ;;
    "docker")
        print_header
        run_docker
        ;;
    "help"|"-h"|"--help")
        print_header
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
