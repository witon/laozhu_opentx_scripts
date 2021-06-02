#include "win_com.h"
#include <vector>
#include <windows.h> // CreateFile GetTickCount64
#include <string>
#include "tchar.h" // _sntprintf _T 
Com::Com()
{

}

std::string Com::WStringToString(const std::wstring& wstr)
{
	if (wstr.empty())
	{
		return std::string();
	}
	int size = WideCharToMultiByte(CP_ACP, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
	std::string ret = std::string(size, 0);
	WideCharToMultiByte(CP_ACP, 0, &wstr[0], (int)wstr.size(), &ret[0], size, NULL, NULL); // CP_UTF8
	return ret;
}


void Com::EnumDetailsSerialPorts(vector<SerialPortInfo>& port_info_list)
{
	bool ret = false;
	std::string str_port_name;
	HANDLE handle;
	TCHAR port_name[255] = { 0 };
    SerialPortInfo serial_port_info;
	for (int i = 1; i <= 255; i++)
	{
		ret = false;
		_sntprintf(port_name, sizeof(port_name), _T("\\\\.\\COM%d"), i);
		handle = CreateFile(port_name, GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
		if (handle == INVALID_HANDLE_VALUE)
		{
			if (ERROR_ACCESS_DENIED == GetLastError())
			{
				ret = true;
			}
		}
		else
		{
			ret = true;
		}

		if (ret)
		{
#ifdef UNICODE
			str_port_name = WStringToString(port_name);
#else
			str_port_name = std::string(port_name);
#endif
			serial_port_info.port_name = str_port_name;
			port_info_list.push_back(serial_port_info);
		}
		CloseHandle(handle);
	}
}

bool Com::Open(string port_name, DWORD baud_rate, BYTE byte_size, BYTE parity, BYTE stop_bits)
{
	if(com_handle != NULL)
		Close();
	com_handle = CreateFile(port_name.c_str(),//COM1口
		GENERIC_READ | GENERIC_WRITE, //允许读和写
		0, //独占方式
		NULL,
		OPEN_EXISTING, //打开而不是创建
		0,//FILE_FLAG_OVERLAPPED, //0, //同步方式
		NULL);
	if (com_handle == INVALID_HANDLE_VALUE)
	{
		return false;
	}
	SetupComm(com_handle, 1024, 1024); //输入缓冲区和输出缓冲区的大小都是1024
	COMMTIMEOUTS timeouts;
	//设定读超时
	timeouts.ReadIntervalTimeout = 0;
	timeouts.ReadTotalTimeoutMultiplier = 0;//5000;
	timeouts.ReadTotalTimeoutConstant = 0;//5000;
	//设定写超时
	timeouts.WriteTotalTimeoutMultiplier = 0;//500;
	timeouts.WriteTotalTimeoutConstant = 0;//2000;
	SetCommTimeouts(com_handle, &timeouts); //设置超时
	DCB dcb;
	GetCommState(com_handle, &dcb);
	dcb.BaudRate = baud_rate;
	dcb.ByteSize = byte_size;
	dcb.Parity = parity;
	dcb.StopBits = stop_bits;
	SetCommState(com_handle, &dcb);

	return true;
}

void Com::Close()
{
	if(com_handle == NULL)
		return;
	CloseHandle(com_handle);
	com_handle = NULL;
}

int Com::Send(const void * buf, int len)
{
	if(com_handle == NULL)
		return -1;
	DWORD written_cnt = 0;
	BOOL ret = WriteFile(com_handle, buf, len, &written_cnt, NULL);
	if(!ret)
		return -1;
	return written_cnt;
}

int Com::Recv(void * buf, int buf_len)
{
	if(com_handle == NULL)
		return -1;
	DWORD err = 0;
	COMSTAT state;
	BOOL ret = ClearCommError(com_handle, &err, &state);
	if(!ret)
		return -1;
	if(state.cbInQue <= 0)
		return 0;
	DWORD read_cnt = 0;
	ret = ReadFile(com_handle, buf, buf_len, &read_cnt, NULL);
	if(!ret)
	{
		int err = GetLastError();
		printf("err: %d\r\n", err);
		if(err == ERROR_IO_PENDING)
			return 0;
		else
			return -1;
	}
	return read_cnt;
}