#pragma comment(linker,"/SUBSYSTEM:Windows /ENTRY:Entry") 
#pragma comment(lib, "mx32.lib")

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
int __stdcall GetPID();
int __stdcall GetPIDsCount();
int __stdcall GetUsagePages();
void __stdcall SendMessage(int PID, int param1, int param2, int param3);
int __stdcall CreateThread(void* codeaddr, char *name, int param);
void __stdcall Draw_BLine(int x, int y, int x_size, int y_size, int color, int WinID);
void __stdcall WriteText(int x, int y, int color, int FontID, char *text);
void __stdcall Begin_xDraw(int WinID);



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

int EventID_Redraw = 1;
int EventID_Focus = 2;
int EventID_LostFocus = 3;
int EventID_Close = 4;
int EventID_MouseEvent = 5;
int EventID_Ctrl0 = 10;
int EventID_Ctrl1 = 11;
int EventID_Ctrl2 = 12;
int EventID_Ctrl3 = 13;
int EventID_Maximize = 14;
int EventID_Restore = 15;
int EventID_Kbd = 20;
int EventID_IPC = 50;



char my_name[] = "taskmgr.exe";
int columns_count = 4;
int WinID;
char sysmsg[0x20];
char saved_sizes[8];
int win_coords = 0, win_sizes = 0;
int win_buttons_def = 23;
int win_buttons_max = 8;
int win_buttons = 0;
int list_offset = 10;
int down_bttns = 30;
char TableItems[4096];
char ListData[0x1000 * 10];
int focus = 1;

void msgint(int a) {
	char buf[16];
	memset(buf, 0, sizeof buf);
	itoa(a, buf, 10);
	msgbox(buf, 0);
}

void MemUsageThrd() {
	for (;;) {
		Sleep(100);
	}
}

int get_pid_from_ListData_array(int lid,int columns) {
	int index = 0, i, len;
	for (i = 0; i < lid*columns; i++) {
		len = strlen(ListData + index);
		index += len + 1;
	}
	len = strlen(ListData + index);
	index += len + 1;
	len = strlen(ListData + index);
	index += len + 1;
	return _atoi(ListData + index);
}

void Update() {
	int win_coords_new, win_sizes_new;
	char buf[0x10];
	Get_WinParams(WinID, buf);
	memcpy(saved_sizes, buf, sizeof saved_sizes);
	memcpy(&win_coords_new, saved_sizes, 4);
	memcpy(&win_sizes_new, saved_sizes + 4, 4);

	SendMessage(0, EventID_Redraw << 8, win_coords_new, win_sizes_new);
}


void __stdcall callFromListBox(int element_id, int key) {
	key = key & 0xFFFF;
	// del
	if (key == 0x53) {
		TaskKill(get_pid_from_ListData_array(element_id, columns_count));
		Update();
	}
}

void FillListData() {
	tinfo task;
	tinfo task_exec;
	int index = 0;
	int len;
	char buf[16];
	int val,i,j;
	char exec_flag[] = " ";

	for (i = 1;; i++) {
		memset(&task, 0, sizeof task);
		TaskList(i, &task, 0);
		if (task.Name[0] == 0) break;
		if (task.Name[0] == '?') continue;
		if (task.Name[0] == '-') continue;
		len = strlen(task.Name);
		if (len == 0) break;
		
		// executing now?
		exec_flag[0] = ' ';
		for (j = 1;j<=i;j++) {
			memset(&task_exec, 0, sizeof task_exec);
			TaskList(j, &task_exec, 1);
			if (task_exec.Name[0] == 0) break;
			if (task_exec.Name[0] == '?') continue;
			if (task_exec.Name[0] == '-') continue;
			if (strlen(task_exec.Name) == 0) break;
			if (task_exec.PID == task.PID) {
				exec_flag[0] = '>';
				break;
			}
		}



		memcpy(ListData + index, exec_flag, 1);
		index += 1 + 1; ListData[index - 1] = 0;
		

		// task name
		memcpy(ListData + index, task.Name, len);
		index += len + 1; ListData[index - 1] = 0;

		// PID
		memset(buf, 0, sizeof buf);
		val = task.PID;
		itoa(val, buf, 10);
		len = strlen(buf);
		strlen(buf);
		memcpy(ListData + index, buf, len);
		index += len + 1; ListData[index - 1] = 0;

		// WID
		memset(buf, 0, sizeof buf);
		val = task.WID;
		itoa(val, buf, 10);
		len = strlen(buf);
		memcpy(ListData + index, buf, len);
		index += len + 1; ListData[index - 1] = 0;
	}

	for (i = 0; i < 4; i++)	ListData[index + i] = 0;
}

void fillTableItems() {
	char item0[] = " \0             ";
	char item1[] = "Name\0          ";
	char item2[] = "PID\0           ";
	char item3[] = "WinID\0         ";

	// fill TableItems:
	unsigned int dword;
	int index = 0;
	dword = columns_count;
	memcpy(TableItems + index, &dword, columns_count); index += 4;

	memcpy(TableItems + index, item0, sizeof item0); index += sizeof item0;
	dword = 10;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = -1;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = 0;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = 0;
	memcpy(TableItems + index, &dword, 4); index += 4;

	memcpy(TableItems + index, item1, sizeof item1); index += sizeof item1;
	dword = 128;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = 0xDFFFDF;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = 0;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = 0;
	memcpy(TableItems + index, &dword, 4); index += 4;

	memcpy(TableItems + index, item2, sizeof item2); index += sizeof item2;
	dword = 30;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = -1;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = 0;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = 0;
	memcpy(TableItems + index, &dword, 4); index += 4;

	memcpy(TableItems + index, item3, sizeof item3); index += sizeof item3;
	dword = 40;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = -1;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = 0;
	memcpy(TableItems + index, &dword, 4); index += 4;
	dword = 0;
	memcpy(TableItems + index, &dword, 4); index += 4;
}
int app_find(char *name) {
	tinfo task;
	int index = 0;
	int len;
	char buf[16];
	int val,i;
	int my_pid = GetPID();

	for (i = 1;; i++) {
		memset(&task, 0, sizeof task);
		TaskList(i, &task, 0);
		if (task.Name[0] == 0) break;
		if (task.Name[0] == '?') continue;
		if (task.Name[0] == '-') continue;
		len = strlen(task.Name);
		if (len == 0) break;
		if (strcmp(task.Name, name) == 0 && task.PID != my_pid) {
			return task.PID;
		}
	}
	return 0;
}

