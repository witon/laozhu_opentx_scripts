
#include <stdint.h>
#include <pthread.h>
#include <queue>
#include <string>
using namespace std;

#ifdef _WIN32
#define PLAY_SOUND(F)   PlaySound(F, NULL, SND_FILENAME | SND_SYNC |SND_NOSTOP |SND_NOWAIT )
#define SLEEP(x)    Sleep(x)
#endif

#ifdef __linux__
#define PLAY_SOUND(F) PlaySound(F)
#define SLEEP(x)    sleep(x)
#endif

class AudioQueue
{
public:
    AudioQueue();
    void playFile(const char *filename, uint8_t flags = 0, uint8_t id = 0);
    void start();

private:
    static queue<string> playFileQueue;
    static void * threadPlaySoundFunc(void *param);
    static pthread_mutex_t mtx;
};