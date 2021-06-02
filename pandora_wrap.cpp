#include "pandora_wrap.h"

PandoraWrap::PandoraWrap()
{
    ;
}

void * PandoraWrap::ThreadRecvFunc(void *param)
{
    PandoraWrap * pandora_wrap = (PandoraWrap *) param;
    char buf[512] = {0};
    int len = 0;
    pandora_wrap->thread_state = THREAD_STATE_RUNNING;
    while(pandora_wrap->thread_state == THREAD_STATE_RUNNING)
    {
        int ret = pandora_wrap->com.Recv(buf, sizeof(buf) - len);

        if(ret < 0)
        {
            pandora_wrap->Close();
            break;
        }
        len = len + ret;
        ret = pandora_wrap->DecodeOnePacket(buf, len);
        if(ret == -1)
        {
            pandora_wrap->Close();
            break;
        }
        memmove(buf, buf + ret, len - ret);
        len = len - ret;
        SLEEP(0);
    }
    pandora_wrap->thread_state = THREAD_STATE_IDLE;
    return NULL;
}

bool PandoraWrap::Open(string port_name)
{
    if(thread_state != THREAD_STATE_IDLE)
        return false;

    Lock();
    if(!com.Open(port_name, 115200, 8, NOPARITY, ONESTOPBIT))
    {
        UnLock();
        return false;
    }
    pthread_create(&thread, NULL, ThreadRecvFunc, (void *)this);
    UnLock();
    return true;
}

void PandoraWrap::Close()
{
    if(thread_state != THREAD_STATE_RUNNING)
        return;
    thread_state = THREAD_STATE_STOPPING;
    Lock();
    com.Close();
    UnLock();
}

int PandoraWrap::SendOnePacket(const void * buf, int len)
{
    return com.Send(buf, len);
}
 
int PandoraWrap::DecodeOnePacket(const void *buf, int len)
{
    const char * p = (char *)buf;
    int ret = 0;
    string packet = "";
    for(int i=0; i<len; i++)
    {
        if(p[i] == 0x0a)
        {
            printf("decoded 1packet\r\n");
            packet.insert(0, p, i);
            ret = i;
        }
    }
    Lock();
    packets.push(packet);
    UnLock();
    return ret;
}

void PandoraWrap::Lock()
{
    pthread_mutex_lock(&mtx);
}

void PandoraWrap::UnLock()
{
    pthread_mutex_unlock(&mtx);
}