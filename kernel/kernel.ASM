 ;==================================================================;
 ;=  Module Name:  KERNEL.ASM                                      =;
 ;=                                                                =;
 ;=  Module Description: Kernel                                    =;
 ;=                                                                =;
 ;=  Author:  Kreoton    11 Jul 2005                               =;
 ;=                                                                =;
 ;=  Revision History:                                             =;
 ;=                                                                =;
 ;=      Date         Version                                      =;
 ;=                                                                =;
 ;=      11/07/05     0.1                                          =;
 ;=        + Created                                               =;
 ;=      29/07/05     0.2                                          =;
 ;=        + Fast call                                             =;
 ;=      04/11/05     0.3                                          =;
 ;=        + Exceptions handler                                    =;
 ;=      02/08/22     0.4                                          =;
 ;=        + Power optimized                                       =;
 ;=      08/08/22     0.8.1 (Santa Catarina)                       =;
 ;=        + API GetSystemTicks                                    =;
 ;=        + API debuginfo                                         =;
 ;=                                                                =;
 ;=                                                                =;
 ;=  Compile with FASM 1.64+                                       =;
 ;=                                                                =;
 ;==================================================================;

machine686 = 0

format PE DLL at DefImageBase on '..\include\mx_stub.exe'
entry start

;include "..\Include\macros.inc"
include "..\Include\data.inc"
include "..\Include\const.inc"
include "..\Include\struct.inc"

display ENDL,"Product Version: ",ProductVersion

section '.text' code readable executable

  start:

  ; Message to log

        mov     edx,step0
        mov     bp,4
        call    [sprint]

  ; Set SysCall...

    ; INT

        mov     edi,1
        mov     eax,SYSCALL_IntNum
        mov     si,S_CODE
        mov     ebx,SysCall_INT
        mov     dl,0
        mov     cl,D_Trap or D_DPL3
        call    [Add_Gate]

    ; SysEnter/SysExit

if machine686 = 1

        mov     eax,0
        cpuid
        bt      edx,11
        jnc     no_SEP

        mov     edx,step1
        mov     bp,4
        call    [sprint]

    ; Code Selector
        mov     eax,S_CODE
        mov     edx,0
        mov     ecx,MSR_SYSENTER_CS
        wrmsr

    ; ESP0
        mov     eax,0x80000000-0x1000
        mov     edx,0
        mov     ecx,MSR_SYSENTER_ESP
        wrmsr

    ; EIP
        mov     eax,SysCall_FastCall
        mov     edx,0
        mov     ecx,MSR_SYSENTER_EIP
        wrmsr

      no_SEP:

end if

        mov     ebx,cr3           
        mov     ebp,P_Present or P_Write or P_Ring3
        mov     ecx,1
        call    [VMM_mallocSys]
        mov     [ring3_page],edx

        mov     ebx,cr3
        mov     ebp,P_Present or P_Write
        mov     ecx,1
        call    [VMM_mallocSys]
        mov     [HookSyscallList],edx
                    
        mov     ebx,cr3
        mov     ebp,P_Present or P_Write
        mov     ecx,1
        call    [VMM_mallocSys]
        mov     [HookExitSyscallList],edx
                    
        mov     ebx,cr3
        mov     ebp,P_Present or P_Write
        mov     ecx,1
        call    [VMM_mallocSys]
        mov     [HookTaskKillList],edx

        mov     ebx,cr3
        mov     ebp,P_Present or P_Write
        mov     ecx,0x1
        call    [VMM_mallocSys]
        mov     [DPC_Stack],edx

	; Set PDE for mallocSys shared system memory
;        mov     ebx,cr3
;        mov     ebp,P_Present or P_Write
;        mov     ecx,0x2400
;        call    [VMM_mallocSys]
;        call    [VMM_Free]

        mov     ebx,cr3           
        mov     ebp,P_Present or P_Write or P_Ring3
        mov     ecx,1
        call    [VMM_mallocSys]
        mov     [con_tmp_page],edx



     ; exceptions

; PF not here
        mov     edi,1
        mov     eax,Exception.PF
        mov     ebx,Handler_PF
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
;        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.TS
        mov     ebx,Handler_TS
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
;        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.DE
        mov     ebx,Handler_DE
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.DB
        mov     ebx,Handler_DB
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.NMI
        mov     ebx,Handler_NMI
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.BP
        mov     ebx,Handler_BP
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.OF
        mov     ebx,Handler_OF
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.BR
        mov     ebx,Handler_BR
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]    
        mov     edi,1
        mov     eax,Exception.UD
        mov     ebx,Handler_UD
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]     
        mov     edi,1
        mov     eax,Exception.NM
        mov     ebx,Handler_NM
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.DF
        mov     ebx,Handler_DF
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.EF
        mov     ebx,Handler_EF
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.NP
        mov     ebx,Handler_NP
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.SS
        mov     ebx,Handler_SS
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.GP
        mov     ebx,Handler_GP
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.MF
        mov     ebx,Handler_MF
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
;        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.AC
        mov     ebx,Handler_AC
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.MC
        mov     ebx,Handler_MC
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]
        mov     edi,1
        mov     eax,Exception.XF
        mov     ebx,Handler_XF
        mov     si,S_CODE
        mov     cl, D_Trap or D_DPL3
        mov     dl,0                    ; params
        call    [Add_Gate]

        mov     eax,1
        ret     0xC



Init_kernel:

;mov eax,[0x8615ece6+0]
;call [print_hex]
;mov eax,[0x8615ece6+4]
;call [print_hex]
;mov eax,[0x8615ece6+8]
;call [print_hex]
;eip=80281533 (cr3?)
;eip=80283b8e 
;80283be7 = SysFail:
;eip=80281537 ; pop eax after reset cr3
;80274d33

;8027e95c
;8027e95f
;861527fe

;jmp $

        pusha

   ; Create thread for DPC

        mov     eax,DPCThread
        mov     esi,DPCThreadName
        call    [Create_SysThread]
        mov     [DPC_PID],edx
        call    [Add_Task]
        popa
        ret

DS_OneSize      = 0x20
             
 ;*********************************************;
 ;   "Create Mutex"                            ;
 ;---------------------------------------------;
 ;  IN  : EAX - Pointer to var                 ;
 ;  OUT : None                                 ;
 ;*********************************************;
CreateMutex:
        pusha
        pushf
        mov     edx,[os_data_PID]
                
      waiting_for_mutex:
        cli

        cmp     [eax],dword 0
        je      free_mutex
        cmp     [eax],edx
        je      my_mutex

        sti
      wait_array_free:
        call    add_into_array
        jnc     to_del_task
        jmp     wait_array_free
      to_del_task:
        call    [Del_Task]
        hlt

      free_mutex:
        cmp     [eax],edx
        je      my_mutex

        cmp     [eax],dword 0
        jne     waiting_for_mutex
        mov     [eax],edx
      my_mutex:

        popf
        popa
        ret

 ;*********************************************;
 ;   "Release mutex"                           ;
 ;---------------------------------------------;
 ;  IN  : EAX - Pointer to var                 ;
 ;  OUT : None                                 ;
 ;*********************************************;
ReleaseMutex:
        pusha
        pushf
        mov     edx,[os_data_PID]
        cmp     [eax],edx
        jne     no_release_mutex
        cli

        call    get_from_array
        cmp     edx,0
        je      no_more_task
        call    [Add_Task]
      no_more_task:
        mov     [eax],edx
           
      no_release_mutex:
        popf
        popa
        ret

;************************************************;
;   "Get first element of array"                 ;
;------------------------------------------------;
;  IN  : EAX - Pointer to array                  ;
;  OUT : EDX - Value, CF installed if no element ;
;************************************************;
get_from_array:
        push    eax ebx ecx esi edi ebp
        pushf

        add     eax,4
        cmp     [eax],dword 0
        je      no_element_in_array

        mov     edx,[eax]

        push    edx                    
        mov     ecx,(0x1000/4)-2        ; max element
      Sort_array:
        mov     edx,[eax+4]
        mov     [eax],edx
        add     eax,4
        dec     ecx
        jne     Sort_array             
        pop     edx

        popf
        pop     ebp edi esi ecx ebx eax        
        clc
        ret
      no_element_in_array:
        popf
        pop     ebp edi esi ecx ebx eax
        mov     edx,0
        stc
        ret

