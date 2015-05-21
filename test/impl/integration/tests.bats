#!/usr/bin/env bats

@test "ensure project created from template" {
    mkdir -p /project
    cp -r /app/{populate.{ini,py},template} /project/

    # Set all files and directories to a consistant, arbitrary date so that the
    # docker ADD command will invalidate the cache on checksum alone.
    find /project -exec touch -t 200001010000.00 {} +

    cd /project

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
    cd /project

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
    cd /project
    travis lint
}

@test "ensure tox environments build correctly" {
    cd /project
    docker-compose build
}

@test "ensure tox environments run tests successfully" {
    cd /project
    run docker-compose up

    # Expect one set of nosetest to be run per Python version.
    [ "$(grep -F "Ran 0 tests" <<< "${output}" | wc -l)" -eq 7 ]

    # No warnings or errors should appear in the output.
    ! grep -Ei "(Warning|Error):" <<< "${output}"
}

@test "ensure no files escaped tox container" {
    cd /project
    [ -z "$(git clean -xnd)" ]
}
