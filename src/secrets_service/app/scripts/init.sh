#!/bin/sh

# Wait for PostgreSQL first
until PGPASSWORD=vault_password psql -h secrets_db_service -U vault -d vault -c '\q'; do
    >&2 echo "PostgreSQL is unavailable - sleeping"
    sleep 1
done

# Start Vault in the background
vault server -config=/vault/config/vault.hcl &

# Give Vault a moment to start its internal processes
sleep 2

# Function to check Vault status
check_vault_status() {
    HEALTH_RESPONSE=$(curl -s http://localhost:8200/v1/sys/health || echo "failed")

    if [ "$HEALTH_RESPONSE" = "failed" ]; then
        echo "Failed to connect to Vault"
        return 1
    fi

    echo "Vault health response: $HEALTH_RESPONSE"
    return 0
}

# Function to unseal Vault
unseal_vault() {
    echo "Unsealing Vault..."
    # Check if unseal keys exist
    if [ -f "/vault/shared_data/unseal_key_1" ] && [ -f "/vault/shared_data/unseal_key_2" ]; then
        curl --request POST --data "{\"key\": \"$(cat /vault/shared_data/unseal_key_1)\"}" http://localhost:8200/v1/sys/unseal
        curl --request POST --data "{\"key\": \"$(cat /vault/shared_data/unseal_key_2)\"}" http://localhost:8200/v1/sys/unseal
        echo "Vault unsealed using existing keys"
    else
        echo "Warning: Unseal keys not found"
        return 1
    fi
}

# Wait for Vault to become responsive
echo "Waiting for Vault to become available..."
until check_vault_status; do
    echo "Vault not yet ready, waiting..."
    sleep 2
done

# Get current Vault status
HEALTH_RESPONSE=$(curl -s http://localhost:8200/v1/sys/health)
INIT_STATUS=$(echo "$HEALTH_RESPONSE" | jq -r '.initialized')
SEALED_STATUS=$(echo "$HEALTH_RESPONSE" | jq -r '.sealed')

echo "Vault status - Initialized: $INIT_STATUS, Sealed: $SEALED_STATUS"

# Handle initialization if needed
if [ "$INIT_STATUS" = "false" ]; then
    echo "Starting Vault initialization..."
    INIT_RESPONSE=$(curl --request POST \
        --data '{"secret_shares": 3, "secret_threshold": 2}' \
        http://localhost:8200/v1/sys/init)

    if [ -z "$INIT_RESPONSE" ]; then
        echo "Error: Got empty response from initialization request"
        exit 1
    fi

    echo "Initialization response: $INIT_RESPONSE"

    ROOT_TOKEN=$(echo "$INIT_RESPONSE" | jq -r '.root_token')
    if [ -z "$ROOT_TOKEN" ] || [ "$ROOT_TOKEN" = "null" ]; then
        echo "Error: Failed to get root token from initialization response"
        exit 1
    fi

    # Save keys and token
    echo "$INIT_RESPONSE" | jq -r .root_token > /vault/shared_data/root_token
    echo "$INIT_RESPONSE" | jq -r '.keys_base64[0]' > /vault/shared_data/unseal_key_1
    echo "$INIT_RESPONSE" | jq -r '.keys_base64[1]' > /vault/shared_data/unseal_key_2
    echo "$INIT_RESPONSE" | jq -r '.keys_base64[2]' > /vault/shared_data/unseal_key_3

    chmod 600 /vault/shared_data/root_token
    chmod 600 /vault/shared_data/unseal_key_*

    # Initial unseal
    unseal_vault
    echo "Vault initialized and unsealed"
else
    echo "Vault is already initialized"
    # Check if vault needs to be unsealed
    if [ "$SEALED_STATUS" = "true" ]; then
        unseal_vault
    fi
fi

# Verify final status
FINAL_HEALTH=$(curl -s http://localhost:8200/v1/sys/health)
FINAL_SEALED=$(echo "$FINAL_HEALTH" | jq -r '.sealed')

if [ "$FINAL_SEALED" = "true" ]; then
    echo "Error: Vault is still sealed after initialization/unseal process"
    exit 1
fi

echo "Vault is initialized and unsealed successfully"

# Keep the container running
exec tail -f /dev/null