;************************************************;
;   "Add element into array"                     ;
;------------------------------------------------;
;  IN  : EAX - Pointer to array, EDX - Value     ;
;  OUT : CF installed if overflow                ;
;************************************************;
add_into_array:
        pusha
        pushf
        mov     ecx,(0x1000/4)-3        ; set for overflow test
      find_free_element:
        add     eax,4                   ; ++
        dec     ecx
        je      array_overflow          ; overflow?
        cmp     [eax],dword 0
        jne     find_free_element
        mov     [eax],edx               ; add!

        popf
        popa        
        clc
        ret
      array_overflow:
        popf
        popa
        stc
        ret

 ;*********************************************;
 ;   "Add DPC"                                 ;
 ;---------------------------------------------;
 ;  IN  : EBX - Code Address, all regs         ;
 ;  OUT : Random                               ;
 ;*********************************************;
Add_DPC:
        push    eax ebx
        mov     [CodeAddress],ebx

        mov     ebx,[DPC_Stack]

     ; Search free...

        push    esi
        mov     esi,0
            
        cmp     [DPC_Active],byte 0
        jne     Search_free_element_DPC

      Search_free_element_DPC:
        cmp     [ebx+esi],dword 0
        je      Free_element_DPC
        add     esi,DS_OneSize
        cmp     esi,0x1000
        jne     Search_free_element_DPC
        pop     esi
        jmp     Break_add_event_DPC

      Free_element_DPC:
        add     ebx,esi
        pop     esi

        push    edx
        mov     edx,[DPC_PID]
        call    [Add_Task]
        pop     edx
        mov     [DPC_Active],byte 1

     ; Save message to private memory

        mov     [ebx+0x04],eax
        mov     [ebx+0x08],ecx
        mov     [ebx+0x0C],edx
        mov     [ebx+0x10],esi
        mov     [ebx+0x14],edi
        mov     [ebx+0x18],ebp

        mov     eax,[CodeAddress]
        mov     [ebx+0x0],eax

        pop     ebx eax
        ret

      Break_add_event_DPC:
        pop     ebx eax
        ret

;****************************;
;       "DPC Thread"         ;
;****************************;
DPCThread:
        mov     ecx,[DPC_Stack]
        cmp     [ecx],dword 0
        je      no_msg_DPC
        cli
        mov     [Save_for_DPC],ecx
        mov     ebx,[ecx+0x00]
        mov     eax,[ecx+0x04]
        mov     edx,[ecx+0x0C]
        mov     esi,[ecx+0x10]
        mov     edi,[ecx+0x14]
        mov     ebp,[ecx+0x18]
        mov     ecx,[ecx+0x08]

        pusha
        mov     ecx,[Save_for_DPC]

     ; Clear last cell

        pusha
        mov     edi,[DPC_Stack]
        add     edi,0x1000-DS_OneSize
        mov     ecx,DS_OneSize
        mov     al,0
        rep     stosb
        popa

     ; Del event and sort array...

        mov     esi,0
      to_sort_array_DPC:
        mov     eax,[ecx+esi+0x00+DS_OneSize]
        mov     [ecx+esi+0x00],eax
        mov     eax,[ecx+esi+0x04+DS_OneSize]
        mov     [ecx+esi+0x04],eax
        mov     eax,[ecx+esi+0x08+DS_OneSize]
        mov     [ecx+esi+0x08],eax
        mov     eax,[ecx+esi+0x0C+DS_OneSize]
        mov     [ecx+esi+0x0C],eax
        mov     eax,[ecx+esi+0x10+DS_OneSize]
        mov     [ecx+esi+0x10],eax
        mov     eax,[ecx+esi+0x14+DS_OneSize]
        mov     [ecx+esi+0x14],eax
        mov     eax,[ecx+esi+0x18+DS_OneSize]
        mov     [ecx+esi+0x18],eax
        mov     eax,[ecx+esi+0x1C+DS_OneSize]
        mov     [ecx+esi+0x1C],eax
        add     esi, DS_OneSize

        cmp     esi,0x1000
        jne     to_sort_array_DPC
        popa

	cli
        call    ebx
        jmp     DPCThread

      no_msg_DPC:
        push    edx
        mov     edx,[DPC_PID]
        mov     [DPC_Active],byte 0
        pop     edx
sti
hlt
        jmp     DPCThread

                
;****************************************************************;
;     "mx Kernel API"                                            ;
;----------------------------------------------------------------;
;                                                                ;
;  Number      Description                                       ;
;                                                                ;
;  0x0000   =  -------------                                     ;
;              IN  : EBX - ----------                            ;
;                                                                ;
;                                                                ;
;                                                                ;
;****************************************************************;
SysCall_FastCall:
        push    ecx
        push    edx
        or      eax,1 shl 31
        jmp     SysCall_

SysCall_INT:
        cli
        and     eax,not (1 shl 31)
        jmp     SysCall_

SysCall_:
        push    ds
        push    es
        push    eax
        mov     ax,S_DATA
        mov     ds,ax
        mov     es,ax
        pop     eax
        push    eax

        mov     ecx,[HookSyscallList]
      CallExtHandler:
        cmp     [ecx],dword 0
        je      exit_CallExtHandler
        call    dword [ecx]
        add     ecx,4
        jmp     CallExtHandler
      exit_CallExtHandler:

 ;*********************************************;
 ;   "Shutdown"                                ;
 ;---------------------------------------------;
 ;  IN  : EBX: 1 - reset, 2 - poweroff, 3 - AXE;
 ;  OUT : None :)                              ;
 ;*********************************************;
        cmp     ax,0x4444
        jne     no_debug4444
        pusha
        mov     [0x80000000],bl
        mov     al,0xFE
        out     0x64,al
        popa
        jmp     Exit_SysCall
      no_debug4444:

DATA16_Size     = 0x1000

 ;*********************************************;
 ;   "Read data16"                             ;
 ;---------------------------------------------;
 ;  IN  : EDI - buffer (one page)              ;
 ;  OUT : None                                 ;
 ;*********************************************;
        cmp     ax,0x0016
        jne     no_debug0016
        pusha
        mov     esi,[os_data_DATA16]
        or      esi,0x80000000
        mov     ecx,DATA16_Size
        rep     movsb
        popa
        jmp     Exit_SysCall
      no_debug0016:

 ;*********************************************;
 ;   "Get count of occupied pages"             ;
 ;---------------------------------------------;
 ;  IN  : None                                 ;
 ;  OUT : ESI - Pages count                    ;
 ;*********************************************;
        cmp     ax,0x0110
        jne     no_debug0
        mov     esi,[os_data_pages]
        jmp     Exit_SysCall
      no_debug0:
                                   
 ;*********************************************;
 ;   "Get count of PIDs"                       ;
 ;---------------------------------------------;
 ;  IN  : None                                 ;
 ;  OUT : ESI - Pages count                    ;
 ;*********************************************;
        cmp     ax,0x0111
        jne     no_0111
        mov     esi,[os_data_PIDs]
        jmp     Exit_SysCall
      no_0111:
                                   
 ;*********************************************;
 ;   "For debug"                               ;
 ;---------------------------------------------;
 ;  IN  : EBX - Address                        ;
 ;  OUT : Random                               ;
 ;*********************************************;

        cmp     ax,-1
        jne     no_debug
        pusha

        mov     ecx,edx

        mov     esi,10
        mov     edi,10

        push    eax edi

        and     esi,0xFFFF
        and     edi,0xFFFF

        imul    edi,[os_data_MaxX]
        add     edi,esi
        shl     edi,2
        add     edi,[os_data_VLFB]
        mov     [edi],ecx

        pop     edi eax
        popa
        jmp     Exit_SysCall
      no_debug:
          
 ;*********************************************;
 ;   "For test exceptions"                     ;
 ;---------------------------------------------;
 ;  IN  : EBX - exception                      ;
 ;  OUT : Random                               ;
 ;*********************************************;

        cmp     ax,0x0098
        jne     no_debug2
        pusha
	db 0x8D,0xF8
	popa
        jmp     Exit_SysCall
      no_debug2:


	; clear SysFail PID
        cmp     ax,0x0097
        jne     no_debug3
        mov     [SysFail_PID],0
        jmp     Exit_SysCall
      no_debug3:


 ;*********************************************;
 ;   "Call function"                           ;
 ;---------------------------------------------;
 ;  IN  : EBX - Address                        ;
 ;  OUT : Random                               ;
 ;*********************************************;

        cmp     ax,0x0000
        jne     no_0000
        call    ebx
        jmp     Exit_SysCall
      no_0000:

 ;*********************************************;
 ;   "Get function address"                    ;
 ;---------------------------------------------;
 ;  IN  : EBX - Module, ESI - Function         ;
 ;  OUT : EBX - Address                        ;
 ;*********************************************;

        cmp     ax,0x0001
        jne     no_0001
        call    get_funct_addr
        jmp     Exit_SysCall
      no_0001:

 ;*********************************************;
 ;   "Get OS version"                          ;
 ;---------------------------------------------;
 ;  IN  : None                                 ;
 ;  OUT : EAX/ESI - ver                        ;
 ;*********************************************;

        cmp     ax,0x0002
        jne     no_0002
	mov	eax,0x00010800
	mov	esi,eax
        jmp     Exit_SysCall
      no_0002:


     ; Param regs: <EBX ESI EDI EBP>

 ;*********************************************;
 ;   "--------"                                ;
 ;---------------------------------------------;
 ;  IN  : EBX - Address, ESI - Size in bytes   ;
 ;  OUT : ESI - Allocated                      ;
 ;*********************************************;

        cmp     ax,0x00F0
        jne     no_00F0
        push    ebx esi edi ebp

        pop     ebp edi esi ebx
        jmp     Exit_SysCall
      no_00F0:

 ;*********************************************;
 ;   "VMM Allocate Virtual Region"             ;
 ;---------------------------------------------;
 ;  IN  : EBX - Address, ESI - Size in bytes   ;
 ;        EDI - Protect                        ;
 ;  OUT : ESI - Allocated                      ;
 ;*********************************************;

        cmp     ax,0x0003
        jne     no_0003
        push    ebx edi ebp

        mov     ebp,edi

        mov     eax,esi
        mov     edx,0
        mov     ecx,0x1000
        div     ecx
        cmp     edx,0
        je      align1000_1
        inc     eax
      align1000_1:
        mov     ecx,eax

        and     ebp,0xFFF               ; Control Access
        mov     edx,ebx                 ; Address                                        
        mov     ebx,cr3                 ; PTE
        call    [VMM_AllocVirtualRegion]

        pop     ebp edi ebx
        jmp     Exit_SysCall
      no_0003:

 ;*********************************************;
 ;   "VMM Map Physical Region"                 ;
 ;---------------------------------------------;
 ;  IN  : EBX - Address, ESI - Size in bytes   ;
 ;        EDI - Physical address+access        ;
 ;  OUT : ESI - mapped                         ;
 ;*********************************************;

