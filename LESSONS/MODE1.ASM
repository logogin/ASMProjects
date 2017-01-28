sseg segment stack
sseg ends

dseg segment
dseg ends

cseg segment
  assume ss:sseg,cs:cseg,ds:dseg
main:
   mov ax,dseg
   mov ds,ax
;--------------------------------
	mov ax,00h
	mov bx,00h
	in al,bx	
;--------------------------------
   mov ah,4ch
   mov al,00
   int 21h
cseg ends
end main
