#!/bin/bash

# Quick start script for Phase 1

echo "========================================"
echo "Data Platform - Phase 1 Setup"
echo "========================================"
echo ""

# Check Docker
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running. Please start Docker first."
    exit 1
fi

echo "✓ Docker is running"
echo ""

# Pull images (optional, but shows progress)
echo "Pulling Docker images (this may take a few minutes)..."
docker-compose pull

echo ""
echo "Starting services..."
docker-compose up -d

echo ""
echo "Waiting for services to be healthy (60 seconds)..."
sleep 60

echo ""
echo "Running health checks..."
./scripts/health-check.sh

echo ""
echo "========================================"
echo "Phase 1 Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Open Jupyter Lab: http://localhost:8888"
echo "2. Run the test notebook: notebooks/01-storage-layer-test.ipynb"
echo "3. Check MinIO Console: http://localhost:9001 (admin/password123)"
echo ""
echo "To stop services: docker-compose down"
echo "To view logs: docker-compose logs -f"
echo "========================================"
