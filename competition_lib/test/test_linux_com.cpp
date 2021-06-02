#include "gtest/gtest.h"
#include "../linux_com.h"

TEST(LinuxComTest, EnumCom)
{
    /*vector<SerialPortInfo> port_info_list;
    Com::EnumDetailsSerialPorts(port_info_list);
    for(auto& it : port_info_list)
    {
        printf("name: %s, desc: %s\r\n", it.port_name.c_str(), it.description.c_str());
    }
    */
}
TEST(LinuxComTest, Open)
{
    Com com;
    /*vector<SerialPortInfo> port_info_list;
    Com::EnumDetailsSerialPorts(port_info_list);
    if(port_info_list.empty())
        return;
        */
    bool ret = com.Open("/dev/ttyUSB0", 9600, 8, NOPARITY, ONESTOPBIT);
    char buf[128] = {0};
    int i = com.Send(buf, 128);
    i = com.Recv(buf, 128);
    printf("recv ret: %d\r\n", i);
    EXPECT_TRUE(ret);

/*
    for(auto& it : port_info_list)
    {
        bool ret = com.Open(it.port_name.c_str(), 9600, 8, NOPARITY, ONESTOPBIT);
        EXPECT_TRUE(ret);
        com.Send("hahahahahaahsdfasdfsadfsadf", 20);
        //char buf[128] = {0};
        //com.Read(buf, 128);
        com.Close();
    }
    */
}