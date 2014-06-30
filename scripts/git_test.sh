#!/usr/bin/env bash

./git_fetch.sh ssh fotonauts MongoHub-Mac master mongohub

cd mongohub
../update_submodule.sh fotonauts mongo-objc-driver ragel Libraries/mongo-objc-driver
