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

# Now let's implement a more thorough health check
check_vault_status() {
    HEALTH_RESPONSE=$(curl -s http://localhost:8200/v1/sys/health || echo "failed")

    if [ "$HEALTH_RESPONSE" = "failed" ]; then
        echo "Failed to connect to Vault"
        return 1
    fi

    # Print the full response for debugging
    echo "Vault health response: $HEALTH_RESPONSE"

    # Try to parse initialization status
    INIT_STATUS=$(echo "$HEALTH_RESPONSE" | jq -r '.initialized' || echo "failed")

    if [ "$INIT_STATUS" = "failed" ]; then
        echo "Failed to parse initialization status"
        return 1
    fi

    return 0
}

# Wait for Vault to become fully responsive
echo "Waiting for Vault to become available..."
until check_vault_status; do
    echo "Vault not yet ready, waiting..."
    sleep 2
done

# Now we can safely check initialization status
HEALTH_RESPONSE=$(curl -s http://localhost:8200/v1/sys/health)
INIT_STATUS=$(echo "$HEALTH_RESPONSE" | jq -r '.initialized')

echo "Final initialization status check: $INIT_STATUS"

if [ "$INIT_STATUS" = "false" ]; then
    echo "Starting Vault initialization..."

    INIT_RESPONSE=$(curl --request POST \
        --data '{"secret_shares": 3, "secret_threshold": 2}' \
        http://localhost:8200/v1/sys/init)

    # Verify we got a valid response
    if [ -z "$INIT_RESPONSE" ]; then
        echo "Error: Got empty response from initialization request"
        exit 1
    fi

    echo "Initialization response: $INIT_RESPONSE"

    # Extract and verify root token before proceeding
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

    # Unseal Vault
    curl --request POST --data "{\"key\": \"$(cat /vault/shared_data/unseal_key_1)\"}" http://localhost:8200/v1/sys/unseal
    curl --request POST --data "{\"key\": \"$(cat /vault/shared_data/unseal_key_2)\"}" http://localhost:8200/v1/sys/unseal

    echo "Vault initialized and unsealed"
else
    echo "Vault is already initialized"
fi

# Keep the container running
exec tail -f /dev/null