#!/bin/sh
# Host tests for the XScavenger port. XSCAV=<the upstream release
# unpacked, unpatched (sdlscav-145)>; the patch is applied to a copy.
# GPL-2.0-or-later, like Scavenger. Copyright (c) 2026 AmiCradle Team.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/../.." && pwd)
: "${XSCAV:?set XSCAV to the unpacked upstream release}"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cp -R "$XSCAV" "$T/scav"
(cd "$T/scav" && for p in "$ROOT"/amiga/patches/*.patch; do patch -s -p1 < "$p"; done)
echo "patches: apply"
# no player path may be built as "%s/%s/%s" from localname on AmigaOS:
# "PROGDIR:" "/" "User" would be PROGDIR's parent
if grep -n -E 'sprintf\([a-z0-9]+, *"%s/%s(/%s)?", *localname' "$T/scav"/*.c; then
    echo "FAIL: a player path still joins PROGDIR: with '/'"; exit 1
fi
n=$(grep -c -E 'LOCALSEP "%s(/%s)?", *localname' "$T/scav"/*.c | awk -F: '{s+=$2} END {print s}')
test "$n" -eq 9   # all 9 of upstream's
echo "paths: all $n player paths join PROGDIR: and User with LOCALSEP"
if command -v sdl-config >/dev/null 2>&1; then
    # the game with the Amiga's paths (PROGDIR:Data, PROGDIR:User are plain
    # directory names on the host), played by play_driver.c on SDL's dummy
    # drivers
    cd "$T"
    for c in scav gfx sound edit anim; do
        cc -std=gnu89 -O1 -w -fcommon -D__amigaos__ -Dmain=scav_main $(sdl-config --cflags) -c "scav/$c.c" -o "$c.o"
    done
    cc -std=gnu89 -O1 $(sdl-config --cflags) -c "$HERE/play_driver.c" -o drv.o
    cc scav.o gfx.o sound.o edit.o anim.o drv.o -o play $(sdl-config --libs)
    mkdir "PROGDIR:Data"
    cp scav/data/*.lbm scav/data/*.wav scav/data/*.scl scav/data/scav.bmp "PROGDIR:Data/"
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./play > play.log 2>&1 || { cat play.log; exit 1; }
    test -s "PROGDIR:User/levels.scl" && test -s "PROGDIR:User/scavrc"
    cmp -s "PROGDIR:User/levels.scl" "PROGDIR:Data/levels.scl"
    grep -qx 'playing level 1' "PROGDIR:User/play-result" || { cat "PROGDIR:User/play-result"; exit 1; }
    echo "play: demo, F4 into level 1, ran right and left, Alt-X out; PROGDIR:User has levels.scl and scavrc"
else
    echo "play: SKIP (no SDL 1.2 or sdl12-compat development files on this host)"
fi
echo PASS
