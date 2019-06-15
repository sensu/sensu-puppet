#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR

if [ -n "$TRAVIS_CI_KEY" -a -n "$TRAVIS_CI_IV" ]; then
  ARGS="--key=${TRAVIS_CI_KEY} --iv=${TRAVIS_CI_IV}"
else
  ARGS=""
fi

tar cvf secrets.tar secrets sensu_license.json
travis encrypt-file secrets.tar --print-key $ARGS

