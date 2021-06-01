
#include <stdint.h>
#include <pthread.h>
#include <queue>
#include <string>
using namespace std;

class AudioQueue
{
public:
    AudioQueue();
    void playFile(const char *filename, uint8_t flags = 0, uint8_t id = 0);
    void start();
    void clean();

private:
    static queue<string> playFileQueue;
    static void * threadPlaySoundFunc(void *param);
    static pthread_mutex_t mtx;
};