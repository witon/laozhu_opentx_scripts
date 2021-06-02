#include <Windows.h>
#include <mmsystem.h>
#include <windows.h>
#include <pthread.h>

#include <iostream>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
extern "C"{
    #include <lualib.h>
    #include <lauxlib.h>
    #include <lua.h>
}


#pragma comment(lib,"WinMM.Lib")
#pragma comment(lib,"libwinmm.a")

#include <iostream>
using namespace std;

#ifdef __cplusplus
extern "C"
{
#endif

int luaopen_TestLua(lua_State*);

#ifdef __cplusplus
}
#endif

int add(lua_state *state)
{
    int n = lua_gettop(state);
    int sum = 0;
    for (int i = 0; i < n; ++i)
    {
        sum += lua_tonumber(state, i+1);
    }
    
    if (n != 0)
    {
        lua_pushnumber(state, sum);
        return 1;
    }
    return 0;
}

using namespace std;

void *threadAddFunc(void *param)
{
    //long thread_id = (long)*param;

    string s = "C:\\opentxsdcard1\\SOUNDS\\en\\fm-1.wav";// "bt.wav";
    for(int i=0; i<300; i++)
    {
        PlaySound(s.c_str(), NULL, SND_FILENAME | SND_SYNC);
        printf("%s\n", s.c_str());
        Sleep(0);
    }
 
    return NULL;  // Never returns
}


    
int main(int argc, char** argv)
{
    pthread_t thread;
    int i = 0;
    pthread_create(&thread, NULL, threadAddFunc, (void *)i);
   while(true)
        Sleep(0);
    return 0;
}