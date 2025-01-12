# vault/Dockerfile
FROM hashicorp/vault:1.13

# Install necessary utilities
RUN apk add --no-cache curl jq postgresql-client

# Copy configuration
COPY ./vault.hcl /vault/config/
COPY ./init.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/init.sh

# Expose Vault's default port
EXPOSE 8200

# Use custom entrypoint script
ENTRYPOINT ["init.sh"]