#!/bin/bash

set -e -o pipefail
shopt -s dotglob

# Copy our template files from /src/ to the pwd.
cp -r /src/{populate.{ini,py},template} ./
chmod +x ./populate.py

# Run tests!
bats /src/test/integration/*.bats
