;
;  Resource:
;
Site                    equ 'www.miraculix.ru'
OSName                  equ 'Miraculix'
ProductVersion          equ "0.81"
ProductName             equ OSName,' Operating System'
LegalCopyright          equ 'Copyright © Kreoton, 2003-2022'
CompanyName             equ 'Kreoton Development Group'
LegalTrademarks         equ 'MX'
SpecialBuild            equ ''
rsrcComments            equ 'You may download new version here: ',Site

DefImageBase            = 0x100000

VER_NUM           equ '0.81'
VER_DATE          equ '06 Aug 2022'
OS_NAME           equ 'Miraculix OS'
MYNAME            equ 'Kreoton'


  D_Reserved1                   = 00000b
  D_FreeTSS16                   = 00001b
  D_LDT                         = 00010b
  D_BusyTSS16                   = 00011b
  D_CALL16                      = 00100b
  D_Task                        = 00101b
  D_int16                       = 00110b
  D_Trap16                      = 00111b
  D_Reserved2                   = 01000b
  D_FreeTSS                     = 01001b
  D_Reserved3                   = 01010b
  D_BusyTSS                     = 01011b
  D_CALL                        = 01100b
  D_Reserved4                   = 01101b
  D_INT                         = 01110b
  D_Trap                        = 01111b

  D_Code                        = 11000b
  D_Data                        = 10000b
  D_Stack                       = 10100b
  D_RW                          = 10010b

  D_DPL0                        = 00000000b
  D_DPL1                        = 00100000b
  D_DPL2                        = 01000000b
  D_DPL3                        = 01100000b

  D_bits16                      = 0000000000000000b
  D_bits32                      = 0100000000000000b
  D_Page_limit                  = 1000000000000000b

  S_RPL0                        = 000b
  S_RPL1                        = 001b
  S_RPL2                        = 010b
  S_RPL3                        = 011b
  S_GDT                         = 000b
  S_LDT                         = 100b

  TSS_link                      = 0x00
  TSS_esp0                      = 0x04
  TSS_ss0                       = 0x08
  TSS_esp1                      = 0x0C
  TSS_ss1                       = 0x10
  TSS_esp2                      = 0x14
  TSS_ss2                       = 0x18
  TSS_cr3                       = 0x1C
  TSS_eip                       = 0x20
  TSS_eflags                    = 0x24
  TSS_eax                       = 0x28
  TSS_ecx                       = 0x2C
  TSS_edx                       = 0x30
  TSS_ebx                       = 0x34
  TSS_esp                       = 0x38
  TSS_ebp                       = 0x3C
  TSS_esi                       = 0x40
  TSS_edi                       = 0x44
  TSS_es                        = 0x48
  TSS_cs                        = 0x4C
  TSS_ss                        = 0x50
  TSS_ds                        = 0x54
  TSS_fs                        = 0x58
  TSS_gs                        = 0x5C
  TSS_ldt                       = 0x60
  TSS_TaskFlags                 = 0x64
  TSS_IO                        = 0x66

  F_VIP                         = 100000000000000000000b
  F_VIF                         = 010000000000000000000b
  F_AlignmentMode               = 001000000000000000000b
  F_V86                         = 000100000000000000000b
  F_IOPL3                       = 000000011000000000000b
  F_IOPL2                       = 000000010000000000000b
  F_IOPL1                       = 000000001000000000000b
  F_IOPL0                       = 000000000000000000000b
  F_Int                         = 000000000001000000000b

  CR0_Pagination                = 10000000000000000000000000000000b
  CR0_CacheDisable              = 01000000000000000000000000000000b
  CR0_NoWrInCache               = 00100000000000000000000000000000b
  CR0_AlignmentMode             = 00000000000001000000000000000000b
  CR0_WritePage                 = 00000000000000010000000000000000b
  CR0_NE                        = 00000000000000000000000000100000b
  CR0_TS                        = 00000000000000000000000000001000b
  CR0_EmulSoproc                = 00000000000000000000000000000100b
  CR0_MP286Wait                 = 00000000000000000000000000000010b
  CR0_Protected                 = 00000000000000000000000000000001b

  CR3_PageCacheDisable          = 10000b
  CR3_PageWrTable               = 01000b

 ; FXSave/FXRstor
  CR4_FastStore                 = 1000000000b         ; FSR
  CR4_RDPMC_AllRings            = 0100000000b         ; PMC
  CR4_PageGlobalEnable          = 0010000000b         ; PGE
 ; Machine Check Exception
  CR4_MachineCheck              = 0001000000b         ; MCE
  CR4_A36Enable                 = 0000100000b         ; PAE
  CR4_Page4M                    = 0000010000b         ; PSE
 ; Disable DR4..DR5
  CR4_NoDebugPort               = 0000001000b         ; DE
  CR4_RDTSC_Ring0Only           = 0000000100b         ; TSD
  CR4_VIFEnable                 = 0000000010b         ; PVI
  CR4_VIFforV86                 = 0000000001b         ; VME

 ; Pages flag
  P_Present                     = 000000000001b
  P_Write                       = 000000000010b
  P_Ring3                       = 000000000100b
  P_WriteThrough                = 000000001000b
  P_CacheDisable                = 000000010000b
  P_Access                      = 000000100000b
  P_Written                     = 000001000000b
  P_BigSize                     = 000010000000b
  P_GlobalTLB                   = 000100000000b
  P_Mapped                      = 001000000000b

 ;'''''''''''''''''''''''

  MSR_TSC                       = 0x00000010
  MSR_MTRRcap                   = 0x000000FE
  MSR_SYSENTER_CS               = 0x00000174
  MSR_SYSENTER_ESP              = 0x00000175
  MSR_SYSENTER_EIP              = 0x00000176
  MSR_MCG_CAP                   = 0x00000179
  MSR_MCG_STATUS                = 0x0000017A
  MSR_MCG_CTL                   = 0x0000017B
  MSR_DebugCtl                  = 0x000001D9
  MSR_LastBranchFromIP          = 0x000001DB
  MSR_LastBranchToIP            = 0x000001DC
  MSR_LastExceptionFromIP       = 0x000001DD
  MSR_LastExceptionToIP         = 0x000001DE
  MSR_EFER                      = 0xC0000080

;=======================================================;
;===============[ Miraculix ]===========================;
;=======================================================;
  


  StartSystemMemory             = 0x80000000

  LDT_Address                   = 0x72000000;0x80114000
  IPC_Address                   = 0x71000000
  MemMap_Addr                   = 0x80060000
  GDT_Address                   = 0x80080000
  GDT_Size                      = 0xFFFF-1
  IDT_Address                   = 0x80090000
  IDT_Size                      = 0xFF*8-1
  KrnlStack_Address             = 0x80093000
  KrnlStack_Size                = 0x4000
  ExportSysInfo                 = 0x80099000
  RAMD_Address                  =   0x200000
  RAMD_RootDirAddr              = 0x8009E000
  RAMD_RootDir                  = 0x9E00
  System_PDE                    = 0x91000
  System_PTE                    = 0x92000
  Start_SystemMemory            = 0x60000
  End_SystemMemory              = 0x380000
  vmm_tmp                       = 0x80110000
  DriversMemorySpace            = 0x86130000
  SYSCALL_IntNum                = 0x90
  VTLFB_PTE                     = 0x57000
  DMA_Reserved                  = 0x58000
  VTLFB_vaddr                   = 0xB0000000

;;;;;;;;;;;;;;;;;;;; OLD ;;;;;;;;;
  MinESP                        = - 0xF

  TSS_Size                      = (0xE0+0x20+2+(0xFFFF/8))-1
  AppTSS_Offset                 = 0x1000-0x200
  PID_Size                      = 0x10
  CR3System                     = 0x1000              ; First
  os_stack_addr                 = 0x7FFFFFFF
  mx_Int_Table                  = 0x80000600
  PTE_Table                     = 0x80000A00
  Inhibitors_Table              = 0x80000E00
  CR3System_virt                = 0x80001000
  TSS_Address                   = 0x80041200
  PDT_Address                   = 0x80045000
  IDT_ijumps                    = 0x80046000
  IDT_Address0                  = 0x80047000
  IDT_ijumps0                   = 0x80048000
  FAT_DataSegment               = 0x80080000
  Names_Address                 = 0x80088000
  Names_Size                    = 0x2000


  os_data                       = 0x80098000
  os_data_size                  = 0x1000

  os_data_GDT_Reg               = os_data + 0x0000
  os_data_IDT_Reg               = os_data + 0x0008
  os_data_InitEIP               = os_data + 0x0010
  os_data_DATA16                = os_data + 0x0014
  os_data_Startup               = os_data + 0x0018
  os_data_StartSystemMemory     = os_data + 0x001C
  os_data_PID                   = os_data + 0x0020
  os_data_LDTR                  = os_data + 0x0024
  os_data_GraphMode             = os_data + 0x0026
  os_data_MaxX                  = os_data + 0x0028
  os_data_MaxY                  = os_data + 0x002C
  os_data_BPP                   = os_data + 0x0030
  os_data_LFB                   = os_data + 0x0034
  os_data_VLFB                  = os_data + 0x0038
  os_data_Tick                  = os_data + 0x003C
  os_data_MouseSpace            = os_data + 0x0040
  os_data_VTLFB                 = os_data + 0x0044
  os_data_tmpX                  = os_data + 0x0048
  os_data_tmpY                  = os_data + 0x004C
  os_data_OneTask               = os_data + 0x0050
  os_data_screen                = os_data + 0x0054
  os_data_BPSL                  = os_data + 0x0058
  os_data_FDDFlag               = os_data + 0x005C
  os_data_pages                 = os_data + 0x0060
  os_data_Tick_meos             = os_data + 0x0064
  os_data_DriversMemorySpaceOff = os_data + 0x0068
  os_data_MaxPID                = os_data + 0x006C
  os_data_debug                 = os_data + 0x0070
  os_data_PIDs                  = os_data + 0x0074

  Main_Memory_Map_Addr          = 0x80100000
;  App_Video                    = 0x80380000
  Page_Table_App                = 0x49000
  IPC_Data                      = 0x80700000

  D16_RAM                       = 0x00

  M_Forbidden                   = 0xFF
  M_System                      = 0xFE
  M_NoRAM                       = 0xFD
  M_Free                        = 0x00
  
  FPID_Waiting                  = 00000001b
  FPID_Killing                  = 00000010b
  FPID_RealTime                 = 00000100b

  SYSCALL_INT0                  = 0x91

  API_drv                       = 0x00
  API_CreateProcess             = 0x10
  API_SetFocus                  = 0x11
  API_RealTime                  = 0x12
  API_GetStatus                 = 0x13
  API_Execute                   = 0x14
  API_RAMFileAddr               = 0x20
  API_ReadRAMFile               = 0x21
  API_GetMem                    = 0x22
  API_LocxMemory                = 0x23
  API_RAMRoot                   = 0x24
  API_FreeMem                   = 0x25
  API_GetEntryDrv               = 0x30
  API_SetInt                    = 0x31
  API_RegisterDrv               = 0x32
  API_GetEIP                    = 0x33
  API_WakeUp                    = 0x34
  API_SendMessage               = 0x35
  API_GetMessage                = 0x36
  API_Kill                      = 0x44
  API_Sleep                     = -0x2
  API_Exit                      = -0x1 

  Wait_1Sec                     = 100

  Free_memory                   = 0x700000
  Max_Process                   = 125



 ; Ring0
  S_CODE                        = 0x01 shl 3   or  S_GDT  or  S_RPL0
  S_DATA                        = 0x02 shl 3   or  S_GDT  or  S_RPL0

 ; Ring3
  S_CODE_App                    = 0x03 shl 3   or  S_GDT  or  S_RPL3
  S_DATA_App                    = 0x04 shl 3   or  S_GDT  or  S_RPL3

 ; Ring1
  S_CODE1                       = 0x05 shl 3   or  S_GDT  or  S_RPL1
  S_DATA1                       = 0x06 shl 3   or  S_GDT  or  S_RPL1

 ; Ring2
  S_CODE2                       = 0x07 shl 3   or  S_GDT  or  S_RPL2
  S_DATA2                       = 0x08 shl 3   or  S_GDT  or  S_RPL2
        

  S_CALL                        = 0x01 shl 3   or  S_GDT  or  S_RPL0
  S_STACK                       = 0x04 shl 3   or  S_GDT  or  S_RPL0
;  S_DATA_App                    = 0x05 shl 3   or  S_GDT  or  S_RPL3
;  S_CODE_App                    = 0x06 shl 3   or  S_GDT  or  S_RPL3
  S_STACK_App                   = 0x07 shl 3   or  S_GDT  or  S_RPL3
  S_TSS_null                    = 0x08 shl 3   or  S_GDT  or  S_RPL0
  S_TSS_Scheduller              = 0x09 shl 3   or  S_GDT  or  S_RPL0
  S_Task                        = 0x0A shl 3   or  S_GDT  or  S_RPL3
  S_TrapTSS                     = 0x0B shl 3   or  S_GDT  or  S_RPL0
  S_CALL0                       = 0x0C shl 3   or  S_GDT  or  S_RPL0
  S_FirstTask                   = 0x0E shl 3   or  S_GDT  or  S_RPL3

  debug                         = 1

  ENDL          equ 0xD,0xA

macro ddd {
        mov     al,0xFE
        out     0x64,al
            }

char_delay      = 3;0000
sprint_delay    = 5;0000