;        cmp     ax,0x0004
;        jne     no_0004
;        push    ebx edi ebp
;
;        mov     ebp,edi
;
;        mov     eax,esi
;        mov     edx,0
;        mov     ecx,0x1000
;        div     ecx
;        cmp     edx,0
;        je      align1000_2
;        inc     eax
;      align1000_2:
;        mov     ecx,eax
;
;        mov     eax,ebp        
;        mov     edx,ebx                 ; Address                                        
;        mov     ebx,cr3                 ; PTE
;        call    [VMM_MapPhysicalRegion]
;
;        pop     ebp edi ebx
;        jmp     Exit_SysCall
;      no_0004:

 ;*********************************************;
 ;   "VMM Virtual Protect"                     ;
 ;---------------------------------------------;
 ;  IN  : EBX - Address, ESI - Size in bytes   ;
 ;        EDI - Old access*65536+New Access    ;
 ;  OUT : ESI - pages                          ;
 ;*********************************************;

        cmp     ax,0x0005
        jne     no_0005
        push    ebx edi ebp
                   
        mov     eax,esi
        mov     edx,0
        mov     ecx,0x1000
        div     ecx
        cmp     edx,0
        je      align1000_3
        inc     eax
      align1000_3:
        mov     ecx,eax

;        and     ebp,0xFFF               ; New protect
;        and     edi,0xFFF               ; Old protect
;        shl     edi,16
;        or      ebp,edi                 ; EBP = (EDI shl 16) + EBP

        mov     ebp,edi
        
        mov     edx,ebx                 ; Address                                        
        mov     ebx,cr3                 ; PTE
        call    [VMM_VirtualProtect]

        pop     ebp edi ebx
        jmp     Exit_SysCall
      no_0005:

 ;*********************************************;
 ;   "VMM Free"                                ;
 ;---------------------------------------------;
 ;  IN  : EBX - Address, ESI - Size in bytes   ;
 ;  OUT : ESI - pages                          ;
 ;*********************************************;

        cmp     ax,0x0006
        jne     no_0006
        push    ebx edi ebp
                   
        mov     eax,esi
        mov     edx,0
        mov     ecx,0x1000
        div     ecx
        cmp     edx,0
        je      align1000_4
        inc     eax
      align1000_4:
        mov     ecx,eax

        mov     edx,ebx                 ; Address                                        
        mov     ebx,cr3                 ; PTE
        call    [VMM_Free]

        pop     ebp edi ebx
        jmp     Exit_SysCall
      no_0006:

 ;*********************************************;
 ;   "Get file address"                        ;
 ;---------------------------------------------;
 ;  IN  : ESI - File name                      ;
 ;  OUT : ESI - Address, EBX - Size            ;
 ;*********************************************;

        cmp     ax,0x0007
        jne     no_0007
                   
        call    [Get_FileAddress]

        jmp     Exit_SysCall
      no_0007:

 ;*********************************************;
 ;   "Read file from ram-disk"                 ;
 ;---------------------------------------------;
 ;  IN  : ESI - File name, EDI - Address       ;
 ;  OUT : EBX - Size                           ;
 ;*********************************************;

        cmp     ax,0x0008
        jne     no_0008
        push    ecx esi edi
                   
        call    [Get_FileAddress]
        cmp     esi,0
        je      no_readfile
        mov     ecx,ebx
        rep     movsb
      no_readfile:

        pop     edi esi ecx
        jmp     Exit_SysCall
      no_0008:

 ;*********************************************;
 ;   "malloc"                                  ;
 ;---------------------------------------------;
 ;  IN  : ESI - size                           ;
 ;  OUT : EAX - address                        ;
 ;*********************************************;

        cmp     ax,0x0009
        jne     no_0009
	mov	ebx,cr3

        mov     eax,esi
        mov     edx,0
        mov     ecx,0x1000
        div     ecx
        cmp     edx,0
        je      align1000_2
        inc     eax
      align1000_2:
        mov     ecx,eax
        mov     ebp,P_Present or P_Write or P_Ring3
	call	[VMM_malloc]
	mov	eax,edx
        jmp     Exit_SysCall
      no_0009:


 ;*********************************************;
 ;   "Create Process"                          ;
 ;---------------------------------------------;
 ;  IN  : EBX - Code address, EDI - Size,      ;
 ;        ESI - Name                           ;
 ;  OUT : EDI - PID                            ;
 ;*********************************************;

        cmp     ax,0x0010
        jne     no_0010
        push    eax ebx ecx esi ebp

        mov     ecx,edi
        mov     eax,ebx
	cmp	eax,0
	jne	old_style_call
	push	esi
        call    [Get_FileAddress]
        mov     ecx,ebx
        mov     eax,esi
	pop	esi
      old_style_call:
	mov	edi,0
	cmp	eax,0
	je	file_not_found
        call    [CreateProcessEx]
        call    [Add_Task]      
        mov     edi,edx
      file_not_found:      
        pop     ebp esi ecx ebx eax
        jmp     Exit_SysCall
      no_0010:

 ;*********************************************;
 ;   "Exit Process"                            ;
 ;---------------------------------------------;
 ;  IN  : EDI - PID                            ;
 ;  OUT : None                                 ;
 ;*********************************************;

        cmp     ax,0x0011
        jne     no_0011
        push    ebx esi ebp

    ;=== if sysfail win active ===;  
        cmp     [SysFail_PID],edi
        jne     no_sysfailWin
        mov     [SysFail_PID],0
      no_sysfailWin:
    ;===-----------------------===;

        mov     edx,edi

	cmp     edx,0
	jne     no_def_exit
	mov     edx,[os_data_PID]
      no_def_exit:

	; check process or thread?
	pusha
        call    Translate_PID
	mov	ebx,cr3
	call	[VMM_GetPhysicalAddress]
	cmp	eax,-1
	popa
	je	prepare_killing_complete		; PID not present
	pusha
        call    Translate_PID
        cmp     [edx+TD.PID_Offset],dword 0
	popa
	je	prepare_killing_complete		; PID not found

