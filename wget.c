#include "mxsock.h"
#pragma comment(linker,"/SUBSYSTEM:Console /ENTRY:Entry") 
#pragma comment(lib, "mx32.lib")
#pragma comment(lib, "mxsock.lib")

/*

Project -> Properties -> C++ -> Code Generation -> Multi-threaded (/MT)
Disable Security Check (/GS-)
No Enhanced Instructions /arch:IA32

*/

void __stdcall print(char* line);
int __stdcall GetTimer();
void __stdcall msgbox(char *param1, char *param2);
void __stdcall ExitProcess(int ExitCode);
void __stdcall Sleep(int milliseconds);
char* __stdcall GetCommandLine();
void __stdcall WaitMessage(char *buf);
void __stdcall ReceiveMessage(char *buf);
void __stdcall StdHandler(char *buf);
void __stdcall Get_WinParams(int WinID, char *buf);
void __stdcall Get_XYSize(char *buf);
int __stdcall Draw_StdWindow(int xy_coord, int xy_size, char *name, int buttons);
void __stdcall End_of_redraw();
void __stdcall Create_StdButton(int xy_coord, int xy_size, char *text, int id, int flags);
void __stdcall DefaultButton(int SetDefCtrl);
void __stdcall ListBox(int x, int y, int xsize, int ysize, int items, int lb_data, int IDs, void* ProcPtr);
void __stdcall TaskList(int index, char *buf, int type);
int __stdcall _atoi(char *str);
int __stdcall _malloc(int size);
void __stdcall TaskKill(int PID);
void __stdcall ExitThread(int exitcode);
int __stdcall GetPID();
int __stdcall GetPIDsCount();
int __stdcall GetUsagePages();
void __stdcall SendMessage(int PID, int param1, int param2, int param3);
int __stdcall CreateThread(void* codeaddr, char *name, int param);
void __stdcall Draw_BLine(int x, int y, int x_size, int y_size, int color, int WinID);
void __stdcall WriteText(int x, int y, int color, int FontID, char *text);
void __stdcall Begin_xDraw(int WinID);

int __stdcall bind(int sock, char *sockaddr, int namelen);
int __stdcall accept(int sock, char *sockaddr, int namelen);
int __stdcall listen(int sock, int backlog);
int __stdcall closesocket(int sock);


typedef unsigned short WORD;
typedef struct TaskListInfo
{
	WORD empty;
	WORD PID;
	WORD BaseProcess;
	WORD StartTickLo;
	WORD StartTickHi;
	WORD WID;
	WORD ParentPID;
	WORD User;
	char reserved[0x10];
	char Name[0x20];
} tinfo;

void print_int(int a) {
	char buf[32];
	memset(buf, 0, sizeof buf);
	itoa(a, buf, 10);
	print(buf);
	print("\r\n");
}
void print_hex(int a) {
	char buf[32];
	memset(buf, 0, sizeof buf);
	itoa(a, buf, 16);
	print(buf);
	print("\r\n");
}

int strpos(char *line1, char* line2) {
	int i;
	if (strlen(line1) <= 0) return -1;
	for (i = 0; i < strlen(line1); i++) {
		if (line1[i] == line2[0]) return i;
	}
	return -1;
}


void Entry()
{
	char req_http[] = "GET /";
	const int ret_size = 0x10000;
	char *arg = GetCommandLine();
	char *ret = _malloc(0x10000);
	char req[1024];

	int res = 0;
	int bip = 0;
	
	int port = 80;
	struct sockaddr_in server;
	int received = 0;
	int bport, cnt, offset, pos, i, sock;
	char protocol[8], host[64], cport[6], file[1024];

	
	if (strlen(arg) == 0) return;

	memset(protocol, 0, sizeof protocol);
	memset(host, 0, sizeof host);
	memset(cport, 0, sizeof cport);
	memset(file, 0, sizeof file);

	if (strlen(arg) == 0) return;
	offset = strpos(arg, ":"); 
	if (offset == -1) return;
	// http://
	memcpy(protocol, arg, offset);
	offset++;
	if (arg[offset] == '/') offset++;
	if (arg[offset] == '/') offset++;
	if (arg[offset] == 0) ExitProcess(-1);
	pos = strpos(arg+offset, "/");
	if (pos == 0) return;
	if (pos == -1) pos = strlen(arg + offset);
	memcpy(host, arg + offset, pos);

	offset += pos;
	if (arg[offset] == '/') offset++;
	// have file?
	if (arg[offset] != 0) {
		memcpy(file, arg + offset, strlen(arg + offset));
	}
	if (strlen(host) <= 0) ExitProcess(-1);
	// have port?
	pos = strpos(host, ":");
	if (pos > 0) {
		memcpy(cport, host + pos + 1, strlen(host) - pos - 1);
		port = _atoi(cport);
		host[pos] = 0;
	}
	// host or ip?
	bip = str2bip(host);
	if (bip == 0) {
		// is host
	}
	sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	// prepare sock struct
	server.sin_family = AF_INET;

	bport = (port & 0xFF) << 8;
	bport += (port >> 8) & 0xFF;
	server.sin_port =bport;
	memcpy(&server.sin_addr, &bip, 4);


	res = connect(sock, (char*)&server, 18);

	memset(req, 0, sizeof req);
	memcpy(req, req_http, sizeof req_http);
	if (strlen(file)>0) memcpy(req + strlen(req), file, strlen(file));

	req[strlen(req)] = 0xD; req[strlen(req)] = 0xA;
	req[strlen(req)] = 0xD; req[strlen(req)] = 0xA;
	req[strlen(req)] = 0;

	cnt = send(sock, req, strlen(req), 0);

	// wait for recv
	for (i = 0; i < 30; i++) {
		Sleep(100);
		received = recv(sock, ret, ret_size, MSG_DONTWAIT);
		if (received>0) break;
	}
	if (received >0) {
		print(ret);
	}
	else {
		print("<!> Error: ");
		print(host);
		print(" - Server offline\r\n");
	}
	ExitProcess(0);
}