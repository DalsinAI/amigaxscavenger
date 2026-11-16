#!/bin/sh
# The release archive and the GFOpenUp part, for Cradle's stove_build
# (target package):
#  1. the upstream release package/xscavenger.lock names, checked against
#     its SHA-256 (it is never kept in this repository), with amiga/patches
#     applied;
#  2. the game built by amiga/Makefile.amigaos;
#  3. the drawer, its icon and the Installer script beside it packed as
#     NAME-VERSION-68040.lha (tools/pack_dist.py), with its .sha256 and a
#     short .readme;
#  4. OUT/Parts/XScavenger, a GFOpenUp part: its Part file and the drawer's
#     files for SYS:Games/XScavenger, installed with
#       GFOpenUpTool INSTALL Parts/XScavenger
#     It needs the GFOpenGPU part, whose SDL2.module draws the game.
# Nothing is published from here.
# Copyright (c) 2026 AmiCradle Team. GPL-2.0-or-later, like Scavenger.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/.." && pwd)
. "$HERE/package.env"
. "$HERE/xscavenger.lock"
OUT=${OUT:-"$ROOT/build-amiga-package"}
mkdir -p "$OUT"
OUT=$(CDPATH= cd -- "$OUT" && pwd)
STOVE=${STOVE:-"$HOME/AmiCradle/stoves/os32-gcc16-open6"}
# outside the checkout: Cradle cleans it (git clean -ffdx) before every job
WORK=${WORK:-"$HOME/.cache/amigaxscavenger"}
cd "$ROOT"

# 1. the upstream release, checked, unpacked and patched afresh every time
TGZ="$WORK/sdlscav-$XSCAV_VERSION.tgz"
mkdir -p "$WORK"
if [ "$(sha256sum "$TGZ" 2>/dev/null | cut -d' ' -f1)" != "$XSCAV_SHA256" ]; then
    curl -fsSL -o "$TGZ.part" "$XSCAV_URL"
    [ "$(sha256sum "$TGZ.part" | cut -d' ' -f1)" = "$XSCAV_SHA256" ] || { echo "upstream release: wrong SHA-256"; exit 1; }
    mv "$TGZ.part" "$TGZ"
fi
X="$WORK/$XSCAV_DIR"
rm -rf "$X"
tar xzf "$TGZ" -C "$WORK"
for p in "$ROOT"/amiga/patches/*.patch; do
    (cd "$X" && patch -s -p1 < "$p")
done

# 2. the game (a stove's compiler is in its prefix/, or STOVE is the prefix)
if [ -x "$STOVE/prefix/bin/m68k-amigaos-gcc" ]; then PREFIX="$STOVE/prefix"; else PREFIX="$STOVE"; fi
make -f amiga/Makefile.amigaos XSCAV="$X" STOVE="$STOVE" PREFIX="$PREFIX" -j4 $TARGET > "$OUT/build-output.txt" 2>&1 || { tail -n 60 "$OUT/build-output.txt"; exit 1; }

# 3. the archive
python3 "$ROOT/tools/pack_dist.py" --dist "$DIST" --name "$NAME" --out "$OUT"

# 4. the GFOpenUp part
sh "$ROOT/package/write-part.sh" "$DIST/$NAME" "$OUT/Parts/$NAME" "$NAME" "$PORT_VERSION" \
    "XScavenger: the Lode Runner-style platform game, with a level editor"
echo "part: $(grep -c '^copy' "$OUT/Parts/$NAME/Part") files, $(du -sk "$OUT/Parts/$NAME" | cut -f1) KB"
ls -l "$DIST/$NAME/$NAME"
