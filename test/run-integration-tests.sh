#!/bin/bash

set -e -o pipefail

cd "${BASH_SOURCE[0]%/*}/.."

function image_id {
    docker inspect -f '{{ .Id }}' "${IMAGE_NAME}"
}

readonly IMAGE_NAME="pypi-template-int-tests"
readonly OLD_IMAGE=$(image_id || true)

# When docker-compose supports the -f option, we can delete this whole file!
docker build -t "${IMAGE_NAME}" -f "test/impl/integration/Dockerfile" .

if [[ -n "${OLD_IMAGE}" ]] && [[ "${OLD_IMAGE}" != $(image_id) ]]; then
    docker rmi "${OLD_IMAGE}"
fi

docker run --privileged --rm -v "${PWD}/.docker:/var/lib/docker" "${IMAGE_NAME}"
