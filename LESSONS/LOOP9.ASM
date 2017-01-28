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
		mov ax,10h
		mov es,ax
		mov di,00h
		mov dl,150d
		mov dh,200d
		mov cx,10h
		mov bx,500h
		mov ah,00h
		clc
compare:	mov al,es:[di]
		inc di
		cmp al,dl
		ja next
		jmp end
next:		cmp al,dh
		jb moving
end:		nop
		loop compare
		jmp finish
moving		inc ah
		mov [bx],ah
finish:		nop
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
