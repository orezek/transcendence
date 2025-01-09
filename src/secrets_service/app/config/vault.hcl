# vault/config/vault.hcl
storage "postgresql" {
  connection_url = "postgres://vault:vault_password@secrets_db_service:5432/vault?sslmode=disable"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1  # Enable TLS in production!
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "https://0.0.0.0:8201"

ui = true