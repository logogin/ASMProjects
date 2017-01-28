COMMENT #  
  ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                                     
€                                            €                                    
€  MOD 1.0 - Source Code in ASM (A86)        €                                    
€                                            €                                    
€  Code by Dake - 1996                       €   
€                                            € 
€  http://www.omedia.ch/pages/dake/index.htm €   
€  dake@omedia.ch                            €                                               €                                          €   
€                                            €                                               €                                          €   
€                                            €   
  ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ 
  
 What does this crap ? It toggles between different text modes under DOS.
 You can use this code to learn but don't be a lamer, don't said
 that this code is yours or I'll send you the subscription for the
 LFC (lamers.fans.club). ;)

 It's the first useful thing I coded in ASM so don't blame me
 if this source is for beginner. There are some bugs if you change
 between VESA mode and 80x50. On my PC, VESA modes and their scrollings
 are quite lame. The help screen sometimes disappear.

 To compile : A86 MOD10.asm

 #

;  ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                                     
;€                                            €                                    
;€  Check what is on the command line         €                                    
;€                                            €                                    
;  ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ 

START:             
xor cx,cx               ;CX is a counter
mov di,081h             ;081h because it's the start of the command
                        ;line data (127 bytes), if you have 'HELP 12'
                        ;the first byte will be '1' and the 2nd '2'
                        ;the register 'ES' has the value of the PSP

Check_Key:
mov al,es:[di]          ;take the first byte in command l.
cmp al,'/'              
jz check_com            ;if the cara. is '/' then we go to check_com
                        ;to see if we have a special command for us

inc di                  ;no ! so we go to next byte in command line
inc cx                  ;cx is incremented
cmp cx,70               
jna Check_Key           ;if cx>70 then we stop our activity and we 
                        ;go back to the DOS


;  ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                                     
;€                                            €                                    
;€  Text mode and back to the DOS             €                                    
;€                                            €                                    
;  ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ  

Normal_End:             ;we finish here if we checked more than 70
call BLACK              ;bytes in the command line
mov ax,03h
int 10h                 ;text mode 80x25
mov ah,09h
lea dx,help             ;a little message
int 21h
mov ax,04ch             ;back to the dos
int 21h

;  ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                                     
;€                                            €                                    
;€  Check which caracters are on command line €                                    
;€                                            €                                    
;  ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ  

; If the first routine 'Check_Key' is OK, we come in this 
; part to check which keys have been typed

Check_Com:
mov al,es:[di+1]
cmp al,49                 ;49 is the code for '1'
jz  MODE49                ;if we have this code, we go to the MODE 49
cmp al,50                 ;'2' ?
jz  MODE50                ;the same..
cmp al,51                 ;'3' ?          
jz  MODE51
cmp al,52                 ;'4' ?          
jz  MODE52
cmp al,53                 ;'5' ?          
jz  MODE53
cmp al,54                 ;'6' ?
jz  MODE54
cmp al,55                 ;'7' ?
jz  MODE55
cmp al,56                 ;'8' ?
jz  NORML              
cmp al,57                 ;'9' ?
jz  BLACKWHITE
;;......................................................................
mov ax,03h
int 10h
mov ah,09h                ;if we haven't any of these codes
lea dx,help
int 21h                   ;we print a message and
mov ax,04ch
int 21h                   ;finish in the DOS
;......................................................................
;  ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                                     
;€                                            €                                    
;€  The different text modes                  €                                    
;€                                            €                                    
;  ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ  

;You can find the interruption parameters to set this text modes
;in interrupt lists like HELPPC. (excepted for VESA modes and non-bios
;modes) - 

