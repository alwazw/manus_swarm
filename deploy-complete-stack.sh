#!/bin/bash

# Complete Stack Deployment Script
# Deploys the entire self-hosted infrastructure

set -e

echo "🚀 Starting Complete Stack Deployment..."
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker compose > /dev/null 2>&1; then
    print_error "Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    print_status "Loading environment variables from .env"
    export $(cat .env | grep -v '^#' | xargs)
else
    print_warning "No .env file found. Using .env.alwazw as template"
    cp .env.alwazw .env
    export $(cat .env | grep -v '^#' | xargs)
fi

# Create necessary directories
print_header "Creating Directory Structure"
sudo mkdir -p /mnt/media/{photos,videos,tv_series,movies,documents,music,books,downloads,backups,nextcloud_data}
sudo chown -R $USER:$USER /mnt/media
print_status "Media directories created"

# Create Docker networks
print_header "Creating Docker Networks"
docker network create proxy_network 2>/dev/null || print_warning "proxy_network already exists"
docker network create database_network 2>/dev/null || print_warning "database_network already exists"
docker network create monitoring_network 2>/dev/null || print_warning "monitoring_network already exists"
docker network create logging_network 2>/dev/null || print_warning "logging_network already exists"
docker network create notifications_network 2>/dev/null || print_warning "notifications_network already exists"
print_status "Docker networks created"

# Deploy stacks in order (dependencies matter)
STACKS=(
    "proxy.yml:Reverse Proxy & SSL"
    "security.yml:Security & Authentication"
    "monitoring.yml:Monitoring & Observability"
    "logging.yml:Logging & Log Management"
    "notifications.yml:Notifications & Alerts"
    "media.yml:Media & File Services"
    "sync.yml:File Synchronization"
    "cloudflare-tunnel.yml:Cloudflare Tunnel"
)

for stack_info in "${STACKS[@]}"; do
    IFS=':' read -r stack_file stack_name <<< "$stack_info"
    
    if [ -f "$stack_file" ]; then
        print_header "Deploying $stack_name"
        print_status "Starting services from $stack_file"
        
        # Deploy the stack
        if docker compose -f "$stack_file" up -d; then
            print_status "$stack_name deployed successfully"
        else
            print_error "Failed to deploy $stack_name"
            exit 1
        fi
        
        # Wait a bit for services to start
        sleep 10
    else
        print_warning "$stack_file not found, skipping $stack_name"
    fi
done

# Wait for services to be ready
print_header "Waiting for Services to Initialize"
sleep 30

# Check service health
print_header "Checking Service Health"

# Function to check if a service is responding
check_service() {
    local service_name=$1
    local port=$2
    local max_attempts=30
    local attempt=1
    
    print_status "Checking $service_name on port $port..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:$port | grep -q "200\|302\|401"; then
            print_status "$service_name is responding ✓"
            return 0
        fi
        
        print_warning "Attempt $attempt/$max_attempts: $service_name not ready yet..."
        sleep 5
        ((attempt++))
    done
    
    print_error "$service_name failed to start properly"
    return 1
}

# Check core services
check_service "Traefik" "8080"
check_service "Grafana" "3000"
check_service "Prometheus" "9090"

# Display running containers
print_header "Running Containers"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Display service URLs
print_header "Service Access URLs"
echo "🌐 External Access (via Cloudflare Tunnel):"
echo "   Authentication: https://visionvation.com/login"
echo "   Dashboard: https://apps.visionvation.com"
echo "   Nextcloud: https://nextcloud.visionvation.com"
echo "   Grafana: https://grafana.visionvation.com"
echo "   Prometheus: https://prometheus.visionvation.com"
echo ""
echo "🏠 Local Access:"
echo "   Traefik Dashboard: http://localhost:8080"
echo "   Grafana: http://localhost:3000"
echo "   Prometheus: http://localhost:9090"
echo "   Heimdall: http://localhost"

# Display resource usage
print_header "Resource Usage"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

print_header "Deployment Complete!"
print_status "All services have been deployed successfully"
print_status "Check the service URLs above to access your infrastructure"
print_warning "Remember to configure your Cloudflare Tunnel token for external access"

echo ""
echo "🎉 Your complete self-hosted infrastructure is now running!"
echo "📚 Check the documentation for configuration details"
echo "🔧 Use 'docker compose logs [service]' to troubleshoot any issues"

