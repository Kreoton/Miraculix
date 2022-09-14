 ;==================================================================;
 ;=  Module Name:  MX32.ASM                                        =;
 ;=                                                                =;
 ;=  Module Description: Miraculix API                             =;
 ;=                                                                =;
 ;=  Author:  Kreoton    15 Jul 2005                               =;
 ;=                                                                =;
 ;=  Revision History:                                             =;
 ;=                                                                =;
 ;=      Date         Version                                      =;
 ;=                                                                =;
 ;=      15/07/05     1.0                                          =;
 ;=        + Created                                               =;
 ;=      29/07/05     1.2                                          =;
 ;=        + Fast call                                             =;
 ;=      26/08/22     1.3                                          =;
 ;=        + Wait/Receive/SendMessage & StdHandler for C           =;
 ;=                                                                =;
 ;=                                                                =;
 ;=  Compile with FASM 1.64+                                       =;
 ;=                                                                =;
 ;==================================================================;

format PE DLL GUI 4.0; at DefImageBase on '..\include\mx_stub.exe'
entry DllEntryPoint

include '%fasminc%\win32ax.inc'

;include "..\Include\macros.inc"
include "..\Include\data.inc"
include "..\Include\const.inc"
include "..\Include\struct.inc"

PanelSize               = 27

struc ListBox_info {
    .xCoord             = 0x00
    .yCoord             = 0x02
    .xSize              = 0x04
    .ySize              = 0x06
    .ItemsInfo          = 0x08
    .ListData           = 0x0C
    .ptrProc            = 0x10
    .CurState           = 0x14
    .ctrlOffset         = 0x18
    .CurElement         = 0x1C
    .ElementsAble       = 0x20
    .CurOnList          = 0x24
    .ElementOffset      = 0x28
    .DrawOffset         = 0x2C


    .One_ListElement    = 16            ; one list element y_size - CONSTs
    .MaxElements        = 0x10
    .Size               = 0x30
}
lb ListBox_info

struc bttnStruct {
    .xCoord     = 0x00
    .yCoord     = 0x02
    .xSize      = 0x04
    .ySize      = 0x06
    .Text       = 0x08
    .attr       = 0x0C
    .Size       = 0x10
}
bttn bttnStruct

bttnAttr_Forbidden      = 00000001b
bttnAttr_State          = 00000010b
bttnAttr_Button         = 00000100b
bttnAttr_Check          = 00001000b
bttnAttr_ListElement    = 00010000b
bttnAttr_TextAttr       = 00100000b

Text_LeftOffset         = 5

Bttn_Color_     = 0xD4D0C8+0x0F0F0F
Bttn_Color      = 0xD4D0C8
Bttn_Color1     = 0xFFFFFF
Bttn_Color2     = 0x333333
Bttn_Color3     = 0x808080
bttn_FontID     = 4
bttn_TextColor  = 0

x_size          = 300
y_size          = 200
x_coord         = 100
y_coord         = 100

Head_YSize      = 0x16
Head_Color      = 0x99
Head_Color2     = 0x808080

Resize_XSize    = 10
Resize_YSize    = 10
Resize_offset   = 2

Client_Color    = 0xD4D0C8

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

; Attribs:
ATTR_NoMove             = 0000000000000001b
ATTR_Top                = 0000000000000010b
ATTR_DeskTop            = 0000000000000100b
ATTR_NoCSize            = 0000000000001000b
ATTR_Unnormal           = 0000000000010000b
ATTR_MaxSize            = 0000000000100000b
ATTR_FastMenu           = 0000000001000000b

ATTR_CBttn_Close        = 0000000100000000b
ATTR_CBttn_Maximize     = 0000001000000000b
ATTR_CBttn_Minimize     = 0000010000000000b

; Reserved ctrl:
CtrlID_Moving           = 0xFF
CtrlID_CSize            = 0xFE
                   

StdCtrlBttn_yoffset     = 4
StdCtrlBttn1_xsize      = 16
StdCtrlBttn1_ysize      = 15
StdCtrlBttn1_xoffset    = 20
StdCtrlBttn2_xoffset    = 20+17
StdCtrlBttn3_xoffset    = 20+17+17



section '.text' code readable writeable executable
                                     
proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
        push    ebp

        mov     eax,0
        cpuid
        bt      edx,11
        jc      yes_SEP
        mov     [mx_SysCall_],word 0x90CD
      yes_SEP:

        mov     esi,end_of_code-DllEntryPoint
        mov     ebx,DllEntryPoint
        mov     edi,((P_Present or P_Ring3 or P_Write) shl 16) + P_Present or P_Ring3
        mov     eax,5
        call    mx_SysCall2

        mov     ebx,UFS_Name
        mov     esi,UFS_readfile
        mov     eax,1
        call    mx_SysCall2
        mov     [UFS_readfile_addr],ebx

        mov     ebx,UFS_Name
        mov     esi,UFS_files
        mov     eax,1
        call    mx_SysCall2
        mov     [UFS_files_addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Get_string_length
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Get_string_length_Addr],ebx
                     
        mov     ebx,GUI_Name
        mov     esi,GUI_Redraw
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Redraw_Addr],ebx
                     
        mov     ebx,GUI_Name
        mov     esi,GUI_Get_focusID
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Get_focusID_Addr],ebx
                     
        mov     ebx,GUI_Name
        mov     esi,GUI_ClearField
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_ClearField_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Hide_Window
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Hide_Window_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_TaskInfo2
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_TaskInfo2_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_TaskInfo
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_TaskInfo_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Get_focus
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Get_focus_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Begin_xDraw
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Begin_xDraw_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Get_WinParams
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Get_WinParams_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Get_XYSize
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Get_XYSize_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Draw_vLine
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Draw_vLine_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Draw_hLine
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Draw_hLine_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_End_of_xdraw
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_End_of_xdraw_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_End_of_redraw
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_End_of_redraw_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_sprint
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_sprint_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Kill_Window
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Kill_Window_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Draw_Picture
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Draw_Picture_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Draw_BF
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Draw_BF_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_DefineWindow
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_DefineWindow_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_DefineButton
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_DefineButton_Addr],ebx

        mov     ebx,GUI_Name
        mov     esi,GUI_Put_pixel_L3
        mov     eax,1
        call    mx_SysCall2
        mov     [GUI_Put_pixel_L3_Addr],ebx

        mov     ebx,KBD_Name
        mov     esi,KBD_GetKbd
        mov     eax,1
        call    mx_SysCall2
        mov     [KBD_GetKbd_Addr],ebx

        mov     ebx,KBD_Name
        mov     esi,KBD_GetWaitKbd
        mov     eax,1
        call    mx_SysCall2
        mov     [KBD_GetWaitKbd_Addr],ebx

        mov     ebx,CON_Name
        mov     esi,CON_PutChar
        mov     eax,1
        call    mx_SysCall2
        mov     [CON_PutChar_Addr],ebx

        mov     ebx,CON_Name
        mov     esi,CON_PrintString
        mov     eax,1
        call    mx_SysCall2
        mov     [CON_PrintString_Addr],ebx

        mov     ebx,CON_Name
        mov     esi,CON_Get_Position
        mov     eax,1
        call    mx_SysCall2
        mov     [CON_Get_Position_Addr],ebx

        mov     ebx,CON_Name
        mov     esi,CON_Set_Position
        mov     eax,1
        call    mx_SysCall2
        mov     [CON_Set_Position_Addr],ebx

        mov     ebx,CON_Name
        mov     esi,CON_PutChar2
        mov     eax,1
        call    mx_SysCall2
        mov     [CON_PutChar2_Addr],ebx

        pop     ebp
        mov     eax,TRUE
        ret
endp

proc msgbox MessageText,TitleText
	pusha
;        stdcall Get_FileAddress, msgbox_filename
;        cmp     esi,0
;        je      msgbox_not_found
;        stdcall CreateProcess, esi,ebx,msgbox_ProcessName
        stdcall CreateProcess , 0,0, msgbox_filename

        mov     ebx,[MessageText]
        call    Send_msg_to_app
        mov     ebx,[TitleText]
        call    Send_msg_to_app
                          
      msgbox_not_found:
	popa
        ret
endp

msgint:
	pusha
        mov     edi,hexbuffer
        call    hex 
	stdcall	msgbox, edi,0
	popa
	ret



; IN  : EAX - PID, EBX - string message
Send_msg_to_app:
        pusha
        cmp     ebx,0
        je      exit_find_zero_msgbox2
        cmp     [ebx],byte 0
        je      exit_find_zero_msgbox2
      Sending_msg1:
        mov     esi,[ebx]
        mov     edi,[ebx+4]
        stdcall SendMessage, eax,EventID_IPC shl 8,esi,edi

        dec     ebx
        mov     esi,0
      find_zero_msgbox:
        inc     ebx
        inc     esi
        cmp     esi,9
        je      exit_find_zero_msgbox
        cmp     [ebx],byte 0
        jne     find_zero_msgbox
        jmp     exit_find_zero_msgbox2
      exit_find_zero_msgbox:
        jmp     Sending_msg1
      exit_find_zero_msgbox2:
        stdcall SendMessage, eax,EventID_IPC shl 8,0,0
        popa
        ret

proc DefaultButton SetDefCtrl
        push    eax
        mov     eax,[SetDefCtrl]
        mov     [CurCtrl],al
        pop     eax
        ret
endp

msgbox_filename         db 'msgbox.exe',0
msgbox_ProcessName      db 'Simple MsgBox',0


item_ysize      = 18

proc ListBox x,y,xsize,ysize,items,lb_data,IDs,ProcPtr
  local ListID:DWORD, ElementsAble:DWORD, tmpENumCnt:DWORD
        pusha

        mov     eax,[x]
        mov     ebx,[y]
        mov     ecx,[xsize]
        mov     edx,[ysize]

  ;++ Draw items button...

        cmp     [items],0
        je      no_items
        pusha
        mov     esi,0
        mov     edi,eax
      drawitems_loop:

        push    esi
        imul    esi,0x20
        add     esi,[items]
        add     esi,4
        mov     ecx,[esi+0x10]
        pop     esi

        pusha
        mov     eax,esi
        add     eax,[IDs]

        imul    esi,0x20
        add     esi,[items]
        add     esi,4

        stdcall Create_StdBttn, edi,ebx,ecx,item_ysize,esi,eax,10b or bttnAttr_TextAttr
     
        popa
        add     edi,ecx 

        inc     esi
        mov     eax,[items]
        cmp     esi,[eax]
        jne     drawitems_loop
        sub     edi,[x]
        cmp     edi,[xsize]
        jbe     no_correctxsize
        mov     [xsize],edi
      no_correctxsize:
        popa        
        add     ebx,item_ysize
        sub     edx,item_ysize
        mov     ecx,[xsize]
      no_items:

  ;--

        stdcall Draw_Frame_down, eax,ebx,ecx,edx
        add     eax,2
        add     ebx,2
        sub     ecx,4
        sub     edx,4

        stdcall Draw_BLine, eax,ebx,ecx,edx,-1,[WinID]


        pusha
        mov     ebp,[items]
        call    Draw_items_color
        popa

  ;++ Calc elements

        pusha
        mov     eax,edx
        mov     ebx,lb.One_ListElement
        mov     edx,0
        div     ebx

        mov     [ElementsAble],eax
        popa        
  ;--               

  ;++ Find free cell for save ListID
                    
        pusha
        mov     eax,0
        mov     ebx,0
      find_freecell_for_lb:
        cmp     [ListInfo+ebx+lb.ListData],dword 0
        je      exit_find_freecell_for_lb
        add     ebx,lb.Size
        inc     eax
        cmp     ebx,lb.MaxElements*lb.Size
        jne     find_freecell_for_lb
     ;<!>Error

     exit_find_freecell_for_lb:
                
        pusha                           ; save global ctrl offset
        mov     eax,[IDs]
        mov     [ListInfo+ebx+lb.ctrlOffset],eax
        mov     eax,[ProcPtr]
        mov     [ListInfo+ebx+lb.ptrProc],eax
        mov     eax,[lb_data]
        mov     [ListInfo+ebx+lb.ListData],eax
        mov     eax,[items]
        mov     [ListInfo+ebx+lb.ItemsInfo],eax
        mov     eax,[ElementsAble]
        mov     [ListInfo+ebx+lb.ElementsAble],eax        
        mov     [ListInfo+ebx+lb.CurOnList],dword 0
        mov     [ListInfo+ebx+lb.ElementOffset],dword 0        
        popa

        mov     [ListID],eax
        popa
  ;--               

  ;++ Register new control element(s)

        push    eax
        mov     eax,[items]
        mov     edi,[eax]
        pop     eax
                 
        mov     [tmpENumCnt],0

      reg_new_elements_loop:
        pusha

        mov     edx,[IDs]
        add     edx,edi
        call    Translate_BID
                    
        mov     esi,lb.One_ListElement

        push    eax
        mov     [edx+bttn.xCoord],ax
        mov     [edx+bttn.yCoord],bx
        mov     [edx+bttn.xSize],cx
        mov     [edx+bttn.ySize],si
        mov     [edx+bttn.attr],dword bttnAttr_ListElement or 11b
        pop     eax

        push    eax
        mov     eax,[tmpENumCnt]
        inc     [tmpENumCnt]
        shl     eax,8                   ; mov ah,[tmpENumCnt]

        push    ebx
        mov     ebx,[ListID]
        mov     al,bl
        mov     [edx+bttn.Text],eax
        pop     ebx
        pop     eax

  ;========
  ;=  Define Button       
  ;===================
 
        pusha
        shl     eax,16
        mov     ax,bx
        shl     ecx,16
        mov     cx,si
        add     edi,[IDs]
        stdcall DefineButton, eax,ecx,0,[WinID],edi
        popa

        popa

        add     ebx,lb.One_ListElement

     ; EDI=Items?

        inc     edi
        pusha
        mov     eax,[items]
        sub     edi,[eax]
        cmp     edi,[ElementsAble]
        popa
        jb      reg_new_elements_loop
  ;--

  ;++ Draw items...

        pusha
        mov     eax,1
        mov     ecx,0
      draw_items_loop:

        mov     ebx,[ListID]
        call    Draw_item_element
        jc      exit_draw_items_loop
        inc     ecx
        mov     eax,0

        cmp     ecx,[ElementsAble]
        jne     draw_items_loop
      exit_draw_items_loop:

        popa

  ;--


        popa
        ret
endp

Draw_items_color:

  ;++ Draw items color...

        cmp     ebp,0
        je      no_items_
        pusha
        mov     esi,0
        mov     edi,eax
      drawitems_loop_:

        push    esi
        imul    esi,0x20
        add     esi,ebp
        add     esi,4
        mov     ecx,[esi+0x10]
        dec     ecx
        mov     eax,[esi+0x14]
        pop     esi

        pusha
        mov     esi,[WinID]
        or      esi,-1 shl 24
        stdcall Draw_BLine, edi,ebx,ecx,edx,eax,esi
        popa

        add     edi,ecx

        inc     esi
        mov     eax,ebp
        cmp     esi,[eax]
        jne     drawitems_loop_
        popa
      no_items_:
  ;--
        ret


