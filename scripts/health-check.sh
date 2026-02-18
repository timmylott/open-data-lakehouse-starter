#!/bin/bash

# Health check script for Phase 1 services

echo "========================================"
echo "Data Platform - Service Health Check"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_service() {
    local service=$1
    local url=$2
    local name=$3
    
    if curl -s -f -o /dev/null "$url"; then
        echo -e "${GREEN}✓${NC} $name is healthy"
        return 0
    else
        echo -e "${RED}✗${NC} $name is not responding"
        return 1
    fi
}

# Check Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}✗${NC} Docker is not running!"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker is running"
echo ""

# Check MinIO
echo "Checking MinIO..."
check_service "minio" "http://localhost:9000/minio/health/live" "MinIO API"
check_service "minio" "http://localhost:9001" "MinIO Console"
echo ""

# Check Nessie
echo "Checking Nessie Catalog..."
check_service "nessie" "http://localhost:19120/api/v2/config" "Nessie API"
echo ""

# Check PostgreSQL
echo "Checking PostgreSQL..."
if docker exec postgres-metadata pg_isready -U nessie > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} PostgreSQL is healthy"
else
    echo -e "${RED}✗${NC} PostgreSQL is not responding"
fi
echo ""

# Check Spark
echo "Checking Spark..."
check_service "spark" "http://localhost:8080" "Spark Master UI"
check_service "jupyter" "http://localhost:8888" "Jupyter Lab"
echo ""

# Docker compose status
echo "Docker Compose Status:"
echo "========================================"
docker-compose ps
echo ""

echo "========================================"
echo "Service URLs:"
echo "========================================"
echo "MinIO Console:    http://localhost:9001"
echo "Nessie API:       http://localhost:19120/api/v2"
echo "Spark UI:         http://localhost:8080"
echo "Jupyter Lab:      http://localhost:8888"
echo "========================================"