Norml:                    
mov ax,03h
int 10h
call BLACK
call retour
;......................................................................
;......................................................................
Mode49:                   ;40x25 B/W
mov ax,0                  ;fonction 0 
int 10h                   ;interrupt 10
call retour      
;......................................................................
Mode50:                   ;40x25 16 colors
mov ax,01h                ;fonc. 01h
int 10h
call retour      
;......................................................................
Mode51:                   ;80x30 16 colors
call T8030 
call retour      
;......................................................................
Mode52:                   ;80x50 16 colors
call T8050
call retour      
;......................................................................
Mode53:                   ;132x60 vesa
mov w[vesamodes],010ch
call T132
call retour      
;......................................................................
Mode54:                   ;132x50 vesa        
mov w[vesamodes],010Bh
call T132
call retour      
;......................................................................
Mode55:                   ;132x43 vesa        
mov w[vesamodes],010Ah
call T132
call retour      
;......................................................................
BlackWhite:
call BACKGROUND            ;the background is white and the text is black
;......................................................................
RETOUR PROC               ;when the text mod is set, we go
mov ax,4c00h              ;to the DOS
int 21h
ret
RETOUR ENDP
;......................................................................
T8050 PROC                ;I've found this code in SWAG 
                          ;it was a PASCAL-ASM example...
mov ax,01202h
mov bl,030h
int 10h                   ;don't ask me why it's like it ...
mov ax,03h
mov ax,01112h
mov bl,0
int 10h
ret
T8050 ENDP
;......................................................................
T8030 PROC        ;I can't remember who wrote this stuff...
mov ax,3
int 10h           ;but I think there's a better way to set this mode...
mov ax,1114h      ;I'm too lazy to search it ;)
xor bl,bl
int 10h
mov dx,3cch
in al,dx
mov dl,0c2h
or al,3*64  
out dx,al
mov dx,3d4h
mov al,11h
out dx,al
inc dx
and al,not (15+128)
or al,12
mov bl,al
out dx,al
dec dx
mov si,offset V480
mov cx,V480size
@OutIt:
lodsw
out dx,ax
loop @OutIt
mov al,11h
out dx,al
inc dx
mov al,bl
out dx,al
mov ax,40h
mov es,ax
mov [byte es:84h],29  
ret
T8030 ENDP
;......................................................................
BACKGROUND PROC
mov ah,10h
mov al,10h
mov bx,0                  
mov ch,55                  ;ch-cl and dh are the three values for R,G,B
mov cl,55  
mov dh,55                  ;a grey-white for the background
int 10h                    ;the bios fonction to change the color
mov ah,10h
mov al,10h
mov bx,7
mov ch,0                   ;a pure black for the letters
mov cl,0
mov dh,0
int 10h                    ;the bios fonction to change the color
ret
BACKGROUND ENDP
;......................................................................
BLACK PROC                 ;here are the settings for the normal
mov ah,10h                 ;screen - grey on black
mov al,10h
mov bx,7
mov ch,55
mov cl,55
mov dh,55
int 10h
mov ah,10h
mov al,10h
mov bx,0
mov ch,0
mov cl,0
mov dh,0
int 10h
ret
BLACK ENDP
;......................................................................
T132 PROC              ;(C) Source from Jonathan Zarate   
vesa  proc near
mov ax,4F03h           ;it uses the VGA registers 
int 10h 
cmp ax,004Fh           ;so read a good book or doc about VGA cards 
je @@10                ;to understand this
clc;
mov ah,09h
lea dx,not_vesa
int 21h
ret
@@10: 
mov cx,1 
mov si,offset vesamodes  
@@20: 
lodsw
mov bx,ax
mov ax,4F02h 
int 10h  
cmp ax,004Fh 
je @@30 
loop @@20
clc
ret
@@30: stc
ret
vesa  endp
vesabuffer db 256 dup(?)
T132 ENDP
;......................................................................
V480 dw 0B06h,3E07h,0EA10h,0DF12h,0E715h,0416h
V480size = ($-V480) shr 1

CRTCdata dw 06B00h  ;Horizontal Total 
dw 05901h  ;Horizontal Displayed 
dw 05A02h  ;Start Horiz Blanking 
dw 08E03h  ;End Horiz Blanking 
dw 06004h  ;Start Horiz Retrace 
dw 08D05h  ;End Horiz Retrace 
dw 02D13h  ;Memory Allocation 

vesamodes dw ?
include help.inc               ;the help screen
not_vesa db 'Vesa Mode not supported $'
;......................................................................

