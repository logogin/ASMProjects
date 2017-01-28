Comment *

        Purpose:
            demos "flashing" text under attribute control mode 0.

        Required external modules:
            flash0.obj

        Prep:
            masm demo0;     (tested under MASM 5.1, OPTASM 1.5)
            link demo0+flash0;
            exe2bin demo0 demo0.com

        Run:
            demo0

        Copyright:
            none

        Author:
            C.J. Dunford [CompuServe 76703,2002]
            301/992-9371

        Revision history:
            1.00 10/03/89

*


code segment word public 'code'
assume cs:code,ds:code,es:code

extrn flash_init:near,flash_term:near
extrn pulse_color:near,pulse_color_partial:near
extrn grade_color_partial:near,grade_color:near
extrn blinker:near
extrn load_palettes:near,reset_palettes:near
extrn set_color:near,set_color_partial:near
extrn set_flash_rate:near,set_delta:near
extrn flash_enabled:byte

org 100h

; ===================================================================
;                                MAINLINE CODE
; ===================================================================

demo0:
; Initialize the VGA for controlled flashing
        call flash_init
        jnc demo1                       ; NC = VGA OK
            mov dx,offset no_VGA$       ; No VGA, terminate with message
            mov ah,9
            int 21h
            mov ax,4C01h
            int 21h

; Pulse reds and greens by slowly augmenting color intensity
demo1:
        mov ax,0202H                    ; AL=color 2 (green), AH=2 (incr/pal)
        call pulse_color                ; Create pulsed attribute
        mov ax,0204H                    ; AL=color 4 (red)
        call pulse_color
        mov ax,020AH                    ; AL=color 10 (brt green)
        call pulse_color
        mov ax,020CH                    ; AL=color 12 (brt red)
        call pulse_color                ; Create pulsed attribute
        call load_palettes              ; Load new palettes into VGA
                                        ; After this call, anything red or
                                        ; green will flash.  Nothing to it.
        mov si,offset rg_aug$           ; Display the demo
        call scrn

; Pulse all 16 attributes, using the same augmented intensity effect
        mov cx,16                       ; 16 attributes
        mov ax,0200H                    ; Start with attr 0
p16:        push ax
            call pulse_color
            pop ax
            inc al                      ; Next attribute
            loop p16
        call load_palettes
        mov si,offset all_aug$
        call scrn

; Instant color change: green to bright red
        call reset_palettes             ; Clear all special effects
        mov al,2
        mov si,offset max_red
        mov cx,0F08h
        call set_color_partial
        call load_palettes
        mov si,offset g2R$              ; Display the demo
        call scrn

; Graded color change: green to bright red
        call reset_palettes             ; Clear all special effects
        mov al,2
        mov si,offset max_red
        call grade_color
        call load_palettes
        mov si,offset grd_g2R$          ; Display the demo
        call scrn

; Blink red to bright red--periodic intensification
        call reset_palettes
        mov al,2
        call set_delta
        mov al,0C4H                     ; Set up blinking on bright red
        call blinker
        call load_palettes
        mov si,offset r2R$              ; Display the demo
        call scrn

; Demo simulated 'real' flashing
        call reset_palettes             ; Reset the green/red flashing
        mov al,2                        ; Flash a little faster
        call set_delta
        mov al,12                       ; Set up blinking on bright red
        call blinker
        call load_palettes
        mov si,offset flash$            ; Display the demo
        call scrn

; Demonstrate "softened blinking": instead of just blinking
; on and off, we reduce the intensity of the color in palettes 0-7
; and then set 8-15 to the BG color (black, in this case)
        call reset_palettes             ; Clear all special effect
        mov al,3                        ; Cyan attribute
        mov si,offset black
        mov cl,0
        mov ch,8
        call grade_color_partial        ; Grade cyan to black in 0->7
        mov al,3                        ; Black BG, cyan FG
        call blinker                    ; Makes cyan black in 8-15
        call load_palettes
        mov si,offset soft$
        call scrn

