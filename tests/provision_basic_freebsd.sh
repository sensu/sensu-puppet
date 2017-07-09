#!/bin/sh

release=$(uname -r | awk -F \. '{print $1}')

export ASSUME_ALWAYS_YES=YES
pkg update
pkg install ca_root_nss
pkg install wget

# install and configure puppet
pkg install puppet4

# suppress default warings for deprecation
cat > /usr/local/etc/puppet/hiera.yaml <<EOF
---
version: 5
hierarchy:
  - name: Common
    path: common.yaml
defaults:
  data_hash: yaml_data
  datadir: hieradata
EOF

# use local sensu module
puppet resource file /usr/local/etc/puppet/modules/sensu ensure=link target=/vagrant

# setup module dependencies
puppet module install puppetlabs/stdlib --version 4.16.0
puppet module install puppetlabs/apt --version 4.1.0
puppet module install lwf-remote_file --version 1.1.3
puppet module install puppetlabs/powershell --version 2.1.0

# install dependencies for sensu
pkg install rubygem-json
