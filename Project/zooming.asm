masm
model small
stack 100h
.data
mes1 db " not equal to 0",0ah,0dh,'$'
mes2 db " equal to 0",0ah,0dh,'$'
mes3 db "element $"
array dw 2,7,0,0,1,9,3,6,0,8
.code
.486
main:
	mov	ax,@data
	mov	ds,ax
	xor	ax,ax
prepare:
	mov	cx,10
	mov	esi,0;
compare:
	mov	dx,array[esi*2]
	cmp	dx,0
	je	equal
not_equal:
	mov	ah,09h
	lea	dx,mes3
	int 	21h
	mov	ah,02h
	mov	dx,si
	add	dl,30h
	int	21h
	mov	ah,09h
	lea	dx,mes1
	int	21h
	inc	esi
	dec	cx
	jcxz	exit
	jmp	compare
equal:
	mov	ah,09h
	lea	dx,mes3
	int	21h
	mov	ah,02h
	mov	dx,si
	add	dl,30h
	int	21h
	mov	ah,09h
	lea	dx,mes2
	int	21h
	inc	esi
	dec	cx
	jcxz	exit
	jmp	compare
exit:
	mov 	ax,4c00h
	int	21h
end	main

