#!/bin/bash

exitcode=1

function get_available_checks {
  curl -s http://admin:secret@127.0.0.1:4567/checks | jq .[].name | awk -F \" '{print $2}' | awk -F \. '{print $1}'
}

function check_available() {
  checks=$(get_available_checks)

  if [ -z "${checks##*$1*}" ] ;then
    echo 'true'
  else
    echo 'false'
  fi
}

echo -e "\nList of checks available beforehand:"
get_available_checks


if [ $(check_available check_to_remove) == 'false' ]; then
  echo -e "\nThe check 'check_to_remove' isn't available and should get added now\n"
  FACTER_test='add' puppet apply /vagrant/tests/add_remove-check.pp

  if [ $(check_available check_to_remove) == 'true' ]; then
    echo -e "\nThe check 'check_to_remove' have been addedd successfully"
    exitcode=0
  else
    echo -e "\nSomething went wrong, the check 'check_to_remove' have NOT been addedd successfully"
  fi

else
  echo -e "\nThe check 'check_to_remove' is available and should get removed now\n"
  FACTER_test='remove' puppet apply /vagrant/tests/add_remove-check.pp
  if [ $(check_available check_to_remove) == 'false' ]; then
    echo -e "\nThe check 'check_to_remove' have been removed successfully"
    exitcode=0
  else
    echo -e "\nSomething went wrong, the check 'check_to_remove' have NOT been removed successfully"
  fi
fi

echo -e "\nList of checks available afterwards:"
get_available_checks
exit $exitcode
