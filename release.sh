#!/bin/bash

current_version=$(grep '"version": ".*"' package.json | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
printf "Current version is: $current_version\n"
printf "Next version (e.g. 0.3.2, ATTENTION: don't prepend 'v' to version number): "
read next_version
if ! [[ "$next_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Wrong version format: $next_version . Expected format: 0.3.2"
    exit 1
fi
next_version_v="v$next_version"

# goto master branch
git checkout master
git pull

# update version
if [ "$(uname)" == "Darwin" ]; then
    sed -i '' -e "s/\"version\": \".*\"/\"version\": \"$next_version\"/" package.json
    sed -i '' -e "s/current version: .*/current version: $next_version_v/" README.md
else
    sed -i'' -e "s/\"version\": \".*\"/\"version\": \"$next_version\"/" package.json
    sed -i'' -e "s/current version: .*/current version: $next_version_v/" README.md
fi

# build source files
rm -rf dist/*
npm run build

# publish master branch
cp package.json dist/
cp package-lock.json dist/
cp README.md dist/
cp index.js dist/

cd dist

# 发布release
git init
git add .
git commit -m "Release version $next_version_v"
git push -u git@github.com:GapGao/react-router-config-upgrade.git HEAD:release --force

# 打版本号
git tag $next_version_v
git push
git push git@github.com:GapGao/react-router-config-upgrade.git --tags

cd -
rm -rf dist

git add .
git commit -m "Release version $next_version_v"
git push