;	call	[Del_Task]

	pusha
        call    Translate_PID
        cmp     [edx+TD.BaseProcess],dword 0
	popa
	jne	is_thrd
        call    Kill_Win
	call	ExitProcess_kernel
	jmp	prepare_killing_complete
      is_thrd:
	call	ExitThread_kernel
      prepare_killing_complete:

	cmp	edi,0
	jne	no_kill_me
	sti
      last_time:
        out     0xEB,al
        jmp    last_time    
      no_kill_me:

        pop     ebp esi ebx
        jmp     Exit_SysCall

ExitProcessDPC:
	call	[Del_Task]
	call	killing_process
        call    [ExitProcess]
	ret

ExitProcess_kernel:
	pusha
	mov 	ebx,ExitProcessDPC
	call 	Add_DPC
	popa
	ret

killing_process:
	push	ecx
        mov     ecx,[HookTaskKillList]
      CallExtHandler3:
        cmp     [ecx],dword 0
        je      exit_CallExtHandler3
	pusha
        call    dword [ecx]
	popa
        add     ecx,4
        jmp     CallExtHandler3
      exit_CallExtHandler3:
	pop	ecx

	; send ConsoleExit to parent
	pusha
        call    Translate_PID
        mov     edx,[edx+TD.ParentPID]
	cmp	edx,0
	je	no_console1
        call    Translate_PID
	mov	ebx,cr3
	call	[VMM_GetPhysicalAddress]
	cmp	eax,-1				; still present?
	je	no_console1
	cmp	[edx+TD.Console],dword 0
	je	no_console1
	mov	edi,[edx+TD.PID_Offset]
	xor	ebx,ebx
	xor	esi,esi
	xor	ebp,ebp
	mov	bh, EventID_ConsoleExit
	call	send_msg
      no_console1:
	popa
	ret


      no_0011:

 ;*********************************************;
 ;   "Create Thread"                           ;
 ;---------------------------------------------;
 ;  IN  : EBX - Code address, ESI - Name       ;
 ;        EDI - Param                          ;
 ;  OUT : EDI - PID                            ;
 ;*********************************************;

        cmp     ax,0x0012
        jne     no_0012
        push    ebx esi ebp

        mov     eax,ebx
        call    [CreateThread]   
	cmp	edx,0
	je	thrd_err
        call    [Add_Task]      
      thrd_err: 
        mov     edi,edx

        pop     ebp esi ebx
        jmp     Exit_SysCall
      no_0012:

 ;*********************************************;
 ;   "Exit Thread"                             ;
 ;---------------------------------------------;
 ;  IN  : EDI - PID                            ;
 ;  OUT : None                                 ;
 ;*********************************************;

        cmp     ax,0x0013
        jne     no_0013
        push    ebx esi ebp

        mov     edx,edi
	call	ExitThread_kernel

        pop     ebp esi ebx
        jmp     Exit_SysCall


ExitThreadDPC:
	call	[Del_Task]
	call	killing_process
        call    [ExitThread]
	ret
ExitThread_kernel:
	pusha
	cmp     edx,0
	jne     no_def_exit1
	mov     edx,[os_data_PID]
      no_def_exit1:
	mov 	ebx,ExitThreadDPC
	call 	Add_DPC
	popa
	ret

      no_0013:

 ;*********************************************;
 ;   "Set focus"                               ;
 ;---------------------------------------------;
 ;  IN  : ESI - PID                            ;
 ;  OUT : None                                 ;
 ;*********************************************;

        cmp     ax,0x0020
        jne     no_0020

        jmp     Exit_SysCall
      no_0020:

 ;*********************************************;
 ;   "Get current PID"                         ;
 ;---------------------------------------------;
 ;  IN  : None                                 ;
 ;  OUT : ESI - PID                            ;
 ;*********************************************;

        cmp     ax,0x0021
        jne     no_0021
        mov     esi,[os_data_PID]
        jmp     Exit_SysCall
      no_0021:

 ;*********************************************;
 ;   "Get system tick"                         ;
 ;---------------------------------------------;
 ;  IN  : None                                 ;
 ;  OUT : ESI - Tick                           ;
 ;*********************************************;

        cmp     ax,0x0022
        jne     no_0022
        mov     esi,[os_data_Tick]
        jmp     Exit_SysCall
      no_0022:

 ;*********************************************;
 ;   "Get system tick (meos)"                  ;
 ;---------------------------------------------;
 ;  IN  : None                                 ;
 ;  OUT : ESI - Tick                           ;
 ;*********************************************;

        cmp     ax,0x0023
        jne     no_0023
        mov     esi,[os_data_Tick_meos]
        jmp     Exit_SysCall
      no_0023:

 ;*********************************************;
 ;   "Get debug info"                          ;
 ;---------------------------------------------;
 ;  IN  : EDI - buffer                         ;
 ;*********************************************;

        cmp     ax,0x0024
        jne     no_0024
        call    [debuginfo]
        jmp     Exit_SysCall
      no_0024:

 ;*********************************************;
 ;   "Send debug info"                         ;
 ;---------------------------------------------;
 ;  IN  : EDX - buffer                         ;
 ;*********************************************;

        cmp     ax,0x0025
        jne     no_0025
	mov	ebp,4
        call    [sprint]
        jmp     Exit_SysCall
      no_0025:

 ;*********************************************;
 ;   "TaskList"                                ;
 ;---------------------------------------------;
 ;  IN  : EBX - buffer                         ;
 ;*********************************************;

        cmp     ax,0x0026
        jne     no_0026
	mov	edx,ebx		; index
        call    [TaskList]
	mov	esi,eax
        jmp     Exit_SysCall
      no_0026:

 ;*********************************************;
 ;   "Set console buffer for current PID"      ;
 ;---------------------------------------------;
 ;  IN  : EDI - buffer addr                    ;
 ;  OUT : None                                 ;
 ;*********************************************;

        cmp     ax,0x0027
        jne     no_0027
	pusha
        mov     edx,[os_data_PID]
        call    Translate_PID
        mov     [edx+TD.Console],edi
	popa
        jmp     Exit_SysCall
      no_0027:


 ;*********************************************;
 ;   "Sleep (IRQ0)"                            ;
 ;---------------------------------------------;
 ;  IN  : ESI - sleep IRQ0 count               ;
 ;*********************************************;

        cmp     ax,0x0029
        jne     no_0029
        add     esi,[os_data_Tick]

      waitIRQ0:
	sti
	hlt
        cmp     esi,[os_data_Tick]
	ja	waitIRQ0

        jmp     Exit_SysCall
      no_0029:

