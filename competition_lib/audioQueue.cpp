#ifdef _WIN32
#include <Windows.h>
#include <mmsystem.h>
#endif
#include "os_adapt.h"
#include <pthread.h>
#include <string>
#include "audioQueue.h"
#include <stdlib.h>
#include <iostream>
using namespace std;


pthread_mutex_t AudioQueue::mtx = PTHREAD_MUTEX_INITIALIZER;
queue<string> AudioQueue::playFileQueue;
bool AudioQueue::isTestRun = false;

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


void * AudioQueue::threadPlaySoundFunc(void *param)
{
    queue<string> playQueue;
    while(true)
    {
        string s = "";
        pthread_mutex_lock(&mtx);
        if(playFileQueue.empty())
        {
            pthread_mutex_unlock(&mtx);
            continue;
        }
        
        s = playFileQueue.front();
        playQueue.push(s);
        playFileQueue.pop();
        pthread_mutex_unlock(&mtx);

        while(playQueue.size()>0)
        {
            s = playQueue.front();
            if(isTestRun)
                printf("%s\r\n", s.c_str());
            else
                PLAY_SOUND(s.c_str());
            playQueue.pop();
        }
        SLEEP(0);
    }
 
    return NULL;  // Never returns
}

void AudioQueue::playFile(const char *filename, uint8_t flags, uint8_t id)
{
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


void AudioQueue::start()
{
    pthread_t thread;
    pthread_create(&thread, NULL, threadPlaySoundFunc, NULL);
}
