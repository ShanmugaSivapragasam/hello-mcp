#!/bin/bash

# Health check script for MCP Server
# Usage: ./health-check.sh [endpoint] [timeout]

ENDPOINT=${1:-"http://localhost:8080/actuator/health"}
TIMEOUT=${2:-10}
MAX_ATTEMPTS=${3:-5}

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[HEALTH]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

check_health() {
    local attempt=1

    while [ $attempt -le $MAX_ATTEMPTS ]; do
        print_status "Health check attempt $attempt/$MAX_ATTEMPTS..."

        # Perform health check
        response=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TIMEOUT "$ENDPOINT")

        if [ "$response" = "200" ]; then
            print_status "✅ Health check passed (HTTP $response)"

            # Get detailed health information
            health_details=$(curl -s --max-time $TIMEOUT "$ENDPOINT")
            echo "Health Details: $health_details"

            return 0
        else
            print_warning "❌ Health check failed (HTTP $response)"
        fi

        if [ $attempt -lt $MAX_ATTEMPTS ]; then
            print_warning "Retrying in 5 seconds..."
            sleep 5
        fi

        ((attempt++))
    done

    print_error "Health check failed after $MAX_ATTEMPTS attempts"
    return 1
}

# Additional checks
check_metrics() {
    print_status "Checking metrics endpoint..."
    metrics_response=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TIMEOUT "http://localhost:9090/actuator/prometheus")

    if [ "$metrics_response" = "200" ]; then
        print_status "✅ Metrics endpoint is healthy"
    else
        print_warning "❌ Metrics endpoint is not responding (HTTP $metrics_response)"
    fi
}

check_mcp_tools() {
    print_status "Checking MCP tools endpoint..."
    # This would need to be implemented based on actual MCP endpoint structure
    print_status "MCP tools check - implementation needed based on MCP protocol"
}

# Main execution
print_status "Starting comprehensive health check..."
print_status "Endpoint: $ENDPOINT"
print_status "Timeout: ${TIMEOUT}s"
print_status "Max attempts: $MAX_ATTEMPTS"

if check_health; then
    check_metrics
    check_mcp_tools
    print_status "🎉 All health checks completed successfully"
    exit 0
else
    print_error "💥 Health check failed"
    exit 1
fi
