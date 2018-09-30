cat > /tmp/sensu_gem1.pp <<EOF
package { 'sensu-plugins-disk-checks':
  ensure   => 'installed',
  provider => 'sensu_gem',
}
EOF
puppet apply /tmp/sensu_gem1.pp

/opt/sensu/embedded/bin/gem which sensu-plugins-disk-checks &>/dev/null
if [ $? -eq 0 ]; then
  echo "GEM sensu-plugins-disk-checks installed"
else
  echo "GEM sensu-plugins-disk-checks NOT installed"
fi

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source /usr/local/rvm/scripts/rvm

gem which sensu-plugins-disk-checks &>/dev/null
if [ $? -ne 0 ]; then
  echo "GEM sensu-plugins-disk-checks not in RVM"
else
  echo "GEM sensu-plugins-disk-checks found in RVM"
fi

cat > /tmp/sensu_gem2.pp <<EOF
package { 'sensu-plugins-memory-checks':
  ensure   => 'installed',
  provider => 'sensu_gem',
}
EOF
puppet apply /tmp/sensu_gem2.pp

/opt/sensu/embedded/bin/gem which sensu-plugins-memory-checks &>/dev/null
if [ $? -eq 0 ]; then
  echo "GEM sensu-plugins-memory-checks installed"
else
  echo "GEM sensu-plugins-memory-checks NOT installed"
fi

gem which sensu-plugins-memory-checks &>/dev/null
if [ $? -ne 0 ]; then
  echo "GEM sensu-plugins-memory-checks not in RVM"
else
  echo "GEM sensu-plugins-memory-checks found in RVM"
fi
