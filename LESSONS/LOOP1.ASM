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
	mov bx,200h
	mov al,[bx]
	cmp ah,al
	jnbe finish
	mov al,11h
	mov [bx],al	
finish:  nop
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
