#!/bin/sh

# Wait for Vault to be fully available
until curl -fs http://secrets_service:8200/v1/sys/health | jq -e '.initialized==true and .sealed==false' >/dev/null; do
    echo "Waiting for Vault to be ready..."
    sleep 2
done

# Read the root token from shared volume
export VAULT_TOKEN=$(cat /vault/shared_data/root_token)

# Enable KV secrets engine version 2 at path 'password_manager'
echo "Enabling KV secrets engine..."
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{"type": "kv", "options": {"version": "2"}}' \
     http://secrets_service:8200/v1/sys/mounts/password_manager

# Create a test policy with read/write access
echo "Creating a policy with read/write access..."
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request PUT \
     --data '{
       "policy": "path \"password_manager/data/*\" { capabilities = [\"create\", \"read\", \"update\", \"delete\", \"list\"] }"
     }' \
     http://secrets_service:8200/v1/sys/policies/acl/password_manager

# Create a token with the policy
echo "Creating password manager token..."
PASSWORD_MANAGER=$(curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{
       "policies": ["password_manager"],
       "ttl": "768h"
     }' \
     http://secrets_service:8200/v1/auth/token/create | jq -r '.auth.client_token')

# Save the token to shared volume
echo $PASSWORD_MANAGER > /vault/shared_data/password_manager_token
chmod 666 /vault/shared_data/password_manager_token

# Save JWT secret key
echo "Storing a JWT secret..."
curl --header "X-Vault-Token: $PASSWORD_MANAGER" \
     --request POST \
     --data '{
       "data": {
         "jwt_secret_key": "asfals2342343safdsfasfasfaersafsjfslfkjaslfasjf"
       }
     }' \
     http://secrets_service:8200/v1/password_manager/data/jwt_secret_key

echo "Vault test configuration completed successfully"