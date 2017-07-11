#!/bin/bash

if [ -z "${FACTER_SE_USER:-}" ]; then
  echo "ERROR: You must export FACTER_SE_USER and FACTER_SE_PASS" >&2
  echo "ERROR: In the shell that executes vagrant up" >&2
  exit 1
fi
echo "FACTER_SE_USER=$FACTER_SE_USER"

# Save the enterprise username and password, make them work with sudo so that
# the following works:
# vagrant ssh sensu-server-enterprise
# sudo puppet apply /vagrant/test/sensu-server-enterprise.pp

cat > ~/.bash_profile <<'EOF'
[ -f ~/.bashrc ] && source ~/.bashrc
export PATH=$PATH:$HOME/.local/bin:$HOME/bin
# Pass these two key facts through sudo invocations to puppet
alias sudo='sudo FACTER_SE_USER=$FACTER_SE_USER FACTER_SE_PASS=$FACTER_SE_PASS'
EOF
cat >> ~/.bash_profile <<EOF
export FACTER_SE_USER='${FACTER_SE_USER}'
export FACTER_SE_PASS='${FACTER_SE_PASS}'
EOF

# setup module dependencies
puppet module install puppetlabs/rabbitmq

# install dependencies for sensu
yum -y install redis jq nagios-plugins-ntp
systemctl start redis
systemctl enable redis

# run puppet
puppet apply /vagrant/tests/rabbitmq.pp
puppet apply /vagrant/tests/sensu-server-enterprise.pp
puppet apply /vagrant/tests/uchiwa.pp
