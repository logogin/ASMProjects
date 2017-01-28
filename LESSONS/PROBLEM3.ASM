;
; Problem 3.
;
sseg segment stack
sseg ends

dseg segment
dseg ends

cseg segment
  assume ss:sseg,cs:cseg,ds:dseg
main:
   mov ax,dseg
   mov ds,ax
;---------------------------------
		mov bx,100h     ;OffSet 100h to BX
		mov al,01h      ;first element of Fibonachi row
		mov [bx],al     
		mov [bx+1],al   ;second element of Fibonachi row
		mov bx,102h
		mov cx,18h      ;number of loops
begin:		mov al,[bx-01h] ;A[n-1]
		mov ah,[bx-02h] ;A[n-2]
		add al,ah       ;A[n]=A[n-1]+A[n-2]
		mov [bx],al     ;A[n] to BX
		inc bx          ;BX=BX+1 
		loop begin      ;end of loop 
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
