/*
 * Host test: runs SDL Scavenger (built with the Amiga's paths) on SDL's
 * dummy video and audio drivers and plays it with queued keys from a
 * thread: F4 starts level 1 out of the demo, the hero runs right and left,
 * and Alt-X leaves the game. scav.c is built with -Dmain=scav_main.
 * At exit it writes PROGDIR:User/play-result: "playing" when the game was
 * in its playing mode (mode1) as the hero ran, and the level number.
 * GPL-2.0-or-later, like Scavenger. Copyright (c) 2026 AmiCradle Team.
 */
#include "SDL.h"
#include <stdio.h>
#include <stdlib.h>

int scav_main(int argc, char **argv);
extern void (*mode)();
extern void mode1();
extern int clevel;

static int was_playing, level_seen;

static void key(SDLKey k, int down)
{
    SDL_Event e;
    SDL_memset(&e, 0, sizeof e);
    e.type = down ? SDL_KEYDOWN : SDL_KEYUP;
    e.key.state = down ? SDL_PRESSED : SDL_RELEASED;
    e.key.keysym.sym = k;
    SDL_PushEvent(&e);
}

static int player(void *unused)
{
    (void)unused;
    SDL_Delay(1500); key(SDLK_F4, 1); SDL_Delay(80); key(SDLK_F4, 0);
    SDL_Delay(1500); key(SDLK_RIGHT, 1);
    SDL_Delay(800);
    was_playing = (mode == mode1);
    level_seen = clevel;
    key(SDLK_RIGHT, 0);
    SDL_Delay(200); key(SDLK_LEFT, 1); SDL_Delay(600); key(SDLK_LEFT, 0);
    SDL_Delay(300); key(SDLK_LALT, 1); SDL_Delay(60); key(SDLK_x, 1);
    SDL_Delay(3000);
    fprintf(stderr, "play: Alt-X did not end the game\n");
    exit(3);
    return 0;
}

static void result(void)
{
    FILE *f = fopen("PROGDIR:User/play-result", "w");
    if (f) {
        fprintf(f, "%s level %d\n", was_playing ? "playing" : "not-playing", level_seen);
        fclose(f);
    }
}

int main(int argc, char **argv)
{
    atexit(result);
    SDL_CreateThread(player, NULL);
    return scav_main(argc, argv);
}
