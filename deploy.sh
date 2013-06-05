#!/bin/bash

die () {
    echo "$0: $@"
    exit 1
}

dotfilesdir="$(dirname $0)"
[ "." = $dotfilesdir ] || die "Must be run from directory: $dotfilesdir"

shopt -s extglob
for f in !($(basename $0)); do
    [ ~/.$f -ef $f ] && continue
    ln -sn $PWD/$f ~/.$f
done