; IN  : EBX - ListID, ECX - Local Button, EAX - State
; OUT : CF installed if "EOF"
Draw_item_element:
        pusha
        mov     [state_ok],0
        mov     [tmp_xoffset],0

        mov     [tmp_ListElementState],eax
        mov     [tmp_ListIndex],ecx

        mov     esi,ListInfo
        imul    ebx,lb.Size
        add     ebx,esi            

        mov     esi,[ebx+lb.ItemsInfo]
        mov     [tmp_ItemsInfo],esi

        mov     edx,[ebx+lb.ctrlOffset]
        add     edx,[esi]
        add     edx,ecx
        mov     ebp,edx
        call    Translate_BID
        mov     edi,edx
        mov     ecx,[edx+bttn.Text]
        shr     ecx,8
                   
  
  ;++ calc last zero...

        add     ecx,[ebx+lb.DrawOffset]
        mov     edx,[esi]
        imul    edx,ecx
        sub     ecx,[ebx+lb.DrawOffset]
  ;--


        mov     esi,[ebx+lb.ListData]

        push    ebx

        mov     ebx,0
        mov     ecx,0                   ; item count


      Go_to_element:
        lodsb
        cmp     al,0
        jne     no_0_items
        inc     ebx
        jmp     yes_0_items
      no_0_items:
        cmp     edx,0
        je      to_draw_item
        dec     edx

      Skip_element:
        lodsb
        cmp     al,0
        jne     Skip_element

        mov     ebx,0
      yes_0_items:         

        cmp     ebx,3
        je      eof_elements

        jmp     Go_to_element
      to_draw_item:

        cmp     [state_ok],1
        je      state_ok_
        pusha      
        mov     ecx,[WinID]
        shl     ebp,24
        or      ecx,ebp
        movzx   eax,word [edi+bttn.xCoord]
        movzx   ebx,word [edi+bttn.yCoord]
        movzx   esi,word [edi+bttn.xSize]
        movzx   edx,word [edi+bttn.ySize]

        cmp     [tmp_ListElementState],0
        je      no_state1_
        stdcall Draw_BLine, eax,ebx,esi,edx,0x80,ecx
        jmp     yes_state1_
      no_state1_:

        stdcall Draw_BLine, eax,ebx,esi,edx,-1,ecx

        mov     ebp,[tmp_ItemsInfo]
        call    Draw_items_color

      yes_state1_:
        popa
        mov     [state_ok],1
      state_ok_:

        pusha
        dec     esi
        
        movzx   eax,word [edi+bttn.xCoord]
        movzx   ebx,word [edi+bttn.yCoord]
        add     eax,[tmp_xoffset]

        mov     [tmp_ItemCnt],ecx               ; save Item count

  ;++ x = x + offset   
        mov     edx,[tmp_ItemsInfo]
        add     edx,4
        imul    ecx,32
        add     edx,ecx
        mov     edx,[edx+16]
        add     [tmp_xoffset],edx
  ;--

        mov     ecx,[WinID]
        shl     ebp,24
        or      ecx,ebp

        mov     ebp,1                           ; color
        cmp     [tmp_ListElementState],0
        je      no_state1
        mov     ebp,-1
        jmp     no_state0
      no_state1:
        pusha

        mov     edx,[tmp_ItemsInfo]
        add     edx,4
        mov     ecx,[tmp_ItemCnt]
        imul    ecx,32
        add     edx,ecx
        mov     esi,[edx+16]
        mov     ebp,[edx+20]

        movzx   ebx,word [edi+bttn.yCoord]
        movzx   edx,word [edi+bttn.ySize]
        stdcall Draw_BLine, eax,ebx,esi,edx,ebp,ecx

        popa
      no_state0:

add ebx,3
        stdcall Write_Text, eax,ebx,ebp,4,esi,ecx
        popa

        inc     ecx
        mov     eax,[tmp_ItemsInfo]             ; ECX=Items?
        cmp     [eax],ecx
        je      exit_draw_item
        jmp     Skip_element
      exit_draw_item:

        pop     ebx             
        popa
        clc
        ret

      eof_elements:
        pop     ebx
        popa
        stc
        ret


state_ok                rb 1
tmp_ItemsInfo           rd 1
tmp_ListIndex           rd 1
tmp_xoffset             rd 1
tmp_ItemCnt             rd 1
tmp_ListElementState    rd 1

; IN  : ECX - Num of list
dec_list:
        pusha
        mov     ecx,[edx+bttn.Text]
        mov     ebx,ecx
        movzx   ebx,bl

        shr     ecx,8

  ;++ Turn off last element
        mov     esi,ebx
        push    ebx
        mov     eax,ecx
        imul    ebx,lb.Size
        add     ebx,ListInfo            
        mov     ecx,[ebx+lb.CurOnList]
        dec     dword [ebx+lb.CurElement]
        cmp     ecx,0
        je      end_of_listelement_2

        cmp     dword [ebx+lb.CurOnList],0
        je      scroll_list_up
        dec     dword [ebx+lb.CurOnList]

        push    ebx
        mov     ebx,esi
        mov     eax,0
        call    Draw_item_element
        pop     ebx
        jc      end_of_listelement_2
        dec     ecx
        push    ebx
        mov     ebx,esi
        mov     eax,1
        call    Draw_item_element
        pop     ebx
        jc      end_of_listelement_2
  ;--
;        dec     [CurCtrl]

        pop     ebx
        popa
        ret                                  
      end_of_listelement_2:
        cmp     dword [ebx+lb.DrawOffset],0
        jne     scroll_list_up
        inc     dword [ebx+lb.CurElement]
        pop     ebx
        popa
        ret

      scroll_list_up:
        ;...

        cmp     dword [ebx+lb.DrawOffset],0
        je      no_updraw

        dec     dword [ebx+lb.DrawOffset]

        pusha

        stdcall Begin_xDraw, [WinID]

        mov     eax,1
        mov     ecx,0
      draw_items_loop_:

        push    ebx
        mov     ebx,esi
        call    Draw_item_element
        pop     ebx
        jc      exit_draw_items_loop_
        inc     ecx
        mov     eax,0

        cmp     ecx,[ebx+lb.ElementsAble]
        jne     draw_items_loop_
      exit_draw_items_loop_:

        call    End_of_redraw
        popa

     no_updraw:

        pop     ebx
        popa
        ret
;;;;;;;;;;;;;;;;;;;;;;;;
; IN  : ECX - Num of list
inc_list:                        

        pusha
        mov     ecx,[edx+bttn.Text]
        mov     ebx,ecx
        movzx   ebx,bl
        shr     ecx,8

  ;++ Turn off last element
        mov     esi,ebx
        push    ebx
        mov     eax,ecx
        imul    ebx,lb.Size
        add     ebx,ListInfo            

        mov     ecx,[ebx+lb.CurOnList]
        inc     dword [ebx+lb.CurElement]

        pusha
        mov     eax,[ebx+lb.CurOnList]
        inc     eax
        cmp     [ebx+lb.ElementsAble],eax
        popa
        je      scroll_list_down
      no_test_scroll:

        inc     dword [ebx+lb.CurOnList]

        push    ebx
        mov     ebx,esi
        mov     eax,0
        call    Draw_item_element
        pop     ebx
        jc      end_of_listelement_1_
        inc     ecx
        push    ebx
        mov     ebx,esi
        mov     eax,1
        call    Draw_item_element
        pop     ebx
        jc      end_of_listelement_1
  ;--
;        inc     [CurCtrl]

        pop     ebx
        popa
        ret                                  
      end_of_listelement_1:
        dec     ecx
        push    ebx
        mov     ebx,esi
        mov     eax,1
        call    Draw_item_element
        pop     ebx
      end_of_listelement_1_:
        dec     dword [ebx+lb.CurElement]
        pop     ebx
        popa
        ret                               

      scroll_list_down:

        dec     dword [ebx+lb.CurElement]
        

        inc     dword [ebx+lb.DrawOffset]

        push    ebx
        mov     ebx,esi
        mov     eax,1
        call    Draw_item_element
        pop     ebx
        jc      end_of_listelement_1_scroll

        cmp     ecx,0
        je      exit_draw_items_
        stdcall Begin_xDraw, [WinID]
      draw_items_:
        dec     ecx
        push    ebx
        mov     ebx,esi
        mov     eax,0
        call    Draw_item_element
        pop     ebx
        jc      exit_draw_items_
        cmp     ecx,0
        jne     draw_items_
      exit_draw_items_:
        call    End_of_redraw
                                                          
        inc     dword [ebx+lb.DrawOffset]
        inc     dword [ebx+lb.CurElement]
                
      end_of_listelement_1_scroll:           
        dec     dword [ebx+lb.DrawOffset]
        pop     ebx
        popa
        ret

; IN  : EDX - BID
ListElement2:ret
        pusha

        call    Translate_BID
        mov     ecx,[edx+bttn.Text]
        mov     ebx,ecx
        movzx   ebx,bl                

        shr     ecx,8

  ; save current element on list...
        pusha
        and     ecx,0xFF
        mov     [ebx+lb.CurOnList],ecx
        popa

        mov     eax,1
        call    Draw_item_element
        jc      end_of_listelement

  ;++ Turn off last element        
        push    ebx
        mov     eax,ecx
        imul    ebx,lb.Size
        add     ebx,ListInfo            
        mov     ecx,[ebx+lb.CurOnList]
        cmp     ecx,eax
        je      no_turnofflistel
        mov     [ebx+lb.CurElement],eax
        pop     ebx
        mov     eax,0
        call    Draw_item_element  
  ;--
      end_of_listelement:
        popa
        ret                                  

      no_turnofflistel:

        mov     ecx,[ebx+lb.CurElement]

  ;====================
  ; IN  : ECX - Num of element
  ;====================================
        call    dword [ebx+lb.ptrProc]
        pop     ebx
        popa
        ret

; IN  : EDX - BID
ListElement1:ret

; IN  : EDX - BID
ListElement0:ret

; IN  : EDX - BID
ListElement3:ret     

 ;*********************************************;
 ;   "Create standard button"                  ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, x_size, y_size, Text,       ;
 ;           Button ID, Flags                  ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
proc Create_StdBttn x,y,xsize,ysize,text,bid,flags
        pusha

        mov     eax,[x]
        shl     eax,16
        mov     ebx,[y]
        mov     ax,bx

        mov     ecx,[xsize]
        shl     ecx,16
        mov     edx,[ysize]
        mov     cx,dx
        
        stdcall Create_StdButton, eax,ecx,[text],[bid],[flags]

        popa
        ret
endp


proc Draw_Frame_down x,y,xsize,ysize
        pusha

        mov     eax,[x]
        mov     ebx,[y]
        mov     ecx,[xsize]
        mov     edx,[ysize]
        sub     ecx,1
        stdcall Draw_hLine, eax,ebx,ecx,[var_Bttn_Color3],[WinID]
        inc     eax
        inc     ebx
        sub     ecx,2
        stdcall Draw_hLine, eax,ebx,ecx,[var_Bttn_Color2],[WinID]

        mov     eax,[x]
        mov     ebx,[y]
        mov     ecx,[xsize]
        mov     edx,[ysize]
        sub     edx,1
        stdcall Draw_vLine, eax,ebx,edx,[var_Bttn_Color3],[WinID]
        inc     eax
        inc     ebx
        sub     edx,2
        stdcall Draw_vLine, eax,ebx,edx,[var_Bttn_Color2],[WinID]

        mov     eax,[x]
        add     eax,[xsize]
        dec     eax
        mov     ebx,[y]
        mov     ecx,[ysize]
        stdcall Draw_vLine, eax,ebx,ecx,[var_Bttn_Color1],[WinID]
        dec     eax
        add     ebx,2
        sub     ecx,4
        stdcall Draw_vLine, eax,ebx,ecx,[var_Bttn_Color],[WinID]
        mov     eax,[x]
        mov     ebx,[y]
        add     ebx,[ysize]
        dec     ebx
        mov     ecx,[xsize]
        stdcall Draw_hLine, eax,ebx,ecx,[var_Bttn_Color1],[WinID]
        dec     ebx
        add     eax,2
        sub     ecx,4
        stdcall Draw_hLine, eax,ebx,ecx,[var_Bttn_Color],[WinID]
        popa
        ret
endp



; IN  : Path, Buffer
ReadFile:
        enter   32,1
        pusha
        mov     esi,[ebp+8+(4* 0 )]
        mov     edi,[ebp+8+(4* 1 )]
        mov     eax,0
        mov     ebx,[UFS_readfile_addr]
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 2

; IN  : Path, Buffer, Num_of_file
FindFile:
        enter   32,1
        pusha
        mov     esi,[ebp+8+(4* 0 )]
        mov     edi,[ebp+8+(4* 1 )]
        mov     edx,[ebp+8+(4* 2 )]
        mov     eax,0
        mov     ebx,[UFS_files_addr]
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 3


; IN  : WinID
Hide_Window:
        enter   32,1
        pusha
        mov     edx,[ebp+8+(4* 0 )]
        mov     eax,0
        mov     ebx,[GUI_Hide_Window_Addr]
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 1

; IN  : WinID
Get_focus:
        enter   32,1
        pusha
        mov     edx,[ebp+8+(4* 0 )]
        mov     eax,0
        mov     ebx,[GUI_Get_focus_Addr]
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 1

; IN  : ESI - x & y, EDI - x_size & y_size, EDX - WinID
End_of_xdraw:
        enter   32,1
        pusha
        mov     edx,[ebp+8+(4* 2 )]
        mov     edi,[ebp+8+(4* 1 )]
        mov     esi,[ebp+8+(4* 0 )]
        rol     edi,16
        rol     esi,16
        mov     eax,0
        mov     ebx,[GUI_End_of_xdraw_Addr]
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 3

; IN  : Index, Buffer
TaskInfo:
        enter   32,1
        push    ebx ecx edx esi edi ebp
        mov     esi,[ebp+8+(4* 0 )]
        mov     edi,[ebp+8+(4* 1 )]
        mov     eax,0
        mov     ebx,[GUI_TaskInfo_Addr]
        call    mx_SysCall2
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 2

; IN  : Index, Buffer
TaskInfo2:
        enter   32,1
        push    ebx ecx edx esi edi ebp
        mov     esi,[ebp+8+(4* 0 )]
        mov     edi,[ebp+8+(4* 1 )]
        mov     eax,0
        mov     ebx,[GUI_TaskInfo2_Addr]
        call    mx_SysCall2
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 2

; IN  : Index, Buffer, Type
TaskList:
        enter   32,1
        push    ebx ecx edx esi edi ebp
        mov     ebx,[ebp+8+(4* 0 )]	; index
        mov     edi,[ebp+8+(4* 1 )]	; buf
        mov     esi,[ebp+8+(4* 2 )]	; type
        mov     eax,0x0026
        call    mx_SysCall
	mov	eax,esi
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 3

; IN  : EDX - WinID
Begin_xDraw:
        enter   32,1
        pusha
        mov     edx,[ebp+8+(4* 0 )]
        mov     eax,0
        mov     ebx,[GUI_Begin_xDraw_Addr]
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 1


; IN  : Buffer
print:
        enter   32,1
        pusha
        mov     esi,[ebp+8+(4* 0 )]
        mov     eax,0x0035
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 1

proc Get_WinParamsC WinID, buf
	pusha
	stdcall	Get_WinParams,[WinID]
	mov	edx,[buf]
	mov	[edx+0],esi
	mov	[edx+4],edi
	popa
	ret
endp

Get_WinParams:
        enter   32,1
        push    eax ebx ecx edx ebp
        mov     edx,[ebp+8+(4* 0 )]
        mov     eax,0
        mov     ebx,[GUI_Get_WinParams_Addr]
        call    mx_SysCall2
        pop     ebp edx ecx ebx eax
        leave
        ret     0x4 * 1

GetWinParams:
        push    eax ebx ecx edx ebp
        mov     edx,[WinID]
        mov     eax,0
        mov     ebx,[GUI_Get_WinParams_Addr]
        call    mx_SysCall2
        pop     ebp edx ecx ebx eax
        ret

