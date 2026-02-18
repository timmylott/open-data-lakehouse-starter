#!/bin/bash

# Script to register Debezium PostgreSQL connector
# This should be run after all services are up and healthy

set -e

echo "========================================="
echo "Debezium Connector Registration"
echo "========================================="

# Wait for Debezium Connect to be ready
echo "Waiting for Debezium Connect to be ready..."
until curl -s http://localhost:8083/ > /dev/null; do
  echo "  Waiting..."
  sleep 5
done
echo "✓ Debezium Connect is ready"

# Check if connector already exists
CONNECTOR_NAME="hr-postgres-connector"
if curl -s http://localhost:8083/connectors | grep -q "$CONNECTOR_NAME"; then
  echo "⚠  Connector '$CONNECTOR_NAME' already exists. Deleting..."
  curl -X DELETE http://localhost:8083/connectors/$CONNECTOR_NAME
  sleep 2
fi

# Register the connector
echo "Registering $CONNECTOR_NAME..."
curl -X POST \
  -H "Content-Type: application/json" \
  --data @config/debezium/hr-postgres-connector.json \
  http://localhost:8083/connectors

echo ""
echo "========================================="
echo "Connector Registration Complete!"
echo "========================================="

# Wait a moment for connector to initialize
sleep 5

# Check connector status
echo ""
echo "Connector Status:"
curl -s http://localhost:8083/connectors/$CONNECTOR_NAME/status | jq '.'

echo ""
echo "========================================="
echo "Kafka Topics Created:"
echo "========================================="
docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list | grep "^hr"

echo ""
echo "========================================="
echo "Next Steps:"
echo "========================================="
echo "1. Check Kafka UI: http://localhost:8090"
echo "2. Monitor topics for CDC events"
echo "3. Run validation notebook"
echo "========================================="
