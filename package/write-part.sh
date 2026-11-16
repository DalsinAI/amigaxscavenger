#!/bin/sh
# A GFOpenUp part from a game's drawer: the files go to SYS:Games/<NAME>,
# and the Part file GFOpenUpTool INSTALL reads (gfopenup src/openuptool.c)
# has one "copy" line for each. The player's own drawer (User/) is not in
# the part: the game makes it on its first start, and an update leaves it.
#   write-part.sh <drawer> <part drawer> <NAME> <version> <one line about it>
# GPL-2.0-or-later, like Scavenger. Copyright (c) 2026 AmiCradle Team.
set -eu
D=$1; P=$2; N=$3; V=$4; ABOUT=$5
rm -rf "$P"; mkdir -p "$P/Games/$N"
(cd "$D" && find . -path ./User -prune -o -type f ! -name User.info -print | LC_ALL=C sort) | while read -r f; do
    f=${f#./}
    mkdir -p "$P/Games/$N/$(dirname "$f")"
    cp "$D/$f" "$P/Games/$N/$f"
done
cp "$(dirname "$D")/$N.info" "$P/Games/$N.info"
{
    echo "part $N $V"
    echo "; $ABOUT"
    echo "needs 68040"
    echo "needs part GFOpenGPU"
    (cd "$P" && find Games -type f | LC_ALL=C sort) | while read -r f; do
        echo "copy \"$f\" \"SYS:$f\""
    done
} > "$P/Part"
