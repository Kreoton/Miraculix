#include "mxsock.h"
#pragma comment(linker,"/SUBSYSTEM:Console /ENTRY:Entry") 
#pragma comment(lib, "mx32.lib")
#pragma comment(lib, "mxsock.lib")

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

void watchdog() {
	// get sock num from taskname
	int pid = GetPID();
	int client = 0;
	char socknum[32];
	char num[32];
	tinfo task;
	TaskList(pid, &task, 0);
	if (strpos(task.Name, "-")) {
		memset(socknum, 0, sizeof socknum);
		memcpy(socknum, task.Name + strpos(task.Name, "-") + 1, strlen(task.Name) - strpos(task.Name, "-") - 1);
		if (strpos(socknum, "-") != -1)
			socknum[strpos(socknum, "-")] = 0;
		client = _atoi(socknum);
	}

	Sleep(1500);

	TaskList(client, &task, 0);
	if (task.Name[0] == 't' && task.Name[1] == 'c' && task.Name[2] == 'p')
		TaskKill(client);
	ExitThread(0);
}

void client_request() {
	// get sock num from taskname
	int pid = GetPID();
	int client = 0;
	tinfo task;
	char tosend[] = "HTTP/1.1 200 OK\r\nX-Powered-By: Miraculix\r\nContent-Type: text/html\r\nConnection: close\r\n\r\nHello from Miraculix";
	char buf[4096];
	TaskList(pid, &task, 0);
	if (strpos(task.Name, "-")) {
		char socknum[32];
		char num[32];
		memset(socknum, 0, sizeof socknum);
		memcpy(socknum, task.Name + strpos(task.Name, "-") + 1, strlen(task.Name) - strpos(task.Name, "-") - 1);
		if (strpos(socknum, "-") != -1)
			socknum[strpos(socknum, "-")] = 0;
		client = _atoi(socknum);
	}

	if (client > 0) {
		int received = recv(client, buf, sizeof(buf)-1, 0);
		send(client, tosend, sizeof tosend, 0);
		closesocket(client);
	}
	ExitThread(0);
}

void Entry()
{
	int res = 0;
	int bip = 0;
	int client;
	char thrd_name1[] = "tcp-";
	char tcp_thrd[sizeof thrd_name1 + 6];

	struct sockaddr_in serverSock, clientSock;
	int received = 0;
	int clientSockLen;
	int pid;
	char thrd_name[] = "watchdog-";
	char wtd_thrd[sizeof thrd_name + 6];

	int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	// prepare sock struct
	serverSock.sin_family = AF_INET;
	serverSock.sin_port = 80 << 8;
	memcpy(&serverSock.sin_addr, &bip, 4);

	res = bind(sock, (char*)&serverSock, 18);
	res = listen(sock, 10);

	while (1) {
		client = accept(sock, (struct sockaddr*)&clientSock, &clientSockLen);
		if (client == 0) continue;
		memset(tcp_thrd, 0, sizeof tcp_thrd);
		memcpy(tcp_thrd, thrd_name1, sizeof thrd_name1);
		itoa(client, tcp_thrd + strlen(tcp_thrd), 10);

		// add ip
		//tcp_thrd[strlen(tcp_thrd)] = '-';
		//int ip = 0x666;
		//memcpy(&ip, &clientSock.sin_addr, 4);
		//memcpy(&ip, csock, 4);
		//itoa(ip, tcp_thrd + strlen(tcp_thrd), 16);

		pid = CreateThread(client_request, tcp_thrd, 0);

		memset(wtd_thrd, 0, sizeof wtd_thrd);
		memcpy(wtd_thrd, thrd_name, sizeof thrd_name);
		itoa(pid, wtd_thrd + strlen(wtd_thrd), 10);
		CreateThread(watchdog, wtd_thrd, 0);
	}
}