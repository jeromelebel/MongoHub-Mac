#!/usr/bin/env bash

set -xeu

submodule_owner="$1"
submodule_name="$2"
submodule_branch="$3"
submodule_path="$4"

pwd
origin_url=`git config --get remote.origin.url` || true
if [ "${origin_url:0:8}" = "https://" ] ; then
    protocol="http"
    tmp=`dirname "${origin_url}"`
    github_url=`dirname "${tmp}"`
    github_url="${github_url}/"
elif [ "${origin_url:0:7}" = "http://" ] ; then
    protocol="http"
    tmp=`dirname "${origin_url}"`
    github_url=`dirname "${tmp}"`
    github_url="${github_url}/"
elif [ "${origin_url}" != "" ] ; then
    protocol="ssh"
    github_url=`echo "${origin_url}" | awk -F: '{ print $1 }'`
    github_url="${github_url}:"
else
    protocol="file"
    github_url=""
fi
sha1=`cat "${submodule_path}.sha1"`

echo $github_url
echo $sha1

if [ "${protocol}" = "ssh" ] ; then
    git submodule update --init
elif [ "${protocol}" = "http" ] ; then
    if [ -d "${submodule_path}/.git" ] ; then
        cd "${submodule_path}"
        git pull
    else
        rmdir "${submodule_path}"
        git clone "${github_url}/${submodule_owner}/${submodule_name}" "${submodule_path}"
        cd "${submodule_path}"
        git checkout "${sha1}"
    fi
else
    cd "${submodule_path}"
    pwd
    if [ ! -f "${submodule_name}.zip" ] ; then
        curl -o "${submodule_name}.zip" -L "https://codeload.github.com/jeromelebel/${submodule_name}/zip/${sha1}"

        unzip "${submodule_name}.zip"
        rm "${submodule_name}.zip"
        submodule_unzip_dir=`ls`
        cd "${submodule_unzip_dir}"
        mv * ..
        cd ..
        rm -fr "${submodule_unzip_dir}"
        touch "${submodule_name}.zip"
    fi
fi
