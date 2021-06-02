#include <string>
#include <vector>
using namespace std;

typedef unsigned long long DWORD;
typedef unsigned char BYTE;

#define NOPARITY            0
#define ODDPARITY           1
#define EVENPARITY          2
#define MARKPARITY          3
#define SPACEPARITY         4

#define ONESTOPBIT          0
#define ONE5STOPBITS        1
#define TWOSTOPBITS         2

struct SerialPortInfo
{
	std::string port_name;
	std::string description;
};


class Com
{
private:
    int fd = -1;
    bool SetOpt(DWORD baud_rate, BYTE byte_size, BYTE parity, BYTE stop_bits);


public:
    static void EnumDetailsSerialPorts(vector<SerialPortInfo>& port_info_list);
    bool Open(string com_name, DWORD baud_rate, BYTE byte_size, BYTE parity, BYTE stop_bits);
    void Close();
    int Send(const void * buf, int len);
    int Recv(void * buf, int buf_len);
    Com();
};