Update_Screen:
        pusha
        mov     eax,0
        mov     ebx,[GUI_Redraw_Addr]
        call    mx_SysCall2              
        popa
        ret

Action4:
        enter   32, 1
        pusha
        mov     esi,0
        mov     edi,[ebp+8+(4* 0 )]
        mov     eax,0x11
        call    mx_SysCall
        mov     eax,edi
        popa
        leave
        ret     0x4 * 1

proc Get_XYSizeC buf
	pusha
	call	Get_XYSize
	mov	edx,[buf]
	mov	[edx+0x00],esi
	mov	[edx+0x04],edi
	popa
	ret
endp

Get_XYSize:
        push    eax ebx ecx edx ebp
        mov     eax,0
        mov     ebx,[GUI_Get_XYSize_Addr]
        call    mx_SysCall2
        sub     edi,PanelSize                ; Panel!!
        pop     ebp edx ecx ebx eax
        ret                                

; OUT : EDX - Focus
Get_focusID:
        push    eax ebx ecx esi edi ebp
        mov     eax,0
        mov     ebx,[GUI_Get_focusID_Addr]
        call    mx_SysCall2
        pop     ebp edi esi ecx ebx eax
        ret

; OUT : EAX - Timer value
GetTimer:
        push    ebx ecx edx esi edi ebp
        mov     eax,0x22
        call    mx_SysCall
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        ret

proc SleepIRQ0 time
        pusha
        mov     esi,[time]
        mov     eax,0x29
        call    mx_SysCall2
        popa
        ret
endp

proc Sleep time
        pusha
        mov     esi,[time]
	mov	eax,5
	xor	edx,edx
	div	esi
	mov	esi,eax
        mov     eax,0x29
        call    mx_SysCall2
	popa
        ret
endp

proc StdHandlerC buf
	pusha
	mov	edx,[buf]
	mov	eax,[edx+0x00]
	mov	edi,[edx+0x04]
	mov	ebx,[edx+0x08]
	mov	esi,[edx+0x0C]
	mov	ebp,[edx+0x10]
	call	StdHandler
	popa
	ret
endp

; StdButtonID:
StdBttnID_Close         = 0x80
StdBttnID_Maximize      = 0x81
StdBttnID_Minimize      = 0x82
StdBttnID_Title         = 0xFF
         
 ;*********************************************;
 ;   "Standard handler"                        ;
 ;---------------------------------------------;
 ;  INPUT  : Random                            ;
 ;  OUTPUT : Random                            ;
 ;*********************************************;
StdHandler:
        pusha                 

        cmp     bh,EventID_Redraw
        je      is_redraw
        cmp     bh,EventID_Maximize
        je      is_redraw
        cmp     bh,EventID_Restore
        je      is_redraw
        jmp     no_redraw
      is_redraw:
        pusha
        mov     edi,ListInfo
        mov     ecx,lb.Size*lb.MaxElements
        mov     al,0
        rep     stosb
        popa
      no_redraw:

        cmp     bh,EventID_Kbd
        jne     no_kbd
        pusha

        movzx   edx,byte [CurCtrl]
        call    Translate_BID
        test    [edx+bttn.attr],dword bttnAttr_ListElement
        je      no_kEvent_list

        shr     si,8

        mov     ecx,[edx+bttn.Text]

        cmp     si,0x48
        jne     no_up
        call    dec_list
      no_up:
        cmp     si,0x50
        jne     no_down
        call    inc_list
      no_down:
        cmp     si,0x47
        jne     no_home
	pusha
	mov	ecx,100
      loop_down1:
        call    dec_list
	loop 	loop_down1
	popa
      no_home:
        cmp     si,0x4F
        jne     no_end
	pusha
	mov	ecx,100
      loop_down2:
        call    inc_list
	loop 	loop_down2
	popa
      no_end:
        cmp     si,0x1C		; enter
        je      is_listenter
        cmp     si,83		; del
        je      is_listenter
        jmp     no_listenter
      is_listenter:
        pusha
        call    Translate_BID
        mov     ecx,[edx+bttn.Text]
        mov     ebx,ecx
        movzx   ebx,bl
        imul    ebx,lb.Size
        add     ebx,ListInfo            
        mov     ecx,[ebx+lb.CurOnList]

        mov     ecx,[ebx+lb.CurElement]

  ;====================
  ; IN  : ECX - Num of element
  ;====================================
	push	esi
	push	ecx
        call    dword [ebx+lb.ptrProc]

        popa
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;
      no_listenter:


      no_kEvent_list:
        
        popa
      no_kbd:


        cmp     bh,EventID_Close                ; Close
        jne     no_Event_Close
        push    [WinID]
        call    Kill_Window
        push    dword 0		; ExitCode
        call    ExitProcess
;        jmp $
      no_Event_Close:

        cmp     bh,EventID_DoubleClick          ; Double click
        jne     no_Event_DoubleClick
        cmp     bl,StdBttnID_Title
        jne     no_Title_db
        call    MaxRest_event
      no_Title_db:                     
      no_Event_DoubleClick:

        cmp     bh,EventID_Focus                ; Focus
        jne     no_Event_Focus        
        mov     [HeadColor],Head_Color
        push    [WinID]
        call    Begin_xDraw
        call    Draw_Frame  
        call    End_of_redraw

        jmp     exit_StdHandler
      no_Event_Focus:

        cmp     bh,EventID_LostFocus             ; Lost Focus
        jne     no_Event_LostFocus        
        mov     [HeadColor],Head_Color2
        push    [WinID]
        call    Begin_xDraw
        call    Draw_Frame
        call    End_of_redraw
        jmp     exit_StdHandler
      no_Event_LostFocus:


        cmp     bh,EventID_Ctrl1                ; Cursor on button
        jne     no_Event_Ctrl1
        cmp     bx,[old_EventID]
        je      no_Event_Ctrl1
        
        pusha

        pusha   
        movzx   edx,bl
        call    Translate_BID

        test    [edx+bttn.attr],dword bttnAttr_Check
        jne     std_checkbutton1
        test    [edx+bttn.attr],dword bttnAttr_Button
        jne     std_button1
        jmp     no_StdBttn1
      std_checkbutton1:
        movzx   edx,bl
        call    Draw_CheckButton1
        jmp     no_StdBttn1
      std_button1:

        mov     edi,[edx+bttn.xSize]
        mov     esi,[edx+bttn.xCoord]
        cmp     [edx+bttn.xSize],word 0
        je      no_StdBttn1
        movzx   edx,bl
        push    [WinID]
        call    Begin_xDraw
        call    Draw_StdButton1
        push    [WinID]
        push    edi
        push    esi
        call    End_of_xdraw
      no_StdBttn1:
        popa

        test    [Buttons],dword 1
        je      Close_bttn_Forbidden1
        cmp     bl,StdBttnID_Close
        je      Close_bttn_1
      Close_bttn_Forbidden1:
        test    [Buttons],dword 10b
        je      Max_bttn_Forbidden1
        cmp     bl,StdBttnID_Maximize
        je      Max_bttn_1
      Max_bttn_Forbidden1:
        test    [Buttons],dword 100b
        je      Min_bttn_Forbidden1
        cmp     bl,StdBttnID_Minimize
        je      Min_bttn_1
      Min_bttn_Forbidden1:
        jmp     no_stdbttn1

      Close_bttn_1:
        mov     esi,close2_bmp
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Close shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn1_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture
        jmp     no_stdbttn1

      Max_bttn_1:
        mov     esi,max2_bmp
        test    [Buttons],dword 1000b
        je      no_Rest1_1_
        mov     esi,rest2_bmp
      no_Rest1_1_:
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Maximize shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn2_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture
        jmp     no_stdbttn1

      Min_bttn_1:
        mov     esi,min2_bmp
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Minimize shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn3_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture
        jmp     no_stdbttn1

      no_stdbttn1:
        popa

      no_Event_Ctrl1:

        cmp     bh,EventID_Ctrl2                ; Cursor on button
        jne     no_Event_Ctrl2
        cmp     bx,[old_EventID]
        je      no_Event_Ctrl2

        mov     [CurCtrl],bl

        pusha
        movzx   edx,bl
        call    Translate_BID
        
        test    [edx+bttn.attr],dword bttnAttr_ListElement
        jne     std_listbutton2
        test    [edx+bttn.attr],dword bttnAttr_Check
        jne     std_checkbutton2
        test    [edx+bttn.attr],dword bttnAttr_Button
        jne     std_button2
        jmp     no_StdBttn2
      std_listbutton2:
        movzx   edx,bl
        call    ListElement2
        jmp     no_StdBttn2                    
      std_checkbutton2:
        movzx   edx,bl
        call    Draw_CheckButton2
        jmp     no_StdBttn2
      std_button2:
        mov     edi,[edx+bttn.xSize]
        mov     esi,[edx+bttn.xCoord]
        cmp     [edx+bttn.xSize],word 0
        je      no_StdBttn2
        movzx   edx,bl
        push    [WinID]
        call    Begin_xDraw
        call    Draw_StdButton2_
        push    [WinID]
        push    edi
        push    esi
        call    End_of_xdraw
      no_StdBttn2:
        popa

        pusha
        test    [Buttons],dword 1
        je      Close_bttn_Forbidden2
        cmp     bl,StdBttnID_Close
        je      Close_bttn_2
      Close_bttn_Forbidden2:
        test    [Buttons],dword 10b
        je      Max_bttn_Forbidden2
        cmp     bl,StdBttnID_Maximize
        je      Max_bttn_2
      Max_bttn_Forbidden2:
        test    [Buttons],dword 100b
        je      Min_bttn_Forbidden2
        cmp     bl,StdBttnID_Minimize
        je      Min_bttn_2
      Min_bttn_Forbidden2:
        jmp     no_stdbttn2

      Close_bttn_2:
        mov     esi,close3_bmp
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Close shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn1_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture
        jmp     no_stdbttn2
        
      Max_bttn_2:
        mov     esi,max3_bmp
        test    [Buttons],dword 1000b
        je      no_Rest1_3
        mov     esi,rest3_bmp
      no_Rest1_3:
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Maximize shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn2_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture
        jmp     no_stdbttn2
        
      Min_bttn_2:
        mov     esi,min3_bmp
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Minimize shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn3_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture
        jmp     no_stdbttn2
        
      no_stdbttn2:
        popa

      no_Event_Ctrl2:

        cmp     bh,EventID_Ctrl0                ; Normal state button
        jne     no_Event_Ctrl0
        cmp     bx,[old_EventID]
        je      no_Event_Ctrl0

        pusha
        movzx   edx,bl
        call    Translate_BID
        test    [edx+bttn.attr],dword bttnAttr_Check
        jne     std_checkbutton0
        test    [edx+bttn.attr],dword bttnAttr_Button
        jne     std_button0
        jmp     no_StdBttn0
      std_checkbutton0:
        movzx   edx,bl
        call    Draw_CheckButton0
        jmp     no_StdBttn0
      std_button0:
        mov     edi,[edx+bttn.xSize]
        mov     esi,[edx+bttn.xCoord]
        cmp     [edx+bttn.xSize],word 0
        je      no_StdBttn0
        movzx   edx,bl
        push    [WinID]
        call    Begin_xDraw
        call    Draw_StdButton0
        push    [WinID]
        push    edi
        push    esi
        call    End_of_xdraw
      no_StdBttn0:
        popa

        pusha
        test    [Buttons],dword 1
        je      Close_bttn_Forbidden0
        cmp     bl,StdBttnID_Close
        je      Close_bttn_0
      Close_bttn_Forbidden0:
        test    [Buttons],dword 10b
        je      Max_bttn_Forbidden0
        cmp     bl,StdBttnID_Maximize
        je      Max_bttn_0
      Max_bttn_Forbidden0:
        test    [Buttons],dword 100b
        je      Min_bttn_Forbidden0
        cmp     bl,StdBttnID_Minimize
        je      Min_bttn_0
      Min_bttn_Forbidden0:
        jmp     no_stdbttn0

      Close_bttn_0:
        mov     esi,close1_bmp
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Close shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn1_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture
        jmp     no_stdbttn0
        
      Max_bttn_0:
        mov     esi,max1_bmp

        test    [Buttons],dword 1000b
        je      no_Rest1_1
        mov     esi,rest1_bmp
      no_Rest1_1:

        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Maximize shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn2_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture
        jmp     no_stdbttn0
        
      Min_bttn_0:
        mov     esi,min1_bmp
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Minimize shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn3_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture
        jmp     no_stdbttn0
        
      no_stdbttn0:
        popa

      no_Event_Ctrl0:

        cmp     bh,EventID_Ctrl3                ; Push button
        jne     no_Event_Ctrl3     
        cmp     bx,[old_EventID]
        je      no_Event_Ctrl3

        pusha
        movzx   edx,bl
        call    Translate_BID
        test    [edx+bttn.attr],dword bttnAttr_Check
        jne     std_checkbutton3
        test    [edx+bttn.attr],dword bttnAttr_Button
        jne     std_button3
        jmp     no_StdBttn3
      std_checkbutton3:
        movzx   edx,bl
        call    Draw_CheckButton1
        call    Translate_BID
        mov     eax,1
        btc     [edx+bttn.attr],eax
        jmp     no_StdBttn3
      std_button3:
        mov     edi,[edx+bttn.xSize]
        mov     esi,[edx+bttn.xCoord]
        cmp     [edx+bttn.xSize],word 0
        je      no_StdBttn3
        movzx   edx,bl
        push    [WinID]
        call    Begin_xDraw
        call    Draw_StdButton1
        push    [WinID]
        push    edi
        push    esi
        call    End_of_xdraw
      no_StdBttn3:
        popa

        pusha
        test    [Buttons],dword 1
        je      Close_bttn_Forbidden3
        cmp     bl,StdBttnID_Close
        je      Close_bttn_3
      Close_bttn_Forbidden3:
        test    [Buttons],dword 10b
        je      Max_bttn_Forbidden3
        cmp     bl,StdBttnID_Maximize
        je      Max_bttn_3
      Max_bttn_Forbidden3:
        test    [Buttons],dword 100b
        je      Min_bttn_Forbidden3
        cmp     bl,StdBttnID_Minimize
        je      Min_bttn_3
      Min_bttn_Forbidden3:
        jmp     no_stdbttn3

      Close_bttn_3:
        mov     esi,close2_bmp
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Close shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn1_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture 
        call    GetPID
        push    dword 0
        push    dword 0
        push    dword EventID_Close shl 8
        push    eax
        call    SendMessage  
        jmp     no_stdbttn3

      Max_bttn_3:
        call    MaxRest_event
        jmp     no_stdbttn3

      Min_bttn_3:
        mov     esi,min2_bmp
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Minimize shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn3_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture

        ; Hide window...

        push    [WinID]
        call    Hide_Window

        jmp     no_stdbttn3

        jmp     no_stdbttn3
                        
      no_stdbttn3:
        popa

      no_Event_Ctrl3:


      exit_StdHandler:
        popa

        mov     [old_EventID],bx
        ret

