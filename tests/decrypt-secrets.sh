#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "$SENSU_SECRETS_PASSWORD" ]; then
  echo "Must have SENSU_SECRETS_PASSWORD environment variable set"
  exit 1
fi

echo $SENSU_SECRETS_PASSWORD | gpg --batch --yes --passphrase-fd 0 --quiet --output ${DIR}/secrets.tar ${DIR}/secrets.tar.gpg

if [ -f ${DIR}/secrets.tar ]; then
  cd ${DIR}
  tar xvf secrets.tar
fi
