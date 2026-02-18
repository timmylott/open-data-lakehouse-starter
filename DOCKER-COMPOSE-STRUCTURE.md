# Docker Compose Structure

## Single Unified File

The project now uses a **single `docker-compose.yml`** file containing all services from both Phase 1 and Phase 2.

### Structure:

```yaml
services:
  # =============================
  # PHASE 1: Storage Layer
  # =============================
  postgres              # Nessie metadata
  minio                 # Object storage
  minio-setup           # Bucket creation
  nessie                # Iceberg catalog
  spark-iceberg         # Compute + Jupyter

  # =============================
  # PHASE 2: Database Replication
  # =============================
  postgres-source-hr    # HR system source
  zookeeper             # Kafka coordination
  kafka                 # Event streaming
  kafka-ui              # Kafka web UI
  debezium              # CDC platform
```

## Starting Services

### All Services (Default)
```bash
docker-compose up -d
```

This starts **all 10 services** (Phase 1 + Phase 2).

### Phase 1 Only
If you only want Phase 1 (storage layer):

```bash
docker-compose up -d postgres minio minio-setup nessie spark-iceberg
```

### Specific Phases

**Phase 1 Services:**
```bash
docker-compose up -d postgres minio minio-setup nessie spark-iceberg
```

**Phase 2 Services (requires Phase 1):**
```bash
# Start Phase 1 first
docker-compose up -d postgres minio minio-setup nessie spark-iceberg

# Then add Phase 2
docker-compose up -d postgres-source-hr zookeeper kafka kafka-ui debezium
```

## Service Dependencies

Phase 2 services depend on Phase 1:
- Spark/Jupyter needs to be running for validation notebooks
- Kafka topics will eventually feed into Iceberg (Phase 2b)

## Backup Files

- `docker-compose-phase1-only.yml` - Phase 1 services only (backup)
- `docker-compose-phase2.yml` - Phase 2 services only (backup)

These are kept for reference but not used by default.

## Resource Management

If you're resource-constrained, start services incrementally:

```bash
# Minimal Phase 1 (no Jupyter)
docker-compose up -d postgres minio nessie

# Add Spark when needed
docker-compose up -d spark-iceberg

# Add CDC when ready for Phase 2
docker-compose up -d postgres-source-hr zookeeper kafka debezium
```

## Checking Status

```bash
# See all services
docker-compose ps

# See only running services
docker-compose ps --services --filter "status=running"

# Check specific service logs
docker-compose logs -f kafka
```

## Stopping Services

```bash
# Stop all
docker-compose down

# Stop but keep data
docker-compose stop

# Stop and remove volumes (fresh start)
docker-compose down -v
```

## Why Single File?

**Pros:**
- ✅ Simpler to manage
- ✅ One command to start everything
- ✅ Clear service relationships
- ✅ Easier for new users

**Cons:**
- ❌ Always pulls all images
- ❌ Can't easily exclude phases

The simplicity wins out for this starter kit. For production, you'd likely split services into separate compose files or use Kubernetes.
