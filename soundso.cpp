#include <iostream>
#include <stdlib.h>

using namespace std;


extern "C" {
    #define LUA_COMPAT_APIINTCASTS
    #include <lualib.h>
    #include <lauxlib.h>
    #include <lua.h>
}

#include "luaApi.h"

extern "C" int luaopen_sound(lua_State* L)
{
    initLua(L);
    return 0;
}
