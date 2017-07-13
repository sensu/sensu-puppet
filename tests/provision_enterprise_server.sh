#!/bin/bash

if [ -z "${FACTER_SE_USER:-}" ]; then
  echo "ERROR: You must export FACTER_SE_USER and FACTER_SE_PASS" >&2
  echo "ERROR: In the shell that executes vagrant up" >&2
  exit 1
fi
echo "FACTER_SE_USER=$FACTER_SE_USER"

scratch="$(mktemp -d)"
finish() {
  [ -e "${scratch:-}" ] && rm -rf "$scratch"
}
trap finish EXIT
TMPDIR="$scratch"
profile="$(mktemp)"

cat > "$profile" <<'EOF'
[ -f ~/.bashrc ] && source ~/.bashrc
export PATH=$PATH:$HOME/.local/bin:$HOME/bin
# Pass these two facts through vagrant sudo invocations to puppet
alias sudo='sudo FACTER_SE_USER=$FACTER_SE_USER FACTER_SE_PASS=$FACTER_SE_PASS'
EOF
cat >> "$profile" <<EOF
export FACTER_SE_USER='${FACTER_SE_USER}'
export FACTER_SE_PASS='${FACTER_SE_PASS}'
EOF

# install the updated profile in vagrant's home.
install -o vagrant -g vagrant -m 0644 "$profile" ~vagrant/.bash_profile

# setup module dependencies
puppet module install puppetlabs/rabbitmq

# inifile is used to tune the JVM heap size in Vagrant
puppet module install puppetlabs/inifile

# install dependencies for sensu
yum -y install redis jq nagios-plugins-ntp
systemctl start redis
systemctl enable redis

# run puppet
puppet apply /vagrant/tests/rabbitmq.pp
puppet apply /vagrant/tests/sensu-server-enterprise.pp
