#ifdef _WIN32
#include <Windows.h>
#include <mmsystem.h>
#endif

#include <pthread.h>
#include <string>
#include "audioQueue.h"
#include <stdlib.h>
#include <iostream>
using namespace std;


pthread_mutex_t AudioQueue::mtx = PTHREAD_MUTEX_INITIALIZER;
queue<string> AudioQueue::playFileQueue;

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


void * AudioQueue::threadPlaySoundFunc(void *param)
{
    //long i = 0;
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
        
        /*if(i%10000==0)
        {
            printf("i:%d queue size:%d\n", i, playFileQueue.size());
        }
        */
        s = playFileQueue.front();
        playQueue.push(s);
        playFileQueue.pop();
        pthread_mutex_unlock(&mtx);

        while(playQueue.size()>0)
        {
            s = playQueue.front();
            PLAY_SOUND(s.c_str());
            //PlaySound(s.c_str(), NULL, SND_FILENAME | SND_SYNC |SND_NOSTOP |SND_NOWAIT );//SND_SYNC);
            playQueue.pop();
        }
        //printf("%s\n", s.c_str());
        SLEEP(0);
     //   i ++;
    }
 
    return NULL;  // Never returns
}

void AudioQueue::playFile(const char *filename, uint8_t flags, uint8_t id)
{
    pthread_mutex_lock(&mtx);
    playFileQueue.push(string(filename));
    pthread_mutex_unlock(&mtx);
}

void AudioQueue::start()
{
    pthread_t thread;
    pthread_create(&thread, NULL, threadPlaySoundFunc, NULL);
    printf("init called\n");
}
