#!/usr/bin/env bash

submodule_scheme="$1"
submodule_owner="$2"
submodule_name="$3"
submodule_branch="$4"
submodule_path="$5"

rm -fr "${submodule_path}"
if [ "$submodule_scheme" = "ssh" ] ; then
    git clone "git@github.com:${submodule_owner}/${submodule_name}.git" "${submodule_path}"
elif [ "$submodule_scheme" = "https" ]; then
    git clone "https://github.com/${submodule_owner}/${submodule_name}.git" "${submodule_path}"
    if [ "${submodule_branch}" != "master" ] ; then
        cd "${submodule_path}"
        git branch "${submodule_branch}" "origin/${submodule_branch}"
        git checkout "${submodule_branch}"
    fi
else
    mkdir "${submodule_path}"
    cd "${submodule_path}"
    curl -o "${submodule_name}.zip" -L "https://github.com/${submodule_owner}/${submodule_name}/archive/${submodule_branch}.zip"
    unzip "${submodule_name}.zip"
    rm "${submodule_name}.zip"
    submodule_unzip_dir=`ls`
    cd "${submodule_unzip_dir}"
    mv * ..
    cd ..
    rm -fr "${submodule_unzip_dir}"
fi
