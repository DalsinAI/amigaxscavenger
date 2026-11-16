/* The Amiga port's start: the stack and the version string. The game
 * makes PROGDIR:User (its levels, key settings and player name) itself.
 * GPL-2.0-or-later, like Scavenger. Copyright (c) 2026 AmiCradle Team. */

/* A Shell gives 4 KB of stack; SDL wants more. libnix's startup sets this
 * much up. */
unsigned long __stack = 256 * 1024;
static const char version[] __attribute__((used)) =
    "$VER: XScavenger 145.4 (16.11.2026)";
