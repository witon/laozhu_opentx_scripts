#include "keyReceiver.h"
#include <conio.h>
#include <iostream>
#include <pthread.h>
#include <windows.h>


pthread_mutex_t KeyReceiver::mtx = PTHREAD_MUTEX_INITIALIZER;
queue<int> KeyReceiver::eventQueue;
int KeyReceiver::threadFlag = THREAD_FLAG_STOP;

KeyReceiver::KeyReceiver()
{

}

int KeyReceiver::detectKey()
{
    int ch = -1;
    if (_kbhit())
    {
        ch = _getch();
    }
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
        Sleep(0);

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