; Demo 'fading'.  Just grade the color to black (or whatever BG)
        call reset_palettes
        mov al,3
        mov si,offset black
        call grade_color
        call load_palettes
        mov si,offset fade$
        call scrn

; Demo "strobe" and "beacon" effects
        call reset_palettes
        mov al,1
        call set_delta
        mov al,14                       ; Set attr 14 to black, pals 0-14
        mov si,offset black
        mov cx,0E00h
        call set_color_partial          ; And to bright yellow for pal 15
        mov al,14
        mov si,offset max_yellow
        mov cx,0F0FH
        call set_color_partial

        mov al,1                        ; Set blue to max blue in pal 15
        mov si,offset max_blue
        mov cx,0F0FH
        call set_color_partial
        call load_palettes
        mov si,offset strobe$
        call scrn

; Demonstrate that the blink rate can be adjusted.  We make
; green and bright red flash bright green, very fast (~18/sec).
; The red/green flash is particularly psychedelic.
        call reset_palettes
        mov al,2
        mov si,offset max_grn
        call grade_color
        mov al,12
        mov si,offset max_grn
        call grade_color
        call load_palettes
        mov al,15
        call set_delta
        mov si,offset fast$
        call scrn

; ...and then very slowly.
        mov al,1
        call set_delta
        mov ax,9
        call set_flash_rate
        mov si,offset slow$
        call scrn
        mov ax,1
        call set_flash_rate
        mov al,2
        call set_delta

