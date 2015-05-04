#!/bin/bash

set -e -o pipefail

cd "${BASH_SOURCE[0]%/*}/.."

docker build \
    -t "pypi-template-int-tests" \
    -f "test/impl/integration/Dockerfile" \
    .

docker run \
    --privileged --rm \
    -v "${PWD}:/app:ro" \
    -v "${PWD}/.docker:/var/lib/docker" \
    "pypi-template-int-tests"
