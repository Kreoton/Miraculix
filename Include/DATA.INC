;
;       OS Name
;
OS_NameU83              equ "MX"
OS_Name                 equ "Miraculix" 
OS_Copyright            equ "Copyright ","(C)"," 2004-2005 by Kreoton"
OS_Loading              equ "MX Loader v0.1"
;
;       FDD Boot
;     
boot_Path               equ "axe"

; View:
boot_Error_msg          equ "File not found"
boot_OEM                equ "BootDOS "
boot_VolumeLabel        equ "Miraculix  "
boot_SerialNumber       = 0x130106

; Memory Map:
LoadCode_Segment        = 0x1010
PSP_Segment             = 0x1000
boot_MemoryAddress      = 0x7C00
boot_LoadMemoryAddress  = 0x7C00
FAT_MemoryAddress       = 0x500
boot_StackAddress       = 0x7C00

; Boot Extensions:
boot_try                = 1
boot_CmdLine            = 1
boot_Stack              = 1
boot_LoadFAT2           = 1
boot_OneFAT             = 1
boot_Above64            = 0

boot_SecretCode         = 0

Max_try13               = 2
;
;       Disk loader
;     
ldr_org                 = 0x100             ; COM
ldr_SysPath             equ OS_NameU83,"\SYSTEM\"
ldr_DiskChar            equ "A"
ldr_optTextFont         = 1
ldr_Stack               = 1
exitint_number          = 0x30
fsint_number            = 0x31
ldr_filename            equ ldr_SysPath,"startup.com"
