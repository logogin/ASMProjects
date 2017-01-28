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
		mov di,700h
		mov bx,di
		inc di
		clc
n_equal:	mov al,[di]
		mov ah,[bx]
		cmp al,ah
		jz finish
		cmp bx,0FFh
		cmp di,0FFFFh
		jz finish
		inc bx
		inc di
		jnz n_equal
finish:		mov ax,bx 
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
