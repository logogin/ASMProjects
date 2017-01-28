; 
; Problem 7.
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
		mov ax,50h    
		mov es,ax      ;new base to Extra Segment 
		mov di,10h    
		mov bx,100h    ;OffSet to BX
		mov dl,0AAh    ;DL=0AAh
		mov dh,0FFh    ;DH=0FFh
		mov cx,10h     ;number of loops
		mov ah,00h     ;AH=0, count is zero
begin:		mov al,es:[di] ;from address 0510h
		cmp al,dl      ;if AL<DL then
		jb next        ;go to the next loop 
		cmp al,dh      ;if AL>DH then 
		ja next        ;go to the next loop 
		inc ah         ;else increase count 
next:		inc di         ;DI=DI+1
		loop begin
		mov [bx],ah    ;moving count to DS:[BX]
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
