# Phase 1: Storage Layer - Quick Reference

## Project Structure
```
data-platform/
├── docker-compose.yml              # Main orchestration file
├── README.md                       # Detailed documentation
├── .gitignore                      # Git ignore patterns
├── config/                         # Future config files
├── data/                           # Local data directory
├── notebooks/
│   └── 01-storage-layer-test.ipynb # Validation tests
└── scripts/
    ├── start.sh                    # Quick start script
    └── health-check.sh             # Service health checker
```

## Quick Start Commands

### Start the Platform
```bash
cd data-platform
./scripts/start.sh
```

Or manually:
```bash
docker-compose up -d
```

### Check Service Health
```bash
./scripts/health-check.sh
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f spark-iceberg
docker-compose logs -f nessie
docker-compose logs -f minio
```

### Stop Services
```bash
# Stop (preserves data)
docker-compose down

# Stop and remove volumes (fresh start)
docker-compose down -v
```

## Service Access

| Service | URL | Credentials |
|---------|-----|-------------|
| MinIO Console | http://localhost:9001 | admin / password123 |
| MinIO API | http://localhost:9000 | - |
| Nessie API | http://localhost:19120/api/v2 | None |
| Spark UI | http://localhost:8080 | None |
| Jupyter Lab | http://localhost:8888 | None |
| PostgreSQL | localhost:5432 | nessie / nessie123 |

## Testing the Setup

1. Open Jupyter Lab: http://localhost:8888
2. Navigate to `notebooks/01-storage-layer-test.ipynb`
3. Run all cells (Cell → Run All)

The notebook tests:
- ✅ Spark + Iceberg integration
- ✅ Nessie catalog operations
- ✅ MinIO object storage
- ✅ Creating namespaces (raw, bronze, silver, gold)
- ✅ Creating and querying Iceberg tables
- ✅ Schema evolution
- ✅ Time travel (historical queries)
- ✅ Table partitioning
- ✅ Nessie branching (version control for data)

## MinIO Buckets Created

- `warehouse/` - Main Iceberg warehouse
- `raw/` - Raw/staging zone
- `bronze/` - Bronze layer
- `silver/` - Silver layer  
- `gold/` - Gold layer
- `iceberg/` - Iceberg metadata

## Key Technologies

- **Apache Iceberg**: Table format with ACID transactions
- **Project Nessie**: Git-like catalog with versioning
- **MinIO**: S3-compatible object storage
- **Apache Spark**: Processing engine
- **PostgreSQL**: Metadata storage
- **Jupyter**: Interactive development

## Common Operations

### Connect to PostgreSQL (metadata)
```bash
docker exec -it postgres-metadata psql -U nessie -d nessie
```

### Access MinIO CLI
```bash
docker exec -it minio mc alias set local http://localhost:9000 admin password123
docker exec -it minio mc ls local/
```

### Restart a Service
```bash
docker-compose restart [service-name]
```

### View Nessie Branches
```bash
curl http://localhost:19120/api/v2/trees
```

## Troubleshooting

### Services won't start
```bash
# Check for port conflicts
sudo lsof -i :5432
sudo lsof -i :9000
sudo lsof -i :19120

# Check Docker resources
docker system df
docker system prune  # Clean up if needed
```

### Jupyter kernel won't start
```bash
docker-compose restart spark-iceberg
docker-compose logs -f spark-iceberg
```

### MinIO buckets not created
```bash
docker-compose logs minio-setup
docker-compose restart minio-setup
```

## Next Phase Preview

**Phase 2** will add:
- PostgreSQL source database (with logical replication)
- MSSQL source database (with CDC)
- Debezium connectors
- Kafka/Redpanda for event streaming

This will enable real-time data replication from source databases into Iceberg tables.

## Resource Requirements

**Minimum:**
- 8 GB RAM
- 20 GB disk space
- 4 CPU cores

**Recommended:**
- 16 GB RAM
- 50 GB disk space
- 8 CPU cores

## Notes

- All data is stored in Docker volumes
- Use `docker-compose down -v` to completely reset
- Jupyter notebooks auto-save to `notebooks/` directory
- MinIO data persists between restarts
- Nessie metadata persists in PostgreSQL volume
