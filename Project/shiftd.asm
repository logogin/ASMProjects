masm
model small
stack 100h
.data
addres label dword
field_l dd 0b21187f5h
field_h dd 45ff6711h
.code
main:
	mov ax,@data
	mov ds,ax
	mov	cl,10h
.386
	mov	eax,field_l
	shld	field_h,eax,cl
	shl	field_l,cl
exit:
	mov 	ax,4c00h
	int	21h
end	main

