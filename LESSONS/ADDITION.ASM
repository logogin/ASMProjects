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
	mov al,4bh
	mov dl,3ah
	mov cl,5ch
	mov bl,al
	add bl,dl
	add bl,cl
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
