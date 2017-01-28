; 19.01.2001
; Home Work no. 2 (Laboratory)
; Pavel Danchenko, group no. 6
;
; Problem 1.  
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
	mov bx,0FFFFh  ;moving base to BX
	mov es,bx      ;moving base Extra Segment 
	mov bx,0Eh
	mov al,es:[bx] ;moving data from cell 0FFFFEh
	mov bx,100h
	mov [bx],al    ;moving data to cell DS:0100h
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
