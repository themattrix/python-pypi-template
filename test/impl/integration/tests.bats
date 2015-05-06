#!/usr/bin/env bats

@test "ensure project created from template" {
    cp -rT /app/ /project

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

    echo -e "\n[Before]"
    find \( -type d -name ".git" -prune \) -o -ls

    run ./populate.py

    echo -e "\n[After]"
    find \( -type d -name ".git" -prune \) -o -ls

    [ "${status}" -eq 0 ]

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
    [ "$(grep "Ran 0 tests" <<< "${output}" | wc -l)" -eq 7 ]
}

@test "ensure no files escaped tox container" {
    cd /project
    [ -z "$(git clean -xnd)" ]
}
