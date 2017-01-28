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
   mov dh,4ah
   mov ah,0f5h
   mov dl,dh
   mov dh,ah
   mov ah,dl
;---------------------------------
   mov ah,4Ch
   mov al,00h
   int 21h
cseg ends
end main