ES_OneSize      = 0x20

 ;*********************************************;
 ;   "IPC_SendMessage"                         ;
 ;---------------------------------------------;
 ;  IN  : EDI - PID, EBX:ESI:EBP - Message     ;
 ;  OUT : Carry installed - error & EDI = 0    ;
 ;*********************************************;

        cmp     ax,0x0030
        jne     no_0030
        call    send_msg
        jmp     Exit_SysCall
      no_0030:  

 ;*********************************************;
 ;   "IPC_ReceiveMessage"                      ;
 ;---------------------------------------------;
 ;  IN  : None                                 ;
 ;  OUT : EDI - PID, EBX:ESI:EBP - Message     ;
 ;*********************************************;

        cmp     ax,0x0031
        jne     no_0031
        call    ReceiveMessage
        jmp     Exit_SysCall
      no_0031:             

 ;*********************************************;
 ;   "IPC_WaitMessage"                         ;
 ;---------------------------------------------;
 ;  IN  : None                                 ;
 ;  OUT : EDI - PID, EBX:ESI:EBP - Message     ;
 ;*********************************************;

        cmp     ax,0x0032
        jne     no_0032
        call    WaitMessage
        jmp     Exit_SysCall
     no_0032:

 ;*********************************************;
 ;   "Console :: Put"                          ;
 ;---------------------------------------------;
 ;  IN  : ESI - buf                            ;
 ;  OUT : None                                 ;
 ;*********************************************;

        cmp     ax,0x0035
        jne     no_0035

	; send ConsolePut to parent
	pusha
	mov     edx,[os_data_PID]
        call    Translate_PID
        mov     edx,[edx+TD.ParentPID]
	cmp	edx,0
	je	no_console
        call    Translate_PID
	mov	ebx,cr3
	call	[VMM_GetPhysicalAddress]
	cmp	eax,-1				; still present?
	je	no_console
	cmp	[edx+TD.Console],dword 0
	je	no_console

	push	esi
	mov	ecx,0
      strlen1:					; strlen of sending string
	lodsb
	cmp	al,0
	je	exit_strlen
	inc	ecx
	cmp	ecx,0xFFF
	je	exit_strlen
	jmp	strlen1
      exit_strlen:
	pop	esi
	cmp	ecx,0
	je	no_console

	; copy buf to parent space
	pusha
	mov	ebx,cr3
	mov	edi,[edx+TD.Console]
        mov     edx,[edx+tss.cr3]

	; calc tail
	push	eax ecx
	mov	ecx,0
	mov	eax,cr3
	mov	cr3,edx
      .strlen2:					; strlen of sending string
	cmp	[edi],byte 0
	je	.exit_strlen2
	inc	edi
	inc	ecx
	cmp	ecx,0xFFF
	je	.exit_strlen2
	jmp	.strlen2
      .exit_strlen2:
	mov	cr3,eax
	pop	ecx eax

	; TODO: not good multi console apps solution! why? now Copy_VirtToVirt work no good
	pusha
 	mov	edi,[con_tmp_page]

	; wait for free over put?
      .waiting:
	cmp	[edi],byte 0
	je	.no_wait
	hlt
	jmp	.waiting
      .no_wait:

	rep	movsb
	mov	al,0
	stosb
	popa
	mov	esi,[con_tmp_page]
	mov	eax,cr3
	mov	cr3,edx
	push	eax esi
	rep	movsb
	mov	al,0
	stosb
	pop	esi eax
	mov	cr3,eax		; return to app cr3 space
	mov	[esi],byte 0				; now over put can do
	;call	[Copy_VirtToVirt]
	popa

	mov	edi,[edx+TD.PID_Offset]
	xor	ebx,ebx
	xor	ebp,ebp
	mov	bh, EventID_ConsolePut
	call	send_msg

      no_console:
	popa

        jmp     Exit_SysCall
     no_0035:

 ;*********************************************;
 ;   "Get screen params"                       ;
 ;---------------------------------------------;
 ;  IN  : None                                 ;
 ;  OUT : ESI - MaxX, EDI - MaxY               ;
 ;*********************************************;

        cmp     ax,0x0100
        jne     no_0100
        mov     esi,[os_data_MaxX]
        mov     edi,[os_data_MaxY]
        jmp     Exit_SysCall
      no_0100:


PID_present:
	pusha
	call	Translate_PID
	mov	ebx,cr3
	call	[VMM_GetPhysicalAddress]
	cmp	eax,-1
	je	not_present
	cmp	[edx+TD.PID_Offset],dword 0
	je	not_present
	jmp 	present
      not_present:
	mov	eax,1
	cmp	eax,0
	popa
	ret
      present:
	cmp	eax,eax
	popa
	ret



; IN  : EDX - PID
; OUT : EDX - Address of PID
Translate_PID:
        dec     edx
        imul    edx,TD.Size
        add     edx,TD.Address
        ret

ReceiveMessage:
        cli
        mov     [os_data_OneTask],dword 0

        mov     ecx,IPC_Address
        cmp     [ecx],dword 0
        je      no_msg
        mov     edi,[ecx+0x00]
        mov     ebx,[ecx+0x04]
        mov     esi,[ecx+0x08]
        mov     ebp,[ecx+0x0C]

        pusha

     ; Del event and sort array...

        mov     esi,0
      to_sort_array:
        mov     eax,[ecx+esi+0x00+ES_OneSize]
        mov     [ecx+esi+0x00],eax
        mov     eax,[ecx+esi+0x04+ES_OneSize]
        mov     [ecx+esi+0x04],eax
        mov     eax,[ecx+esi+0x08+ES_OneSize]
        mov     [ecx+esi+0x08],eax
        mov     eax,[ecx+esi+0x0C+ES_OneSize]
        mov     [ecx+esi+0x0C],eax
        add     esi,ES_OneSize

        cmp     esi,0x1000
        jne     to_sort_array
        
        popa 
        ret
      no_msg:
        mov     ebx,0
        mov     esi,0
        mov     ebp,0
sti
hlt
        ret

WaitMessage:
      loop_waitmsg:
        mov     [os_data_OneTask],dword 0
        push    ecx
        mov     ecx,IPC_Address
        cmp     [ecx],dword 0
        pop     ecx
        jne     ReceiveMessage
        mov     edx,[os_data_PID]
        mov     [os_data_OneTask],dword 0
	cli
        call    [Del_Task]
	sti
;        call    [Scheduler]
        jmp     loop_waitmsg


Exit_SysCall:
        pop     eax

        mov     ecx,[HookExitSyscallList]
      CallExtHandler2:
        cmp     [ecx],dword 0
        je      exit_CallExtHandler2
        call    dword [ecx]
        add     ecx,4
        jmp     CallExtHandler2
      exit_CallExtHandler2:
      
        pop     es
        pop     ds
        test    eax,1 shl 31
        je      from_int
        pop     edx
        pop     ecx
        sti
        SysExit
      from_int:
        iret

; IN  : EAX - Code Address
HookSyscall:
        pusha

        push    eax
        mov     esi,[HookSyscallList]
      Search_free_hookcell:
        lodsd
        cmp     eax,0
        jne     Search_free_hookcell
        sub     esi,4
        pop     eax

        mov     edi,esi
        stosd

        popa
        ret                  

; IN  : EAX - Code Address
HookExitSyscall:
        pusha

        push    eax
        mov     esi,[HookExitSyscallList]
      Search_free_hookcell2:
        lodsd
        cmp     eax,0
        jne     Search_free_hookcell2
        sub     esi,4
        pop     eax

        mov     edi,esi
        stosd

        popa
        ret

; IN  : EAX - Code Address
HookTaskKill:
        pusha

        push    eax
        mov     esi,[HookTaskKillList]
      Search_free_hookcell3:
        lodsd
        cmp     eax,0
        jne     Search_free_hookcell3
        sub     esi,4
        pop     eax

        mov     edi,esi
        stosd

        popa
        ret


;*********************************************;
;   "IPC_SendMessage"                         ;
;---------------------------------------------;
;  IN  : EDI - PID, EBX:ESI:EBP - Message     ;
;  OUT : Carry installed - error & EDI = 0    ;
;*********************************************;
send_msg:    
        cmp     edi,0
        je      no_pid_for_mess
        pusha

        mov     edx,edi
        call    [Add_Task]

        mov     edx,edi
        call    Translate_PID

        mov     edx,[edx+tss.cr3]
        cmp     edx,0
        je      Break_add_event

        mov     eax,cr3
        cmp     eax,edx
        je      no_reset_cr3
        mov     cr3,edx
      no_reset_cr3:
        push    eax
        mov     ecx, IPC_Address

     ; Search free...

        push    esi
        mov     esi,0

      Search_free_element:
        cmp     [ecx+esi],dword 0
        je      Free_element
        add     esi,ES_OneSize
        cmp     esi,0x1000
        jne     Search_free_element
        pop     esi
        jmp     Break_add_event

      Free_element:
        add     ecx,esi
        pop     esi

     ; Save message to private memory

        mov     eax,[os_data_PID]
        mov     [ecx+0x00],eax
        mov     [ecx+0x04],ebx
        mov     [ecx+0x08],esi
        mov     [ecx+0x0C],ebp

        pop     eax
        mov     cr3,eax

        popa
      no_pid_for_mess:
        ret

      Break_add_event:
        pop     eax
        mov     cr3,eax     
        popa
        mov     edi,0
        ret

 ;*********************************************;
 ;   "Get function address"                    ;
 ;---------------------------------------------;
 ;  IN  : EBX - Module, ESI - Function         ;
 ;  OUT : EBX - Address                        ;
 ;*********************************************;
