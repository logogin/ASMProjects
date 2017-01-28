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
	mov di,320h
	mov bl,[di]
	add bl,[di+1]
	add bl,[di+2]
	mov [di+3],bl
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
