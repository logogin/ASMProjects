masm
model small
stack 100h
.data
len=4
unpck_BCD label dword
dig_BCD db 2,4,3,6
pck_BCD dd 0
.code
main:
	mov	ax,@data
	mov	ds,ax
	xor	ax,ax
	mov	cx,len
.386
	mov	eax,unpck_BCD
m1:
	shl	eax,4
	shld	pck_BCD,eax,4
	shl	eax,4
	loop	m1
exit:
	mov 	ax,4c00h
	int	21h
end	main