////////////////////////////


int Client_Color = 0xD4D0C8;
int bttn_y_coord;
char mem[16];
int bline_x_size;

void Redraw() {
	int bttns_xsize = 100;
	int bttns_ysize = 22;
	int list_x_size = ((win_sizes & 0xFFFF0000) >> 16)-30;
	int list_y_size = (win_sizes & 0xFFFF) - 80;

	if (focus == 1)
		WinID = Draw_StdWindow(win_coords, win_sizes, "Task Manager", win_buttons);
	else
		Begin_xDraw(WinID);


	bttn_y_coord = ((win_sizes & 0xFFFF) - 30);

	Create_StdButton((10 << 16) + bttn_y_coord, bttns_xsize * 65536 + bttns_ysize, "Kill", 1, 2);
	Create_StdButton((10 + 103 << 16) + bttn_y_coord, bttns_xsize * 65536 + bttns_ysize, "Update", 2, 2);


	FillListData();

	ListBox(10, 30, list_x_size, list_y_size, TableItems, ListData, 50, callFromListBox); 
	WriteText(10, bttn_y_coord - 15, 1, 4, "Memory Usage (KBytes): ");

	bline_x_size = ((win_sizes & 0xFFFF0000) >> 16) - 10 - 120 - 10;
	Draw_BLine(10 + 120, bttn_y_coord - 15, bline_x_size, 20, Client_Color, WinID);
	WriteText(10 + 120, bttn_y_coord - 15, 1, 4, mem);

	DefaultButton(50 + 4);
	End_of_redraw();
}


void Maximize() {
	int x = 0, y = 0;
	Get_WinParams(WinID, sysmsg);
	memcpy(saved_sizes, sysmsg, sizeof saved_sizes);
	Get_XYSize(sysmsg);
	memcpy(&x, sysmsg, 4);
	memcpy(&y, sysmsg + 4, 4);

	win_coords = 0;
	win_sizes = (x << 16) + y;

	win_buttons = win_buttons | 8;

	Redraw();
}

void Restore() {
	win_buttons = win_buttons_def;
	memcpy(&win_coords, saved_sizes, 4);
	memcpy(&win_sizes, saved_sizes + 4, 4);
	Redraw();
}


void Entry()
{
	int another_id = app_find(my_name);
	int min_xsize = 245 + list_offset;
	int min_ysize = ((0x16 + 16 * 2) + 27 + (list_offset * 2)) + down_bttns;
	int x_size = min_xsize + (list_offset);
	int y_size = 310 + (list_offset * 2);
	int x_coord = 130;
	int y_coord = 130;
	int pids_old = 0;
	int mem_old = 0;
	char evnt[0x20];
	int pids;
	int pages;

	if (another_id != 0)  {
		SendMessage(another_id, EventID_Focus << 8, 0, 0);
		ExitProcess(0);
	}

	win_coords = x_coord * 65536 + y_coord;
	win_sizes = x_size * 65536 + y_size;

	win_buttons = win_buttons_def;
	fillTableItems();

	Redraw();

	while (1) {
		ReceiveMessage(evnt);
		if (evnt[9] == EventID_LostFocus) focus = 0;
		if (evnt[9] == EventID_Focus) focus = 1;
		StdHandler(evnt);

		// update interactive info
		pids = GetPIDsCount();
		if (pids != pids_old) {
			Update();
			pids_old = pids;
		}
		pages = GetUsagePages() * 4;
		
		if (mem_old != pages) {
			int bline_x_size = ((win_sizes & 0xFFFF0000) >> 16) - 10 - 120 - 10;
			memset(mem, 0, sizeof mem);
			itoa(pages, mem, 10);
			Draw_BLine(10 + 120, bttn_y_coord - 15, bline_x_size, 20, Client_Color, WinID);
			WriteText(10 + 120, bttn_y_coord - 15, 1, 4, mem);
			mem_old = pages;
		}

		if (evnt[9] == EventID_Redraw) {
			win_buttons = win_buttons_def;

			memcpy(&win_coords, evnt + 0x0C, 4);
			memcpy(&win_sizes, evnt + 0x10, 4);

			Redraw();
		}
		if (evnt[9] == EventID_Kbd) {
			if (evnt[0x0C + 1] == 1) SendMessage(0, EventID_Close << 8, 0, 0);
		}
		if (evnt[9] == EventID_Maximize) Maximize();
		if (evnt[9] == EventID_Restore) Restore();
		if (evnt[9] == EventID_Ctrl3 && evnt[8] == 1) {
			memset(evnt, 0, sizeof evnt);
			evnt[0x09] = EventID_Kbd;
			evnt[0x0C + 1] = 0x53;			// scan code DEL
			DefaultButton(50 + 4);
			StdHandler(evnt);
		}
		if (evnt[9] == EventID_Ctrl3 && evnt[8] == 2) {
			Update();
		}


	}
}