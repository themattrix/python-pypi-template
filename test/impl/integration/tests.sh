#!/bin/bash

set -e -o pipefail

# Delete any pesky swap files that made it in. These should be excluded by the
# .dockerignore file, but it doesn't seem to be working.
find /app/ -type f \( -name "*.swp" -o -name ".*.swp" \) -exec rm -f {} +

cp -rT /app/ /project
cd /project

# Set all files and directories to a consistant, arbitrary date so that the
# docker ADD command will invalidate the cache on checksum alone.
find -exec touch -t 200001010000.00 {} +

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
find \( -type d -name ".git" -prune \) -o -ls

travis lint

docker-compose --verbose build
docker-compose --verbose up

# No files should have escaped the container during a run.
[ -z "$(git clean -xnd)" ]