MaxRest_event:
        pusha
        mov     esi,max2_bmp

        test    [Buttons],dword 1000b
        je      no_Rest1_2
        mov     esi,rest2_bmp
      no_Rest1_2:

        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Maximize shl 24
        push    eax
        push    esi
        push    dword StdCtrlBttn_yoffset
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn2_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture

        test    [Buttons],dword 1000b
        jne     to_Rest

      to_Max:
        call    GetPID
        push    dword 0
        push    dword 0
        push    dword EventID_Maximize shl 8
        push    eax
        call    SendMessage
        jmp     Exit_MaxRest_event
      to_Rest:
        call    GetPID
        push    dword 0
        push    dword 0
        push    dword EventID_Restore shl 8
        push    eax
        call    SendMessage
      Exit_MaxRest_event:
        popa
        ret

; EDX - BttnID
Translate_BID:
        imul    edx,bttn.Size
        add     edx,StdButtons
        ret

; EDX - BttnID
Draw_CheckButton0:
        pusha
        push    edx
        call    Translate_BID
        pop     ecx

        mov     esi,check1_bmp
        mov     eax,[edx+bttn.attr]
        and     eax,bttnAttr_State
        cmp     eax,bttnAttr_State
        je      no_StateCheck_0
        mov     esi,check4_bmp
      no_StateCheck_0:

        push    ecx
        mov     eax,7
        int     0x90
        pop     ecx
        push    ecx
        mov     eax,[WinID]
        shl     ecx,24
        or      eax,ecx
        pop     ecx

        push    eax
        push    esi
        mov     ax,[edx+bttn.yCoord]
        and     eax,0xFFFF
        push    eax
        mov     ax,[edx+bttn.xCoord]
        and     eax,0xFFFF
        push    eax
        call    Draw_Picture  

        popa
        ret

; EDX - BttnID
Draw_CheckButton1:
        pusha
        push    edx
        call    Translate_BID
        pop     ecx

        mov     esi,check2_bmp
        mov     eax,[edx+bttn.attr]
        and     eax,bttnAttr_State
        cmp     eax,bttnAttr_State
        je      no_StateCheck_1
        mov     esi,check5_bmp
      no_StateCheck_1:

        push    ecx
        mov     eax,7
        int     0x90
        pop     ecx
        push    ecx
        mov     eax,[WinID]
        shl     ecx,24
        or      eax,ecx
        pop     ecx

        push    eax
        push    esi
        mov     eax,[edx+bttn.yCoord]
        and     eax,0xFFFF
        push    eax
        mov     eax,[edx+bttn.xCoord]
        and     eax,0xFFFF
        push    eax
        call    Draw_Picture  

        popa
        ret

; EDX - BttnID
Draw_CheckButton2:
        pusha
        push    edx
        call    Translate_BID
        pop     ecx

        mov     esi,check3_bmp
        mov     eax,[edx+bttn.attr]
        and     eax,bttnAttr_State
        cmp     eax,bttnAttr_State
        je      no_StateCheck_2
        mov     esi,check6_bmp
      no_StateCheck_2:

        push    ecx
        mov     eax,7
        int     0x90
        pop     ecx
        push    ecx
        mov     eax,[WinID]
        shl     ecx,24
        or      eax,ecx
        pop     ecx

        push    eax
        push    esi
        mov     eax,[edx+bttn.yCoord]
        and     eax,0xFFFF
        push    eax
        mov     eax,[edx+bttn.xCoord]
        and     eax,0xFFFF
        push    eax
        call    Draw_Picture  

        popa
        ret          



; EDX - BttnID
Draw_StdButton0:
        pusha
        push    edx
        call    Translate_BID
        pop     ecx

  ;========
  ;=  Draw button
  ;===================

        push    ecx
        mov     eax,[WinID]
        shl     ecx,24
        or      eax,ecx
        pop     ecx
        push    eax                     ; WinID
        push    dword [var_Bttn_Color]  ; Color
        mov     bx,[edx+bttn.ySize]
        dec     bx
        push    ebx                     ; y_size
        mov     bx,[edx+bttn.xSize]
        dec     bx
        push    ebx                     ; x_size
        push    dword [edx+bttn.yCoord] ; y_coord
        push    dword [edx+bttn.xCoord] ; x_coord
        call    Draw_BLine                   

  ;========
  ;=  Draw "frame"
  ;===================

        push    eax
        push    dword [var_Bttn_Color1]
        mov     bx,[edx+bttn.xSize]
        dec     bx
        push    ebx
        push    dword [edx+bttn.yCoord]
        push    dword [edx+bttn.xCoord]
        call    Draw_hLine

        push    eax
        push    dword [var_Bttn_Color1]
        mov     bx,[edx+bttn.ySize]
        dec     bx
        push    ebx
        push    dword [edx+bttn.yCoord]
        push    dword [edx+bttn.xCoord]
        call    Draw_vLine

        push    eax
        push    dword [var_Bttn_Color2]
        push    dword [edx+bttn.xSize]
        mov     bx,[edx+bttn.yCoord]
        add     bx,[edx+bttn.ySize]
        dec     bx
        and     ebx,0xFFFF
        push    ebx
        push    dword [edx+bttn.xCoord]
        call    Draw_hLine

        push    eax
        push    dword [var_Bttn_Color2]
        push    dword [edx+bttn.ySize]
        push    dword [edx+bttn.yCoord]
        mov     bx,[edx+bttn.xCoord]
        add     bx,[edx+bttn.xSize]
        dec     bx
        and     ebx,0xFFFF
        push    ebx
        call    Draw_vLine

        push    eax
        push    dword [var_Bttn_Color3]
        mov     bx,[edx+bttn.xSize]
        sub     bx,2
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.yCoord]
        add     bx,[edx+bttn.ySize]
        dec     bx
        dec     bx
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.xCoord]
        inc     bx
        push    ebx
        call    Draw_hLine

        push    eax
        push    dword [var_Bttn_Color3]
        mov     bx,[edx+bttn.ySize]
        sub     bx,2
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.yCoord]
        inc     bx
        push    ebx
        mov     bx,[edx+bttn.xCoord]
        add     bx,[edx+bttn.xSize]
        dec     bx
        dec     bx
        and     ebx,0xFFFF
        push    ebx
        call    Draw_vLine
                
  ;========
  ;=  Print text
  ;===================

     ; calc center

        push    dword bttn_FontID
        push    dword [edx+bttn.Text]
        call    Get_string_length
        shr     si,1
        shr     di,1

        push    eax
        push    dword [edx+bttn.Text]
        push    dword bttn_FontID
        push    dword bttn_TextColor

        mov     bx,[edx+bttn.yCoord]
        mov     cx,[edx+bttn.ySize]
        shr     cx,1
        sub     cx,di
        add     bx,cx
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.xCoord]
        mov     cx,[edx+bttn.xSize]
        
        shr     cx,1
        sub     cx,si
        add     bx,cx

        test    [edx+bttn.attr],dword bttnAttr_TextAttr
        je      no_attr_textleft0
        mov     bx,[edx+bttn.xCoord]
        add     bx,Text_LeftOffset
      no_attr_textleft0:

        and     ebx,0xFFFF
        push    ebx
        call    Write_Text
                
        popa
        ret

; EDX - BttnID
Draw_StdButton1:
        pusha
        push    edx
        call    Translate_BID
        pop     ecx

  ;========
  ;=  Draw button
  ;===================

        push    ecx
        mov     eax,[WinID]
        shl     ecx,24
        or      eax,ecx
        pop     ecx
        push    eax                     ; WinID
        push    dword [var_Bttn_Color_] ; Color
        mov     bx,[edx+bttn.ySize]
        dec     bx
        push    ebx                     ; y_size
        mov     bx,[edx+bttn.xSize]
        dec     bx
        push    ebx                     ; x_size
        push    dword [edx+bttn.yCoord] ; y_coord
        push    dword [edx+bttn.xCoord] ; x_coord
        call    Draw_BLine                   

  ;========
  ;=  Draw "frame"
  ;===================

        push    eax
        push    dword [var_Bttn_Color1]
        mov     bx,[edx+bttn.xSize]
        dec     bx
        push    ebx
        push    dword [edx+bttn.yCoord]
        push    dword [edx+bttn.xCoord]
        call    Draw_hLine

        push    eax
        push    dword [var_Bttn_Color1]
        mov     bx,[edx+bttn.ySize]
        dec     bx
        push    ebx
        push    dword [edx+bttn.yCoord]
        push    dword [edx+bttn.xCoord]
        call    Draw_vLine

        push    eax
        push    dword [var_Bttn_Color2]
        push    dword [edx+bttn.xSize]
        mov     bx,[edx+bttn.yCoord]
        add     bx,[edx+bttn.ySize]
        dec     bx
        and     ebx,0xFFFF
        push    ebx
        push    dword [edx+bttn.xCoord]
        call    Draw_hLine

        push    eax
        push    dword [var_Bttn_Color2]
        push    dword [edx+bttn.ySize]
        push    dword [edx+bttn.yCoord]
        mov     bx,[edx+bttn.xCoord]
        add     bx,[edx+bttn.xSize]
        dec     bx
        and     ebx,0xFFFF
        push    ebx
        call    Draw_vLine

        push    eax
        push    dword [var_Bttn_Color3]
        mov     bx,[edx+bttn.xSize]
        sub     bx,2
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.yCoord]
        add     bx,[edx+bttn.ySize]
        dec     bx
        dec     bx
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.xCoord]
        inc     bx
        push    ebx
        call    Draw_hLine

        push    eax
        push    dword [var_Bttn_Color3]
        mov     bx,[edx+bttn.ySize]
        sub     bx,2
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.yCoord]
        inc     bx
        push    ebx
        mov     bx,[edx+bttn.xCoord]
        add     bx,[edx+bttn.xSize]                              
        dec     bx
        dec     bx
        and     ebx,0xFFFF
        push    ebx
        call    Draw_vLine
                
  ;========
  ;=  Print text
  ;===================

     ; calc center

        push    dword bttn_FontID
        push    dword [edx+bttn.Text]
        call    Get_string_length
        shr     si,1
        shr     di,1

        push    eax
        push    dword [edx+bttn.Text]
        push    dword bttn_FontID
        push    dword bttn_TextColor

        mov     bx,[edx+bttn.yCoord]
        mov     cx,[edx+bttn.ySize]
        shr     cx,1
        sub     cx,di
        add     bx,cx
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.xCoord]
        mov     cx,[edx+bttn.xSize]
        shr     cx,1
        sub     cx,si
        add     bx,cx

        test    [edx+bttn.attr],dword bttnAttr_TextAttr
        je      no_attr_textleft1
        mov     bx,[edx+bttn.xCoord]
        add     bx,Text_LeftOffset
      no_attr_textleft1:

        and     ebx,0xFFFF
        push    ebx
        call    Write_Text
                
        popa
        ret

; EDX - BttnID
Draw_StdButton2_:
        pusha
        push    edx
        call    Translate_BID
        pop     ecx

  ;========
  ;=  Draw button
  ;===================

        push    ecx
        mov     eax,[WinID]
        shl     ecx,24
        or      eax,ecx
        pop     ecx

        push    eax                     ; WinID
        push    dword [var_Bttn_Color]  ; Color
        mov     bx,[edx+bttn.ySize]
        dec     bx
        push    ebx                     ; y_size
        mov     bx,[edx+bttn.xSize]
        dec     bx
        push    ebx                     ; x_size
        push    dword [edx+bttn.yCoord] ; y_coord
        push    dword [edx+bttn.xCoord] ; x_coord
        call    Draw_BLine                   

  ;========
  ;=  Draw "frame"
  ;===================

        push    eax
        push    dword [var_Bttn_Color2]
        mov     bx,[edx+bttn.xSize]
        dec     bx
        push    ebx   
        push    dword [edx+bttn.yCoord]
        push    dword [edx+bttn.xCoord]
        call    Draw_hLine

        push    eax
        push    dword [var_Bttn_Color2]
        mov     bx,[edx+bttn.ySize]
        dec     bx
        push    ebx
        push    dword [edx+bttn.yCoord]
        push    dword [edx+bttn.xCoord]
        call    Draw_vLine

        push    eax
        push    dword [var_Bttn_Color1]
        push    dword [edx+bttn.xSize]
        mov     bx,[edx+bttn.yCoord]
        add     bx,[edx+bttn.ySize]
        dec     bx
        and     ebx,0xFFFF
        push    ebx
        push    dword [edx+bttn.xCoord]
        call    Draw_hLine

        push    eax
        push    dword [var_Bttn_Color1]
        push    dword [edx+bttn.ySize]
        push    dword [edx+bttn.yCoord]
        mov     bx,[edx+bttn.xCoord]
        add     bx,[edx+bttn.xSize]
        dec     bx
        and     ebx,0xFFFF
        push    ebx
        call    Draw_vLine

        push    eax
        push    dword [var_Bttn_Color3]
        mov     bx,[edx+bttn.xSize]
        sub     bx,4
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.yCoord]
        inc     bx
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.xCoord]
        inc     bx
        push    ebx
        call    Draw_hLine

        push    eax
        push    dword [var_Bttn_Color3]
        mov     bx,[edx+bttn.ySize]
        sub     bx,3
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.yCoord]
        inc     bx
        push    ebx
        mov     bx,[edx+bttn.xCoord]
        inc     bx
        and     ebx,0xFFFF
        push    ebx
        call    Draw_vLine
                
  ;========
  ;=  Print text
  ;===================

     ; calc center

        push    dword bttn_FontID
        push    dword [edx+bttn.Text]
        call    Get_string_length
        shr     si,1
        shr     di,1

        push    eax
        push    dword [edx+bttn.Text]
        push    dword bttn_FontID
        push    dword bttn_TextColor

        mov     bx,[edx+bttn.yCoord]
        mov     cx,[edx+bttn.ySize]
        shr     cx,1
        sub     cx,di
        add     bx,cx
        inc     bx
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.xCoord]
        mov     cx,[edx+bttn.xSize]
        shr     cx,1
        sub     cx,si
        add     bx,cx
        inc     bx

        test    [edx+bttn.attr],dword bttnAttr_TextAttr
        je      no_attr_textleft2_
        mov     bx,[edx+bttn.xCoord]
        add     bx,Text_LeftOffset
      no_attr_textleft2_:

        and     ebx,0xFFFF
        push    ebx
        call    Write_Text
                
        popa
        ret

