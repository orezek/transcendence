#!/bin/sh

# Wait for Vault to be fully available
until curl -fs http://secrets_service:8200/v1/sys/health | jq -e '.initialized==true and .sealed==false' >/dev/null; do
    echo "Waiting for Vault to be ready..."
    sleep 2
done

# Read the root token from shared volume
export VAULT_TOKEN=$(cat /vault/shared_data/root_token)

# Enable KV secrets engine version 2 at path 'secret'
echo "Enabling KV secrets engine..."
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{"type": "kv", "options": {"version": "2"}}' \
     http://secrets_service:8200/v1/sys/mounts/secret

# Create a simple test policy with read/write access
echo "Creating test policy with read/write access..."
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request PUT \
     --data '{
       "policy": "path \"secret/data/*\" { capabilities = [\"create\", \"read\", \"update\", \"delete\", \"list\"] }"
     }' \
     http://secrets_service:8200/v1/sys/policies/acl/test-access

# Create a test token with the policy
echo "Creating test token..."
TEST_TOKEN=$(curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{
       "policies": ["test-access"],
       "ttl": "768h"
     }' \
     http://secrets_service:8200/v1/auth/token/create | jq -r '.auth.client_token')

# Save the test token to shared volume
echo $TEST_TOKEN > /vault/shared_data/test_service_token
chmod 600 /vault/shared_data/test_service_token

# Store some test data
echo "Storing test data..."
curl --header "X-Vault-Token: $TEST_TOKEN" \
     --request POST \
     --data '{
       "data": {
         "test_key": "test_value"
       }
     }' \
     http://secrets_service:8200/v1/secret/data/test

echo "Vault test configuration completed successfully"