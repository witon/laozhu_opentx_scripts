#ifdef _WIN32
#include <Windows.h>
#include <mmsystem.h>
#include <io.h>
#endif
#ifdef __linux__
#include <fcntl.h>
#endif
#include "os_adapt.h"
#include <pthread.h>
#include <string>
#include "audioQueue.h"
#include <stdlib.h>
#include <iostream>
#include "comm.h"
using namespace std;


pthread_mutex_t AudioQueue::mtx = PTHREAD_MUTEX_INITIALIZER;
queue<string> AudioQueue::playFileQueue;
bool AudioQueue::isTestRun = false;
int AudioQueue::threadState = THREAD_STATE_IDLE;


#ifdef __linux__
#include "playsound.h"
int PlaySound(string fileName)
{
    class PlaySound playSound;
    return playSound.playFile(fileName);
}
#endif

AudioQueue::AudioQueue()
{
}

void AudioQueue::setTestRun(bool isTest)
{
    isTestRun = isTest;
}

bool AudioQueue::checkWaveFile(const char * filepath)
{

    int ret = -1;
#ifdef _WIN32
    ret = _access(filepath, 4);
#endif
#ifdef __linux__
    ret = access(filepath, R_OK);
#endif
    return ret == 0;
}


void * AudioQueue::threadPlaySoundFunc(void *param)
{
    queue<string> threadPlayQueue;
    while(threadState == THREAD_STATE_RUNNING)
    {
        string s = "";
        pthread_mutex_lock(&mtx);
        if(playFileQueue.empty())
        {
            pthread_mutex_unlock(&mtx);
            continue;
        }
        while(!playFileQueue.empty())
        {
            s = playFileQueue.front();
            playFileQueue.pop();
            threadPlayQueue.push(s);
        }
        pthread_mutex_unlock(&mtx);
        while(!threadPlayQueue.empty())
        {
            s = threadPlayQueue.front();
            threadPlayQueue.pop();
            if (isTestRun)
            {
                if (!checkWaveFile(s.c_str()))
                {
                    printf("%s\r\n", s.c_str());
                }
            }
            else
            {
                PLAY_SOUND(s.c_str());
            }
        }
        SLEEP(0);
    }
    threadState = THREAD_STATE_IDLE;
 
    return NULL;
}

void AudioQueue::playFile(const char *filename, uint8_t flags, uint8_t id)
{
    //printf("%s\r\n", filename);
    pthread_mutex_lock(&mtx);
    playFileQueue.push(string(filename));
    pthread_mutex_unlock(&mtx);
}

void AudioQueue::clean()
{
    pthread_mutex_lock(&mtx);
    while(playFileQueue.size() > 0)
        playFileQueue.pop();
    pthread_mutex_unlock(&mtx);
}

void AudioQueue::stop()
{
    threadState = THREAD_STATE_STOPPING;
    while(threadState != THREAD_STATE_IDLE)
        SLEEP(1);
    return;
}

bool AudioQueue::start()
{
    if(threadState != THREAD_STATE_IDLE)
        return false;
    pthread_t thread;
    threadState = THREAD_STATE_RUNNING;
    pthread_create(&thread, NULL, threadPlaySoundFunc, NULL);
    return true;
}
