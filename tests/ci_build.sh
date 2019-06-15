#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${DIR}/secrets

which apt 1>/dev/null 2>&1
if [ $? -eq 0 ]; then
  script='script.deb.sh'
else
  script='script.rpm.sh'
fi

curl -s https://${CI_BUILD_TOKEN}:@packagecloud.io/install/repositories/sensu/ci-builds/${script} | bash 1>/dev/null 2>&1

