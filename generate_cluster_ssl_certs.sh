#!/bin/bash
set -e

# Script to generate SSL certificates for Sensu cluster tests
# This script will be called from the cluster test to generate certs with correct IPs

echo "=== Generating SSL Certificates for Sensu Cluster ==="

# Get the node IPs passed as arguments
NODE1_IP=$1
NODE2_IP=$2
NODE3_IP=$3

if [ -z "$NODE1_IP" ] || [ -z "$NODE2_IP" ] || [ -z "$NODE3_IP" ]; then
    echo "Error: Node IPs required"
    echo "Usage: $0 <node1_ip> <node2_ip> <node3_ip>"
    exit 1
fi

echo "Node 1 IP: $NODE1_IP"
echo "Node 2 IP: $NODE2_IP"
echo "Node 3 IP: $NODE3_IP"

# Create temporary directory for certificates
CERT_DIR="/tmp/sensu_cluster_certs"
rm -rf "$CERT_DIR"
mkdir -p "$CERT_DIR"

# Generate CA key and certificate
echo "Generating CA certificate..."
openssl genrsa -out "$CERT_DIR/ca-key.pem" 4096

openssl req -new -x509 -days 365 -key "$CERT_DIR/ca-key.pem" \
    -sha256 -out "$CERT_DIR/ca.pem" \
    -subj "/C=US/ST=State/L=City/O=Sensu/OU=Test/CN=Sensu-CA"

# Create OpenSSL config for SANs
cat > "$CERT_DIR/openssl.cnf" <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = sensu-backend
DNS.3 = sensu-backend-1
DNS.4 = sensu-backend-2
DNS.5 = sensu-backend-3
IP.1 = 127.0.0.1
IP.2 = $NODE1_IP
IP.3 = $NODE2_IP
IP.4 = $NODE3_IP
EOF

# Generate backend certificate with all IPs in SANs
echo "Generating backend certificate with SANs..."
openssl genrsa -out "$CERT_DIR/backend-key.pem" 4096

openssl req -new -key "$CERT_DIR/backend-key.pem" \
    -out "$CERT_DIR/backend.csr" \
    -subj "/C=US/ST=State/L=City/O=Sensu/OU=Test/CN=sensu-backend" \
    -config "$CERT_DIR/openssl.cnf"

openssl x509 -req -in "$CERT_DIR/backend.csr" \
    -CA "$CERT_DIR/ca.pem" \
    -CAkey "$CERT_DIR/ca-key.pem" \
    -CAcreateserial \
    -out "$CERT_DIR/backend-cert.pem" \
    -days 365 \
    -sha256 \
    -extensions v3_req \
    -extfile "$CERT_DIR/openssl.cnf"

# Verify the certificate
echo ""
echo "=== Verifying Certificate SANs ==="
openssl x509 -in "$CERT_DIR/backend-cert.pem" -text -noout | grep -A 10 "Subject Alternative Name"

echo ""
echo "=== Certificates generated successfully ==="
echo "CA Certificate: $CERT_DIR/ca.pem"
echo "Backend Certificate: $CERT_DIR/backend-cert.pem"
echo "Backend Key: $CERT_DIR/backend-key.pem"
echo ""
echo "These certificates are valid for:"
echo "  - 127.0.0.1"
echo "  - $NODE1_IP"
echo "  - $NODE2_IP"
echo "  - $NODE3_IP"
echo "  - localhost, sensu-backend, sensu-backend-1, sensu-backend-2, sensu-backend-3"
