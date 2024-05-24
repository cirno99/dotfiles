#!/bin/bash

set -e

if [ $# -ne 1 ] && [ ! -e build.zig.zon ]; then
  echo "Couldn't find build.zig.zon file, please give path to it, or change current dir to a decent zig project"
  echo "  usage: zfetch.sh [build.zig.zon]"
  exit -1
fi

do_fetch() {
  for d in `grep -o 'https://.*tar\.gz' $1`; do
    wget $d
    tarfile=${d##*/}
    hash=`zig fetch --debug-hash $tarfile | tail -n 1`
    rm $tarfile
    if [ -e ~/.cache/zig/p/$hash/build.zig.zon ]; then
      do_fetch ~/.cache/zig/p/$hash/build.zig.zon
    fi
  done
}

zonfile=$1
if [ -z "$1" ]; then
  zonfile=build.zig.zon
fi

do_fetch $zonfile

