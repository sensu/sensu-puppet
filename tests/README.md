# Running acceptance tests locally

## Run all base acceptance tests (matches CI)

Uses two containers (`sensu-backend` + `sensu-agent`). Tests run in alphabetical order so `00_backend_spec.rb` sets up the backend before `01_agent_spec.rb` needs it.

```bash
BEAKER_set=rocky-9-modern \
BEAKER_sensu_mode=base \
bundle exec rake acceptance
```

## Run a single spec

Use the same two-host nodeset so both `sensu-backend` and `sensu-agent` roles are available.
When running `01_agent_spec.rb` alone, always include `00_backend_spec.rb` first so the backend service is already up:

```bash
BEAKER_set=rocky-9-modern \
bundle exec rspec spec/acceptance/00_backend_spec.rb spec/acceptance/01_agent_spec.rb
```

For backend-only specs (no agent needed):

```bash
BEAKER_set=rocky-9-modern \
bundle exec rspec spec/acceptance/00_backend_spec.rb
```

## Faster local re-runs

After the first run, containers are committed to named Docker images (`docker_preserve_image: true` in nodesets). Subsequent runs can skip reprovisioning:

```bash
# Keep containers alive between runs (skips docker_image_commands re-execution)
BEAKER_DESTROY=no BEAKER_set=rocky-9-modern BEAKER_sensu_mode=base bundle exec rake acceptance

# Reuse existing containers without re-provisioning (fastest iteration)
BEAKER_PROVISION=no BEAKER_DESTROY=no BEAKER_set=rocky-9-modern BEAKER_sensu_mode=base bundle exec rake acceptance
```

Container names are fixed (e.g. `sensu-backend-el9`, `sensu-agent-ubuntu2404`) via `docker_container_name` in each nodeset — beaker reconnects to them by name on the next run.

**Apple Silicon (M1/M2/M3):** Puppet's aarch64 EL yum repo (CloudFront) returns 403
for `libdnf` user-agent requests. `spec_helper_acceptance.rb` works around this automatically
by overriding `user_agent` in `/etc/dnf/dnf.conf` on arm64 hosts before puppet-agent is installed.

Puppet does **not** publish `puppetserver` or `puppet-bolt` RPMs for EL9 aarch64.
The following modes cannot run locally on Apple Silicon and are covered by CI (x86_64 GitHub Actions runners):
- `BEAKER_sensu_mode=types BEAKER_sensu_use_agent=yes`
- `BEAKER_sensu_mode=bolt`

**Corporate SSL inspection (e.g. Netskope):** Disable the proxy before running tests,
or use `docker_image_first_commands` in the nodeset to inject your CA cert before any
package installs:

```yaml
docker_image_first_commands:
  - 'echo BASE64_CERT | base64 -d > /etc/pki/ca-trust/source/anchors/corporate-ca.crt && update-ca-trust extract'
```

---

# Generate SSL certs for tests

Boot `sensu-backend` vagrant box and log in as root

```
vagrant up sensu-backend
vagrant ssh sensu-backend
sudo su -
```

Generate certs (Puppet 8 uses `puppetserver ca`)

```
puppetserver ca generate --certname sensu-backend --subject-alt-names localhost,127.0.0.1,sensu-backend,sensu-backend1,sensu-backend2,sensu-backend3,sensu-backend.example.com,sensu-backend-peer1.example.com,sensu-backend-peer2.example.com
puppetserver ca generate --certname sensu-backend1 --subject-alt-names localhost,127.0.0.1,sensu-backend,sensu-backend1,sensu-backend2,sensu-backend3,sensu-backend.example.com,sensu-backend-peer1.example.com,sensu-backend-peer2.example.com
puppetserver ca generate --certname sensu-backend2 --subject-alt-names localhost,127.0.0.1,sensu-backend,sensu-backend1,sensu-backend2,sensu-backend3,sensu-backend.example.com,sensu-backend-peer1.example.com,sensu-backend-peer2.example.com
puppetserver ca generate --certname sensu-backend3 --subject-alt-names localhost,127.0.0.1,sensu-backend,sensu-backend1,sensu-backend2,sensu-backend3,sensu-backend.example.com,sensu-backend-peer1.example.com,sensu-backend-peer2.example.com
puppetserver ca generate --certname sensu-agent
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

Encrypt `tests/secrets.tar` — only run this when adding or modifying secrets. Update the `SENSU_SECRETS_PASSWORD` secret with the printed password.

```
./tests/encrypt-secrets.sh
```

Decrypt `tests/secrets.tar`. Requires `SENSU_SECRETS_PASSWORD` environment variable.

```
./tests/decrypt-secrets.sh
```

