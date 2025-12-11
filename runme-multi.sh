#!/bin/bash

set -e  # Exit immediately if a command fails

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

GREEN='\033[0;32m'
NC='\033[0m' # No Color

function success() {
  echo -e "${GREEN}✅ $1${NC}"
}

echo "*** Cleaning up old containers..."
docker rm -f postgres-dev postgres-qa postgres-prod vault-server || true
success "Old containers cleaned up."

echo "*** Pulling images..."
docker pull postgres
docker pull hashicorp/vault:1.14.4
success "Docker images pulled."

echo "*** Starting PostgreSQL containers..."
docker run --name postgres-dev -p 5433:5432 -e POSTGRES_PASSWORD=secret -d postgres
docker run --name postgres-qa -p 5434:5432 -e POSTGRES_PASSWORD=secret -d postgres
docker run --name postgres-prod -p 5435:5432 -e POSTGRES_PASSWORD=secret -d postgres
success "Postgres containers started."

echo "*** Waiting for PostgreSQL to be ready..."
sleep 5
success "PostgreSQL containers ready."

echo "*** Creating multi-database structure (master, batch, admin)..."
for container in postgres-dev postgres-qa postgres-prod; do
  docker exec -i $container psql -U postgres -c "CREATE DATABASE master;"
  docker exec -i $container psql -U postgres -c "CREATE DATABASE batch;"
  docker exec -i $container psql -U postgres -c "CREATE DATABASE admin;"
done
success "Databases created: master, batch, admin in dev/qa/prod."

echo "*** Starting Vault dev server..."
docker run --name vault-server -p 8200:8200 \
  -e VAULT_DEV_ROOT_TOKEN_ID=vault-plaintext-root-token \
  -e VAULT_ADDR=http://0.0.0.0:8200 \
  -d hashicorp/vault:1.14.4 server -dev -dev-root-token-id=vault-plaintext-root-token
success "Vault server started."

echo "*** Waiting for Vault to be ready..."
until curl -s http://localhost:8200/v1/sys/health >/dev/null; do
  sleep 1
done
success "Vault is ready."

echo "*** Writing secrets to Vault..."
export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN='vault-plaintext-root-token'

vault kv put secret/liquibase/credentials username=postgres password=secret
vault kv put secret/liquibase/license pro_key="${LIQUIBASE_PRO_LICENSE}"
success "Secrets written to Vault."

echo "*** Copying SQL files into containers..."
docker cp SQL/Tables_DEV.sql postgres-dev:/tmp/Tables_DEV.sql
docker cp SQL/Tables_QA.sql postgres-qa:/tmp/Tables_QA.sql
success "SQL files copied."

echo "*** Running schema for postgres-dev..."
docker exec -i postgres-dev bash -c "psql -U postgres -a -f /tmp/Tables_DEV.sql"
success "Schema loaded for postgres-dev."

echo "*** Running schema for postgres-qa..."
docker exec -i postgres-qa bash -c "psql -U postgres -a -f /tmp/Tables_QA.sql"
success "Schema loaded for postgres-qa."

echo "*** Demo environment setup complete: PostgreSQL + Vault is ready."
success "Environment fully setup."

########################################
# NEW: Start GitHub Actions Runner
########################################

echo "*** Starting GitHub Actions runner in background..."

cd actions-runner  

# Start runner quietly in background
nohup ./run.sh > /dev/null 2>&1 &

success "GitHub Actions runner started in background."
```

**What changed:**
- Added database creation loop after containers start
- Creates `master`, `batch`, and `admin` databases in all three environments (dev/qa/prod)

**Now you can connect to:**
```
jdbc:postgresql://localhost:5433/master   (dev)
jdbc:postgresql://localhost:5433/batch    (dev)
jdbc:postgresql://localhost:5433/admin    (dev)
jdbc:postgresql://localhost:5434/master   (qa)
jdbc:postgresql://localhost:5434/batch    (qa)
jdbc:postgresql://localhost:5434/admin    (qa)