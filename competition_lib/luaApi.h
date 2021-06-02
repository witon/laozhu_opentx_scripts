
#ifndef __LUA_API_H_
#define __LUA_API_H_
extern "C"{
#define LUA_COMPAT_APIINTCASTS
    #include <lualib.h>
    #include <lauxlib.h>
    #include <lua.h>
}
static int luaPlayNumber(lua_State *L);
static int luaPlayDuration(lua_State *L);
static int luaPlayFile(lua_State * L);
int initLua(lua_State * L);
#endif