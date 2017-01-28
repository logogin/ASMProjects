masm
model small
stack 100h
.data

bit_str dd 11010111h
ins_str dd 0ffff0000h
.code
main:
	mov	ax,@data
	mov	ds,ax
	xor	ax,ax
.386
	mov	eax,ins_str
	ror	bit_str,8
	shr	bit_str,16
	shld	bit_str,eax,16
	rol	bit_str,8
exit:
	mov 	ax,4c00h
	int	21h
end	main

