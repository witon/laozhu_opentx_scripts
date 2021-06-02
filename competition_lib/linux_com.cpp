//TODO: Enum Serial Ports
#include <stdio.h>
#include <string.h>
#include "linux_com.h"
#include <vector>
#include <string>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>

Com::Com()
{

}

void Com::EnumDetailsSerialPorts(vector<SerialPortInfo>& port_info_list)
{
}

extern int errno;
bool Com::SetOpt(DWORD baud_rate, BYTE byte_size, BYTE parity, BYTE stop_bits)
{
	struct termios newtio, oldtio;
	if(tcgetattr(fd, &oldtio) != 0)
	{
		return false;
	}
	memset(&newtio, 0, sizeof(newtio));
	newtio.c_cflag |= CLOCAL | CREAD;
	newtio.c_cflag &= ~CSIZE;
	switch (byte_size)
	{
	case 7:
		newtio.c_cflag |= CS7;
		break;
	case 8:
		newtio.c_cflag |= CS8;
		break;
	}
	switch (parity)
	{
	case ODDPARITY: //奇校验
		newtio.c_cflag |= PARENB;
		newtio.c_cflag |= PARODD;
		newtio.c_iflag |= (INPCK | ISTRIP);
		break;
	case EVENPARITY: //偶校验
		newtio.c_iflag |= (INPCK | ISTRIP);
		newtio.c_cflag |= PARENB;
		newtio.c_cflag &= ~PARODD;
		break;
	case NOPARITY: //无校验
		newtio.c_cflag &= ~PARENB;
		break;
	}
	switch (baud_rate)
	{
	case 2400:
		cfsetispeed(&newtio, B2400);
		cfsetospeed(&newtio, B2400);
		break;
	case 4800:
		cfsetispeed(&newtio, B4800);
		cfsetospeed(&newtio, B4800);
		break;
	case 9600:
		cfsetispeed(&newtio, B9600);
		cfsetospeed(&newtio, B9600);
		break;
	case 115200:
		cfsetispeed(&newtio, B115200);
		cfsetospeed(&newtio, B115200);
		break;
	default:
		cfsetispeed(&newtio, B9600);
		cfsetospeed(&newtio, B9600);
		break;
	}
	if (stop_bits == ONESTOPBIT)
	{
		newtio.c_cflag &= ~CSTOPB;
	}
	else if (stop_bits == TWOSTOPBITS)
	{
		newtio.c_cflag |= CSTOPB;
	}
	newtio.c_cc[VTIME] = 0;
	newtio.c_cc[VMIN] = 0;
	tcflush(fd, TCIFLUSH);
	if ((tcsetattr(fd, TCSANOW, &newtio)) != 0)
	{
		return false;
	}
	return true;
}

bool Com::Open(string port_name, DWORD baud_rate, BYTE byte_size, BYTE parity, BYTE stop_bits)
{
	fd = open(port_name.c_str(), O_RDWR|O_NOCTTY|O_NDELAY);
	if(fd == -1)
	{
		printf("open failed. errno: %d\r\n", errno);
		return false;
	}
	if(!SetOpt(baud_rate, byte_size, parity, stop_bits))
	{
		printf("setopt failed. errno: %d\r\n", errno);
		Close();
		return false;
	}
	return true;
}

void Com::Close()
{
	if(fd < 0)
		return;
	close(fd);
	fd = -1;
}

int Com::Send(const void * buf, int len)
{
	return write(fd, buf, len);
}

int Com::Recv(void * buf, int buf_len)
{
	int ret = read(fd, buf, buf_len);
	return ret;
}