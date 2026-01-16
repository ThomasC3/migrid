# MiGrid Deployment Guide

**Version:** 10.0.0
**Last Updated:** January 2026

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ (for development)
- PostgreSQL 15+ with TimescaleDB
- 8GB RAM minimum (16GB recommended)
- 50GB disk space

### One-Command Deploy

```bash
# Start entire platform
docker-compose up --build

# Access services
# Admin Portal: http://localhost:5173
# API Docs: http://localhost:3001/health (and 3002-3010)
```

## Service Ports

| Service | Port | Description |
|---------|------|-------------|
| Physics Engine (L1) | 3001 | Energy variance calculation |
| Grid Signal (L2) | 3002 | OpenADR 3.0 VEN |
| VPP Aggregator (L3) | 3003 | Fleet capacity aggregation |
| Market Gateway (L4) | 3004 | CAISO/PJM integration |
| Driver Experience API (L5) | 3005 | Mobile app backend |
| Engagement Engine (L6) | 3006 | Gamification & leaderboards |
| Device Gateway (L7) | 3007, 9220 | OCPP WebSocket |
| Energy Manager (L8) | 3008 | Dynamic Load Management |
| Commerce Engine (L9) | 3009 | Billing & tariffs |
| Token Engine (L10) | 3010 | Web3 rewards |
| Admin Portal Web | 5173 | React admin interface |

## Database Setup

### Initialize Schema

```bash
# Run migrations
docker exec -i migrid-postgres-1 psql -U migrid -d migrid_core < scripts/migrations/001_init_schema.sql
```

### Seed Demo Data

```bash
# Install dependencies
npm install

# Run seed script
node scripts/seed-data.js
```

### Demo Credentials

**Email:** alice@demo.com
**Password:** demo123

## Environment Variables

### Production Setup

Create `.env` file:

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/migrid_core

# Security
JWT_SECRET=your-secret-key-here

# Markets
CAISO_SC_ID=your_sc_id
CAISO_API_KEY=your_api_key
PJM_MEMBER_ID=your_member_id
PJM_API_KEY=your_api_key

# Blockchain
POLYGON_RPC_URL=https://polygon-rpc.com
WALLET_PRIVATE_KEY=your_private_key

# Grid
GRID_CONNECTION_LIMIT_KW=500
MODBUS_HOST=192.168.1.100
MODBUS_PORT=502
```

## Health Checks

```bash
# Check all services
for port in 3001 3002 3003 3004 3005 3006 3007 3008 3009 3010; do
  echo "Checking port $port..."
  curl -s http://localhost:$port/health | jq
done
```

## Monitoring

### Logs

```bash
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f physics-engine
docker-compose logs -f vpp-aggregator
```

### Database Queries

```bash
# Active sessions
docker exec -it migrid-postgres-1 psql -U migrid -d migrid_core -c "SELECT * FROM charging_sessions WHERE end_time IS NULL;"

# VPP capacity
docker exec -it migrid-postgres-1 psql -U migrid -d migrid_core -c "SELECT * FROM vpp_resources;"

# Leaderboard
docker exec -it migrid-postgres-1 psql -U migrid -d migrid_core -c "SELECT * FROM leaderboard ORDER BY rank;"
```

## API Examples

### Authentication

```bash
# Register driver
curl -X POST http://localhost:3005/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "secure123",
    "first_name": "Test",
    "last_name": "User",
    "fleet_id": "YOUR_FLEET_ID"
  }'

# Login
curl -X POST http://localhost:3005/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@demo.com",
    "password": "demo123"
  }'
```

### VPP Operations

```bash
# Get available capacity
curl http://localhost:3003/capacity/available

# Register vehicle as VPP resource
curl -X POST http://localhost:3003/resources/register \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle_id": "YOUR_VEHICLE_ID",
    "battery_capacity_kwh": 131,
    "v2g_enabled": true
  }'
```

### Market Gateway

```bash
# Get current LMP prices
curl http://localhost:3004/markets/CAISO/prices

# Submit energy bid
curl -X POST http://localhost:3004/bids/submit \
  -H "Content-Type: application/json" \
  -d '{
    "iso": "CAISO",
    "market_type": "day-ahead",
    "quantity_kw": 500,
    "price_per_mwh": 75.00,
    "delivery_hour": "2026-01-16T14:00:00Z"
  }'
```

### Energy Manager

```bash
# Get current site load
curl http://localhost:3008/load/current

# Apply Dynamic Load Management
curl -X POST http://localhost:3008/dlm/apply
```

## Troubleshooting

### Service won't start

```bash
# Check logs
docker-compose logs service-name

# Restart service
docker-compose restart service-name

# Rebuild service
docker-compose up --build service-name
```

### Database connection issues

```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check connection
docker exec -it migrid-postgres-1 psql -U migrid -d migrid_core -c "SELECT 1;"
```

### Port conflicts

```bash
# Check what's using a port
lsof -i :3001

# Stop conflicting service
kill -9 PID
```

## Production Deployment

### Kubernetes

```bash
# Coming soon: Helm charts for k8s deployment
# helm install migrid ./charts/migrid
```

### Security Checklist

- [ ] Change all default passwords
- [ ] Enable TLS/SSL for all services
- [ ] Set up firewall rules
- [ ] Configure backup strategy
- [ ] Enable audit logging
- [ ] Set up monitoring (Prometheus/Grafana)
- [ ] Configure log aggregation (ELK/Loki)

## Backup & Recovery

```bash
# Backup database
docker exec migrid-postgres-1 pg_dump -U migrid migrid_core > backup.sql

# Restore database
docker exec -i migrid-postgres-1 psql -U migrid -d migrid_core < backup.sql
```

## Performance Tuning

### PostgreSQL

```sql
-- Recommended settings for production
ALTER SYSTEM SET shared_buffers = '4GB';
ALTER SYSTEM SET effective_cache_size = '12GB';
ALTER SYSTEM SET work_mem = '64MB';
```

### TimescaleDB

```sql
-- Optimize chunk intervals
SELECT set_chunk_time_interval('charging_sessions', INTERVAL '7 days');
SELECT set_chunk_time_interval('lmp_prices', INTERVAL '1 day');
```

---

*For questions or support, see the main README or open an issue on GitHub.*