; EDX - BttnID
Draw_StdButton2:
        pusha
        push    edx
        call    Translate_BID
        pop     ecx

  ;========
  ;=  Draw button
  ;===================

        push    ecx
        mov     eax,[WinID]
        shl     ecx,24
        or      eax,ecx
        pop     ecx

        push    eax                     ; WinID
        push    dword [var_Bttn_Color]  ; Color
        mov     bx,[edx+bttn.ySize]
        dec     bx
        push    ebx                     ; y_size
        mov     bx,[edx+bttn.xSize]
        dec     bx
        push    ebx                     ; x_size
        push    dword [edx+bttn.yCoord] ; y_coord
        push    dword [edx+bttn.xCoord] ; x_coord
        call    Draw_BLine                   

  ;========
  ;=  Draw "frame"
  ;===================

        pusha
        mov     edx,eax
        mov     ecx,[var_Bttn_Color2]
        mov     bp,[edx+bttn.ySize]
        mov     ax,[edx+bttn.xSize]
        mov     di,[edx+bttn.yCoord]
        mov     si,[edx+bttn.xCoord]
        call    Draw_LineB
                
        mov     ecx,[var_Bttn_Color3]
        mov     bp,[edx+bttn.ySize]
        mov     ax,[edx+bttn.xSize]
        mov     di,[edx+bttn.yCoord]
        mov     si,[edx+bttn.xCoord]
        dec     bp
        dec     ax
        dec     bp
        dec     ax
        inc     di
        inc     si
        call    Draw_LineB
        popa

  ;========
  ;=  Print text
  ;===================

     ; calc center

        push    dword bttn_FontID
        push    dword [edx+bttn.Text]
        call    Get_string_length
        shr     si,1
        shr     di,1

        push    eax
        push    dword [edx+bttn.Text]
        push    dword bttn_FontID
        push    dword bttn_TextColor

        mov     bx,[edx+bttn.yCoord]
        mov     cx,[edx+bttn.ySize]
        shr     cx,1
        sub     cx,di
        add     bx,cx
        inc     bx
        and     ebx,0xFFFF
        push    ebx
        mov     bx,[edx+bttn.xCoord]
        mov     cx,[edx+bttn.xSize]
        shr     cx,1
        sub     cx,si
        add     bx,cx
        inc     bx

        test    [edx+bttn.attr],dword bttnAttr_TextAttr
        je      no_attr_textleft2
        mov     bx,[edx+bttn.xCoord]
        add     bx,Text_LeftOffset
      no_attr_textleft2:

        and     ebx,0xFFFF
        push    ebx
        call    Write_Text
                
        popa
        ret


 ;*********************************************;
 ;   "Create standard button"                  ;
 ;---------------------------------------------;
 ;  INPUT  : x*65536+y, x_size*65536+y_size,   ;
 ;           Text, Button ID, Flags            ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Create_StdButton:
        enter   32, 1
        pusha

        mov     edx,[ebp+8+(4* 3 )]
        call    Translate_BID

        mov     eax,[ebp+8+(4* 0 )]
        mov     [edx+bttn.yCoord],ax
        shr     eax,16
        mov     [edx+bttn.xCoord],ax

        mov     eax,[ebp+8+(4* 1 )]
        mov     [edx+bttn.ySize],ax
        shr     eax,16
        mov     [edx+bttn.xSize],ax
        
        mov     eax,bttnAttr_Button
        mov     ebx,[ebp+8+(4* 4 )]
;        and     ebx,1
        or      eax,ebx
        mov     [edx+bttn.attr],eax

        mov     eax,[ebp+8+(4* 2 )]
        mov     [edx+bttn.Text],eax  

  ;========
  ;=  Define Button       
  ;===================

        mov     edx,[ebp+8+(4* 3 )]

        push    edx                     ; ID 
        push    [WinID]                 ; WinID
        push    dword 0                 ; style
        mov     eax,[ebp+8+(4* 1 )]
        push    eax                     ; x_size & y_size
        mov     eax,[ebp+8+(4* 0 )]
        push    eax                     ; x & y
        call    DefineButton

  ;========
  ;=  Draw Button       
  ;===================

        mov     edx,[ebp+8+(4* 3 )]

        call    Draw_StdButton0

        popa
        leave
        ret     0x4 * 5

 ;*********************************************;
 ;   "Create check button"                     ;
 ;---------------------------------------------;
 ;  INPUT  : x*65536+x, Button ID, Flags       ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Create_CheckButton:
        enter   32, 1
        pusha

        mov     edx,[ebp+8+(4* 1 )]
        call    Translate_BID

        mov     eax,[ebp+8+(4* 0 )]
        mov     [edx+bttn.yCoord],ax
        shr     eax,16
        mov     [edx+bttn.xCoord],ax
                                                                        
        mov     eax,bttnAttr_Check
        mov     ebx,[ebp+8+(4* 2 )]
        and     ebx,11b
        or      eax,ebx
        mov     [edx+bttn.attr],eax

  ;========
  ;=  Define Button       
  ;===================

        push    dword [ebp+8+(4* 1 )]   ; ID 
        push    [WinID]                 ; WinID
        push    dword 0                 ; style
        push    dword 13 *65536+ 13     ; x_size & y_size
        push    dword [ebp+8+(4* 0 )]   ; x & y
        call    DefineButton

  ;========
  ;=  Draw Button       
  ;===================

        mov     edx,[ebp+8+(4* 1 )]

        call    Draw_CheckButton0

        popa
        leave
        ret     0x4 * 3


 ;*********************************************;
 ;   "Draw standard window"                    ;
 ;---------------------------------------------;
 ;  INPUT  : x*65536+x, x_size*65536+y_size,   ;
 ;           Name, buttons                     ;
 ;  OUTPUT : EAX - WinID                       ;
 ;*********************************************;
Draw_StdWindow:
        enter   32, 1
        pusha   
         
        mov     eax,[ebp+8+(4* 3 )]
        mov     [Buttons],eax
        mov     eax,[ebp+8+(4* 2 )]
        mov     [WinName],eax
        mov     eax,[ebp+8+(4* 0 )]
        mov     [Default_XY],eax
        mov     eax,[ebp+8+(4* 1 )]
        mov     [Default_XYSize],eax
                         
        call    Init_Bitmap

  ;========
  ;=  Define Window
  ;===================

        mov     eax,0

        test    [Buttons],dword 1000b
        je      no_Rest1_x1
        or      eax,ATTR_NoMove
      no_Rest1_x1:

        push    eax                     ; Attrib
        push    [WinName]               ; Name of window
        push    dword win_bitmap        ; Bit map
        push    [Default_XYSize]        ; x_coord & y_coord 
        push    [Default_XY]            ; x_size & y_size
        call    DefineWindow
        mov     [WinID],eax             ; Save WinID
        mov     [Default_XYSize],esi

        push    [WinID]
        call    Begin_xDraw

  ;========
  ;=  Define Take Field
  ;===================

        push    dword CtrlID_Moving     ; ID 
        push    [WinID]                 ; WinID
        push    dword 0                 ; style
        mov     eax,[Default_XYSize]
        mov     ax,Head_YSize
        push    eax                     ; x_size & y_size
        push    dword 0                 ; x & y
        call    DefineButton


  ;========
  ;=  Define Resize Field
  ;===================

;        push    dword CtrlID_CSize      ; ID 
;        push    [WinID]                 ; WinID
;        push    dword 0                 ; style
;        push    dword Resize_XSize*65536+Resize_YSize     ; x_size & y_size
;        mov     eax,[Default_XYSize]
;        sub     eax,(Resize_XSize+Resize_offset)*65536+(Resize_YSize+Resize_offset)
;        push    eax                     ; x & y
;        call    DefineButton

        mov     [HeadColor],Head_Color
        call    Draw_Frame

        test    [Buttons],dword 10000b
        je      no_ResizeFrame

        push    dword CtrlID_CSize      ; ID 
        push    [WinID]                 ; WinID
        push    dword 0                 ; style
        push    dword 0x16*65536+3      ; x_size & y_size
        mov     eax,[Default_XYSize]
        sub     eax,0x16*65536+3
        push    eax                     ; x & y
        call    DefineButton

        push    dword CtrlID_CSize      ; ID 
        push    [WinID]                 ; WinID
        push    dword 0                 ; style
        push    dword 3*65536+0x16      ; x_size & y_size
        mov     eax,[Default_XYSize]
        sub     eax,3*65536+0x16
        push    eax                     ; x & y
        call    DefineButton
      no_ResizeFrame:

  ;========
  ;=  Define Close Button
  ;===================

        push    dword StdBttnID_Close   ; ID 
        push    [WinID]                 ; WinID
        push    dword 0                 ; style

        mov     eax,StdCtrlBttn1_xsize*65536+StdCtrlBttn1_ysize
        test    [Buttons],dword 1000b
        je      no_Rest1_x2
        add     eax,(StdCtrlBttn1_xoffset-StdCtrlBttn1_xsize)*65536+StdCtrlBttn_yoffset
      no_Rest1_x2:                                             
        push    eax
        mov     eax,[Default_XYSize]
        mov     ax,StdCtrlBttn_yoffset
        sub     eax,StdCtrlBttn1_xoffset shl 16

        test    [Buttons],dword 1000b
        je      no_Rest1_x2_
        mov     ax,0
      no_Rest1_x2_:

        push    eax                     ; x & y
        call    DefineButton
                     
        test    [Buttons],dword 100b    ; ??? [Min] | [Max] ??? | [X]
        jne     no_one_bttn_test
        test    [Buttons],dword 10b
        jne     no_one_bttn_test
        jmp     no_other_buttons
      no_one_bttn_test:

  ;========
  ;=  Define Max Button
  ;===================

        push    dword StdBttnID_Maximize; ID 
        push    [WinID]                 ; WinID
        push    dword 0                 ; style
        mov     eax,StdCtrlBttn1_xsize*65536+StdCtrlBttn1_ysize
        test    [Buttons],dword 1000b
        je      no_Rest1_x3
        add     eax,StdCtrlBttn_yoffset
      no_Rest1_x3:
        push    eax
        mov     eax,[Default_XYSize]
        mov     ax,StdCtrlBttn_yoffset
        sub     eax,StdCtrlBttn2_xoffset shl 16

        test    [Buttons],dword 1000b
        je      no_Rest1_x3_
        mov     ax,0
      no_Rest1_x3_:

        push    eax                     ; x & y
        call    DefineButton

  ;========
  ;=  Define Min Button
  ;===================

        push    dword StdBttnID_Minimize; ID 
        push    [WinID]                 ; WinID
        push    dword 0                 ; style
        mov     eax,StdCtrlBttn1_xsize*65536+StdCtrlBttn1_ysize
        test    [Buttons],dword 1000b
        je      no_Rest1_x4
        add     eax,StdCtrlBttn_yoffset
      no_Rest1_x4:
        push    eax
        mov     eax,[Default_XYSize]
        mov     ax,StdCtrlBttn_yoffset
        sub     eax,StdCtrlBttn3_xoffset shl 16

        test    [Buttons],dword 1000b
        je      no_Rest1_x4_
        mov     ax,0
      no_Rest1_x4_:

        push    eax                     ; x & y
        call    DefineButton

        mov     [HeadColor],Head_Color
        call    Draw_Frame

      no_other_buttons:

  ;========
  ;=  Draw Resize Field
  ;===================

;        mov     eax,[WinID]
;        or      eax,CtrlID_CSize shl 24
;        push    eax
;        push    dword Head_Color
;        push    dword Resize_YSize
;        push    Resize_XSize
;        mov     esi,[Default_XYSize]
;        and     esi,0xFFFF
;        sub     esi,Resize_YSize+Resize_offset
;        push    esi
;        mov     esi,[Default_XYSize]
;        shr     esi,16
;        sub     esi,Resize_XSize+Resize_offset
;        push    esi
;        call    Draw_BLine

  ;========
  ;=  Draw Client region
  ;===================

        push    [WinID]
        push    dword Client_Color
        mov     esi,[Default_XYSize]
        and     esi,0xFFFF
        sub     si,Head_YSize+3
        push    esi
        mov     esi,[Default_XYSize]
        shr     esi,16
        sub     esi,6
        push    esi
        push    dword Head_YSize
        push    dword 3
        call    Draw_BLine
        
;        call    End_of_redraw

        popa
        mov     eax,[WinID]
        leave

;        mov     edi,[Default_XYSize]
;        mov     esi,[Default_XY]

        ret     0x4 * 4

Draw_Frame:
        pusha

  ;========
  ;=  Draw Frame
  ;===================

dec_framesize   = 1*65536+1

        mov     eax,[Default_XYSize]
        sub     eax,dec_framesize
        movzx   ebp,ax
        shr     eax,16              
        mov     ecx,[HeadColor]
        mov     esi,0
        mov     edi,0
        push    edx
        mov     edx,[WinID]
        call    Draw_LineB
        pop     edx
        mov     eax,[Default_XYSize]
        sub     eax,dec_framesize
        movzx   ebp,ax
        shr     eax,16
        sub     ax,2
        sub     bp,2
        mov     ecx,[HeadColor]
        add     ecx,0x20
        mov     esi,1
        mov     edi,1
        push    edx
        mov     edx,[WinID]
        call    Draw_LineB
        pop     edx
        mov     eax,[Default_XYSize]
        sub     eax,dec_framesize
        movzx   ebp,ax
        shr     eax,16
        sub     ax,4
        sub     bp,4
        mov     ecx,[HeadColor]
        mov     esi,2
        mov     edi,2
        push    edx
        mov     edx,[WinID]
        call    Draw_LineB
        pop     edx

        push    [WinID]
        or      [WinID],CtrlID_CSize shl 24

        mov     eax,[Default_XYSize]
        sub     eax,dec_framesize
        movzx   ebp,ax
        shr     eax,16              
        mov     ecx,[HeadColor]
        mov     esi,0
        mov     edi,0
        push    edx
        mov     edx,[WinID]
        call    Draw_LineB
        pop     edx
        mov     eax,[Default_XYSize]
        sub     eax,dec_framesize
        movzx   ebp,ax
        shr     eax,16
        sub     ax,2
        sub     bp,2
        mov     ecx,[HeadColor]
        add     ecx,0x20
        mov     esi,1
        mov     edi,1
        push    edx
        mov     edx,[WinID]
        call    Draw_LineB
        pop     edx
        mov     eax,[Default_XYSize]
        sub     eax,dec_framesize
        movzx   ebp,ax
        shr     eax,16
        sub     ax,4
        sub     bp,4
        mov     ecx,[HeadColor]
        mov     esi,2
        mov     edi,2
        push    edx
        mov     edx,[WinID]
        call    Draw_LineB
        pop     edx

        pop     [WinID]

  ;========
  ;=  Draw Take Field
  ;===================

        mov     eax,[WinID]
        or      eax,CtrlID_Moving shl 24

        mov     esi,0
        mov     ecx,[Default_XYSize]
        shr     ecx,16
        call    Draw_TitleBar

        mov     eax,[WinID]
        or      eax,StdBttnID_Close shl 24

        mov     esi,[Default_XYSize]
        shr     esi,16
        sub     esi,StdCtrlBttn1_xoffset
        mov     ecx,StdCtrlBttn1_xsize+16
        call    Draw_TitleBar

        mov     eax,[WinID]
        or      eax,StdBttnID_Maximize shl 24

        mov     esi,[Default_XYSize]
        shr     esi,16
        sub     esi,StdCtrlBttn2_xoffset
        mov     ecx,StdCtrlBttn1_xsize
        call    Draw_TitleBar

        mov     eax,[WinID]
        or      eax,StdBttnID_Minimize shl 24

        mov     esi,[Default_XYSize]
        shr     esi,16
        sub     esi,StdCtrlBttn3_xoffset
        mov     ecx,StdCtrlBttn1_xsize
        call    Draw_TitleBar

     ; Write title...

        mov     eax,[WinID]
        or      eax,CtrlID_Moving shl 24
        push    eax
        push    dword [WinName]
        push    dword 2
        push    dword -1
        push    dword 5
        push    dword 9
        call    Write_Text

        mov     esi,close1_bmp
        test    [Buttons],dword 1
        jne     no_CloseBttn
        mov     esi,close4_bmp
      no_CloseBttn:          

        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Close shl 24
        push    eax
        push    esi
        mov     eax,[Default_XYSize]
        mov     ax,StdCtrlBttn_yoffset
        sub     eax,StdCtrlBttn1_xoffset shl 16
        and     eax,0xFFFF
        push    dword eax
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn1_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture

        mov     esi,max1_bmp

        test    [Buttons],dword 1000b
        je      no_Rest1_
        mov     esi,rest1_bmp
      no_Rest1_:
           
        test    [Buttons],dword 10b
        jne     no_MaxBttn
        mov     esi,max4_bmp

        test    [Buttons],dword 1000b
        je      no_Rest1_x
        mov     esi,rest4_bmp
      no_Rest1_x:

      no_MaxBttn:

        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Maximize shl 24
        push    eax
        push    esi
        mov     eax,[Default_XYSize]
        mov     ax,StdCtrlBttn_yoffset
        sub     eax,StdCtrlBttn2_xoffset shl 16
        and     eax,0xFFFF
        push    dword eax
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn2_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture

        mov     esi,min1_bmp
        test    [Buttons],dword 100b
        jne     no_MinBttn
        mov     esi,min4_bmp
      no_MinBttn:
        
        mov     eax,7
        int     0x90
        mov     eax,[WinID]
        or      eax,StdBttnID_Minimize shl 24
        push    eax
        push    esi
        mov     eax,[Default_XYSize]
        mov     ax,StdCtrlBttn_yoffset
        sub     eax,StdCtrlBttn3_xoffset shl 16
        and     eax,0xFFFF
        push    dword eax
        mov     eax,[Default_XYSize]
        sub     eax,StdCtrlBttn3_xoffset shl 16
        shr     eax,16
        push    dword eax
        call    Draw_Picture
        
        popa
        ret

