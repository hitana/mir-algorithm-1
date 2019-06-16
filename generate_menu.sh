#!/bin/bash

root="$1"
compiler="$2"
if [ -z "$1" ]; then
    root=.
fi
if [ -z "$2" ]; then
    compiler="dmd"
fi


mkdir -p $root'/.generated'

latest_tag=`git describe --abbrev=0 --tags | tr -d v`
latest_stable_tag=`git tag | grep -vE "(alpha|beta)" | tail -n1 | tr -d v`

ddoc_latest=$root'/.generated/'$latest_tag'.ddoc'
ddoc_mir=$root'/.generated/mir.ddoc'

echo 'LATEST='$latest_tag > $ddoc_latest
echo 'LATEST_STABLE='$latest_stable_tag >> $ddoc_latest

$compiler -run $root/doc/gen_modlist.d $root/source > $root/.generated/mir.ddoc
