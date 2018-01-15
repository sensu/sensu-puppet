#!/bin/bash

# This script will verify that plugins installed with the "sensu_gem" package
# provider are installed AFTER any sensu package changes.
#
# USAGE:
#   1. Use Vagrant to spin up an open source or enterprise Sensu server
#   2. SSH into the box and change to the root user account
#   3. Execute this script
#   4. Ensure that the plugins install after any package changes and that
#      Puppet need only be executed once
#

################################
## Build out Puppet manifests ##
################################

TMPDIR="$(mktemp -d)"
finish() {
  [ -e "${TMPDIR:-}" ] && rm -rf "$TMPDIR"
}
trap finish EXIT

LATEST="$TMPDIR/latest.pp"
OLDER="$TMPDIR/older.pp"

cat > "$LATEST" <<'EOF'

$deregistration = { 'handler' => 'deregister_client' }

package { 'redphone':
  ensure   => 'installed',
  provider => sensu_gem,
}

package { 'sensu-plugins-nginx':
  ensure   => 'installed',
  provider => sensu_gem,
}

package { 'sensu-plugins-disk-checks':
  ensure   => 'installed',
  provider => sensu_gem,
}

class { '::sensu':
  install_repo          => true,
  version               => 'latest',
  server                => true,
  manage_services       => true,
  manage_user           => true,
  rabbitmq_password     => 'correct-horse-battery-staple',
  rabbitmq_vhost        => '/sensu',
  spawn_limit           => 16,
  api                   => true,
  api_user              => 'admin',
  api_password          => 'secret',
  client_address        => $::ipaddress_eth1,
  subscriptions         => ['all', 'roundrobin:poller'],
  client_deregister     => true,
  client_deregistration => $deregistration,
}

EOF

cat > "$OLDER" <<'EOF'

$deregistration = { 'handler' => 'deregister_client' }

package { 'redphone':
  ensure   => 'installed',
  provider => sensu_gem,
}

package { 'sensu-plugins-nginx':
  ensure   => 'installed',
  provider => sensu_gem,
}

package { 'sensu-plugins-disk-checks':
  ensure   => 'installed',
  provider => sensu_gem,
}

class { '::sensu':
  install_repo          => true,
  version               => '0.23.0',
  server                => true,
  manage_services       => true,
  manage_user           => true,
  rabbitmq_password     => 'correct-horse-battery-staple',
  rabbitmq_vhost        => '/sensu',
  spawn_limit           => 16,
  api                   => true,
  api_user              => 'admin',
  api_password          => 'secret',
  client_address        => $::ipaddress_eth1,
  subscriptions         => ['all', 'roundrobin:poller'],
  client_deregister     => true,
  client_deregistration => $deregistration,
}

EOF


###############################
## Apply everything in order ##
###############################
echo -e "\e[33mInstalling plugins into current installation..."
puppet apply "$LATEST" --detailed-exitcodes
EXIT_FIRST=$?
echo
echo
echo -e "\e[33mRunning again for idempotency"
puppet apply "$LATEST" --detailed-exitcodes
EXIT_SECOND=$?
echo
echo
echo -e "\e[33mDowngrading Sensu - if everything works correctly the plugins should be installed after the package downgrade..."
puppet apply "$OLDER" --detailed-exitcodes
EXIT_THIRD=$?
echo -e "\e[33mNOTE: There will be errors when the services try to start, that's expected because of the upgrade."
echo -e "\e[33mIf everything worked correctly, you should see Package[redphone], Package['sensu-plugins-nginx'] and Package['sensu-plugins-disk-checks'] occur AFTER Package['sensu']..."
echo
echo -e "\e[33mEXIT CODES:"
echo -e "\e[33mFirst run: \e[0m$EXIT_FIRST"
echo -e "\e[33mIdempotency check: \e[0m$EXIT_SECOND"
echo -e "\e[33mFinal Run: \e[0m$EXIT_THIRD"
exit 0

