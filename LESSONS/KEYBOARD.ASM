sseg segment stack
sseg ends

dseg segment
	prompt db 10,13,'TRUE$'
dseg ends

cseg segment
  assume ss:sseg,cs:cseg,ds:dseg
main:
   mov ax,dseg
   mov ds,ax
;---------------------------------
	mov dh,0dh
	mov dl,00h
next:	mov ah,01h
	int 21h
	inc dl
	cmp al,dh
	jnz next
	mov dh,06h
	cmp dl,dh
	jb finish
	mov dx,offset prompt
	mov ah,09h
	int 21h
finish:	nop
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
