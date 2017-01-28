masm
model small
stack 100h
.586p
pnt	struc
	union
offs_16 dw ?
offs_32 dd ?
ends
segm dw ?
pnt ends

.data
point union
off_16 dw ?
off_32 dd ?
point_16 pnt <>
point_32 pnt <>
point ends
string db "Testing string $"
adr_data point <>

.code

main:
	mov	ax,@data
	mov	ds,ax
	mov	adr_data.point_16.segm,ax
	mov	bx,adr_data.point_16.segm
	mov	ax,offset string
	mov	adr_data.point_16.offs_16,ax
	mov	bx,adr_data.point_16.offs_16
exit:
	mov 	ax,4c00h
	int	21h
end	main