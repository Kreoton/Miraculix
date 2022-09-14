#pragma comment(linker,"/SUBSYSTEM:Console /ENTRY:Entry") 
#pragma comment(lib, "mx32.lib")
#pragma comment(lib, "mxsock.lib")

void __stdcall msgbox(char *param1, char *param2);
void __stdcall ExitProcess(int ExitCode);
void __stdcall Sleep(int milliseconds);
void __stdcall print(char* line);
char* __stdcall GetCommandLine();
int __stdcall ipconfig(int interface1, int obj, int rw, int val, int reserved);

void ip2str(int ip, char *buf) {
	int a;
	int i;
	char ipv4[4];
	memset(buf, 0, 16);
	memset(ipv4, 0, 16);
	memcpy(ipv4, &ip, 4);

	for (i = 0; i < 4; i++) {
		unsigned char c = ipv4[i];
		a = c;
		itoa(a, buf + strlen(buf), 10);
		if (i == 3) break;
		buf[strlen(buf)] = '.';
	}
}

void Entry()
{
	int ip;
	int i;
	char ip_line0[] = "\r\nMiraculix IP Configuration\r\n\r\n";
	char ip_line1[] = "   IPv4 Address. . . . . . . . . . . : ";
	char ip_line2[] = "   Subnet Mask . . . . . . . . . . . : ";
	char ip_line3[] = "   Default Gateway . . . . . . . . . : ";
	char ip_line4[] = "   DNS Server. . . . . . . . . . . . : ";
	char ip_addr[16];

	print(ip_line0);

	for (i = 1; i < 4; i++) {
		ip = ipconfig(i, 1, 0, 0, 0);
		if (ip != -1) {
			ip2str(ip, ip_addr);
			print(ip_line1);
			print(ip_addr);
			print("\r\n");

			ip = ipconfig(i, 2, 0, 0, 0);

			ip2str(ip, ip_addr);
			print(ip_line2);
			print(ip_addr);
			print("\r\n");

			ip = ipconfig(i, 3, 0, 0, 0);

			ip2str(ip, ip_addr);
			print(ip_line3);
			print(ip_addr);
			print("\r\n");

			ip = ipconfig(i, 4, 0, 0, 0);

			ip2str(ip, ip_addr);
			print(ip_line4);
			print(ip_addr);
			print("\r\n");
		}
	}
}