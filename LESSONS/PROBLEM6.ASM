;
; Problem 6.
;
sseg segment stack
sseg ends

dseg segment
dseg ends

cseg segment
  assume ss:sseg,cs:cseg,ds:dseg
main:
   mov ax,dseg
   mov ds,ax
;---------------------------------
		mov bx,450h     ;OffSet to BX
		mov al,[bx]     ;from [BX] to AL
		clc             ;clearing CF
		add al,[bx+01h] ;AL=AL+[BX+01h]
		mov ah,00h      ;AH=0
		adc ah,00h      ;AH=AH+0+CF or AH=CF
		clc             ;clearing CF
		mov cl,[bx+02h] ;from [BX+02h] to CL
		add cl,[bx+03h] ;CL=CL+[BX+03h]
		mov ch,00h      ;CH=0
		adc ch,00h      ;CH=CH+0+CF or CH=CF
		cmp ax,cx       ;if AX<CX
		jb finish       ;then go to end
		sub ax,cx       ;else AX=AX-CX
		mov dx,ax       ;DX=AX 
finish:		nop	 		
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
