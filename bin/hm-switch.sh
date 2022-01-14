#!/bin/bash

# From https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"


find_host_sha () {
    host=`echo $1 | sha256sum | awk '{print $1}'`
    for h in hosts/*; do
        sha=`cat $h/.host.sha256 2>/dev/null`
        if [ "$host" == "$sha" ]; then
            echo $h | sed 's/^hosts\///'
        fi
    done
}

check_home_nix () {
    host=$1
    if [ -f hosts/$host/home.nix ]; then
        echo 1
    fi
}


CACHIX_COMMAND=`command -v cachix`
if [ "$CACHIX_COMMAND" == "" ]; then
  nix-env -iA cachix -f https://cachix.org/api/v1/install
fi

# cachix use all-hies
cachix use nix-community

if [ "$HOST" == "" ]; then
  HOST=`hostname`
fi

HOST=`echo $HOST | sed 's/\.\(local\|lan\)//'`

if [ "$HM_HOST" == "" ]; then
  HM_HOST=$HOST
fi


if [ "$(check_home_nix $HM_HOST)" != 1 ]; then
    h=$(find_host_sha $HM_HOST)
    if [ "$(check_home_nix $h)" == 1 ]; then
        HM_HOST=$h
    fi
fi

HOME_NIX=$DIR/../hosts/${HM_HOST}/home.nix

if [ ! -f $HOME_NIX ]; then
  echo "${HM_HOST} is not configured: couldn't find ${HOME_NIX}"
  exit 1
fi

function pinned_path {
   jq -r ".[\"${1}\"].url" < $DIR/../nix/sources.json
}

PINNED_NIXPKGS=$(pinned_path "nixpkgs")
PINNED_HOME_MANAGER=$(pinned_path "home-manager")

home-manager switch \
  -f $HOME_NIX \
  -I nixpkgs=$PINNED_NIXPKGS \
  -I home-manager=$PINNED_HOME_MANAGER \
  $*