get_funct_addr:
        push    eax ecx edx esi edi ebp

        mov     edx,ebx
        mov     ecx,esi

        mov     eax,edx
        push    ecx
        mov     ecx,ExportSysInfo
      Search_DLL:

        mov     edx,eax

        and     ecx,not 1111b
        cmp     [ecx+0x00],dword 0
        jne     no_dll_
        cmp     [ecx+0x10],dword 0
        jne     no_dll_   
        jmp     no_funct
      no_dll_:

      cmp_one_dll:
        mov     bl,[edx]
        cmp     bl,'a'
        jb      no_lcase2
        cmp     bl,'z'
        ja      no_lcase2
        sub     bl,' '
      no_lcase2:
        inc     edx
 
        cmp     [ecx],bl
        jne     search_dll_next
        inc     ecx
        cmp     bl,0
        jne     cmp_one_dll
                
        jmp     search_dll_ok
      search_dll_next:
        add     ecx,0x10
        jmp     Search_DLL
      search_dll_ok:
        pop     eax

        and     ecx,not 1111b

    ; Search name

        push    eax ecx edx esi edi ebp

        mov     edx,eax

      Search_f:
        mov     ebx,[ecx]
        cmp     ebx,0
        je      no_F

        pusha
        mov     ebx,0
        add     ecx,4
      cmp_one_f:
        mov     al,[edx]
        mov     ah,[ecx]  

        cmp     al,ah
        jne     no_F2
        inc     ebx
        inc     ecx
        inc     edx
        
        cmp     al,0
        jne     cmp_one_f
        jmp     yes_F
      no_F2:
        popa        

        add     ecx,0x10
        jmp     Search_f

      no_F:
        mov     ebx,0
        jmp     no_F_
      yes_F:
        popa
      no_F_:
        pop     ebp edi esi edx ecx eax


        jmp     yes_funct
      no_funct:
        pop     ecx
        mov     ebx,0
      yes_funct:
        pop     ebp edi esi edx ecx eax
        ret

Handler_DE:
        mov     [ExDescription],Ex0
        jmp     SysFail
Handler_DB:
        mov     [ExDescription],Ex1
        jmp     SysFail
Handler_NMI:
        mov     [ExDescription],Ex2
        jmp     SysFail
Handler_BP:
        mov     [ExDescription],Ex3
        jmp     SysFail
Handler_OF:
        mov     [ExDescription],Ex4
        jmp     SysFail
Handler_BR:
        mov     [ExDescription],Ex5
        jmp     SysFail            
Handler_UD:
        mov     [ExDescription],Ex6
        jmp     SysFail
Handler_NM:
        mov     [ExDescription],Ex7
        jmp     SysFail
Handler_DF:
        add     esp,4
        mov     [ExDescription],Ex8
        jmp     SysFail
Handler_EF:
        mov     [ExDescription],Ex9
        jmp     SysFail
Handler_TS:
        mov     [ExDescription],ExA
        jmp     SysFail
Handler_NP:
        add     esp,4
        mov     [ExDescription],ExB
        jmp     SysFail
Handler_SS:
        add     esp,4
        mov     [ExDescription],ExC
        jmp     SysFail
Handler_GP:
        mov     [ExDescription],ExD
        add     esp,4
        jmp     SysFail
Handler_PF:

;cli
;mov eax,cr2
;call [print_hex]
;mov     eax,[os_data_PID]
;call [print_hex]
;jmp $

        popa
        pop     es
        pop     ds

        mov     [ExDescription],ExE
        jmp     SysFail
Handler_MF:
        mov     [ExDescription],Ex10
        jmp     SysFail
Handler_AC:
        mov     [ExDescription],Ex11
        add     esp,4
        jmp     SysFail
Handler_MC:
        mov     [ExDescription],Ex12
        jmp     SysFail
Handler_XF:
        mov     [ExDescription],Ex19
        jmp     SysFail


SysFail:
        push    fs
        push    gs
        push    ss
        push    es
        push    ds
        pushf
        pusha

        mov     ax,S_DATA
        mov     ds,ax
        mov     es,ax
        mov     ss,ax

        mov     ebx,esp

        call    Print_SysFail


        popa
        popf
        pop     ds
        pop     es
        add     esp,4
        pop     gs
        pop     fs
        ret

; IN  : EBX - Regs
Print_SysFail:
        pusha
        cmp     [SysFail_PID],0
        jne     already_showen
        mov     esi,sysfail_filename
        push    ebx
        call    [Get_FileAddress]
;        cmp     esi,0
;        je      sysfailbox_not_found
        mov     ecx,ebx
        mov     eax,esi
        mov     esi,sysfail_ProcessName
        call    [CreateProcessEx]
        pop     ebx
        mov     [SysFail_PID],edx
        call    [Add_Task]


        mov     eax,[ebx+4* 7]                  ; EAX
        mov     edi,sys_fail_text1+4+14*0
        call    hex
        mov     eax,[ebx+4* 4]                  ; EBX
        mov     edi,sys_fail_text1+4+14*1
        call    hex
        mov     eax,[ebx+4* 6]                  ; ECX
        mov     edi,sys_fail_text1+4+14*2
        call    hex
        mov     eax,[ebx+4* 5]                  ; EDX
        mov     edi,sys_fail_text1+4+14*3
        call    hex

        mov     eax,[ebx+4* 1]                  ; ESI
        mov     edi,sys_fail_text2+4+14*0
        call    hex
        mov     eax,[ebx+4* 0]                  ; EDI
        mov     edi,sys_fail_text2+4+14*1
        call    hex
        mov     eax,[ebx+4* 2]                  ; EBP
        mov     edi,sys_fail_text2+4+14*2
        call    hex
        mov     eax,[ebx+4* 3]                  ; ESP
        mov     edi,sys_fail_text2+4+14*3
        call    hex

        mov     eax,[ebx+4* 14]                 ; EIP
pusha
        mov     edx,[ebx+4* 14]

        mov     eax,[edx+0]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+6],ax
        mov     eax,[edx+1]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+9],ax
        mov     eax,[edx+2]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+12],ax
        mov     eax,[edx+3]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+15],ax
        mov     eax,[edx+4]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+18],ax
        mov     eax,[edx+5]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+21],ax
        mov     eax,[edx+6]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+24],ax
        mov     eax,[edx+7]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+27],ax
        mov     eax,[edx+8]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+30],ax
        mov     eax,[edx+9]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+33],ax
        mov     eax,[edx+10]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+36],ax
        mov     eax,[edx+11]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+39],ax
        mov     eax,[edx+12]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+42],ax
        mov     eax,[edx+13]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+45],ax
        mov     eax,[edx+14]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+48],ax
        mov     eax,[edx+15]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+51],ax
        mov     eax,[edx+16]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code+54],ax

        mov     [sys_fail_code+56],byte 0


        mov     eax,[edx+17]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+6],ax
        mov     eax,[edx+18]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+9],ax
        mov     eax,[edx+19]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+12],ax
        mov     eax,[edx+20]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+15],ax
        mov     eax,[edx+21]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+18],ax
        mov     eax,[edx+22]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+21],ax
        mov     eax,[edx+23]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+24],ax
        mov     eax,[edx+24]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+27],ax
        mov     eax,[edx+25]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+30],ax
        mov     eax,[edx+26]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+33],ax
        mov     eax,[edx+27]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+36],ax
        mov     eax,[edx+28]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+39],ax
        mov     eax,[edx+29]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+42],ax
        mov     eax,[edx+30]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+45],ax
        mov     eax,[edx+31]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+48],ax
        mov     eax,[edx+32]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+51],ax
        mov     eax,[edx+33]
        mov     edi,hexbuffer
        call    hex
        mov     ax,[edi+6]
        mov     [sys_fail_code2+54],ax

        mov     [sys_fail_code2+56],byte 0

