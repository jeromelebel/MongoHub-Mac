#!/bin/sh

set -eux

VERSION="$1"
if [ "$VERSION" = "" ] ; then
  echo "Usage: $(basename $0) VERSION"
  exit 1
fi

cd Libraries/MongoObjCDriver
./scripts/create_version.sh "MongoHub-$VERSION"
cd ../..

git submodule status | sed 's/^.//' | awk '{ print $1 }' > Libraries/MongoObjCDriver.sha1
git commit -m "software update $VERSION" . || true
git push
git tag -a "$VERSION" -m "software update $VERSION"
git push --tags
