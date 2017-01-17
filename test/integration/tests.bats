#!/usr/bin/env bats

@test "ensure project created from template" {
    # Set all files and directories to a consistant, arbitrary date so that the
    # docker ADD command will invalidate the cache on checksum alone.
    find . -exec touch -t 200001010000.00 {} +

    git init
    git config user.name "Test User"
    git config user.email "test.email@localhost"

    cat >> .git/config <<"ORIGIN-AND-MASTER"
[remote "origin"]
    url = git@github.com:test-github-user/test-github-project.git
    fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
    remote = origin
    merge = refs/heads/master
ORIGIN-AND-MASTER

    sed -e 's/^package_name=/&test-package/' \
        -e 's/^package_version=/&1.0.0/' \
        -e 's/^short_description=/&This is my test project!/' \
        -i populate.ini

    git add .
    git commit -m "Pre-populated template."
}

@test "ensure populate.py runs successfully" {
    function debug {
        echo -e "\n[${1}]"
        find \( -type d -name ".git" -prune \) -o -ls
    }

    debug "Before"
    run ./populate.py
    echo "${output}"
    debug "After"

    [ "${status}" -eq 0 ]

    [ "${output}" == "$(
        echo "Using the following template values:"
        echo "    package_name: 'test-package'"
        echo "    install_requires: ()"
        echo "    package_version: '1.0.0'"
        echo "    author_name: 'Test User'"
        echo "    tests_require: ()"
        echo "    package_dir_name: 'test_package'"
        echo "    author_email: 'test.email@localhost'"
        echo "    github_user: 'test-github-user'"
        echo "    copyright_years: '$(date +%Y)'"
        echo "    short_description: 'This is my test project!'"
        echo "    repo_name: 'test-github-project'")" ]

    git commit -m "Post-populated template."
}

@test "ensure .travis.yml looks valid" {
    travis lint
}

@test "ensure tox base image up-to-date" {
    docker pull themattrix/tox:latest
}

@test "ensure tox environments build correctly" {
    docker-compose rm -f --all
    run docker-compose build
    echo "${output}"

    [[ "${status}" -eq 0 ]]

    # No errors should appear in the output.
    ! grep -Ei "Error:" <<< "${output}"
}

@test "ensure pwd is visible to docker daemon" {
    # The docker daemon we're talking to is the same one in which we're
    # running. This allows us to create "sibling" containers, but it also
    # creates a problem for volumes. When we tell the daemon to mount the
    # working directory, it will mount an empty directory because it doesn't
    # have visibility into *this* container.
    #
    # Solution: We can employ a little trickery to find where the working
    # directory is actually stored on disk (as seen by the daemon). This
    # relies on the fact that the working directory happens to be a mountpoint
    # and that we can inspect mountpoints "docker inspect".

    find_pwd_on_disk() {
        docker inspect \
            -f '{{ range .Mounts }}{{ if eq .Destination "'"${PWD}"'" }}{{ .Source }}{{ end }}{{ end }}' \
            test_integration_tests_1
    }

    sed -e "s#.:/src:ro#$(find_pwd_on_disk):/src:ro#" \
        -i "docker-compose.yml"

    # Expect the mount point to be updated.
    grep "/var/lib/docker" "docker-compose.yml"
}

@test "ensure tox environments run tests successfully" {
    run docker-compose up
    echo "${output}"

    # Expect one set of nosetests to be run per Python version.
    [[ "$(grep -F "Ran 0 tests" <<< "${output}" | wc -l)" -eq 8 ]]

    # Python 2.x and 3.x should run static analysis.
    [[ "$(grep ' python tests.py --static-analysis$' <<< "${output}" | wc -l)" -eq 2 ]]
    [[ "$(grep ' running check$' <<< "${output}" | wc -l)" -eq 2 ]]

    # Other runs should not run static analysis
    [[ "$(grep ' python tests.py$' <<< "${output}" | wc -l)" -eq 6 ]]

    # No errors should appear in the output.
    ! grep -Ei "Error:" <<< "${output}"
}

@test "ensure no files escaped tox container" {
    [ -z "$(git clean -xnd)" ]
}