; Show that all this can be done with BG colors too.  We'll set blue
; to flash to bright blue and use it as a background.  Just for grins,
; we'll set attribute 2 (green) to display as blue, to show that you can
; have a plain blue and a flashing blue on the same screen (but there
; won't be any green).
        call reset_palettes
        mov al,1
        mov si,offset max_blue
        mov cx,0F08h
        call set_color_partial
        mov al,2
        mov si,offset blue
        call set_color
        call load_palettes
        mov si,offset back$
        mov al,20h
        call scrn9

; Demo shows that we can use bright backgrounds but still flash.
; We CLS with a bright BG, then flash cyan text to light cyan
        call hw_blink_off               ; Disable hardware blinking
        call reset_palettes
        mov al,93H                      ; Brt blue BG, cyan FG
        call blinker
        call load_palettes
        mov si,offset brightback$
        mov al,90h                      ; CLS with attrib 90 (bright blue)
        call scrn9
        call hw_blink_on                ; Re-enable hardware blink

; The grand finale.  Show that all effects can be mixed on one screen.
finale:
        mov al,1
        call set_delta

        ; "Beacon" in 1
        mov al,1                        ; Set blue to max blue in pal 15
        mov si,offset max_blue
        mov cx,0F0FH
        call set_color_partial

        ; Quick shift green to red in 2
        mov al,2
        mov si,offset max_red
        mov cx,0F08h
        call set_color_partial

        ; Graded green-to-red on attribute 3
        mov al,3                        ; Make attr 3 base green
        mov si,offset green
        call set_color
        mov al,3
        mov si,offset max_red
        call grade_color

        ; Blink red to bright red (periodic intensification) in 4
        mov al,0C4H                     ; Set up blinking on bright red
        call blinker

        ; Flash 5 on an off
        mov al,5
        call blinker

        ; "Softened blinking" in 6
        mov al,6
        mov si,offset black
        mov cx,0800h
        call grade_color_partial
        mov al,6
        call blinker

        ; "Fading" in 7
        mov al,7
        mov si,offset black
        call grade_color

        ; "Pulse" in 10
        mov al,10
        mov si,offset green
        call set_color
        mov ax,020AH
        mov cx,0F00H
        call pulse_color

        ; Blacken every other palette in 11 (we haven't seen this one yet)
        mov si,offset black
        mov cx,0000
GF10:       mov al,11
            call set_color_partial
            add cx,0202h
            cmp ch,0FH
            jbe GF10

        ; "Strobe" in 14
        mov al,14
        mov si,offset black
        mov cx,0E00h
        call set_color_partial
        mov al,14
        mov si,offset max_yellow
        mov cx,0F0FH
        call set_color_partial

        ; Load all those into VGA and display
        call load_palettes
        mov si,offset mixed$            ; Display the demo
        call scrn

; Demos done, clean up for return to DOS
        call flash_term

; Exit
        mov al,7
        call cls
        mov ax,4C00h
        int 21h

; No VGA found by flash_init, exit with message
no_VGA:
        mov dx,offset no_VGA$
        mov ah,9
        int 21h
        mov ax,4C01h
        int 21h

; ----- hw_blink_off -----------------------------------------------
; Function disables hardware blink, which enables bright BG.
; AX,BX destroyed.
;
hw_blink_off:
        mov ax,1003h
        xor bl,bl
        int 10h
        ret

; ----- hw_blink_on -----------------------------------------------
; Function enables hardware blink, which disables bright BG.
; AX,BX destroyed.
;
hw_blink_on:
        mov ax,1003h
        mov bl,1
        int 10h
        ret

; ----- scrn -------------------------------------------------------------
; This function clears the screen, displays the text at DS:SI, and waits
; for a keystroke.  Note that the text is flashing in background while
; we're in BIOS, waiting for a key.  In other words, once you've set
; up flashing, all you have to do is display text with the proper attributes
; (i.e., any attribute whose colors differ between palettes 1 and 2), then
; you can go on about your business.
;
; SCRN2 is similar but doesn't display the color chart and uses a
; background color of AL
;
scrn:
        mov al,7                        ; CLS with attrib 7 (B/W)
        call cls
        call display                    ; Display text at SI
        call colors                     ; Display the color chart
scrn50: mov si,offset prompt            ; And the "any key" prompt
        call display
        mov ah,1                        ; Wait for a keystroke
        int 21h
        ret

scrn9:
        call cls
        call display                    ; Display the message
        jmp scrn50

; ========================================================================
;                           FUNCTIONS FOR DEMO ONLY
; ========================================================================


; ----- colors -------------------------------------------------
; This subroutine display the chart of all 16 attributes.
;
show macro strings
        irp s,<strings>
          mov si,offset &s
          call display
        endm
endm

colors:
        show <Atr0,Atr1,Atr2,Atr3,Atr4,Atr5,Atr6,Atr7,Atr8,Atr9,AtrA,AtrB,AtrC,AtrD,AtrE,AtrF>
        ret


; ----- display -----------------------------------------------------
; Clears the screen and displays some text with various attributes.
; Text taken from DS:SI in this format:
;    Byte   Start row
;    Byte   Start col
;    Word   Number of char/attr pairs in string
;    Words  Char/attr pairs
;
display:
        lodsb                           ; Get row
        mov dh,al
        lodsb                           ; Get col
        mov dl,al
        lodsw                           ; Get length
        mov cx,ax
        mov bh,0                        ; Display page 0
        mov bp,si                       ; DS:BP -> char/attr string
        mov ax,1303h                    ; Display
        int 10h
        ret

; ----- cls ---------------------------------------------------------
; Clear the screen, attribute 7 (normally white over black).
; AX,BX,CX,DX destroyed.
;
cls:
        push si
        push ax

; Get last row number to DH
        push bp                         ; Function destroys ES:BP
        push es
        mov ax,1130h                    ; Char gen interface function
        xor bh,bh                       ; Any valid subfn is OK
        int 10h                         ; DL = last row #
        pop es
        pop bp
        mov dh,dl

; Get last column # to DL
        mov ah,0FH                      ; Video GETMODE
        int 10h
        dec ah                          ; AH = last col #
        mov dl,ah

; Clear screen from (0,0) to (DH,DL)
        pop ax                          ; Recover CLS attribute
        mov bh,al                       ; Attribute to BH
        mov cx,0                        ; From 0,0
        mov ax,0700H                    ; Scroll up, clear entire window
        int 10h

        pop si
        ret

; ========================================================================
;                                DATA FOR DEMO
; ========================================================================

; These are some color definitions that we'll use for some of the demos.
; Each definition is three bytes long (one each for red, green, and blue).
; Valid values for each byte are 0-63.
max_red     db 3FH,   0,   0
green       db   0, 2AH,   0
max_grn     db   0, 3FH,   0
max_cyan    db   0, 3FH, 3FH
black       db   0,   0,   0
max_yellow  db 3FH, 3FH,   0
blue        db   0,   0, 2AH
brt_blue    db   0,   0, 33H
max_blue    db   0,   0, 3FH


; Macro to define char/attr pairs for the demo display strings.
; Call: atext attrib,<text>
atext macro attr,dat
        irpc x,<dat>
            db "&x",attr
        endm
endm

; Text/attribute strings for the demo displays.  See DISPLAY routine.
rg_aug$ label byte
        db 0,0
        dw rg_aug$L
        atext 15,<This 'pulses' >
        atext 4,<REDS>
        atext 15,< and >
        atext 2,<GREENS>
        atext 15,<; high intensity >
        atext 10,<colors>
        atext 15,< pulse less dramatically>
rg_aug$L equ ($-rg_aug$-4)/2

all_aug$  label byte
        db 0,0
        dw all_aug$L
        atext 15,<This palette pulses all 16 attributes...>
all_aug$L equ ($-all_aug$-4)/2

g2R$  label byte
        db 0,0
        dw g2r$L
        atext 15,<Here we make green flash bright red...>
g2R$L equ ($-g2r$-4)/2

grd_g2R$  label byte
        db 0,0
        dw grd_g2R$L
        atext 15,<And this is a slow green-to-red 'grade'...>
grd_g2R$L equ ($-grd_g2R$-4)/2

flash$ label byte
        db 0,0
        dw flash$L
        atext 15,<We can also simulate blinking...>
flash$L equ ($-flash$-4)/2

strobe$ label byte
        db 0,0
        dw strobe$L
        atext 15,<This demonstrates strobes (E) and beacons (1)...>
strobe$L equ ($-strobe$-4)/2

r2R$ label byte
        db 0,0
        dw r2R$L
        atext 15,<Blinking by periodic intensification...>
r2R$L equ ($-r2R$-4)/2

mixed$ label byte
        db 0,0
        dw mixed$L
        atext 15,<All types of special effects can be mixed on one screen...>
mixed$L equ ($-mixed$-4)/2

fast$ label byte
        db 0,0
        dw fast$L
        atext 15,<You can make flashing very rapid...>
fast$L equ ($-fast$-4)/2

slow$ label byte
        db 0,0
        dw slow$L
        atext 15,<...or almost too slow to detect (C is obvious, but watch 2)...>
slow$L equ ($-slow$-4)/2

soft$ label byte
        db 0,0
        dw soft$L
        atext 15,<Here we demonstrate 'softened' blinking...>
soft$L equ ($-soft$-4)/2

fade$ label byte
        db 0,0
        dw fade$L
        atext 15,<And this is 'fading', which is even softer...>
fade$L equ ($-fade$-4)/2

back$ label byte
        db 10,16
        dw back$L
        atext 1EH,< All these effects work on background, too... >
back$L equ ($-back$-4)/2

brightback$ label byte
        db 10,0
        dw brightback$L
        atext 9Eh,<With hardware blink off, you can use bright BG but still >
        atext 93h,<flash>
        atext 9Eh,< your text>
brightback$L equ ($-brightback$-4)/2

prompt label byte
        db 24,0
        dw promptL
        atext 15,<Strike any key to continue...>
promptL equ ($-prompt-4)/2

; Macro generates the data definitions for the attribute chart
a = 0   ; Start with attribute 0
r = 2   ; At screen row 2
        irp x,<0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F>
Atr&x label byte
        db r,25
        dw 10
        REPT 10
            db "&x",a
        endm
        a = a+1
        r = r+1
        endm

; Error message for non-VGA systems
no_VGA$ db 'Sorry, flash demo requires VGA',13,10,10,'$'

code ends
end demo0
