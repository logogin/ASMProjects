sseg segment stack
sseg ends

dseg segment
	;num1 db ?
	;num2 db ?
dseg ends

cseg segment
  assume ss:sseg,cs:cseg,ds:dseg
main:
   mov ax,dseg
   mov ds,ax
;---------------------------------
	mov ch,00h
	mov ah,01h
	int 21h
	mov dh,al
	mov dl,01h
	int 21h
	sub dh,30h
	mov cl,dh
next:	mov ah,02h
	int 21h
	jmp next
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
