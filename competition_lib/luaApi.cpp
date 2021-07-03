#include "tts_en.h"
#include "audioQueue.h"
#include "audio.h"
#include <string.h>
#include <stdlib.h>
#include "keyReceiver.h"
#include "pandora_wrap.h"

extern char soundPath[];
extern int soundPathLngOfs;
extern AudioQueue audioQueue;
KeyReceiver keyReceiver;
PandoraWrap pandoraWrap;

#ifdef __linux__
    bool OpenPcm();
    void ClosePcm();
#endif

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
        //printf("lua play filename:%s\n", filename);
        // relative sound file path - use current language dir for absolute path
        char file[AUDIO_FILENAME_MAXLEN + 1];
        char *str = getAudioPath(file);
        strncpy(str, filename, AUDIO_FILENAME_MAXLEN - (str - file));
        file[AUDIO_FILENAME_MAXLEN] = 0;
        //printf("lua play file name:%s\n", file);
        audioQueue.playFile(file, 0, 0);
        return 0;
    }
    static int luaGetEvent(lua_State * L)
    {
        int event = keyReceiver.getEvent();
        lua_pushinteger(L, event);
        return 1; //作为返回值传递给Lua,返回1个
    }
    static int luaCleanAudioQueue(lua_State * L)
    {
        audioQueue.clean();
        return 0;
    }
    static int luaSend2Pandora(lua_State *L)
    {
        const char * packet = luaL_checkstring(L, 1);
        int ret = pandoraWrap.SendOnePacket(packet, strlen(packet));
        lua_pushinteger(L, ret);
        return 1;
    }
    static int luaInitPandoraPort(lua_State *L)
    {
        const char * portName = luaL_checkstring(L, 1);
        bool ret = pandoraWrap.Open(portName);
        lua_pushboolean(L, ret);
        return 1;
    }
    static int luaClosePandoraPort(lua_State *L)
    {
        pandoraWrap.Close();
        return 0;
    }
    static int luaSleep(lua_State *L)
    {
        int ms = luaL_checkinteger(L, 1);
        SLEEP(ms);
        return 0;
    }
    static int luaSetTestRun(lua_State *L)
    {
        audioQueue.setTestRun(lua_toboolean(L, 1));
        return 0;
    }
    static int luaStartKeyReceiver(lua_State *L)
    {
        keyReceiver.start();
        return 0;
    }
    static int luaStopKeyReceiver(lua_State *L)
    {
        keyReceiver.stop();
        return 0;
    }

    static int luaStartAudio(lua_State *L)
    {
        bool ret = false;
#ifdef __linux__
        ret = OpenPcm();
        if(!ret)
        {
            lua_pushboolean(L, ret);
            return 1;
        }
#endif
        audioQueue.start();
        lua_pushboolean(L, ret);
        return 1;
    }
 
    static int luaStopAudio(lua_State *L)
    {
        audioQueue.stop();
#ifdef __linux__
        ClosePcm();
#endif
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
    lua_register(L, "getEvent", luaGetEvent);
    lua_register(L, "cleanAudioQueue", luaCleanAudioQueue);
    lua_register(L, "send2Pandora", luaSend2Pandora);
    lua_register(L, "initPandoraPort", luaInitPandoraPort);
    lua_register(L, "closePandoraPort", luaClosePandoraPort);
    lua_register(L, "sleep", luaSleep);
    lua_register(L, "setTestRun", luaSetTestRun);
    lua_register(L, "stopAudio", luaStopAudio);
    lua_register(L, "startAudio", luaStartAudio);
    lua_register(L, "stopKeyReceiver", luaStopKeyReceiver);
    lua_register(L, "startKeyReceiver", luaStartKeyReceiver);
 
    lua_setglobal(L, "sound");

    return 0;
}