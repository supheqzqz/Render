#!/bin/bash


_get_ziplink () {
    local regex
    regex='(https?)://github.com/.+/.+'
    if [[ $UPSTREAM_REPO == "Repthon" ]]
    then
        echo "aHR0cHM6Ly9naXRodWIuY29tL2JhbmVuLWlzLW15LWxvdmUvUmVwdGhvbi9hcmNoaXZlL21hc3Rlci56aXA=" | base64 -d
    elif [[ $UPSTREAM_REPO =~ $regex ]]
    then
        if [[ $UPSTREAM_REPO_BRANCH ]]
        then
            echo "${UPSTREAM_REPO}/archive/${UPSTREAM_REPO_BRANCH}.zip"
        else
            echo "${UPSTREAM_REPO}/archive/master.zip"
        fi
    else
        echo "aHR0cHM6Ly9naXRodWIuY29tL2JhbmVuLWlzLW15LWxvdmUvUmVwdGhvbi9hcmNoaXZlL21hc3Rlci56aXA=" | base64 -d
    fi
}

_get_repolink () {
    local regex
    local rlink
    regex='(https?)://github.com/.+/.+'
    if [[ $UPSTREAM_REPO == "Repthon" ]]
    then
        rlink=`echo "aHR0cHM6Ly9naXRodWIuY29tL0JhcWlydWIvUmVuZGVyLmdpdA==" | base64 -d`
    elif [[ $UPSTREAM_REPO =~ $regex ]]
    then
        rlink=`echo "${UPSTREAM_REPO}"`
    else
        rlink=`echo "aHR0cHM6Ly9naXRodWIuY29tL0JhcWlydWIvUmVuZGVyLmdpdA==" | base64 -d`
    fi
    echo "$rlink"
}


_run_python_code() {
    python3${pVer%.*} -c "$1"
}

_run_catpack_git() {
    $(_run_python_code 'from git import Repo
import sys
OFFICIAL_UPSTREAM_REPO = "https://github.com/Baqirub/Render"
ACTIVE_BRANCH_NAME = "main"
repo = Repo.init()
origin = repo.create_remote("temponame", OFFICIAL_UPSTREAM_REPO)
origin.fetch()
repo.create_head(ACTIVE_BRANCH_NAME, origin.refs[ACTIVE_BRANCH_NAME])
repo.heads[ACTIVE_BRANCH_NAME].checkout(True) ')
}

_run_cat_git() {
    local repolink=$(_get_repolink)
    $(_run_python_code 'from git import Repo
import sys
OFFICIAL_UPSTREAM_REPO="'$repolink'"
ACTIVE_BRANCH_NAME = "'$UPSTREAM_REPO_BRANCH'" or "main"
repo = Repo.init()
origin = repo.create_remote("temponame", OFFICIAL_UPSTREAM_REPO)
origin.fetch()
repo.create_head(ACTIVE_BRANCH_NAME, origin.refs[ACTIVE_BRANCH_NAME])
repo.heads[ACTIVE_BRANCH_NAME].checkout(True) ')
}

_set_bot () {
    local zippath
    zippath="main.zip"
    echo "⌭ جاري تنزيل اكواد السورس ⌭"
    wget -q $(_get_ziplink) -O "$zippath"
    echo "⌭ تفريغ البيانات ⌭"
    CATPATH=$(zipinfo -1 "$zippath" | grep -v "/.");
    unzip -qq "$zippath"
    echo "⌭ تـم التفريـغ ⌭"
    echo "⌭ يتم التنظيف ⌭"
    rm -rf "$zippath"
    sleep 5
    _run_catpack_git
    cd $CATPATH
    _run_cat_git
    python3 ../setup/updater.py ../requirements.txt requirements.txt
    chmod -R 755 bin
    echo "⌭ جـاري بـدء تنصيـب ريبـــثون ⌭"
    echo "
    "
    python3 -m repthon
}

_set_bot
