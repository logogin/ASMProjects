data	segment	para public 'data'	;сегмент данных
;-----------------------------------------------------

;-----------------------------------------------------
data	ends

stk	segment	stack
	db	256 dup ('?')	;сегмент стека
stk	ends

code	segment	;начало сегмента кода
	assume cs:code,ds:data,ss:stk
main:	mov	ax,data	;адрес сегмента данных в регистр ax
	mov	ds,ax	;ax в ds
;------------------------------------------------------
	mov     ax,0bc5ah
	mov	bx,3000
	mov	cx,ax
	mov	ax,bx
	mov	bx,cx
;------------------------------------------------------
	mov	ax,4c00h	;пересылка 4c00h в регистр ax
	int	21h	;вызов прерывания с номером 21h
code	ends		;конец сегмента кода
end	main		;конец программы с точкой входа main

