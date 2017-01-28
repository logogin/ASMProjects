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
	 mov dx,3d4h
	 mov al,09h
	 out dx,al
	 inc dx
	 in al,dx
	 and al,01100111b
	 or  al,00000111b
	 out dx,al
;	 dec dx
;	 mov al,0ah
;	 out dx,al
;	 inc dx
;	 mov al,2
;	 out dx,al
;	 dec dx
;	 mov al,0bh
;	 inc dx
;	 in al,dx
;	 and al,11100000b
;	 or al,5
;	 out dx,al
;--------------------------------
   mov ah,4ch
   mov al,00
   int 21h
cseg ends
end main
