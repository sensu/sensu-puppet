#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR

if [ -z "$SENSU_SECRETS_PASSWORD" ]; then
  SENSU_SECRETS_PASSWORD="pwgen 30 1"
fi

echo $SENSU_SECRETS_PASSWORD | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 secrets.tar

echo $SENSU_SECRETS_PASSWORD