popa

        mov     edi,sys_fail_text3+4+14*0
        call    hex          
        mov     eax,[ebx+4* 8]                  ; EFLAGS
        mov     edi,sys_fail_text3+21
        call    hex
                   
        mov     eax,cr0                         ; CR0
        mov     edi,sys_fail_text4+4+14*0
        call    hex
        mov     eax,cr2                         ; CR2
        mov     edi,sys_fail_text4+4+14*1
        call    hex
        mov     eax,cr3                         ; CR3
        mov     edi,sys_fail_text4+4+14*2
        call    hex

        mov     eax,[ebx+4* 15]                 ; CS
        mov     edi,hexbuffer
        call    hex
        mov     eax,[edi+4]
        mov     [sys_fail_text5+3+9*0],eax
        mov     eax,[ebx+4* 9]                  ; DS
        mov     edi,hexbuffer
        call    hex
        mov     eax,[edi+4]
        mov     [sys_fail_text5+3+9*1],eax
        mov     eax,[ebx+4* 10]                 ; ES
        mov     edi,hexbuffer                     
        call    hex
        mov     eax,[edi+4]
        mov     [sys_fail_text5+3+9*2],eax
        mov     eax,[ebx+4* 11]                 ; SS
        mov     edi,hexbuffer                     
        call    hex
        mov     eax,[edi+4]
        mov     [sys_fail_text5+3+9*3],eax
        mov     eax,[ebx+4* 12]                 ; GS
        mov     edi,hexbuffer                     
        call    hex
        mov     eax,[edi+4]
        mov     [sys_fail_text5+3+9*4],eax
        mov     eax,[ebx+4* 13]                 ; FS
        mov     edi,hexbuffer                     
        call    hex
        mov     eax,[edi+4]
        mov     [sys_fail_text5+3+9*5],eax
                       
        mov     edi,sys_fail_textn+22
        mov     ecx,TD.Name_Size-4
        mov     al,' '
        rep     stosb
        mov     edx,[os_data_PID]

        call    Translate_PID
        lea     esi,[edx+TD.Name_Offset]
        mov     edi,sys_fail_textn+22           ; Task Name
        mov     ecx,TD.Name_Size-4
      copy_tname:
        mov     al,[esi]
        mov     [edi],al
        inc     esi
        inc     edi
        cmp     al,0        
        je      exit_copy_tname
        dec     ecx
        cmp     ecx,0
        jne     copy_tname
      exit_copy_tname:


        mov     edi,Ex_text
        mov     ecx,32
        mov     al,' '
        rep     stosb

        mov     esi,[ExDescription]
        mov     edi,Ex_text                     ; Exception Description
        mov     ecx,32
      copy_descr:
        mov     al,[esi]
        mov     [edi],al
        inc     esi
        inc     edi
        cmp     al,0        
        je      exit_copy_descr
        dec     ecx
        cmp     ecx,0
        jne     copy_descr
      exit_copy_descr:

;;;;;;;;;;;;;;;;;;;;;

        pusha
        mov     edi,[ring3_page]
        mov     esi,sys_fail_text
        mov     ecx,4096
        mov     ax,ds
        mov     es,ax
        rep     movsb
        popa

        mov     esi,[ring3_page]
        mov     ebx,EventID_IPC shl 8
        mov     edi,[SysFail_PID]
        cmp     edi,0
        je      sysfailbox_not_found
        call    send_msg

        mov     edx,0
        call    Kill_Win

mov edx,[os_data_PID]
call    [Del_Task]
	call	ExitProcess_kernel
;        call    [ExitProcess]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        sti
      hlt_fail:


	hlt
        jmp     hlt_fail

      sysfailbox_not_found:
        popa
        iret
      already_showen:
	sti
	hlt
	jmp already_showen

; IN  : EDX - PID
Kill_Win:
        pusha
        cmp     edx,0
        jne     no_def_killwin
        mov     edx,[os_data_PID]

      no_def_killwin:
        call    Translate_PID
        mov     edx,[edx+TD.TWinID]
        cmp     edx,0
        je      no_killwin
        pushf
        cli
        ; Kill
        mov     ebx,GUI_Name
        mov     esi,GUI_Kill_Window
        call    get_funct_addr
        cmp     ebx,0
        je      funct_not_found1
        call    ebx
      funct_not_found1:
        ; Redraw
        mov     ebx,GUI_Name
        mov     esi,GUI_Redraw
        call    get_funct_addr
        call    ebx
        popf
      no_killwin:
        popa
        ret

hexbuffer       db '00000000'
;****************************************************************************;
;*  "Translate value to hex."                                               *;
;*--------------------------------------------------------------------------*;
;*   INPUT:   EAX - hex, EDI - Buffer                                       *;
;*   OUTPUT:  None                                                          *;
;****************************************************************************;
hex:
        pusha
        xchg    edx,eax
        mov     ecx,8
      Translate_hex:
        rol     edx,4
        mov     al,dl
        and     al,1111b
        cmp     al,10
        sbb     al,0x69
        das
        stosb
        loop    Translate_hex
        popa
        ret



EventID_Redraw          = 1
EventID_Focus           = 2
EventID_LostFocus       = 3
EventID_Close           = 4
EventID_MouseEvent      = 5
EventID_Ctrl0           = 10
EventID_Ctrl1           = 11
EventID_Ctrl2           = 12
EventID_Ctrl3           = 13
EventID_Maximize        = 14
EventID_Restore         = 15
EventID_DoubleClick     = 16
EventID_Kbd             = 20
EventID_IPC             = 50
EventID_ConsoleExit     = 70
EventID_ConsolePut      = 71
EventID_ConsoleGet      = 72

section '.data' data readable writeable
        ExDescription           dd 0
    ExX          db 'Unknown!',0
    Ex0          db 'Division by zero.',0
    Ex1          db 'Trace.',0
    Ex2          db 'Non maskable interrupt.',0
    Ex3          db '<','.','> Break point.',0
    Ex4          db 'Into detected overflow.',0
    Ex5          db 'Bound range exceeded.',0
    Ex6          db 'Invalid opcode.',0
    Ex7          db 'CPU extension not available.',0
    Ex8          db 'Double fault!.',0
    Ex9          db 'CPU extension protection fault.',0
    ExA          db 'Invalid TSS.',0
    ExB          db 'Segment not present.',0
    ExC          db 'Stack fault.',0
    ExD          db 'General protection fault.',0
    ExE          db 'Page fault.',0
    Ex10         db 'Copreocessor error.',0
    Ex11         db 'Aligment error.',0
    Ex12         db 'Machine check exciption.',0
    Ex19         db 'SSE fault.',0


        GUI_Name                db 'GUI.DLL',0
        GUI_Redraw              db 'Redraw',0
        GUI_Kill_Window         db 'Kill_Window',0
        sys_fail_text:
        sys_fail_textn:         db ' System failure from:                               ',0
        Ex_text                 db '                                                      ',0
        sys_fail_text1:         db 'EAX=00000000  EBX=00000000  ECX=00000000  EDX=00000000',0
        sys_fail_text2:         db 'ESI=00000000  EDI=00000000  EBP=00000000  ESP=00000000',0
        sys_fail_text5:         db 'CS=0000  DS=0000  ES=0000  SS=0000  GS=0000  FS=0000',0
        sys_fail_text4:         db 'CR0=00000000  CR2=00000000  CR3=00000000',0
        sys_fail_text3:         db 'EIP=00000000  EFLAGS=00000000',0
        sys_fail_code:          db 'code:                                                  ',0
				db ' '
        sys_fail_code2:         db '                                                       ',0
;        sys_fail_here:          db 'in module 

                                dw 0

        ring3_page              dd 0
        con_tmp_page		dd 0
        sysfail_filename        db 'sysboard.exe',0
        sysfail_ProcessName     db 'System Failure',0
        SysFail_PID             dd 0
        step0                   db 'Loading KERNEL',0
        step1                   db 'Setting SYSENTER/SYSEXIT for syscalls',0
        DPCThreadName           db 'DPC_Thread',0
        HookSyscallList         dd 0
        HookExitSyscallList     dd 0
	HookTaskKillList	dd 0
        DPC_Stack               dd 0
        CodeAddress             dd 0
        DPC_Active              db 0
        DPC_PID                 dd 0
        Save_for_DPC            dd 0
        
