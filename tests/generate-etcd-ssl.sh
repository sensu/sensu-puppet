#!/bin/bash
set -e

CFSSL_VERSION="1.6.5"
RELEASE_BASE="https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}"

if ! command -v cfssl &>/dev/null; then
  echo "Downloading cfssl ${CFSSL_VERSION}..."
  curl -sL -o /usr/local/bin/cfssl "${RELEASE_BASE}/cfssl_${CFSSL_VERSION}_linux_amd64"
  curl -sL -o /usr/local/bin/cfssljson "${RELEASE_BASE}/cfssljson_${CFSSL_VERSION}_linux_amd64"
  chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/etcd-ssl" && pwd)"
cd "$DIR"

echo "Generating etcd CA..."
echo '{"CN":"CA","key":{"algo":"rsa","size":2048}}' | cfssl gencert -initca - | cfssljson -bare ca -

echo "Generating sensu-backend1 peer cert (192.168.52.30)..."
echo '{"CN":"sensu-backend1","hosts":[""],"key":{"algo":"rsa","size":2048}}' | \
  cfssl gencert -config=ca-config.json -ca=ca.pem -ca-key=ca-key.pem \
  -hostname="192.168.52.30,sensu-backend1" -profile=peer - | cfssljson -bare sensu-backend1

echo "Generating sensu-backend2 peer cert (192.168.52.31)..."
echo '{"CN":"sensu-backend2","hosts":[""],"key":{"algo":"rsa","size":2048}}' | \
  cfssl gencert -config=ca-config.json -ca=ca.pem -ca-key=ca-key.pem \
  -hostname="192.168.52.31,sensu-backend2" -profile=peer - | cfssljson -bare sensu-backend2

echo "Generating client cert..."
echo '{"CN":"client","hosts":[""],"key":{"algo":"rsa","size":2048}}' | \
  cfssl gencert -config=ca-config.json -ca=ca.pem -ca-key=ca-key.pem \
  -hostname="" -profile=client - | cfssljson -bare client

echo "Done. Certs written to tests/etcd-ssl/"
