# Generate SSL certs for tests

Boot `sensu-backend` vagrant box and log in as root

```
vagrant up sensu-backend
vagrant ssh sensu-backend
sudo su -
```

Generate certs

```
puppet cert generate sensu-backend --dns_alt_names=localhost,127.0.0.1,sensu-backend,sensu-backend1,sensu-backend2,sensu-backend3,sensu-backend.example.com,sensu-backend-peer1.example.com,sensu-backend-peer2.example.com
puppet cert generate sensu-backend1 --dns_alt_names=localhost,127.0.0.1,sensu-backend,sensu-backend1,sensu-backend2,sensu-backend3,sensu-backend.example.com,sensu-backend-peer1.example.com,sensu-backend-peer2.example.com
puppet cert generate sensu-backend2 --dns_alt_names=localhost,127.0.0.1,sensu-backend,sensu-backend1,sensu-backend2,sensu-backend3,sensu-backend.example.com,sensu-backend-peer1.example.com,sensu-backend-peer2.example.com
puppet cert generate sensu-backend3 --dns_alt_names=localhost,127.0.0.1,sensu-backend,sensu-backend1,sensu-backend2,sensu-backend3,sensu-backend.example.com,sensu-backend-peer1.example.com,sensu-backend-peer2.example.com
puppet cert generate sensu-agent
```

Copy certs from vagrant instance to this repo

```
\cp -r /etc/puppetlabs/puppet/ssl/* /vagrant/tests/ssl/
```

# Generate self signed certs for Etcd

Boot `sensu-backend` vagrant box and log in as root

```
vagrant up sensu-backend
vagrant ssh sensu-backend
sudo su -
```

Bootstrap SSL cert tool

```
yum install golang-bin
cd /root
git clone https://github.com/cloudflare/cfssl.git
cd cfssl/
make
export PATH=/root/cfssl/bin:$PATH
```

Generate CA

```
mkdir -p /vagrant/tests/etcd-ssl
cd /vagrant/tests/etcd-ssl
echo '{"CN":"CA","key":{"algo":"rsa","size":2048}}' | cfssl gencert -initca - | cfssljson -bare ca -
echo '{"signing":{"default":{"expiry":"43800h","usages":["signing","key encipherment","server auth","client auth"]}}}' > ca-config.json
```

Generate certs

```
export ADDRESS=192.168.52.30,sensu-backend1
export NAME=sensu-backend1
echo '{"CN":"'$NAME'","hosts":[""],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -config=ca-config.json -ca=ca.pem -ca-key=ca-key.pem -hostname="$ADDRESS" -profile=peer - | cfssljson -bare $NAME

export ADDRESS=192.168.52.31,sensu-backend2
export NAME=sensu-backend2
echo '{"CN":"'$NAME'","hosts":[""],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -config=ca-config.json -ca=ca.pem -ca-key=ca-key.pem -hostname="$ADDRESS" -profile=peer - | cfssljson -bare $NAME

export NAME=client
echo '{"CN":"'$NAME'","hosts":[""],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -config=ca-config.json -ca=ca.pem -ca-key=ca-key.pem -hostname="" -profile=client - | cfssljson -bare $NAME
```

# Secrets

Currently `tests/secrets.tar` holds secrets:

* sensu_licenson.json - test enterprise license
* secrets - environment variables that are secrets used by various scripts

Encrypt `tests/secrets.tar`, this should only be run if new secrets are needing to be added or modified. If available ensure `TRAVIS_CI_KEY` and `TRAVIS_CI_IV` environment variables are set or new ones will be used.

The print environment variable names for the openssl command must be updated in `.travis.yml`.

```
./tests/encrypt-secrets.sh
```

Decrypt `tests/secrets.tar`. Requires `TRAVIS_CI_KEY` and `TRAVIS_CI_IV` environment variables.

```
./tests/decrypt-secrets.sh
```

