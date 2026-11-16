XScavenger for GFOS
===================

A port of SDL Scavenger, David Ashley's Lode Runner-style platform game
(XScavenger; the SDL version by Barry Mead, release sdlscav-145.4 of
5 January 2015 from https://sourceforge.net/projects/sdlscavenger), for
GFOS: AmigaOS 3.2 with GFOpenUp, on a 68040 or 68060 with an FPU, on
GFOpenUp's SDL 2.

Run, climb and hang your way through the levels collecting the treasure,
digging holes to trap the enemies, then reach the top. It has a level
editor and an animator for drawing your own graphics.

Status: built in Cradle's os32-gcc16-open6 stove (XScavenger 341,588
bytes, no warnings); not yet run in a lab.


What you need
-------------

- GFOS: AmigaOS 3.2 with GFOpenUp 0.8.26 or later, which installs
  LIBS:GFOpenGPU/SDL2.module.
- A 68040 or 68060 with an FPU (not an LC040 or EC040), an RTG screen
  with room for a 640 x 480 window, about 8 MB of free memory and 1 MB
  of disk.
- Nothing else: the pictures, sounds and levels are in the drawer.


How to play
-----------

Install it one of three ways:

- GFOpenUp: `GFOpenUpTool INSTALL Parts/XScavenger` puts it in
  SYS:Games/XScavenger.
- Run Install-XScavenger from the archive (it offers Work:Games).
- Or copy the XScavenger drawer where you want it.

Then double-click XScavenger. It opens in a 640 x 480 window on the
Workbench screen (from a Shell, `XScavenger -f` asks for a screen of its
own). It starts in demo mode: F1 or Space plays, the cursor keys run and
climb, Ctrl and Alt dig left and right, Alt + X leaves; the drawer's
Controls file has the rest. The levels you have solved, your keys and
your name are kept in the drawer's User drawer, which Install-XScavenger
and GFOpenUp keep when they update the game.


Building
--------

    sh package/build-amiga.sh        (STOVE=/path/to/os32-gcc16-open6)

or, in Cradle, stove_build with the os32-gcc16-open6 stove and target
package. It fetches the release package/xscavenger.lock names and checks
its SHA-256, applies amiga/patches, builds with amiga/Makefile.amigaos
(the game's SDL 1.2 calls go through the kit's sdl12-compat to SDL 2)
and packs XScavenger-VERSION-68040.lha and the GFOpenUp part
Parts/XScavenger.

Host tests: `XSCAV=<the unpacked release> sh tests/host/test_all.sh`
applies the patch; checks that all nine of the game's paths into the
player's drawer join PROGDIR: and User without a '/' (which AmigaDOS
would read as PROGDIR's parent); and, where the host has SDL 1.2 or
sdl12-compat, builds the game with the Amiga's paths and plays it on
SDL's dummy drivers: the demo, F4 into level 1, the hero running right
and left, and Alt + X out, with the levels and keys set up in
PROGDIR:User.

The game's files are byte-order safe as they are: its IFF pictures, its
levels and its replays are read and written a byte at a time.


What was changed
----------------

- amiga/patches/0001-amigaos-drawer-paths-window.patch, on __amigaos__
  only:
  - names.h: the game's files in PROGDIR:Data, the player's in
    PROGDIR:User, the log in PROGDIR:User/SCAVINFO.LOG;
  - scav.c, anim.c: the player's paths joined with no '/' after
    PROGDIR:, the data path one drawer (upstream's is a ':'-separated
    list, and an Amiga path has a ':' in it), no HOME needed;
  - scav.c: a window at start (-f for a screen); the simple option
    parser upstream uses on Windows, since a Workbench start has no
    arguments; scav.h: no getopt.h.
- amiga/amiga_start.c: 256 KB of stack, the $VER string.
- amiga/: the Makefile, the GlowIcons (our own art), the Installer script
  and its spec. package/: the build, the release archive and the GFOpenUp
  part. The release's own Linux and Windows programs are not used.

The AmiCradle Team.
