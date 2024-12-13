#!/bin/bash
set -e

echo "Creating additional indexes..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE INDEX idx_users_email ON users(email);
EOSQL

