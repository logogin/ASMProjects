masm
model small
stack 100h
iotest	record i1:1,i2:2=01,i3:1,i4:2=11,i5:2=00
.data
flags iotest <>
ent db 0ah,0dh,'$'
.code

main:
	mov	ax,@data
	mov	ds,ax
	xor	ax,ax
	xor	bx,bx
	mov	bh,[flags]
	mov	cx,8
cycl:
	shl	bh,1
	jnc	zero
	mov	dl,31h
	jmp	next
zero:
	mov	dl,30h
next:
	mov	ah,02h
	int	21h
	loop	cycl
	lea	dx,ent
	mov	ah,09h
	int	21h
	
	mov	ah,mask i2
	mov	al,[flags]
	and	al,ah
	shr	al,i2

	not	ah
;	mov	bl,[flags]
	and	[flags],ah
	mov	ah,02h
	shl	ah,i2
	or	[flags],ah
	
	xor	bx,bx
	mov	bh,[flags]
	mov	cx,8
cycl1:
	shl	bh,1
	jnc	zero1
	mov	dl,31h
	jmp	next1
zero1:
	mov	dl,30h
next1:
	mov	ah,02h
	int	21h
	loop	cycl1
	lea	dx,ent
	mov	ah,09h
	int	21h
exit:
	mov 	ax,4c00h
	int	21h
end	main