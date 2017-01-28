masm
model small
stack 100h
.data
mes1 db "Source array:",0ah,0dh,'$'
mes2 db 0ah,0dh,"Sorted array:",0ah,0dh,'$'
blank db " $"
n equ 10
array dw 2,7,0,1,9,3,6,5,8,4
i dw 0
j dw 0
tmp dw ?
.code
.486
main:
	mov	ax,@data
	mov	ds,ax
	xor	ax,ax
prepare:
	mov	cx,n
	mov	esi,0;
	mov	ah,09h
	lea	dx,mes1
	int	21h
show_source:
	mov	dx,array[esi*2]
	mov	ah,02h
	add	dl,30h
	int	21h
	mov	ah,09h
	lea	dx,blank
	int	21h
	inc	esi
	loop	show_source
	mov	cx,n
	dec	cx
i_loop:
	push	cx
	push	i
	pop	j
	inc	j
	mov	cx,n
	sub	cx,j
j_loop:
	xor	esi,esi
	mov	si,i
	mov	bx,array[esi*2]
	mov	si,j
	cmp	bx,array[esi*2]
	jle	next
	
	mov	ax,array[esi*2]
	mov	tmp,ax
	mov	array[esi*2],bx
	mov	bx,tmp
	mov	si,i
	mov	array[esi*2],bx
next:	
	inc	j
	loop	j_loop
	inc	i
	pop	cx
	loop	i_loop
	
	mov	ah,09h
	lea	dx,mes2
	int	21h
	mov	cx,n
	mov	esi,0
show_sorted:
	mov	ah,02h
	mov	dx,array[esi*2]
	inc	si
	add	dl,30h
	int	21h
	mov	ah,09h
	lea	dx,blank
	int	21h
	loop	show_sorted
exit:
	mov 	ax,4c00h
	int	21h
end	main

