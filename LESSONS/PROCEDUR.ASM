sseg segment stack
 db	32h dup(0)
sseg ends

dseg segment
 prompt	db 'Enter your text: ','$'
 maxlen	db 20
 actlen	db ?
 text	db 20 dup(0)
dseg ends

cseg segment
  assume ss:sseg,cs:cseg,ds:dseg
scan proc near
	pop si
	pop dx
	mov ah,0ah
	int 21h
	push si
	ret
scan ends
main:
   mov ax,dseg
   mov ds,ax
;---------------------------------
	mov dx,offset prompt
	mov ah,09h
	int 21h
	mov dx,offset text
	push dx
	call scan
	mov dx,offset text
	mov bx,dx
	mov al,[bx+1]
	mov ah,'$'
	add bx,ax
	add bx,02h
	mov [bx],ah
	add dx,02h
	mov ah,09h
	int 21h
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
