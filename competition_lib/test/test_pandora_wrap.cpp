#include "gtest/gtest.h"
#include "../pandora_wrap.h"
void foo()
{
    char * p = NULL;
    *p = 1;
}
TEST(P1andoraWrapTest, Open)
{
    PandoraWrap pandora_wrap;
    bool ret = pandora_wrap.Open("COM6");
    if(ret)
        printf("open pandora port success.\r\n");
    else
        printf("open pandora port failed.\r\n");
    pandora_wrap.Close();
}