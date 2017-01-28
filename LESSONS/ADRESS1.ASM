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
	mov bx,450h
	mov di,460h
	mov al,[bx]
	mov ah,[di]
	mov [di],al
	mov [bx],ah
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
