data	segment	para public 'data'	;ᥣ���� ������
;-----------------------------------------------------

;-----------------------------------------------------
data	ends

stk	segment	stack
	db	256 dup ('?')	;ᥣ���� �⥪�
stk	ends

code	segment	;��砫� ᥣ���� ����
	assume cs:code,ds:data,ss:stk
main:	mov	ax,data	;���� ᥣ���� ������ � ॣ���� ax
	mov	ds,ax	;ax � ds
;------------------------------------------------------
	mov     ax,0bc5ah
	mov	bx,3000
	mov	cx,ax
	mov	ax,bx
	mov	bx,cx
;------------------------------------------------------
	mov	ax,4c00h	;����뫪� 4c00h � ॣ���� ax
	int	21h	;�맮� ���뢠��� � ����஬ 21h
code	ends		;����� ᥣ���� ����
end	main		;����� �ணࠬ�� � �窮� �室� main

