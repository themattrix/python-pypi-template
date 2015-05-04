#!/bin/bash

set -e -o pipefail

mkdir /project
cd /project

find /app/ -maxdepth 1 -mindepth 1 '(' -type d -name "test" -prune ')' -o -exec mv -t . {} +

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

./populate.py
git commit -m "Post-populated template."

# List files for manual inspection if necessary.
find . \( -type d -name ".git" -prune \) -o -ls

travis lint

docker-compose build
docker-compose up

# No files should have escaped the container during a run.
[ -n "$(git clean -xnd)" ]
