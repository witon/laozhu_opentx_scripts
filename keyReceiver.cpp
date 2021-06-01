#include "keyReceiver.h"
#include <iostream>
#include <pthread.h>
#include "os_adapt.h"

#ifdef _WIN32
#include <windows.h>
#include <conio.h>
#endif

#ifdef __linux__
#include <termios.h>
#include <stdio.h>
#include <unistd.h>
#endif

pthread_mutex_t KeyReceiver::mtx = PTHREAD_MUTEX_INITIALIZER;
queue<int> KeyReceiver::eventQueue;
int KeyReceiver::threadFlag = THREAD_FLAG_STOP;

#ifdef __linux__

static struct termios old, current;
/* Initialize new terminal i/o settings */
void initTermios(int echo)
{
    tcgetattr(0, &old);         /* grab old terminal i/o settings */
    current = old;              /* make new settings same as old settings */
    current.c_lflag &= ~ICANON; /* disable buffered i/o */
    if (echo)
    {
        current.c_lflag |= ECHO; /* set echo mode */
    }
    else
    {
        current.c_lflag &= ~ECHO; /* set no echo mode */
    }
    tcsetattr(0, TCSANOW, &current); /* use these new terminal i/o settings now */
}

/* Restore old terminal i/o settings */
void resetTermios(void)
{
    tcsetattr(0, TCSANOW, &old);
}

/* Read 1 character - echo defines echo mode */
char _getch()
{
    char ch;
    initTermios(0);
    ch = getchar();
    resetTermios();
    return ch;
}
#endif

KeyReceiver::KeyReceiver()
{

}

int KeyReceiver::detectKey()
{
    int ch = _getch();
    return ch;
}

void * KeyReceiver::threadDetectKeyFunc(void *param)
{
    while(threadFlag == THREAD_FLAG_RUNNING)
    {
        int key = detectKey();
        pthread_mutex_lock(&mtx);
        eventQueue.push(key);
        pthread_mutex_unlock(&mtx);
        SLEEP(0);

    }
    return NULL;
}

int KeyReceiver::getEvent()
{
    int ret = -1;
    pthread_mutex_lock(&mtx);
    if(eventQueue.size() > 0)
    {
        ret = eventQueue.front();
        eventQueue.pop();
    }
    pthread_mutex_unlock(&mtx);
    return ret;
}

void KeyReceiver::start()
{
    threadFlag = THREAD_FLAG_RUNNING;
    pthread_create(&thread, NULL, threadDetectKeyFunc, NULL);
}

void KeyReceiver::stop()
{
    threadFlag = THREAD_FLAG_STOP;
}