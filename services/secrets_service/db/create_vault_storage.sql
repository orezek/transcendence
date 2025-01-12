-- First, create database and user
CREATE DATABASE vault;
CREATE USER vault WITH PASSWORD 'vault_password';
GRANT ALL PRIVILEGES ON DATABASE vault TO vault;

-- Connect to the vault database
\c vault

-- Create the table and immediately set ownership
CREATE TABLE IF NOT EXISTS vault_kv_store (
                                              parent_path TEXT COLLATE "C" NOT NULL,
                                              path        TEXT COLLATE "C",
                                              key         TEXT COLLATE "C",
                                              value       BYTEA,
                                              CONSTRAINT pkey PRIMARY KEY (path, key)
    );

CREATE INDEX IF NOT EXISTS parent_path_idx ON vault_kv_store (parent_path);

-- Grant schema permissions
GRANT USAGE ON SCHEMA public TO vault;

-- Grant table permissions AND alter ownership
GRANT ALL PRIVILEGES ON TABLE vault_kv_store TO vault;
ALTER TABLE vault_kv_store OWNER TO vault;
ALTER INDEX parent_path_idx OWNER TO vault;

-- Grant sequence permissions if any exist
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO vault;