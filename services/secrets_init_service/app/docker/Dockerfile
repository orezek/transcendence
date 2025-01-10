FROM alpine:latest

# Install necessary tools for interacting with Vault
RUN apk add --no-cache curl jq

# Copy our configuration script
COPY ./app/scripts/configure_secrets_service.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/configure_secrets_service.sh

# Set this as our entry point
ENTRYPOINT ["/usr/local/bin/configure_secrets_service.sh"]