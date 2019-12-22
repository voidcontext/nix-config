#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

if [ `command -v cachix` == "" ]; then
  nix-env -iA cachix -f https://cachix.org/api/v1/install
fi

cachix use all-hies

if [ "$HOST" == "" ]; then
  HOST=`hostname`
fi

HOME_NIX=$DIR/../hosts/${HOST}/home.nix

if [ ! -f $HOME_NIX ]; then
  echo "${HOST} is not configured: couldn't find ${HOME_NIX}"
  exit 1
fi

home-manager switch -f $HOME_NIX $*

