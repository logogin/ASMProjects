; 
; Problem 4.
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
		mov bx,390h  ;OffSet to BX
		mov ah,[bx]
		mov dl,01h   ;DL=1 (first, number not divided by 7)
		mov ch,80h   ;10000000b to CH
		mov al,ah    ;reserving number in AH
		and al,ch    ;checking bit of sign
		cmp ch,al
		je negative  ;if number is negative then go to label

next:		sub ah,07h   ;AH=AH-7
		jz divided   ;if AH=0 then number divided by 7 and go to label
		mov al,ah    ;reserving number in AH
		and al,ch    ;checking bit of sign
		cmp al,00h   ;if number is positive yet
		je next      ;then go to next loop  

		jmp finish   ;to end of the program 
negative:	add ah,07h   ;AH=AH+7
		jz divided   ;if AH=0 then number divided by 7 and go to label  
		mov al,ah    ;reserving number in AH
		and al,ch    ;checking bit of sign
		cmp al,80h   ;if number is negative yet
		je negative  ;then go to next loop

		jmp finish   ;to the end of the program
divided:	mov dl,00h   ;DL=0, number divided by 7
finish:		nop	
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
