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
	mov bx,575h
	mov al,[bx]
	cmp al,[bx+04h]
	ja equal
	mov bx,100h
	mov al,00h
	mov [bx],al
	jmp finish
equal:  mov bx,100h
	mov al,01h
	mov [bx],al
finish: nop
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
