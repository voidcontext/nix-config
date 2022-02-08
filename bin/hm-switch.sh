#!/bin/bash

host=$1

if [ -z "$host" ]; then
    echo "Please provide a host";
    exit 1;
fi


# From https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"



CACHIX_COMMAND=`command -v cachix`
if [ "$CACHIX_COMMAND" == "" ]; then
  nix-env -iA cachix -f https://cachix.org/api/v1/install
fi

# cachix use all-hies
cachix use nix-community

cd $DIR/..

nix build .#hmConfig.${host}.activationPackage && result/activate

