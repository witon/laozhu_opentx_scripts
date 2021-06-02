#include <string>
#include <vector>
#include <windows.h>
using namespace std;

struct SerialPortInfo
{
	std::string port_name;
	std::string description;
};


class Com
{
private:
    static std::string WStringToString(const std::wstring& wstr);
    HANDLE com_handle;
public:
    static void EnumDetailsSerialPorts(vector<SerialPortInfo>& port_info_list);
    bool Open(string com_name, DWORD baud_rate, BYTE byte_size, BYTE parity, BYTE stop_bits);
    void Close();
    int Send(const void * buf, int len);
    int Recv(void * buf, int buf_len);
    Com();
};