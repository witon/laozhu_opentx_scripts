#include <stdint.h>
#include <pthread.h>
#include <queue>
#include <string>
using namespace std;

enum THREAD_FLAG
{
    THREAD_FLAG_STOP = 0,
    THREAD_FLAG_RUNNING
};
class KeyReceiver
{
private:
    static queue<int> eventQueue;
    static void * threadDetectKeyFunc(void *param);
    static pthread_mutex_t mtx;
    static int detectKey();
    static int threadFlag;
    pthread_t thread;
public:
    KeyReceiver();
    int getEvent();
    void start();
    void stop();
};