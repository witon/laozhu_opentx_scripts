#include "tts_en.h"
#include "audioQueue.h"
#include "audio.h"
#include <string.h>
#include <stdlib.h>
extern char soundPath[];
extern int soundPathLngOfs;
extern AudioQueue audioQueue;
extern "C" {
    #define LUA_COMPAT_APIINTCASTS
    #include <lualib.h>
    #include <lauxlib.h>
    #include <lua.h>


    static int luaSetSoundPath(lua_State *L)
    {
        const char * path = luaL_checkstring(L, 1);
        strncpy(soundPath, path, MAX_SOUND_PATH_LEN);
        soundPathLngOfs = strlen(soundPath);
        return 0;
    }
    static int luaPlayNumber(lua_State *L)
    {
        int number = luaL_checkinteger(L, 1);
        int unit = luaL_checkinteger(L, 2);
        unsigned int att = luaL_optunsigned(L, 3, 0);
        playNumber(number, unit, att, 0);
        return 0;
    }
    static int luaPlayDuration(lua_State *L)
    {
        int duration = luaL_checkinteger(L, 1);
        bool playTime = (luaL_optinteger(L, 2, 0) != 0);
        playDuration(duration, playTime ? 1 : 0, 0);
        return 0;
    }
    static int luaPlayFile(lua_State * L)
    {
        const char * filename = luaL_checkstring(L, 1);
        printf("lua play filename:%s\n", filename);
        // relative sound file path - use current language dir for absolute path
        char file[AUDIO_FILENAME_MAXLEN + 1];
        char *str = getAudioPath(file);
        strncpy(str, filename, AUDIO_FILENAME_MAXLEN - (str - file));
        file[AUDIO_FILENAME_MAXLEN] = 0;
        printf("lua play file name:%s\n", file);
        audioQueue.playFile(file, 0, 0);
        return 0;
    }
}

int initLua(lua_State * L)
{
    const char *libName = "sound";
    lua_newtable(L);
    lua_register(L, "playNumber", luaPlayNumber);
    lua_register(L, "playDuration", luaPlayDuration);
    lua_register(L, "playFile", luaPlayFile);
    lua_register(L, "setSoundPath", luaSetSoundPath);
 
    lua_setglobal(L, "sound");
    audioQueue.start();
    return 0;
}