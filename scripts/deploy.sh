#!/bin/bash

# =============================================================================
# SELF-HOSTED INFRASTRUCTURE DEPLOYMENT SCRIPT
# =============================================================================
# Automated deployment script for complete infrastructure stack
# Usage: ./scripts/deploy.sh
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if Docker is running
check_docker() {
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
}

# Function to create directories
create_directories() {
    print_status "Creating required directories..."
    
    # Create media directories
    sudo mkdir -p /mnt/media/{photos,videos,movies,tv_series,music,documents,downloads}
    sudo chown -R $USER:$USER /mnt/media
    sudo chmod -R 755 /mnt/media
    
    # Create config directories
    mkdir -p config/{traefik/{dynamic,static},prometheus,grafana/{provisioning/{datasources,dashboards}},loki,promtail}
    
    # Create secrets directory
    mkdir -p secrets
    chmod 700 secrets
    
    print_success "Directories created successfully"
}

# Function to check environment file
check_environment() {
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            print_warning ".env file not found. Copying from .env.example"
            cp .env.example .env
            print_warning "Please edit .env file with your configuration before continuing."
            print_warning "Required: DOMAIN, passwords, and other settings."
            read -p "Press Enter after editing .env file..."
        else
            print_error ".env file not found and no .env.example available"
            exit 1
        fi
    fi
    
    # Check for required variables
    source .env
    
    if [ -z "$DOMAIN" ]; then
        print_error "DOMAIN not set in .env file"
        exit 1
    fi
    
    if [ -z "$POSTGRES_PASSWORD" ]; then
        print_error "POSTGRES_PASSWORD not set in .env file"
        exit 1
    fi
    
    print_success "Environment configuration validated"
}

# Function to create basic configurations
create_configs() {
    print_status "Creating basic configuration files..."
    
    # Create Traefik configuration
    if [ ! -f config/traefik/traefik.yml ]; then
        cat > config/traefik/traefik.yml << EOF
api:
  dashboard: true
  insecure: true

entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

providers:
  docker:
    exposedByDefault: false
  file:
    directory: /etc/traefik/dynamic
    watch: true

certificatesResolvers:
  letsencrypt:
    acme:
      tlsChallenge: {}
      email: ${ACME_EMAIL:-admin@example.com}
      storage: /letsencrypt/acme.json
EOF
    fi
    
    # Create Traefik middlewares
    if [ ! -f config/traefik/dynamic/middlewares.yml ]; then
        cat > config/traefik/dynamic/middlewares.yml << EOF
http:
  middlewares:
    authentik-forward-auth:
      forwardAuth:
        address: "http://authentik-server:9000/outpost.goauthentik.io/auth/traefik"
        trustForwardHeader: true
        authResponseHeaders:
          - X-authentik-username
          - X-authentik-groups
          - X-authentik-email
          - X-authentik-name
          - X-authentik-uid
          - X-authentik-jwt
          - X-authentik-meta-jwks
          - X-authentik-meta-outpost
          - X-authentik-meta-provider
          - X-authentik-meta-app
          - X-authentik-meta-version
EOF
    fi
    
    # Create Prometheus configuration
    if [ ! -f config/prometheus/prometheus.yml ]; then
        cat > config/prometheus/prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'traefik'
    static_configs:
      - targets: ['traefik:8080']
EOF
    fi
    
    print_success "Configuration files created"
}

# Function to deploy the stack
deploy_stack() {
    print_status "Deploying infrastructure stack..."
    
    # Pull latest images
    print_status "Pulling latest Docker images..."
    docker compose -f full-stack.yml pull
    
    # Deploy the stack
    print_status "Starting services..."
    docker compose -f full-stack.yml up -d
    
    print_success "Infrastructure stack deployed successfully"
}

# Function to check service health
check_services() {
    print_status "Checking service health..."
    
    sleep 30  # Wait for services to start
    
    # Check if services are running
    services=$(docker compose -f full-stack.yml ps --services)
    running_services=0
    total_services=0
    
    for service in $services; do
        total_services=$((total_services + 1))
        if docker compose -f full-stack.yml ps $service | grep -q "Up"; then
            running_services=$((running_services + 1))
            print_success "$service is running"
        else
            print_warning "$service is not running"
        fi
    done
    
    print_status "$running_services/$total_services services are running"
    
    if [ $running_services -eq $total_services ]; then
        print_success "All services are healthy!"
    else
        print_warning "Some services may need attention. Check logs with:"
        print_warning "docker compose -f full-stack.yml logs [service-name]"
    fi
}

# Function to display access information
show_access_info() {
    source .env
    
    echo ""
    echo "============================================================================="
    echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE!${NC}"
    echo "============================================================================="
    echo ""
    echo "Your self-hosted infrastructure is now running!"
    echo ""
    echo "🌐 Access your services:"
    echo ""
    if [ ! -z "$DOMAIN" ]; then
        echo "🔐 Login:      https://$DOMAIN/login"
        echo "🏠 Dashboard:  https://apps.$DOMAIN"
        echo "☁️  Files:     https://nextcloud.$DOMAIN"
        echo "📸 Photos:     https://photos.$DOMAIN"
        echo "🎬 Media:      https://plex.$DOMAIN"
        echo "📊 Analytics:  https://grafana.$DOMAIN"
        echo "🔧 Management: https://portainer.$DOMAIN"
    else
        echo "🔐 Login:      http://localhost/login"
        echo "🏠 Dashboard:  http://localhost:8081"
        echo "☁️  Files:     http://localhost:8082"
        echo "📸 Photos:     http://localhost:2342"
        echo "🎬 Media:      http://localhost:32400"
        echo "📊 Analytics:  http://localhost:3000"
        echo "🔧 Management: http://localhost:9000"
    fi
    echo ""
    echo "🔑 Default credentials:"
    echo "   Username: admin"
    echo "   Password: (check your .env file)"
    echo ""
    echo "📚 Documentation: docs/"
    echo "🛠️  Logs: docker compose -f full-stack.yml logs -f"
    echo "⏹️  Stop: docker compose -f full-stack.yml down"
    echo ""
    echo "============================================================================="
}

# Main execution
main() {
    echo "============================================================================="
    echo -e "${BLUE}🚀 SELF-HOSTED INFRASTRUCTURE DEPLOYMENT${NC}"
    echo "============================================================================="
    echo ""
    
    print_status "Starting deployment process..."
    
    # Check prerequisites
    check_docker
    
    # Setup environment
    check_environment
    
    # Create directories and configs
    create_directories
    create_configs
    
    # Deploy the stack
    deploy_stack
    
    # Check service health
    check_services
    
    # Show access information
    show_access_info
    
    print_success "Deployment completed successfully!"
}

# Run main function
main "$@"