Draw_TitleBar:
        pusha
        mov     edx,[HeadColor]

        pusha
        mov     [Add_HeadColor],0x12
        mov     edx,[HeadColor]
        and     edx,0xFFFF00
        cmp     edx,0
        je      no_LostFocusHColor
        mov     [Add_HeadColor],0x121212
      no_LostFocusHColor:
        popa

        mov     edi,0 
        mov     ebx,4
        
      loop_linex:
        push    eax
        push    edx
        push    ecx
        push    edi
        push    esi
        call    Draw_hLine
        add     edx,[Add_HeadColor]
        inc     edi
        dec     ebx
        cmp     ebx,0
        jne     loop_linex   
        popa

        pusha
        mov     edx,[HeadColor]
        add     edx,(0x12*4)

        pusha
        mov     edx,[HeadColor]
        and     edx,0xFFFF00
        cmp     edx,0
        popa
        je      no_LostFocusHColor_
        push    eax
        mov     edx,[HeadColor]
        add     edx,(0x12*4)
        mov     al,dl
        shl     edx,16
        mov     dh,al
        mov     dl,al
        pop     eax
      no_LostFocusHColor_:
          
        mov     edi,4
        mov     ebx,Head_YSize-4

        pusha
        mov     [Add_HeadColor],0x4
        mov     edx,[HeadColor]
        and     edx,0xFFFF00
        cmp     edx,0
        je      no_LostFocusHColor__
        mov     [Add_HeadColor],0x040404
      no_LostFocusHColor__:
        popa

      loop_linex2:
        push    eax
        push    edx
        push    ecx
        push    edi
        push    esi
        call    Draw_hLine
        sub     edx,[Add_HeadColor]
        inc     edi
        dec     ebx
        cmp     ebx,0
        jne     loop_linex2  
        popa
        ret

;****************************************************************;
;     "Draw B Line"                                              ;
;----------------------------------------------------------------;
;  IN  : SI - x, DI - y, AX - x_size, BP - y_size, ECX - Color   ;
;        EDX - WinID                                             ;
;****************************************************************;
Draw_LineB:
        pusha
      ;--
      ;          
        push      edx
        push      ecx
        push      eax
        push      edi
        push      esi
        call      Draw_hLine
      ;
      ;--
        pusha
        add     di,bp
        push    edx
        push    ecx
        push    eax
        push    edi
        push    esi
        call    Draw_hLine
        popa

      ;|
      ;|
;        pusha
;      Loop_draw_LineB3:
;        push    eax
;        push    edx
;        push    ecx
;        push    edi
;        push    esi
;        call    Put_pixel
;        pop     eax    
;        inc     di
;        cmp     di,bp
;        jb      Loop_draw_LineB3
;        popa

        push      edx
        push      ecx
        push      ebp
        push      edi
        push      esi
        call      Draw_vLine

      ; |
      ; |
;        pusha
;        add     esi,eax
;        dec     esi
;        inc     ebp
;      Loop_draw_LineB4:
;        push    eax
;        push    edx
;        push    ecx
;        push    edi
;        push    esi
;        call    Put_pixel
;        pop     eax    
;        inc     di
;        cmp     di,bp
;        jb      Loop_draw_LineB4
;        popa

        add     si,ax
        push      edx
        push      ecx
        push      ebp
        push      edi
        push      esi
        call      Draw_vLine

        popa
        ret



Init_Bitmap:
        pusha
        mov     ecx,[Default_XYSize]
        and     ecx,0xFFFF
        mov     esi,[Default_XYSize]
        shr     esi,16
        imul    ecx,esi
        shr     ecx,3

        mov     edi,win_bitmap
        mov     al,0xFF
        rep     stosb

        test    [Buttons],dword 1000b
        jne     no_bitmap

        mov     ecx,[Default_XYSize]
        shr     ecx,16

        mov     eax,win_bitmap
        mov     esi,0
        mov     edi,0
        call    reset_bit
        inc     esi
        call    reset_bit
        inc     esi
        call    reset_bit
        inc     esi
        call    reset_bit
        inc     esi
        call    reset_bit
        mov     eax,win_bitmap
        mov     esi,0
        mov     edi,0
        call    reset_bit
        inc     edi
        call    reset_bit
        inc     edi
        call    reset_bit
        inc     edi
        call    reset_bit
        inc     edi
        call    reset_bit
        mov     eax,win_bitmap
        mov     esi,1
        mov     edi,1
        call    reset_bit
        mov     esi,1
        mov     edi,2
        call    reset_bit
        mov     esi,2
        mov     edi,1
        call    reset_bit
 
        mov     eax,win_bitmap
        mov     esi,[Default_XYSize]
        shr     esi,16
        mov     edi,0
        dec     esi
        call    reset_bit
        dec     esi
        call    reset_bit
        dec     esi
        call    reset_bit
        dec     esi
        call    reset_bit
        dec     esi
        call    reset_bit
        mov     eax,win_bitmap
        mov     esi,[Default_XYSize]
        shr     esi,16
        dec     esi
        mov     edi,0
        call    reset_bit
        inc     edi
        call    reset_bit
        inc     edi
        call    reset_bit
        inc     edi
        call    reset_bit
        inc     edi
        call    reset_bit
        mov     eax,win_bitmap
        mov     esi,[Default_XYSize]
        shr     esi,16
        dec     esi
        mov     edi,0
        dec     esi
        inc     edi
        call    reset_bit
        mov     esi,[Default_XYSize]
        shr     esi,16
        dec     esi
        mov     edi,0
        dec     esi
        dec     esi
        inc     edi
        call    reset_bit
        mov     esi,[Default_XYSize]
        shr     esi,16
        dec     esi
        mov     edi,0
        dec     esi
        inc     edi
        inc     edi
        call    reset_bit
      no_bitmap:
        popa
        ret

;****************************************************************;
;       "Reset bit"                                              ;
;----------------------------------------------------------------;
;  INPUT  : EAX - Bitmap address, ESI - x, EDI - y, ECX - x_size ;
;  OUTPUT : None                                                 ;
;****************************************************************;
reset_bit:
        pusha
        mov     ebx,[Default_XYSize]
        shr     ebx,16
        imul    edi,ebx
        add     edi,esi
        mov     ecx,edi

        mov     edi,eax
        mov     eax,ecx
        mov     ecx,8
        mov     edx,0
        div     ecx     
        mov     ebx,[edi+eax]
        btr     ebx,edx
        mov     [edi+eax],ebx
        popa
        ret

;****************************************************************;
;       "Set bit"                                                ;
;----------------------------------------------------------------;
;  INPUT  : EAX - Bitmap address, ESI - x, EDI - y, ECX - x_size ;
;  OUTPUT : None                                                 ;
;****************************************************************;
set_bit:
        pusha
        imul    edi,ecx
        add     edi,esi
        mov     ecx,edi

        mov     edi,eax
        mov     eax,ecx
        mov     ecx,8
        mov     edx,0
        div     ecx     
        mov     ebx,[edi+eax]
        bts     ebx,edx
        mov     [edi+eax],ebx
        popa
        ret

;****************************************************************;
;       "Invert bit"                                             ;
;----------------------------------------------------------------;
;  INPUT  : EAX - Bitmap address, ESI - x, EDI - y, ECX - x_size ;
;  OUTPUT : None                                                 ;
;****************************************************************;
invert_bit:
        pusha
        imul    edi,ecx
        add     edi,esi
        mov     ecx,edi

        mov     edi,eax
        mov     eax,ecx
        mov     ecx,8
        mov     edx,0
        div     ecx     
        mov     ebx,[edi+eax]
        btc     ebx,edx
        mov     [edi+eax],ebx
        popa
        ret

;****************************************************************;
;       "get bit"                                                ;
;----------------------------------------------------------------;
;  INPUT  : EAX - Bitmap address, ESI - x, EDI - y, ECX - x_size ;
;  OUTPUT : Carry Flag - bit                                     ;
;****************************************************************;
get_bit:
        pusha
        imul    edi,ecx
        add     edi,esi
        mov     ecx,edi

        mov     edi,eax
        mov     eax,ecx
        mov     ecx,8
        mov     edx,0
        div     ecx     
        mov     ebx,[edi+eax]
        bt      ebx,edx
        mov     [edi+eax],ebx
        popa
        ret

End_of_redraw:
        pusha
        mov     ebx,[GUI_End_of_redraw_Addr]
        mov     eax,0
        call    mx_SysCall
        popa
        ret

 ;*********************************************;
 ;   "Kill Window"                             ;
 ;---------------------------------------------;
 ;  INPUT  : WinID                             ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Kill_Window:
        enter   32, 1
        pusha
        mov     edx,[ebp+8+(4* 0 )]
        mov     ebx,[GUI_Kill_Window_Addr]
        mov     eax,0
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 1


 ;*********************************************;
 ;   "Get string length"                       ;
 ;---------------------------------------------;
 ;  INPUT  : String address, FontID            ;
 ;  OUTPUT : ESI - x_size, EDI - y_size        ;
 ;*********************************************;
Get_string_length:
        enter   32, 1
        push    eax ebx ecx edx ebp

        mov     esi,[ebp+8+(4* 0 )]
        mov     ebp,[ebp+8+(4* 1 )]

        mov     eax,0
        mov     ebx,[GUI_Get_string_length_Addr]
        call    mx_SysCall
        pop     ebp edx ecx ebx eax
        leave
        ret     0x4 * 2


 ;*********************************************;
 ;   "Write Hex"                               ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, text_color, FontID, Hex,    ;
 ;           WinID                             ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Write_Hex:
        enter   32, 1
        pusha

        mov     eax,[ebp+8+(4* 4 )]
        mov     edi,hexbuffer
        call    hex 

        mov     ebx,[ebp+8+(4* 5 )]
        mov     [bss+0x00],ebx
        mov     ebx,[ebp+8+(4* 2 )]
        mov     [bss+0x04],ebx
        mov     [bss+0x08],dword hexbuffer
        mov     ebx,[ebp+8+(4* 0 )]
        mov     [bss+0x0C],ebx
        mov     ebx,[ebp+8+(4* 1 )]
        mov     [bss+0x10],ebx
        mov     ebx,[ebp+8+(4* 3 )]
        mov     [bss+0x14],ebx

        mov     esi,bss

        mov     eax,0
        mov     ebx,[GUI_sprint_Addr]
        call    mx_SysCall
        popa
        leave
        ret     0x4 * 6

 ;*********************************************;
 ;   "Write Hex for application"               ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, text_color, Hex             ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
WriteHex:
        enter   32, 1
        pusha

        mov     eax,[ebp+8+(4* 3 )]
        mov     edi,hexbuffer
        call    hex 

        mov     ebx,[WinID]            
        mov     [bss+0x00],ebx
        mov     ebx,[ebp+8+(4* 2 )]
        mov     [bss+0x04],ebx
        mov     [bss+0x08],dword hexbuffer
        mov     ebx,[ebp+8+(4* 0 )]
        mov     [bss+0x0C],ebx
        mov     ebx,[ebp+8+(4* 1 )]
        mov     [bss+0x10],ebx
        mov     ebx,4
        mov     [bss+0x14],ebx

        mov     esi,bss

        mov     eax,0
        mov     ebx,[GUI_sprint_Addr]
        call    mx_SysCall
        popa
        leave
        ret     0x4 * 4


 ;*********************************************;
 ;   "Write Text"                              ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, text_color, FontID, Address,;
 ;           WinID                             ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Write_Text:
        enter   32, 1
        pusha

        mov     ebx,[ebp+8+(4* 5 )]
        mov     [bss+0x00],ebx
        mov     ebx,[ebp+8+(4* 2 )]
        mov     [bss+0x04],ebx
        mov     ebx,[ebp+8+(4* 4 )]
        mov     [bss+0x08],ebx
        mov     ebx,[ebp+8+(4* 0 )]
        mov     [bss+0x0C],ebx
        mov     ebx,[ebp+8+(4* 1 )]
        mov     [bss+0x10],ebx
        mov     ebx,[ebp+8+(4* 3 )]
        mov     [bss+0x14],ebx

        mov     esi,bss

        mov     eax,0
        mov     ebx,[GUI_sprint_Addr]
        call    mx_SysCall
        popa
        leave
        ret     0x4 * 6

 ;*********************************************;
 ;   "Write Text for application"              ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, text_color, FontID, Address ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
WriteText:
        enter   32, 1
        pusha

        mov     ebx,[WinID]             
        mov     [bss+0x00],ebx
        mov     ebx,[ebp+8+(4* 2 )]
        mov     [bss+0x04],ebx
        mov     ebx,[ebp+8+(4* 4 )]
        mov     [bss+0x08],ebx
        mov     ebx,[ebp+8+(4* 0 )]
        mov     [bss+0x0C],ebx
        mov     ebx,[ebp+8+(4* 1 )]
        mov     [bss+0x10],ebx
        mov     ebx,[ebp+8+(4* 3 )]
        mov     [bss+0x14],ebx

        mov     esi,bss

        mov     eax,0
        mov     ebx,[GUI_sprint_Addr]
        call    mx_SysCall
        popa
        leave
        ret     0x4 * 5


 ;*********************************************;
 ;   "Draw_Picture"                            ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, Address, WinID              ;
 ;  OUTPUT : EAX - Total images                ;
 ;*********************************************;
Draw_Picture:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     esi,[ebp+8+(4* 0 )]
        mov     edi,[ebp+8+(4* 1 )]
        mov     edx,[ebp+8+(4* 2 )]
        mov     ebp,[ebp+8+(4* 3 )]
        mov     eax,0
        mov     ebx,[GUI_Draw_Picture_Addr]
        call    mx_SysCall2
        mov     eax,ebx
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 4

 ;*********************************************;
 ;   "Draw_Picture for application"            ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, Address                     ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
