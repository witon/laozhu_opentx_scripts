#include <string>
#include <pthread.h>
#include <queue>
#include <string.h>

#ifdef _WIN32
#include "win_com.h"
#define SLEEP(x)    Sleep(x)
#endif

#ifdef __linux__
#include <unistd.h>
#include "linux_com.h"
#define SLEEP(x)    sleep(x)
#endif

using namespace std;
enum ThreadState
{
    THREAD_STATE_IDLE = 0,
    THREAD_STATE_RUNNING,
    THREAD_STATE_STOPPING
};

//P|02|01|0|A(2) - L1 5 max in 7m
//R02G01T0201ST

//P|03|02|0|B(1) - L2 4max in 10m



class PandoraWrap
{
private:
    static void * ThreadRecvFunc(void *param);
    string com_port_name;
    pthread_t thread;
    pthread_mutex_t mtx = PTHREAD_MUTEX_INITIALIZER;;
    queue<string> packets;

public:
    ThreadState thread_state = THREAD_STATE_IDLE;
    Com com;
    int SendOnePacket(const void * buf, int len);
    int DecodeOnePacket(const void * buf, int len);
    void Lock();
    void UnLock();
    PandoraWrap();
    bool Open(string port_name);
    void Close();
};