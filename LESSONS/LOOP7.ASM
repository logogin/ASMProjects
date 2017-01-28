sseg segment stack
sseg ends

dseg segment
	num1 db 00h
	num2 db 00h	
dseg ends

cseg segment
  assume ss:sseg,cs:cseg,ds:dseg
main:
   mov ax,dseg
   mov ds,ax
;---------------------------------
		mov cx,04h
		mov di,300h
		mov ax,00h
		mov bx,00h
		clc
addition:	;mov num1,[di]
		adc al,[di]
		inc di
		;mov num2,[di]
 		adc bl,[di]
		inc di
		loop addition
	cmp ax,bx
	jz equal
	jmp finish
equal:  mov bx,01h
finish: mov bx,00h
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
