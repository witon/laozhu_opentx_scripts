#include "playsound.h"

    
int main(int argc, char** argv)
{
    pthread_t thread;
    int i = 0;
    pthread_create(&thread, NULL, threadAddFunc, (void *)i);
   while(true)
        Sleep(0);
    return 0;
}