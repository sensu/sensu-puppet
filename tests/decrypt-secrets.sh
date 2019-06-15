#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "$TRAVIS_CI_KEY" -o -z "$TRAVIS_CI_IV" ]; then
  echo "Must have TRAVIS_CI_KEY and TRAVIS_CI_IV environment variables set"
  exit 1
fi

travis encrypt-file ${DIR}/secrets.tar.enc --decrypt --key $TRAVIS_CI_KEY --iv $TRAVIS_CI_IV
