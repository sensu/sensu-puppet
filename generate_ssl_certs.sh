#!/bin/bash

# Generate new SSL certificates for Sensu testing
# This script creates a CA and certificates valid for 10 years

set -e

SSL_DIR="tests/ssl"
CA_DIR="$SSL_DIR/ca"
SIGNED_DIR="$CA_DIR/signed"

# Backup old certificates if they exist
if [ -d "$SSL_DIR" ]; then
  BACKUP_DIR="tests/ssl_backup_$(date +%Y%m%d_%H%M%S)"
  echo "Backing up old certificates to $BACKUP_DIR"
  cp -r "$SSL_DIR" "$BACKUP_DIR"
  rm -rf "$SSL_DIR"
fi

# Create directories
mkdir -p "$CA_DIR/private"
mkdir -p "$SIGNED_DIR"
mkdir -p "$SSL_DIR/certs"
mkdir -p "$SSL_DIR/private_keys"
mkdir -p "$SSL_DIR/public_keys"

# Generate CA private key
openssl genrsa -out "$CA_DIR/private/ca_key.pem" 4096

# Generate CA certificate (valid for 10 years)
openssl req -new -x509 -key "$CA_DIR/private/ca_key.pem" -out "$CA_DIR/ca_crt.pem" -days 3650 -subj "/C=US/ST=CA/L=San Francisco/O=Sensu/OU=Testing/CN=Sensu Test CA"

# Generate CA public key
openssl rsa -in "$CA_DIR/private/ca_key.pem" -pubout -out "$CA_DIR/ca_pub.pem"

# Create index and serial files
touch "$CA_DIR/index.txt"
echo 1000 > "$CA_DIR/serial"
echo 1000 > "$CA_DIR/crlnumber"

# Create a simple CA config file
cat > "$CA_DIR/ca.conf" << EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir = $CA_DIR
certs = \$dir
crl_dir = \$dir
database = \$dir/index.txt
new_certs_dir = \$dir/signed
certificate = \$dir/ca_crt.pem
serial = \$dir/serial
crlnumber = \$dir/crlnumber
crl = \$dir/crl.pem
private_key = \$dir/private/ca_key.pem
RANDFILE = \$dir/private/.rand
x509_extensions = usr_cert
name_opt = ca_default
cert_opt = ca_default
default_days = 3650
default_crl_days = 3650
default_md = sha256
preserve = no
policy = policy_match

[ policy_match ]
countryName = match
stateOrProvinceName = match
organizationName = match
organizationalUnitName = optional
commonName = supplied
emailAddress = optional

[ usr_cert ]
basicConstraints = CA:FALSE
nsComment = "OpenSSL Generated Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = sensu-backend
DNS.2 = localhost
IP.1 = 127.0.0.1
EOF

# Generate CRL
openssl ca -gencrl -keyfile "$CA_DIR/private/ca_key.pem" -cert "$CA_DIR/ca_crt.pem" -out "$SSL_DIR/crl.pem" -config "$CA_DIR/ca.conf"

# Generate sensu-backend certificate
openssl genrsa -out "$SSL_DIR/private_keys/sensu-backend_key.pem" 2048
openssl req -new -key "$SSL_DIR/private_keys/sensu-backend_key.pem" -out "$CA_DIR/sensu-backend.csr" -subj "/C=US/ST=CA/L=San Francisco/O=Sensu/OU=Testing/CN=sensu-backend"
openssl ca -in "$CA_DIR/sensu-backend.csr" -out "$SIGNED_DIR/sensu-backend.pem" -days 3650 -config "$CA_DIR/ca.conf" -batch

# Generate sensu-agent certificate
openssl genrsa -out "$SSL_DIR/private_keys/sensu-agent_key.pem" 2048
openssl req -new -key "$SSL_DIR/private_keys/sensu-agent_key.pem" -out "$CA_DIR/sensu-agent.csr" -subj "/C=US/ST=CA/L=San Francisco/O=Sensu/OU=Testing/CN=sensu-agent"
openssl ca -in "$CA_DIR/sensu-agent.csr" -out "$SIGNED_DIR/sensu-agent.pem" -days 3650 -config "$CA_DIR/ca.conf" -batch

# Copy certificates to expected locations
cp "$CA_DIR/ca_crt.pem" "$SSL_DIR/certs/ca.crt"
cp "$SIGNED_DIR/sensu-backend.pem" "$SSL_DIR/certs/cert.pem"
cp "$SSL_DIR/private_keys/sensu-backend_key.pem" "$SSL_DIR/private_keys/key.pem"

echo "SSL certificates generated successfully!"
echo "CA certificate: $SSL_DIR/ca/ca_crt.pem"
echo "Backend certificate: $SIGNED_DIR/sensu-backend.pem"
echo "Agent certificate: $SIGNED_DIR/sensu-agent.pem"