section '.idata' import data readable writeable
;
; Import functions:
;

  dd RVA tdt_table,0,0,RVA tdt_name,RVA tdt_table
  dd RVA mm_table,0,0,RVA mm_name,RVA mm_table
  dd RVA tm_table,0,0,RVA tm_name,RVA tm_table
  dd RVA mxvdm_table,0,0,RVA mxvdm_name,RVA mxvdm_table
  dd RVA subsys_table,0,0,RVA subsys_name,RVA subsys_table
  dd RVA loadctrl_table,0,0,RVA loadctrl_name,RVA loadctrl_table
  dd 0,0,0,0,0

  loadctrl_table:
    sprint                      dd RVA _sprint
    to_tail                     dd RVA _to_tail
    print_hex                   dd RVA _print_hex                    
    debuginfo                   dd RVA _debuginfo
    dd 0

  _sprint                       dw 0
    db 'sprint',0
  _to_tail                      dw 0
    db 'to_tail',0
  _print_hex                    dw 0
    db 'print_hex',0
  _debuginfo                    dw 0
    db 'debuginfo',0

  loadctrl_name                 db 'LOADCTRL.DLL',0
                
  tdt_table:
    Add_Gate                    dd RVA _Add_Gate
    Add_Descriptor              dd RVA _Add_Descriptor
    reset_idtr                  dd RVA _reset_idtr
    reset_gdtr                  dd RVA _reset_gdtr
    Find_FreeElement            dd RVA _Find_FreeElement
    Del_Element                 dd RVA _Del_Element
    dd 0

  tm_table:
    CreateProcess               dd RVA _CreateProcess
    ExitProcess                 dd RVA _ExitProcess
    CreateThread                dd RVA _CreateThread
    ExitThread                  dd RVA _ExitThread
    Add_Task                    dd RVA _Add_Task
    Del_Task                    dd RVA _Del_Task
    RegNewPID                   dd RVA _RegNewPID
    Create_SysThread            dd RVA _Create_SysThread
    Scheduler                   dd RVA _Scheduler
    TaskList                    dd RVA _TaskList
    dd 0

  mm_table:
    Get_FileAddress             dd RVA _Get_FileAddress
    Get_TotalMemory             dd RVA _Get_TotalMemory
    Get_FreePage                dd RVA _Get_FreePage
    VMM_Free                    dd RVA _Get_Free
    GetPDE                      dd RVA _GetPDE
    GetPTE                      dd RVA _GetPTE
    SetPTE                      dd RVA _GetPTE
    VMM_AllocVirtualRegion      dd RVA _VMM_AllocVirtualRegion
    Occupy_FreePage             dd RVA _Occupy_FreePage
    Copy_PhysToPhys             dd RVA _Copy_PhysToPhys
    Copy_VirtToVirt             dd RVA _Copy_VirtToVirt
    FreeUserMemory              dd RVA _FreeUserMemory
    VMM_mallocSys               dd RVA _VMM_mallocSys
    VMM_malloc                  dd RVA _VMM_malloc
    VMM_VirtualProtect          dd RVA _VMM_VirtualProtect
    VMM_GetPhysicalAddress      dd RVA _VMM_GetPhysicalAddress
    dd 0

  mm_name                       db 'MM.DLL',0
  tm_name                       db 'TM.DLL',0
  tdt_name                      db 'TDT.DLL',0
  mxvdm_name                    db 'MXVDM.DLL',0
  subsys_name                   db 'SUBSYS.DLL',0

  _Get_FileAddress              dw 0
    db 'Get_FileAddress',0
  _Get_TotalMemory              dw 0
    db 'Get_TotalMemory',0
  _Get_FreePage                 dw 0
    db 'Get_FreePage',0
  _Get_Free                     dw 0
    db 'VMM_Free',0
  _GetPTE                       dw 0
    db 'GetPTE',0
  _GetPDE                       dw 0
    db 'GetPDE',0
  _SetPTE                       dw 0
    db 'SetPTE',0
  _SetPDE                       dw 0
    db 'SetPDE',0
  _VMM_AllocVirtualRegion       dw 0
    db 'VMM_AllocVirtualRegion',0
  _Occupy_FreePage              dw 0
    db 'Occupy_FreePage',0
  _Copy_PhysToPhys              dw 0
    db 'Copy_PhysToPhys',0
  _Copy_VirtToVirt              dw 0
    db 'Copy_VirtToVirt',0
  _FreeUserMemory               dw 0
    db 'FreeUserMemory',0
  _VMM_mallocSys                dw 0
    db 'VMM_mallocSys',0
  _VMM_malloc                   dw 0
    db 'VMM_malloc',0
  _VMM_VirtualProtect           dw 0
    db 'VMM_VirtualProtect',0
  _VMM_GetPhysicalAddress       dw 0
    db 'VMM_GetPhysicalAddress',0


  _CreateProcess                dw 0
    db 'CreateProcess',0
  _ExitProcess                  dw 0
    db 'ExitProcess',0
  _CreateThread                 dw 0
    db 'CreateThread',0
  _ExitThread                   dw 0
    db 'ExitThread',0
  _Add_Task                     dw 0
    db 'Add_Task',0
  _Del_Task                     dw 0
    db 'Del_Task',0
  _RegNewPID                    dw 0
    db 'RegNewPID',0
  _Create_SysThread             dw 0
    db 'Create_SysThread',0
  _Scheduler                    dw 0
    db 'Scheduler',0
  _TaskList                     dw 0
    db 'TaskList',0


  _Add_Gate                     dw 0
    db 'Add_Gate',0
  _Add_Descriptor               dw 0
    db 'Add_Descriptor',0
  _reset_idtr                   dw 0
    db 'reset_idtr',0
  _reset_gdtr                   dw 0
    db 'reset_gdtr',0
  _Find_FreeElement             dw 0
    db 'Find_FreeElement',0
  _Del_Element                  dw 0
    db 'Del_Element',0

  mxvdm_table:
    CreateV86Task               dd RVA _CreateV86Task
    dd 0

  _CreateV86Task                dw 0
    db 'CreateV86Task',0

  subsys_table:
    CreateProcessEx             dd RVA _CreateProcessEx
    dd 0

  _CreateProcessEx              dw 0
    db 'CreateProcessEx',0

section '.edata' export data readable

num_of_functions        = 11

  dd 0,0,0,RVA my_name,1
  dd num_of_functions,num_of_functions,RVA addresses_table,RVA names_table,RVA ordinal_table

  addresses_table:
    dd RVA HookSyscall
    dd RVA HookExitSyscall
    dd RVA HookTaskKill
    dd RVA Add_DPC
    dd RVA Init_kernel
    dd RVA send_msg
    dd RVA ReceiveMessage
    dd RVA WaitMessage
    dd RVA Handler_PF
    dd RVA CreateMutex
    dd RVA ReleaseMutex
    
  names_table:
    dd RVA _HookSyscall
    dd RVA _HookExitSyscall
    dd RVA _HookTaskKill
    dd RVA _Add_DPC
    dd RVA _Init_kernel
    dd RVA _send_msg
    dd RVA _ReceiveMessage
    dd RVA _WaitMessage
    dd RVA _Handler_PF
    dd RVA _CreateMutex
    dd RVA _ReleaseMutex
  ordinal_table:
    dw 0,1,2,3,4,5,6,7,8,9,0xA,0xB,0xC,0xD,0xE,0xF,0x10,0x11,0x12,0x13,0x14
    dw 0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F,0x20,0x21,0x22

  my_name               db 'KERNEL.DLL',0

  _HookSyscall          db 'HookSyscall',0
  _HookExitSyscall      db 'HookExitSyscall',0
  _HookTaskKill         db 'HookTaskKill',0
  _Add_DPC              db 'Add_DPC',0
  _Init_kernel          db 'Init_kernel',0
  _send_msg             db 'send_msg',0
  _ReceiveMessage       db 'ReceiveMessage',0
  _WaitMessage          db 'WaitMessage',0
  _Handler_PF           db 'PageFault',0
  _CreateMutex          db 'CreateMutex',0
  _ReleaseMutex         db 'ReleaseMutex',0

include '%fasminc%\win32ax.inc'

section '.rsrc' resource data readable

  ; resource directory

  directory RT_ICON,icons,\
            RT_GROUP_ICON,group_icons,\
            RT_VERSION,versions

  ; resource subdirectories

  resource icons,\
           1,LANG_NEUTRAL,icon_data

  resource group_icons,\
           17,LANG_NEUTRAL,main_icon

  resource versions,\
           1,LANG_NEUTRAL,version

  icon main_icon,icon_data,'..\include\mx.ico'

  versioninfo version,\
          VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,LANG_ENGLISH+SUBLANG_DEFAULT,0,\
          'FileDescription','Miraculix Kernel',\
          'FileVersion','0.8.1',\
          'OriginalFilename','KERNEL.DLL',\
          'InternalName','kernel.dll',\
          'SpecialBuild',SpecialBuild,\
          'ProductName',ProductName,\
          'ProductVersion',ProductVersion,\
          'LegalCopyright',LegalCopyright,\
          'CompanyName',CompanyName,\
          'Comments',rsrcComments,\
          'LegalTrademarks',LegalTrademarks

section '.reloc' fixups data readable discardable
