;
; Miraculix stub for PE header
;       
format MZ


include 'const.inc'

	push	cs
	pop	ds

	mov	ah,9
        mov     dx,message
	int	21h

        mov     ax,4C01h
	int	21h

message db 'This program requires ',OSName,' or Windows',ENDL
        db 'You may download ',OSName,' here: ',Site,ENDL
        db '$'
