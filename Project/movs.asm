masm
model small
stack 100h
.data
source db "Tested string",'$'
len equ $-source
dest db len DUP (" ")
.code
	assume	ds:@data,es:@data
main:
	mov	ax,@data
	mov	ds,ax
	mov	es,ax
	cld
	lea	si,source
	lea	di,dest
	mov	cx,len
	rep
	movs	dest,source
	lea	dx,dest
	mov	ah,09h
	int	21h
exit:
	mov 	ax,4c00h
	int	21h
end	main

