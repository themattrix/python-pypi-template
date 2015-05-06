#!/bin/bash
# When docker-compose supports the -f option, we can delete this whole file!

set -e -o pipefail

cd "${BASH_SOURCE[0]%/*}/.."

function image_id {
    docker inspect -f '{{ .Id }}' "${IMAGE_NAME}"
}

function clean {
    if [[ -n "${OLD_IMAGE}" ]] && [[ "${OLD_IMAGE}" != $(image_id) ]]; then
        docker rmi "${OLD_IMAGE}"
    fi
}

function run {
    local output
    local status
    local title=${1}
    shift

    set +e
    echo -n "# ${title}..."
    output=$("$@" 2>&1)
    status=$?
    set -e

    if [ ${status} -eq 0 ]; then
        echo "ok"
    else
        echo "fail"
        echo "${output}"
        exit "${status}"
    fi
}

readonly IMAGE_NAME="pypi-template-int-tests"
readonly OLD_IMAGE=$(image_id || true)

run "Building" docker build -t "${IMAGE_NAME}" -f "test/impl/integration/Dockerfile" .
run "Cleaning" clean

docker run --privileged --rm -v "${PWD}/.docker:/var/lib/docker" "${IMAGE_NAME}"
