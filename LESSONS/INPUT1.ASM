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
	mov ah,01h
	int 21h
	mov dl,al
	mov ah,01h
	int 21h
	mov dh,al
	sub dl,dh
	add dl,30h
	mov ah,02h
	int 21h
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
