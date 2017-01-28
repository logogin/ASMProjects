;
; Problem 5.
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
		mov bx,50h      ;OffSet to BX 
		mov ah,[bx]     ;from [BX] to AH
		mov al,[bx+01h] ;from [BX+01h] to AL
		add ah,al       ;AL=AL+AH
		mov al,ah       ;reserving result of addition
		and al,80h      ;checking bit of sign, if the result is negative
		jnz finish      ;then go to the end

		cmp ah,dl       ;comparing with low level 
		jb finish       ;if AH<DL then go to end 

		cmp ah,dh       ;comparing with high level
		ja finish       ;if AH>DH then go to end
		mov [bx+10h],ah ;(AH<DH) and (AH>DL)
finish:		nop	
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
