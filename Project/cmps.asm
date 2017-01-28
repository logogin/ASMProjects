masm
model small
stack 100h
.data
match db 0ah,0dh,"String are matching$"
filed db 0ah,0dh,"Strings are not matching$"
string1 db "0123556789",0ah,0dh,'$'
string2 db "0123456789",0ah,0dh,'$'
;len equ $-source
;dest db len DUP (" ")
.code
	assume	ds:@data,es:@data
main:
	mov	ax,@data
	mov	ds,ax
	mov	es,ax
	
	mov	ah,09h
	lea	dx,string1
	int	21h
	lea	dx,string2
	int	21h

	cld
	lea	si,string1
	lea	di,string2
	mov	cx,10
cycl:
	repe	cmpsb
	jcxz	equal
	jne	not_match
equal:
	mov	ah,09h
	lea	dx,match
	int	21h
	jmp	exit
not_match:
	mov	ah,09h
	lea	dx,filed
	int	21h
	dec	si
	dec	di
	mov	ah,02h
	lodsb
	mov	dl,al
	int	21h
	mov	dl,32
	int	21h
	push	si
	mov	si,di
	lods	string2
	mov	di,si
	pop	si
	mov	dl,al
	int	21h
	jmp	cycl		

exit:
	mov 	ax,4c00h
	int	21h
end	main

