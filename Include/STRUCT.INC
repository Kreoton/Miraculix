struc Exceptions
        {
     .DE        = 0x00   ; Div by 0
     .DB        = 0x01   ; Debug
     .NMI       = 0x02   ; Non maskable interrupt     
     .BP        = 0x03   ; Break point 
     .OF        = 0x04   ; Overflow
     .BR        = 0x05   ; Bound range exceeded     
     .UD        = 0x06   ; Illegal instruction
     .NM        = 0x07   ; Processor extension not availabale
     .DF        = 0x08   ; Double fault, param=0
     .EF        = 0x09   ; Processor extension protection fault
     .TS        = 0x0A   ; Invalid task state segment, param=EXT
     .NP        = 0x0B   ; Segment not present, param=EXT
     .SS        = 0x0C   ; Stack fault, param=SEL
     .GP        = 0x0D   ; General protection fault, param=SEL
     .PF        = 0x0E   ; Page fault, param= bit# 0:GP 1:W 2:CPL 3:AttrErr
     .MF        = 0x10   ; Coprocessor error     
     .AC        = 0x11   ; Alignment error, param=0
     .MC        = 0x12   ; Machine chech exception, param=???
     .XF        = 0x19   ; SSE fault
        }
Exception Exceptions

IRQ0_Base       = 0x20
IRQ8_Base       = 0x28

struc IRQs
        {
     .0         = IRQ0_Base + 0x0   ; Timer
     .1         = IRQ0_Base + 0x1   ; Keyboard
     .2         = IRQ0_Base + 0x2   ; PIC
     .3         = IRQ0_Base + 0x3   ; COM2
     .4         = IRQ0_Base + 0x4   ; COM1
     .5         = IRQ0_Base + 0x5   ; ---free---
     .6         = IRQ0_Base + 0x6   ; FDC
     .7         = IRQ0_Base + 0x7   ; LPT1

     .8         = IRQ8_Base + 0x0   ; Real-time clock
     .9         = IRQ8_Base + 0x1   ; Video card
     .10        = IRQ8_Base + 0x2   ; ---free---
     .11        = IRQ8_Base + 0x3   ; ---free---
     .12        = IRQ8_Base + 0x4   ; PS/2
     .13        = IRQ8_Base + 0x5   ; FPU
     .14        = IRQ8_Base + 0x6   ; IDE
     .15        = IRQ8_Base + 0x7   ; IDE
        }
IRQ IRQs

struc TaskStaySegment
        {
     .link      = 0x00
     .esp0      = 0x04
     .ss0       = 0x08
     .esp1      = 0x0C
     .ss1       = 0x10
     .esp2      = 0x14
     .ss2       = 0x18
     .cr3       = 0x1C
     .eip       = 0x20
     .eflags    = 0x24
     .eax       = 0x28
     .ecx       = 0x2C
     .edx       = 0x30
     .ebx       = 0x34
     .esp       = 0x38
     .ebp       = 0x3C
     .esi       = 0x40
     .edi       = 0x44
     .es        = 0x48
     .cs        = 0x4C
     .ss        = 0x50
     .ds        = 0x54
     .fs        = 0x58
     .gs        = 0x5C
     .ldt       = 0x60
     .TaskFlags = 0x64
     .IO        = 0x66
        }
tss TaskStaySegment

struc TaskDescriptor
        {
     .Address           = 0xC0001000    ; Reserved virtual space
     .AllSize           = 0x30000000
     .PID_Offset        = 0x00 +0x80
     .TSS_Offset        = 0x04 +0x80
     .Status_Offset     = 0x08 +0x80
     .Priority_Offset   = 0x0C +0x80
     .BaseProcess       = 0x10 +0x80
     .Name_Offset       = 0x20 +0x80
     .Name_Size         = 0x20
;     .Name_Offset       = 0x20 +.Name_Size+0x80
     .TWinID            = 0x40 +0x80
     .ParentPID         = 0x44 +0x80	; word
     .Group             = 0x46 +0x80 	; byte
     .User              = 0x47 +0x80	; word
     .StartTick         = 0x49 +0x80	; dword
     .Console           = 0x4D +0x80    ; dword - console buffer in private app memory. will fill from child
     .Reserved          = 0x51 +0x80    ; (0x13 - reserved ...0x60)
     .IntMap            = 0xE0
     .IOMap             = 0x100
     .EndIOMap          = 0x2100
     .FXState           = 0x2200
     .Size              = 0x3000
        }
TD TaskDescriptor

struc TaskListInfo {
    .PID                = 0x02	; word
    .BaseProcess        = 0x04	; word
    .StartTick          = 0x06	; dword
    .WID                = 0x0A	; word
    .ParentPID          = 0x0C	; word
    .User               = 0x0E	; word
    .Reserved           = 0x10	; 0x10...0x1F
    .Name               = 0x20
    .Size               = 0x40
}
tinfo TaskListInfo
  
struc CR0_Reg
        {
     .PE                = 00000000000000000000000000000001b  ; Protected mode
     .MP                = 00000000000000000000000000000010b  ; 286 fwait
     .EM                = 00000000000000000000000000000100b  ; Emul soproc
     .TS                = 00000000000000000000000000001000b  ; TS
     .NE                = 00000000000000000000000000100000b  ; 0:IRQ13,1:#MF (FPU Error)
     .WP                = 00000000000000010000000000000000b  ; Write page
     .AM                = 00000000000001000000000000000000b  ; Alignment mode
     .NW                = 00100000000000000000000000000000b  ; No write in cache
     .CD                = 01000000000000000000000000000000b  ; Cache disable
     .PG                = 10000000000000000000000000000000b  ; Page mode
        }
CR0_ CR0_Reg

struc CR3_Reg
        {
     .PWT               = 00000000000000000000000000001000b  ; Page write table
     .PCD               = 00000000000000000000000000010000b  ; Page cache disable
        }
CR3_ CR3_Reg

struc CR4_Reg
        {
     .VME               = 00000000000000000000000000000001b  ; VIF for V86
     .PVI               = 00000000000000000000000000000010b  ; VIF for PM
     .TSD               = 00000000000000000000000000000100b  ; RDTSC execute in ring0 only
     .DE                = 00000000000000000000000000001000b  ; No debug port
     .PSE               = 00000000000000000000000000010000b  ; Page 4M
     .PAE               = 00000000000000000000000000100000b  ; 36-Bit address mode
     .MCE               = 00000000000000000000000001000000b  ; Machine check
     .PGE               = 00000000000000000000000010000000b  ; Global pages
     .PMC               = 00000000000000000000000100000000b  ; RDPMC all rings
     .FSR               = 00000000000000000000001000000000b  ; FXSAVE/FXRSTOR
        }
CR4_ CR4_Reg

struc FXStateSegment
        {
     .FCW               = 0x000
     .FSW               = 0x002
     .FTW               = 0x004
     .FOP               = 0x006
     .FIP               = 0x008
     .FCS               = 0x00C
     .FDP               = 0x010
     .FDS               = 0x014
     .MXCSR             = 0x018
     .mm0               = 0x020         ; FPU or MMX
     .mm1               = 0x030
     .mm2               = 0x040
     .mm3               = 0x050
     .mm4               = 0x060
     .mm5               = 0x070
     .mm6               = 0x080
     .mm7               = 0x090
     .xmm0              = 0x0A0         ; SSE
     .xmm1              = 0x0B0
     .xmm2              = 0x0C0
     .xmm3              = 0x0D0
     .xmm4              = 0x0E0
     .xmm5              = 0x0F0
     .xmm6              = 0x100
     .xmm7              = 0x110
        }
FXS FXStateSegment


