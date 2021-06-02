#include "gtest/gtest.h"
#include "../win_com.h"

TEST(ComTest, EnumCom)
{
    vector<SerialPortInfo> port_info_list;
    Com::EnumDetailsSerialPorts(port_info_list);
    for(auto& it : port_info_list)
    {
        printf("name: %s, desc: %s\r\n", it.port_name.c_str(), it.description.c_str());
    }
}
TEST(ComTest, Open)
{
    Com com;
    vector<SerialPortInfo> port_info_list;
    Com::EnumDetailsSerialPorts(port_info_list);
    if(port_info_list.empty())
        return;

    for(auto& it : port_info_list)
    {
        bool ret = com.Open(it.port_name.c_str(), 9600, 8, NOPARITY, ONESTOPBIT);
        EXPECT_TRUE(ret);
        com.Send("hahahahahaahsdfasdfsadfsadf", 20);
        //char buf[128] = {0};
        //com.Read(buf, 128);
        com.Close();
    }
}