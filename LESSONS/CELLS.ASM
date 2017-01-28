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
	mov bx,500h
	mov ah,00h
	mov [bx],ah
	mov al,[bx+10h]
	mov [bx],al
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
