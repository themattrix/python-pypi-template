#!/usr/bin/env bash

set -o errexit -o pipefail
shopt -s dotglob

# Copy our template files from /src/ to the pwd.
cp -r /src/{populate.{ini,py},template} ./
chmod +x ./populate.py

# Run tests!
exec bats /src/test/integration/*.bats