DrawPicture:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     esi,[ebp+8+(4* 0 )]
        mov     edi,[ebp+8+(4* 1 )]
        mov     edx,[ebp+8+(4* 2 )]
        mov     ebp,[WinID]             
        mov     eax,0
        mov     ebx,[GUI_Draw_Picture_Addr]
        call    mx_SysCall2
        mov     eax,ebx
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 3

 ;*********************************************;
 ;   "Draw_hLine"                              ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, x_size, Color, WinID        ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Draw_hLine:
        enter   32, 1
        pusha
        mov     esi,[ebp+8+(4* 0 )]
        mov     edi,[ebp+8+(4* 1 )]
        shl     esi,16
        mov     si,di
        mov     edi,[ebp+8+(4* 2 )]
        mov     edx,[ebp+8+(4* 3 )]
        mov     ebp,[ebp+8+(4* 4 )]
        mov     eax,0
        mov     ebx,[GUI_Draw_hLine_Addr]
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 5

 ;*********************************************;
 ;   "Draw_vLine"                              ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, x_size, Color, WinID        ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Draw_vLine:
        enter   32, 1
        pusha
        mov     esi,[ebp+8+(4* 0 )]
        mov     edi,[ebp+8+(4* 1 )]
        shl     esi,16
        mov     si,di
        mov     edi,[ebp+8+(4* 2 )]
        mov     edx,[ebp+8+(4* 3 )]
        mov     ebp,[ebp+8+(4* 4 )]
        mov     eax,0
        mov     ebx,[GUI_Draw_vLine_Addr]
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 5
                    
 ;*********************************************;
 ;   "Draw_BLine"                              ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, x_size, y_size, color, WinID;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Draw_BLine:
        enter   32, 1
        pusha
        mov     esi,[ebp+8+(4* 0 )]
        shl     esi,16
        mov     ebx,[ebp+8+(4* 1 )]
        mov     si,bx
        mov     edi,[ebp+8+(4* 2 )]
        shl     edi,16
        mov     ebx,[ebp+8+(4* 3 )]
        mov     di,bx
        push    ebp
        mov     edx,[ebp+8+(4* 5 )]
        mov     ebp,[ebp+8+(4* 4 )]
        mov     eax,0
        mov     ebx,[GUI_Draw_BF_Addr]
        call    mx_SysCall2
        pop     ebp
        popa
        leave
        ret     0x4 * 6

 ;*********************************************;
 ;   "Clear field"                             ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, x_size, y_size              ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
ClearField:
        enter   32, 1
        pusha
        mov     esi,[ebp+8+(4* 0 )]
        shl     esi,16
        mov     ebx,[ebp+8+(4* 1 )]
        mov     si,bx
        mov     edi,[ebp+8+(4* 2 )]
        shl     edi,16
        mov     ebx,[ebp+8+(4* 3 )]
        mov     di,bx
        mov     edx,[WinID]
        mov     eax,0
        mov     ebx,[GUI_ClearField_Addr]
        call    mx_SysCall2
        popa
        leave
        ret     0x4 * 4


 ;*********************************************;
 ;   "Get screen params"                       ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : ESI - MaxX, EDI - MaxY            ;
 ;*********************************************;
Get_screen_param:
        mov     eax,0x100
        call    mx_SysCall        
        ret

 ;*********************************************;
 ;   "Put_pixel"                               ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, color, WinID                ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Put_pixel:
        enter   32, 1
        pusha

        mov     ebx,[ebp+8+(4* 0 )]
        mov     [bss+0x00],ebx
        mov     ebx,[ebp+8+(4* 1 )]
        mov     [bss+0x04],ebx
        mov     ebx,[ebp+8+(4* 2 )]
        mov     [bss+0x08],ebx
        mov     ebx,[ebp+8+(4* 3 )]
        mov     [bss+0x0C],ebx

        mov     esi,bss

        mov     eax,0
        mov     ebx,[GUI_Put_pixel_L3_Addr]
        call    mx_SysCall
        popa
        leave
        ret     0x4 * 4

 ;*********************************************;
 ;   "Put_pixel for application"               ;
 ;---------------------------------------------;
 ;  INPUT  : x, y, color                       ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
PutPixel:
        enter   32, 1
        pusha

        mov     ebx,[ebp+8+(4* 0 )]
        mov     [bss+0x00],ebx
        mov     ebx,[ebp+8+(4* 1 )]
        mov     [bss+0x04],ebx
        mov     ebx,[ebp+8+(4* 2 )]
        mov     [bss+0x08],ebx
        mov     ebx,[WinID]           
        mov     [bss+0x0C],ebx

        mov     esi,bss

        mov     eax,0
        mov     ebx,[GUI_Put_pixel_L3_Addr]
        call    mx_SysCall
        popa
        leave
        ret     0x4 * 3


 ;*********************************************;
 ;   "Define Button"                           ;
 ;---------------------------------------------;
 ;  INPUT  : x*65536+x, x_size*65536+y_size    ;
 ;           Attrib, Style, Name               ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
DefineButton:
        enter   32, 1
        pusha

        mov     ebx,[ebp+8+(4* 0 )]
        mov     [bss+0x00],ebx
        mov     ebx,[ebp+8+(4* 1 )]
        mov     [bss+0x04],ebx
        mov     ebx,[ebp+8+(4* 2 )]
        mov     [bss+0x08],ebx
        mov     ebx,[ebp+8+(4* 3 )]
        mov     [bss+0x0C],ebx
        mov     ebx,[ebp+8+(4* 4 )]
        mov     [bss+0x10],ebx

        mov     esi,bss

        mov     eax,0
        mov     ebx,[GUI_DefineButton_Addr]
        call    mx_SysCall
        mov     eax,edi
        popa
        leave
        ret     0x4 * 5

 ;*********************************************;
 ;   "Define Window"                           ;
 ;---------------------------------------------;
 ;  INPUT  : x*65536+x, x_size*65536+y_size,   ;
 ;           Style, Name, Attrib               ;
 ;  OUTPUT : EAX - WinID, ESI - winsize        ;
 ;*********************************************;
DefineWindow:
        enter   32, 1
        push    ebx ecx edx edi ebp

        mov     ebx,[ebp+8+(4* 0 )]
        mov     [bss+0x00],ebx
        mov     ebx,[ebp+8+(4* 1 )]
        mov     [bss+0x04],ebx
        mov     ebx,[ebp+8+(4* 2 )]
        mov     [bss+0x08],ebx
        mov     ebx,[ebp+8+(4* 3 )]
        mov     [bss+0x0C],ebx
        mov     ebx,[ebp+8+(4* 4 )]
        mov     [bss+0x10],ebx

        mov     esi,bss

        mov     eax,0
        mov     ebx,[GUI_DefineWindow_Addr]
        call    mx_SysCall
        mov     eax,edi

        mov     [WinID],eax

        pop     ebp edi edx ecx ebx
        leave
        ret     0x4 * 5

 ;*********************************************;
 ;   "Set focus"                               ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Set_focus:
        pusha
        mov     eax,0x21
        call    mx_SysCall
        mov     eax,0x20
        call    mx_SysCall
        popa
        ret

 ;*********************************************;
 ;   "Get current PID"                         ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : EAX - PID                         ;
 ;*********************************************;
GetPID:
        push    ebx ecx edx esi edi ebp 
        mov     eax,0x21
        call    mx_SysCall
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        ret                 

 ;*********************************************;
 ;   "Get Command Line Param offset"           ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : EAX - PID                         ;
 ;*********************************************;
GetCommandLine:
        mov     eax,0x400
        ret                 



 ;*********************************************;
 ;   "Get Used Pages"                          ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : EAX - pages count                 ;
 ;*********************************************;
GetUsagePages:
        push    ebx ecx edx esi edi ebp 
        mov     eax,0x110
        call    mx_SysCall2
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        ret                 

 ;*********************************************;
 ;   "Get PIDs count"                          ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : EAX - pages count                 ;
 ;*********************************************;
GetPIDsCount:
        push    ebx ecx edx esi edi ebp 
        mov     eax,0x111
        call    mx_SysCall2
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        ret                 

 ;*********************************************;
 ;   "GetVersion"                              ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : EAX - ver                         ;
 ;*********************************************;
GetVersion:
        push    ebx ecx edx esi edi ebp 
        mov     eax,0x02
        call    mx_SysCall2
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        ret                 

 ;*********************************************;
 ;   "Set focus PID"                           ;
 ;---------------------------------------------;
 ;  INPUT  : PID                               ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Set_focusPID:
        enter   32, 1
        pusha
        mov     esi,[ebp+8+(4* 0 )]
        mov     eax,0x20
        call    mx_SysCall
        popa
        leave
        ret     0x4 * 1

 ;*********************************************;
 ;   "Set position"                            ;
 ;---------------------------------------------;
 ;  INPUT  : Position                          ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
Set_Position:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     esi,[ebp+8+(4* 0 )]
        mov     eax,0
        mov     ebx,[CON_Set_Position_Addr]
        call    mx_SysCall
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 1

 ;*********************************************;
 ;   "Get position"                            ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : Position                          ;
 ;*********************************************;
Get_Position:
        push    ebx ecx edx esi edi ebp
        mov     eax,0
        mov     ebx,[CON_Get_Position_Addr]
        call    mx_SysCall
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        ret

 ;*********************************************;
 ;   "Put char"                                ;
 ;---------------------------------------------;
 ;  INPUT  : Position, Char & Color            ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
PutChar2:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     esi,[ebp+8+(4* 0 )]
        mov     edi,[ebp+8+(4* 1 )]
        mov     eax,0
        mov     ebx,[CON_PutChar2_Addr]
        call    mx_SysCall
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 2

 ;*********************************************;
 ;   "Put char to console"                     ;
 ;---------------------------------------------;
 ;  INPUT  : Char                              ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
PutChar:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     esi,[ebp+8+(4* 0 )]
        mov     eax,0
        mov     ebx,[CON_PutChar_Addr]
        call    mx_SysCall
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 1

 ;*********************************************;
 ;   "Get file address"                        ;
 ;---------------------------------------------;
 ;  INPUT  : Name                              ;
 ;  OUTPUT : ESI - Address, EBX - Size         ;
 ;*********************************************;
Get_FileAddress:
        enter   32, 1
        push    ecx edx edi ebp
        mov     esi,[ebp+8+(4* 0 )]
        mov     eax,0x07
        call    mx_SysCall
        pop     ebp edi edx ecx
        leave
        ret     0x4 * 1

 ;*********************************************;
 ;   "Print string"                            ;
 ;---------------------------------------------;
 ;  INPUT  : String                            ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
PrintString:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     esi,[ebp+8+(4* 0 )]
        mov     eax,0
        mov     ebx,[CON_PrintString_Addr]
        call    mx_SysCall
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 1

 ;*********************************************;
 ;   "Inkey"                                   ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : AL - ASCII Char, AH - ScanCode,   ;
 ;           DL - Flags                        ;
 ;*********************************************;
Inkey:
        push    ecx esi edi ebp
        mov     ebx,[KBD_GetWaitKbd_Addr]
        mov     eax,0                
        call    mx_SysCall
        mov     eax,esi
        pop     ebp edi esi ecx
        ret

 ;*********************************************;
 ;   "Read from keyboard"                      ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : AL - ASCII Char, AH - ScanCode,   ;
 ;           DL - Flags                        ;
 ;*********************************************;
TestKbdInput:
        push    ecx esi edi ebp
        mov     ebx,[KBD_GetKbd_Addr]
        mov     eax,0
        call    mx_SysCall
        mov     eax,esi
        pop     ebp edi esi ecx
        ret

 ;*********************************************;
 ;   "Virtual Alloc"                           ;
 ;---------------------------------------------;
 ;  INPUT  : Address, Size, Protect            ;
 ;  OUTPUT : EAX - Allocated                   ;
 ;*********************************************;
VirtualAlloc:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     ebx,[ebp+8+(4* 0 )]
        mov     esi,[ebp+8+(4* 1 )]
        mov     edi,[ebp+8+(4* 2 )]
        mov     eax,3
        call    mx_SysCall
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 3

 ;*********************************************;
 ;   "malloc"                                  ;
 ;---------------------------------------------;
 ;  INPUT  : Size                              ;
 ;  OUTPUT : EAX - Allocated                   ;
 ;*********************************************;
malloc:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     esi,[ebp+8+(4* 0 )]
        mov     eax,0x0009
        call    mx_SysCall
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 1

 ;*********************************************;
 ;   "Virtual Protect"                         ;
 ;---------------------------------------------;
 ;  INPUT  : Address, Size, Old Access,        ;
 ;           New Access                        ;
 ;  OUTPUT : EAX - pages                       ;
 ;*********************************************;
VirtualProtect:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     ebx,[ebp+8+(4* 0 )]
        mov     esi,[ebp+8+(4* 1 )]
        mov     edi,[ebp+8+(4* 2 )]
        shl     edi,16
        or      edi,[ebp+8+(4* 3 )]
        mov     eax,5
        call    mx_SysCall
        mov     eax,esi
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 4

 ;*********************************************;
 ;   "Virtual Free"                            ;
 ;---------------------------------------------;
 ;  INPUT  : Address, Size                     ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
VirtualFree:
        enter   32, 1
        pusha
        mov     ebx,[ebp+8+(4* 0 )]
        mov     esi,[ebp+8+(4* 1 )]
        mov     eax,6
        call    mx_SysCall
        mov     eax,esi
        popa
        leave
        ret     0x4 * 2

 ;*********************************************;
 ;   "Create Process"                          ;
 ;---------------------------------------------;
 ;  INPUT  : CodeAddress, Size of code, Name   ;
 ;  OUTPUT : EAX - PID                         ;
 ;*********************************************;
CreateProcess:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     ebx,[ebp+8+(4* 0 )]
        mov     edi,[ebp+8+(4* 1 )]
        mov     esi,[ebp+8+(4* 2 )]
        mov     eax,0x10
        call    mx_SysCall
        mov     eax,edi
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 3         

 ;*********************************************;
 ;   "Task Kill"                               ;
 ;---------------------------------------------;
 ;  INPUT  : EDI - PID                         ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
TaskKill:
        enter   32, 1
        mov     edi,[ebp+8+(4* 0 )]
        pusha

;        push    esi
;        call    Kill_Window

        mov     eax,0x11
        call    mx_SysCall


;        mov     edi,0
;        mov     eax,0x11
;        call    mx_SysCall
        popa
        leave
        ret     0x4 * 1

 ;*********************************************;
 ;   "Exit Process"                            ;
 ;---------------------------------------------;
 ;  INPUT  : ReturnCode                        ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
ExitProcess:
        enter   32, 1
        pusha
        mov     esi,[ebp+8+(4* 0 )]
        mov     edi,0
        mov     eax,0x11
        call    mx_SysCall
        mov     eax,edi
        mov     ecx,-1
      last_time:
        out     0xEB,al
        jmp    last_time    
        popa
        leave
        ret     0x4 * 1

 ;*********************************************;
 ;   "Create Thread"                           ;
 ;---------------------------------------------;
 ;  INPUT  : CodeAddress, Name, Param          ;
 ;  OUTPUT : EAX - PID                         ;
 ;*********************************************;
proc CreateThread codeaddr,name,param
        push    ebx ecx edx esi edi ebp
        mov     ebx,[codeaddr]
        mov     esi,[name]
        mov     edi,[param]
        mov     eax,0x12
        call    mx_SysCall
        mov     eax,edi
        pop     ebp edi esi edx ecx ebx
	ret
endp

 ;*********************************************;
 ;   "Exit Thread"                             ;
 ;---------------------------------------------;
 ;  INPUT  : PID                               ;
 ;  OUTPUT : None                              ;
 ;*********************************************;
ExitThread:
        enter   32, 1
        pusha
        mov     edi,[ebp+8+(4* 0 )]
        mov     eax,0x13
        call    mx_SysCall
        mov     ecx,-1
      last_time2:
        out     0xEB,al
        jmp    last_time2
        popa
        leave
        ret     0x4 * 1

 ;*********************************************;
 ;   "Send Message"                            ;
 ;---------------------------------------------;
 ;  INPUT  : PID, Param1, Param2, Param3       ;
 ;  OUTPUT : EAX - PID or 0                    ;
 ;*********************************************;
