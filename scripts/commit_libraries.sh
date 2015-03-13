#!/bin/sh

set -eux

COMMENT="$1"
if [ "$COMMENT" = "" ] ; then
  echo "Usage: $(basename $0) COMMENT"
  exit 1
fi

cd Libraries/MongoObjCDriver
./scripts/commit_libraries.sh "${VERSION}"
cd ../..

git submodule status | sed 's/^.//' | awk '{ print $1 }' > Libraries/MongoObjCDriver.sha1
git commit -m "${VERSION}" .
