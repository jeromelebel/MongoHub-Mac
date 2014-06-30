#!/usr/bin/env bash

set -x

submodule_owner="$1"
submodule_name="$2"
submodule_branch="$3"
submodule_path="$4"

pwd
origin_url=`git config --get remote.origin.url`
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
fi

echo $url
echo $github_url

if [ "${protocol}" = "ssh" ] ; then
    git submodule update --init
elif [ "${protocol}" = "http" ] ; then
    if [ -d "${submodule_path}/.git" ] ; then
        cd "${submodule_path}"
        git pull
    else
        rmdir "${submodule_path}"
        git clone "${github_url}/${submodule_owner}/${submodule_name}" "${submodule_path}"
        if [ "${submodule_branch}" != "master" ] ; then
            cd "${submodule_path}"
            git branch "${submodule_branch}" "origin/${submodule_branch}"
            git checkout "${submodule_branch}"
        fi
    fi
else
    cd "${submodule_path}"
    pwd
    if [ ! -f "${submodule_name}.zip" ] ; then
        curl -o "${submodule_name}.zip" -L "https://github.com/${submodule_owner}/${submodule_name}/archive/${submodule_branch}.zip"
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
