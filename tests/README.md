# Generate SSL certs for tests

Boot `sensu-backend` vagrant box and log in as root

```
vagrant up sensu-backend
vagrant ssh sensu-backend
sudo su -
```

Generate certs

```
puppet cert generate sensu_backend --dns_alt_names=localhost,127.0.0.1,sensu_backend,sensu_backend1,sensu_backend2,sensu_backend3,sensu-backend.example.com,sensu-backend-peer1.example.com,sensu-backend-peer2.example.com
puppet cert generate sensu_agent
```

Copy certs from vagrant instance to this repo

```
\cp -r /etc/puppetlabs/puppet/ssl/* /vagrant/tests/ssl/
```

# Secrets

Currently `tests/secrets.tar` holds secrets:

* sensu_licenson.json - test enterprise license
* secrets - environment variables that are secrets used by various scripts

Encrypt `tests/secrets.tar`, this should only be run if new secrets are needing to be added or modified. If available ensure `TRAVIS_CI_KEY` and `TRAVIS_CI_IV` environment variables are set or new ones will be used.

```
./tests/encrypt-secrets.sh
```

Decrypt `tests/secrets.tar`. Requires `TRAVIS_CI_KEY` and `TRAVIS_CI_IV` environment variables.

```
./tests/decrypt-secrets.sh
```

