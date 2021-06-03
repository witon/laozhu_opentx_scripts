#include <stdint.h>
#include <pthread.h>
#include <queue>
#include <string>
using namespace std;

#ifdef __linux__
char _getch();
#endif

class KeyReceiver
{
private:
    static queue<int> eventQueue;
    static void * threadDetectKeyFunc(void *param);
    static pthread_mutex_t mtx;
    static int detectKey();
    static int threadState;
    pthread_t thread;
public:
    KeyReceiver();
    int getEvent();
    bool start();
    void stop();
};