#!/bin/bash
# 🚀 Dynamic Trading System Launcher

set -e

echo "🚀 QBot Dynamic Trading System Launcher"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for required environment variables
check_env() {
    local required_vars=(
        "ALPACA_API_KEY"
        "ALPACA_SECRET_KEY"
        "GROK_API_KEY"
        "FINNHUB_API_KEY"
    )
    
    echo -e "${BLUE}Checking environment variables...${NC}"
    local missing=0
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo -e "${RED}❌ Missing: $var${NC}"
            missing=1
        else
            echo -e "${GREEN}✅ Found: $var${NC}"
        fi
    done
    
    if [ $missing -eq 1 ]; then
        echo -e "${YELLOW}Please set missing environment variables in .env file${NC}"
        exit 1
    fi
}

# Create necessary directories
setup_directories() {
    echo -e "${BLUE}Setting up directories...${NC}"
    mkdir -p logs models grafana/dashboards grafana/datasources ssl
    echo -e "${GREEN}✅ Directories created${NC}"
}

# Generate SSL certificates for development
generate_ssl() {
    if [ ! -f ssl/cert.pem ]; then
        echo -e "${BLUE}Generating SSL certificates...${NC}"
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout ssl/key.pem -out ssl/cert.pem \
            -subj "/C=US/ST=State/L=City/O=QBot/CN=qbot.local"
        echo -e "${GREEN}✅ SSL certificates generated${NC}"
    fi
}

# Create nginx configuration
create_nginx_config() {
    echo -e "${BLUE}Creating Nginx configuration...${NC}"
    cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream api {
        server dashboard-api:8000;
    }
    
    upstream websocket {
        server realtime-engine:8765;
    }
    
    map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
    }
    
    server {
        listen 80;
        server_name qbot.local api.qbot.local;
        
        location / {
            proxy_pass http://api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location /ws {
            proxy_pass http://websocket;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_read_timeout 86400;
        }
        
        location /graphql {
            proxy_pass http://api/graphql;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
        }
    }
}
EOF
    echo -e "${GREEN}✅ Nginx configuration created${NC}"
}

# Create Prometheus configuration
create_prometheus_config() {
    echo -e "${BLUE}Creating Prometheus configuration...${NC}"
    cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
  
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
  
  - job_name: 'api'
    static_configs:
      - targets: ['dashboard-api:8000']
    metrics_path: '/metrics'
EOF
    echo -e "${GREEN}✅ Prometheus configuration created${NC}"
}

# Create Grafana dashboards
create_grafana_dashboards() {
    echo -e "${BLUE}Creating Grafana dashboards...${NC}"
    
    # Create datasource
    cat > grafana/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF
    
    # Create dashboard provider
    cat > grafana/dashboards/provider.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'QBot Dashboards'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /etc/grafana/provisioning/dashboards
EOF
    
    echo -e "${GREEN}✅ Grafana configuration created${NC}"
}

# Start services
start_services() {
    echo -e "${BLUE}Starting services...${NC}"
    
    # Start core services first
    echo -e "${YELLOW}Starting core infrastructure...${NC}"
    docker-compose -f docker-compose.dynamic.yml up -d redis-master postgres
    
    # Wait for services to be healthy
    echo -e "${YELLOW}Waiting for services to be ready...${NC}"
    sleep 10
    
    # Start remaining services
    echo -e "${YELLOW}Starting all services...${NC}"
    docker-compose -f docker-compose.dynamic.yml up -d
    
    # Optional: Start monitoring stack
    read -p "Start monitoring stack (Prometheus, Grafana)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose -f docker-compose.dynamic.yml --profile monitoring up -d
    fi
}

# Show status
show_status() {
    echo ""
    echo -e "${GREEN}🎉 QBot Dynamic Trading System is starting!${NC}"
    echo ""
    echo "Services:"
    echo "  📊 Dashboard API:     http://localhost:8000"
    echo "  📡 WebSocket:         ws://localhost:8765"
    echo "  🔴 Redis Commander:   http://localhost:8081"
    echo "  📈 Grafana:          http://localhost:3000 (admin/admin)"
    echo "  📊 Prometheus:       http://localhost:9090"
    echo ""
    echo "API Endpoints:"
    echo "  REST API:     http://localhost:8000/docs"
    echo "  GraphQL:      http://localhost:8000/graphql"
    echo "  WebSocket:    ws://localhost:8000/ws/{channel}"
    echo ""
    echo -e "${YELLOW}Use 'docker-compose -f docker-compose.dynamic.yml logs -f [service]' to view logs${NC}"
    echo -e "${YELLOW}Use 'docker-compose -f docker-compose.dynamic.yml down' to stop all services${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}Starting Dynamic Trading System setup...${NC}"
    
    # Load .env file if exists
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi
    
    check_env
    setup_directories
    generate_ssl
    create_nginx_config
    create_prometheus_config
    create_grafana_dashboards
    start_services
    show_status
}

# Run main function
main