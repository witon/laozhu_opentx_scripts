
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
    bool start();
    void stop();
    void clean();
    void setTestRun(bool isTest);
private:
    static int threadState;
    static bool isTestRun;
    static queue<string> playFileQueue;
    static void * threadPlaySoundFunc(void *param);
    static pthread_mutex_t mtx;
    static bool checkWaveFile(const char *filepath);
};