SendMessage:
        enter   32, 1
        push    ebx ecx edx esi edi ebp
        mov     esi,[ebp+8+(4* 2 )]
        mov     ebx,[ebp+8+(4* 1 )]
        mov     edi,[ebp+8+(4* 0 )]
        mov     ebp,[ebp+8+(4* 3 )]
	cmp	edi,0
	jne	no_my_PID
	call	GetPID
	mov	edi,eax
      no_my_PID:
        mov     eax,0x30
        call    mx_SysCall
        mov     eax,edi
        pop     ebp edi esi edx ecx ebx
        leave
        ret     0x4 * 4

 ;*********************************************;
 ;   "Receive Message"                         ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : EDI - PID, EBX:ESI:EBP - Message  ;
 ;*********************************************;
ReceiveMessage:
        push    eax ecx edx
        mov     eax,0x31
        call    mx_SysCall
        pop     edx ecx eax
        ret

proc WaitMessageC buf
	pusha
	mov	edx,[buf]
	push	edx
	call	WaitMessage
	pop	edx
	mov	[edx+0x00],eax
	mov	[edx+0x04],edi
	mov	[edx+0x08],ebx
	mov	[edx+0x0C],esi
	mov	[edx+0x10],ebp
	popa
	ret
endp

proc ReceiveMessageC buf
	pusha
	mov	edx,[buf]
	push	edx
	call	ReceiveMessage
	pop	edx
	mov	[edx+0x00],eax
	mov	[edx+0x04],edi
	mov	[edx+0x08],ebx
	mov	[edx+0x0C],esi
	mov	[edx+0x10],ebp
	popa
	ret
endp

 ;*********************************************;
 ;   "Wait Message"                            ;
 ;---------------------------------------------;
 ;  INPUT  : None                              ;
 ;  OUTPUT : EDI - PID, EBX:ESI:EBP - Message  ;
 ;*********************************************;
WaitMessage:
        push    eax ecx edx
        mov     eax,0x32
        call    mx_SysCall
        pop     edx ecx eax
        ret

f1:
        enter   32,1
        pusha
        mov     eax,[ebp+8]
        mov     [0x800B8000],eax
        popa
        leave
        ret     0x4

mx_SysCall2:
        int     0x90
        ret
mx_SysCall:
        mov     edx,SysCall_return
        mov     ecx,esp
mx_SysCall_:
;        SysEnter
        int     0x90
      SysCall_return:
        ret

proc atoi buf
	; edi=buff
        push    ebx ecx edx esi edi ebp
	mov	edi,[buf]
        xor     eax,eax
        cmp     [edi],byte 0
        je      exit_dec
        cmp     [edi],byte '.'
        je      exit_dec

        ; calc len
        xor     ecx,ecx
      calc_len:
        inc     ecx
        inc     edi
        cmp     [edi],byte 0
        je      exit_calc_len
        cmp     [edi],byte '.'
        je      exit_calc_len
        jmp     calc_len
      exit_calc_len:
        dec     edi

      decoding:
        mov     al,[edi]        ; pos0
        dec     edi
        sub     al,0x30
        xor     ebx,ebx
        mov     bl,[edi]        ; pos1
        dec     edi
        dec     ecx
        cmp     ecx,0
        je      exit_dec
        sub     bl,0x30
        imul    ebx,10
        add     eax,ebx
        xor     ebx,ebx
        mov     bl,[edi]        ; pos2
        dec     edi
        dec     ecx
        cmp     ecx,0
        je      exit_dec
        sub     bl,0x30
        imul    ebx,100
        add     eax,ebx
        xor     ebx,ebx
        mov     bl,[edi]        ; pos3
        dec     edi
        dec     ecx
        cmp     ecx,0
        je      exit_dec
        sub     bl,0x30
        imul    ebx,1000
        add     eax,ebx
        xor     ebx,ebx
        mov     bl,[edi]        ; pos4
        dec     edi
        dec     ecx
        cmp     ecx,0
        je      exit_dec
        sub     bl,0x30
        imul    ebx,10000
        add     eax,ebx
      exit_dec:
        pop     ebp edi esi edx ecx ebx
        ret  ; =eax
endp


  hexbuffer             db '00000000',0
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


Get_CurListElement:
        push    ebx ecx edx esi edi ebp
        call    Translate_BID
        mov     ecx,[edx+bttn.Text]
        mov     ebx,ecx
        movzx   ebx,bl
        imul    ebx,lb.Size
        add     ebx,ListInfo            
        mov     ecx,[ebx+lb.CurOnList]

        mov     ecx,[ebx+lb.CurElement]

  ;====================
  ; IN  : ECX - Num of element
  ;====================================
        pop     ebp edi esi edx ecx ebx
        ret

; OUT : EAX - Randomize
proc Randomize Lower,Upper
        push    edx edi
        mov     edi,[Upper]
        sub     edi,[Lower]
        inc     edi
        rdtsc
        and     eax,0xFFFF
        imul    eax,edi
        shr     eax,16
        add     eax,[Lower]
        pop     edi edx
        ret
endp

end_of_code:

section '.bss' data readable writeable
bss rd 0x400

section '.data' data readable writeable
  old_EventID           dw 0
  var_Bttn_Color        dd Bttn_Color
  var_Bttn_Color_       dd Bttn_Color_
  var_Bttn_Color1       dd Bttn_Color1
  var_Bttn_Color2       dd Bttn_Color2
  var_Bttn_Color3       dd Bttn_Color3

  GUI_Name              db 'GUI.DLL',0
  GUI_DefineWindow      db 'DefineWindow_',0
  GUI_DefineWindow_Addr dd 0
  GUI_DefineButton      db 'DefineButton_',0
  GUI_DefineButton_Addr dd 0
  GUI_Put_pixel_L3      db 'Put_pixel_L3_',0
  GUI_Put_pixel_L3_Addr dd 0  
  GUI_Draw_BF           db 'Draw_BF',0
  GUI_Draw_BF_Addr      dd 0
  GUI_Draw_Picture      db 'Draw_Picture',0
  GUI_Draw_Picture_Addr dd 0
  GUI_Kill_Window       db 'Kill_Window',0
  GUI_Kill_Window_Addr  dd 0
  GUI_sprint            db 'print_string_L4_',0
  GUI_sprint_Addr       dd 0
  GUI_End_of_redraw     db 'End_of_redraw',0
  GUI_End_of_redraw_Addr dd 0
  GUI_End_of_xdraw      db 'End_of_xdraw',0
  GUI_End_of_xdraw_Addr dd 0
  GUI_Draw_hLine        db 'Draw_hLine',0
  GUI_Draw_hLine_Addr   dd 0
  GUI_Draw_vLine        db 'Draw_vLine',0
  GUI_Draw_vLine_Addr   dd 0
  GUI_Get_XYSize        db 'Get_XYSize',0
  GUI_Get_XYSize_Addr   dd 0
  GUI_Get_WinParams     db 'Get_WinParams',0
  GUI_Get_WinParams_Addr dd 0
  GUI_Begin_xDraw       db 'Begin_xDraw',0
  GUI_Begin_xDraw_Addr  dd 0
  GUI_Get_focus         db 'Get_focus',0
  GUI_TaskInfo_Addr     dd 0
  GUI_TaskInfo          db 'TaskInfo',0
  GUI_TaskInfo2_Addr    dd 0
  GUI_TaskInfo2         db 'TaskInfo2',0
  GUI_Get_focus_Addr    dd 0
  GUI_Get_string_length db 'Get_string_length',0
  GUI_Get_string_length_Addr dd 0
  GUI_ClearField        db 'ClearField',0
  GUI_ClearField_Addr   dd 0
  GUI_Hide_Window       db 'Hide_Window',0
  GUI_Hide_Window_Addr  dd 0
  GUI_Get_focusID       db 'Get_focusID',0
  GUI_Get_focusID_Addr  dd 0
  GUI_Redraw            db 'Redraw',0
  GUI_Redraw_Addr       dd 0

  KBD_Name              db 'KBD.DRV',0
  KBD_GetKbd            db 'GetKbd',0
  KBD_GetKbd_Addr       dd 0
  KBD_GetWaitKbd        db 'GetWaitKbd',0
  KBD_GetWaitKbd_Addr   dd 0

  CON_Name              db 'CONS.DRV',0
  CON_PutChar           db 'PutChar',0
  CON_PutChar_Addr      dd 0
  CON_PutChar2          db 'PutChar2',0
  CON_PutChar2_Addr     dd 0
  CON_PrintString       db 'PrintString',0
  CON_PrintString_Addr  dd 0
  CON_Get_Position      db 'Get_Position',0
  CON_Get_Position_Addr dd 0
  CON_Set_Position      db 'Set_Position',0
  CON_Set_Position_Addr dd 0
  
  UFS_Name              db 'UFS.DLL',0
  UFS_readfile          db 'readfile',0
  UFS_files             db 'files',0
  UFS_files_addr        dd 0
  UFS_readfile_addr     dd 0

  MOUSE_Name            db 'MOUSE.DRV',0


check1_bmp      db 'check1.bmp',0
check2_bmp      db 'check2.bmp',0
check3_bmp      db 'check3.bmp',0
check4_bmp      db 'check4.bmp',0
check5_bmp      db 'check5.bmp',0
check6_bmp      db 'check6.bmp',0

close1_bmp      db 'close1.bmp',0
close2_bmp      db 'close2.bmp',0
close3_bmp      db 'close3.bmp',0
close4_bmp      db 'close4.bmp',0
max1_bmp        db 'max1.bmp',0
max2_bmp        db 'max2.bmp',0
max3_bmp        db 'max3.bmp',0
max4_bmp        db 'max4.bmp',0
min1_bmp        db 'min1.bmp',0
min2_bmp        db 'min2.bmp',0
min3_bmp        db 'min3.bmp',0
min4_bmp        db 'min4.bmp',0
rest1_bmp       db 'rest1.bmp',0
rest2_bmp       db 'rest2.bmp',0
rest3_bmp       db 'rest3.bmp',0
rest4_bmp       db 'rest4.bmp',0

  Default_XY            rd 1
  Default_XYSize        rd 1
  Save_XY               rd 1
  Save_XYSize           rd 1

  WinID                 rd 1
  win_bitmap            rb 0x18000
  WinName               rd 1
  HeadColor             rd 1
  Buttons               rd 1     

  StdButtons            rd 4096

  Add_HeadColor         rd 1

  ListInfo:             rb lb.Size*lb.MaxElements
  CurCtrl               rb 1

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


section '.edata' export data readable

  export 'MX32.DLL',\
         f1,'OneFunction',\
         VirtualAlloc,'VirtualAlloc',\
         VirtualProtect,'VirtualProtect',\
         VirtualFree,'VirtualFree',\
         CreateProcess,'CreateProcess',\
         ExitProcess,'ExitProcess',\
         ExitProcess,'mx_ExitProcess@4',\
         CreateThread,'CreateThread',\
         CreateThread,'CreateThread@12',\
         ExitThread,'ExitThread',\
         ExitThread,'ExitThread@4',\
         TestKbdInput,'TestKbdInput',\
         PutChar,'PutChar',\
         PutChar2,'PutChar2',\
         PrintString,'PrintString',\
         Get_Position,'Get_Position',\
         Set_Position,'Set_Position',\
         Set_focus,'Set_focus',\
         Set_focusPID,'Set_focusPID',\
         Get_FileAddress,'Get_FileAddress',\
         Inkey,'Inkey',\
         SendMessage,'SendMessage',\
         SendMessage,'SendMessage@16',\
         ReceiveMessage,'ReceiveMessage',\
         ReceiveMessageC,'ReceiveMessage@4',\
         WaitMessage,'WaitMessage',\
         GetPID,'GetPID',\
         GetPID,'GetPID@0',\
         DefineWindow,'DefineWindow',\
         DefineWindow,'DefineWindow@20',\
         DefineButton,'DefineButton',\
         Put_pixel,'Put_pixel',\
         Get_screen_param,'Get_screen_param',\
         Get_string_length,'Get_string_length',\
         Draw_BLine,'Draw_BLine',\
         Draw_BLine,'Draw_BLine@24',\
         Draw_Picture,'Draw_Picture',\
         Kill_Window,'Kill_Window',\
         Write_Text,'Write_Text',\
         Write_Text,'Write_Text@24',\
         WriteText,'WriteText',\
         WriteText,'WriteText@20',\
         Write_Hex,'Write_Hex',\
         WriteHex,'WriteHex',\
         Draw_StdWindow,'Draw_StdWindow',\
         Draw_StdWindow,'Draw_StdWindow@16',\
         StdHandler,'StdHandler',\
         Draw_hLine,'Draw_hLine',\
         Draw_vLine,'Draw_vLine',\
         Get_XYSize,'Get_XYSize',\
         Get_XYSize,'Get_XYSize@0',\
         Get_WinParams,'Get_WinParams',\
         Get_WinParams,'Get_WinParams@4',\
         GetWinParams,'GetWinParams',\
         End_of_redraw,'End_of_redraw',\
         End_of_redraw,'End_of_redraw@0',\
         End_of_xdraw,'End_of_xdraw',\
         Begin_xDraw,'Begin_xDraw',\
         Begin_xDraw,'Begin_xDraw@4',\
         Get_focus,'Get_focus',\
         TaskInfo2,'TaskInfo2',\
         TaskInfo,'TaskInfo',\
         Create_CheckButton,'Create_CheckButton',\
         ClearField,'ClearField',\
         Hide_Window,'Hide_Window',\
         Get_focusID,'Get_focusID',\
         Action4,'Action4',\
         Sleep,'Sleep',\
         Sleep,'Sleep@4',\
         SleepIRQ0,'SleepIRQ0',\
         Update_Screen,'Update_Screen',\
         ReadFile,'ReadFile',\
         FindFile,'FindFile',\
         ListBox,'ListBox',\
         ListBox,'ListBox@32',\
         msgbox,'msgbox',\
         msgbox,'msgbox@8',\
         GetTimer,'GetTimer',\
         GetTimer,'GetTimer@0',\
         DefaultButton,'DefaultButton',\
         DefaultButton,'DefaultButton@4',\
         Draw_Frame_down,'Draw_Frame_down',\
         Create_StdBttn,'Create_StdBttn',\
         Randomize,'Randomize',\
         TaskKill,'TaskKill',\
         TaskKill,'TaskKill@4',\
         TaskList,'TaskList',\
         TaskList,'TaskList@12',\
         print,'print',\
         malloc,'malloc',\
         malloc,'_malloc@4',\
         atoi,'_atoi@4',\
         print,'print@4',\
         GetVersion,'GetVersion',\
         GetPIDsCount,'GetPIDsCount',\
         GetPIDsCount,'GetPIDsCount@0',\
	GetUsagePages,'GetUsagePages',\
	GetUsagePages,'GetUsagePages@0',\
	GetCommandLine,'GetCommandLine',\
	GetCommandLine,'GetCommandLine@0',\
	Create_StdButton,'Create_StdButton@20',\
	Get_XYSizeC,'Get_XYSize@4',\
	StdHandlerC,'StdHandler@4',\
	WaitMessageC,'WaitMessage@4',\
	Get_WinParamsC,'Get_WinParams@8',\
	Create_StdButton,'Create_StdButton'
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
          'FileDescription','Miraculix API',\
          'FileVersion','1.2',\
          'OriginalFilename','MX32.DLL',\
          'InternalName','mx32.dll',\
          'ProductName',ProductName,\
          'SpecialBuild',SpecialBuild,\
          'ProductVersion',ProductVersion,\
          'LegalCopyright',LegalCopyright,\
          'CompanyName',CompanyName,\
          'Comments',rsrcComments,\
          'LegalTrademarks',LegalTrademarks
            
section '.reloc' fixups data readable discardable
