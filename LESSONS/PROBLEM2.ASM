;
; Problem 2.
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
		mov bx,300h      
		mov cx,10h	 ;number of loops
begin:		mov al,[bx]      ;begin of loop, from [BX] to AL 
		mov ah,[bx+20h]  ;from [BX+20H] to AH
		mov [bx],ah      ;from AH to [BX]
		mov [bx+20h],al  ;from AL to [BX+20h]
		inc bx           ;BX=BX+1
		loop begin       ;end of loop
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
