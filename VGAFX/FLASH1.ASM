Comment |

    This module demonstrates special effect attributes in attribute
    control mode 1 and provides several user-callable functions for
    attribute manipulation.  The callable functions are:

      flash_init          Initializes system; call before using others
      flash_term          Restores system; call before terminating
      set_flash_rate      Sets number of timer ticks between palettes
      set_delta           Sets number added to current palette per change
      load_palettes       Loads all 16 palettes into VGA
      reset_palettes      Resets to 16 base palettes
      pulse_color         Creates a pulsing color, 16 palettes
      pulse_color_partial Creates a pulsing color, < 16 palettes
      set_color           Defines a color for one attibute, all 16 palettes
      set_color_partial   Defines a color for one attibute, < 16 palettes
      grade_color         Creates a graded color over 16 palettes
      grade_color_partial Creates a grade color over < 16 palettes
      blinker             Copies BG colors into FG, for simulated blinking

    Additionally, one data item is public to the user.  FLASH_ENABLED
    is a byte variable; a zero value here disables palette changes,
    effectively "freezing" the colors currently displayed.

    The module is designed for linking into a COM program.  All functions
    are NEAR calls and assume DS=ES, except for TIMER_INT, which is an
    interrupt intercept and assumes that CS=DS=ES.

    The module prologues provide greater detail on function requirements
    and register use.

    Tested under MASM 5.1 and OPTASM 1.5.

    Prep:
        masm flash0;
           -or-
        optasm flash0;
        link hostprog+flash0;
        exe2bin hostprog

    Uncopyrighted material, use freely
    By Chris Dunford/Cove Software (CompuServe 76703,2002; tel. 301/992-9371)

    Version history:
        1.00 10/09/89

|

public flash_init,flash_term
public pulse_color,pulse_color_partial
public grade_color,grade_color_partial
public set_color,set_color_partial
public blinker
public load_palettes,reset_palettes
public set_flash_rate,set_delta
public flash_enabled

; This equate determines whether TIMER_INT uses BIOS or register-level
; programming to accomplish palette changes.  Set to 0 for register-level,
; any non-zero value for BIOS level.
USE_BIOS equ 0

; Macro accesses the palette control video BIOS function (fn 10H)
; Call: palctrl subfunction
palctrl macro fn
        mov ax,10h shl 8 + fn
        int 10h
endm

; Structure for storing graded color scaling data.  See CALC_SCALE_FACTORS.
scale_factors struc
incr        db ?
xs_count    db ?
xs_incr_val db ?
scale_factors ends

; Subfunctions (AL values) for palette control function
_SET_PALREGS           equ 2
_GET_PALREGS           equ 9
_SET_COLOR             equ 10h
_SET_DACS              equ 12h
_SET_ATR_SELECT_STATE  equ 13h
_GET_DACS              equ 17h
_GET_ATR_SELECT_STATE  equ 1AH


code segment word public 'code'
assume cs:code,ds:code,es:code

; ========================================================================
;                          DATA FOR VGA MANIPULATION
; ========================================================================

; Storage for the original 16 palettes
origpals db 16*16*3 dup (0)     ; 16 palettes, 16 colors each, 3 RGB values per

; Additional saved state info
orig_mode           db ?                ; Original attr control mode
orig_color_select   db ?                ; Original color select reg value

; Storage for the augmented palettes
newpals  db 16*16*3 dup (0)

; Storage for the 16 palatte registers + overscan reg
palregs db 17 dup (0)

; The 16 new palette register contents we will use, plus overscan
newpalregs db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0

; Storage for factors used to scale one color to another over
; fifteen palettes.  Don't separate or re-order; module assumes
; that the R/G/B records are contiguous and in that order.
red_scale   scale_factors <>
green_scale scale_factors <>
blue_scale  scale_factors <>

; Color definitions for our 16 base colors.  16 colors, 3 RGB values each
new_base_pal label byte
.radix 16
        db 00,00,00    ; Color 0 (normally black)
        db 00,00,2A    ; Color 1 (blue)
        db 00,2A,00    ; Color 2 (green)
        db 00,2A,2A    ; Color 3 (cyan)
        db 2A,00,00    ; Color 4 (red)
        db 2A,00,2A    ; Color 5 (magenta)
        db 2A,2A,00    ; Color 6 (brown)
        db 2A,2A,2A    ; Color 7 (white)

        db 00,00,15    ; Color 8 (some very dark color)
        db 00,00,33    ; Color 9 (brt blue)
        db 00,33,00    ; Color 10 (brt green)
        db 00,33,33    ; Color 11 (brt cyan)
        db 33,00,00    ; Color 12 (brt red)
        db 33,00,33    ; Color 13 (brt magenta)
        db 33,33,00    ; Color 14 (yellow)
        db 33,33,33    ; Color 15 (brt white)
.radix 10

; Flasher data
flash_enabled       db 1                ; 0=disabled, 1=enabled
flash_reset_count   dw 1                ; Flash rate, in timer ticks
count               dw 9                ; Remaining countdown
pal_select          db 0                ; Current palette #
delta               db 1                ; # palettes to change per flash

; Storage for original timer vector
oldtimer label dword
tickvec_lo dw ?
tickvec_hi dw ?

; ========================================================================
;                              CALLABLE FUNCTIONS
; ========================================================================


; ----- flash_init ------------------------------------------------------
; This function must be called to initialize the system for controlled
; flashing.  It accomplishes several tasks:
;
;    - Saves the 16 palette registers in palregs
;    - Gets the current 256 colors (4 palettes) to origpals
;    - Duplicates palette 0 in palette 1 and loads it into the VGA
;    - Installs the timer intercept
;
; On exit, flashing is set up, but nothing is actually flashing (because
; palettes 0 and 1 are identical).
;
; Returns CF=1 if no VGA detected.  All regs except segregs may be destroyed.
;
flash_init:

; Make sure we've got a VGA.  Use a VGA-only function, and one that
; we can use to save the current attribute control mode and color select reg.
        palctrl _GET_ATR_SELECT_STATE   ; A VGA-only function
        mov orig_mode,bl
        mov orig_color_select,bh
        cmp al,_GET_ATR_SELECT_STATE
;        jne got_VGA
;            stc                         ; Oops
;            jmp fi_exit

; Save the 16 current palette registers into palregs; reset the
; palette registers to contain 16 "standard" 4-bit colors.
got_VGA:
        ; Get current regs
        mov dx,offset palregs
        palctrl _GET_palregs

        ; Continue to use the current border color
        mov al,palregs+16
        and al,0FH
        mov newpalregs+16,al

        ; Set new palregs
        mov dx,offset newpalregs
        palctrl _SET_PALREGS

; Save the original DAC color registers (256 colors) in origpals
        xor bx,bx                       ; Start with register 0
        mov cx,256                      ; 256 registers
        mov dx,offset origpals          ; Where to put 'em
        palctrl _GET_DACS

; Create 16 standard palettes in newpals and send them to the VGA
        call dupe_palette0
        mov dx,offset newpals
        call set_colors

; Set attribute control mode 1
        mov bx,100h
        palctrl _SET_ATR_SELECT_STATE

; Save/set the timer intercept
        push es
        mov ax,3508h
        int 21h
        mov tickvec_lo,bx
        mov tickvec_hi,es
        pop es

        mov dx,offset timer_int
        mov ax,2508h
        int 21h

        clc

fi_exit:
        ret

; ----- flash_term -----------------------------------------------------
; This function must be called for cleanup when program terminates:
;    - Deactivates the timer intercept
;    - Restores the original VGA state
; AX,BX,CX,DX destroyed
;
flash_term:

; Clear the timer interrupt
        push ds
        lds dx,oldtimer
        mov ax,2508h
        int 21h
        pop ds

; Restore original palette registers and video DAC color registers
        mov dx,offset palregs
        palctrl _SET_PALREGS
        mov dx,offset origpals
        call set_colors

; Restore original attribute control mode
        xor bl,bl                       ; Subfn to set control mode
        mov bh,orig_mode
        palctrl _SET_ATR_SELECT_STATE

; Go back to palette 0
        mov bl,1                        ; Subfn to set color select reg
        mov bh,orig_color_select        ; Value to set
        palctrl _SET_ATR_SELECT_STATE

        ret

; ----- set_flash_rate ------------------------------------------------
; Reset the flash rate to the number of ticks in AX (18/sec); i.e.,
; the palette will change every AX ticks.  All regs preserved.
;
set_flash_rate:
        cli
        mov flash_reset_count,ax
        mov count,ax
        sti
        ret

; ----- set_delta ------------------------------------------------------
; Set the increment value for palette changes.  When the ticker
; ticks down and the palette is to be changed, the timer ISR will
; add/subtract this number to the current palette number.  With a
; higher delta, you can flash more rapidly.  E.g., with delta=1,
; the palettes change 0,1,2,3,...,15.  With delta=3, the palette
; changes are 1,3,6,9,12,15.  If delta=0, only palette 0 is used.
;
; AX destroyed.
;
set_delta:
        push cx
        and al,15
        mov cl,al
        cli
        mov delta,al

        ; Ensure that the selected palettes will
        ; be multiples of the delta
        or cl,cl
        jnz SD20
            xor al,al
            jmp SD50

SD20:
            mov al,pal_select
            xor ah,ah
            div cl
            mul cl

SD50:
        mov pal_select,al
        sti
        pop cx
        ret

; ----- load_palettes -------------------------------------------------
; Load the set of palettes in NEWPALS into the VGA.
;
load_palettes:
        mov dx,offset newpals
        call set_colors
        ret

; ----- reset_palettes ----------------------------------------------
; This function resets the VGA to 16 copies of the "standard" palette.
;
reset_palettes:
        call dupe_palette0
        call load_palettes
        ret

; ----- pulse_color_partial ----------------------------------------
; Creates a "pulsing" attribute.  This is one whose intensity increases
; and decreases cyclically.  On entry:
;    AL = attribute
;    AH = intensity increase/palette (each palette's RGB values
;         will be this much higher than the previous palette's)
;    CH = base palette
;    CL = terminal palette
; The color definition in palette CH is unaffected; palettes CH+1..CL
; will contain augmented color definitions.  Function does nothing
; if CL >= CH.
;
; AX destroyed.  New palettes not loaded into VGA.
;
pulse_color_partial:

        push bx
        push cx
        push si
        push di

; Verify the palette numbers
        cmp ch,15                       ; CH > 15?
        ja P90                          ; Yes
        cmp cl,ch                       ; CL >= CH?
        jae P90                         ; Yes

; Address the base definition (palette CL) for this attribute
        call get_DAC_ptr
        mov si,bx                       ; SI -> first definition
        sub ch,cl                       ; CH = # of palettes affected
        mov cl,ch
        xor ch,ch                       ; Now CX


; Loop through the required number of palettes
p_palette_loop:
            push cx
            mov cx,3
            mov di,si                   ; SI/DI -> color def, crnt palette
            add di,16*3                 ; DI -> color def, next palette
p_RGB_loop:
                lodsb                   ; Get R/G/B intensity, crnt pal
                or al,al                ; Don't increment missing primaries
                jz P10
                    add al,ah           ; Add per-palette increment
                    cmp al,63           ; Don't let it go past 63
                    jbe P10
                    mov al,63
P10:            stosb                   ; Store increment value in next pal
                loop p_RGB_loop         ; Loop for 3 primaries
            pop cx
            add si,16*3-3               ; Next palette
        loop p_palette_loop

P90:
        pop di
        pop si
        pop cx
        pop bx
        ret

; ----- pulse_color -----------------------------------------------------
; Identical to pulse_color_partial except that a full range 0-15 is used;
; reg CX input not required.
;
; Entry: see pulse_color_partial; CH/CL not required.
;
; AX destroyed.  New palettes not loaded into VGA.
;
pulse_color:

        push cx
        mov cx,0F00H
        call pulse_color_partial
        pop cx
        ret


; ----- set_color_partial --------------------------------------------
; This function sets the color definitions for attribute AL in palettes
; CL to CH to the 3-byte RGB definition at DS:SI.  Ensure that CH >= CL
; and that both are in the range 0..15.  The new palette is not sent to
; the VGA.
;
; The function does nothing if CL > CH or either is not in the range
; 0-15.
;
; AX destroyed.
;
set_color_partial:

        push bx
        push cx
        push si
        push di

; Verify the palette numbers
        cmp ch,15                       ; CH > 15?
        ja S10                          ; Yes
        cmp cl,ch                       ; CL >= CH?
        ja S10                          ; Yes

; Address the base definition (palette CL) for this attribute
        call get_DAC_ptr
        mov di,bx                       ; DI -> first definition
        inc ch
        sub ch,cl                       ; CH = # of palettes affected
        mov cl,ch
        xor ch,ch                       ; Now CX

; Loop through the required number of palettes
sc_palette_loop:
            push si                     ; Copy def from SI to palette n
            lodsb
            stosb
            lodsw
            stosw
            pop si
            add di,16*3-3               ; DI -> color def in pal n+1
        loop sc_palette_loop

S10:
        pop di
        pop si
        pop cx
        pop bx
        ret

; ----- set_color --------------------------------------------------
; Identical to set_color_partial, except that the full range of
; palettes (0..15) is assumed.  I.e., this function defines all palettes
; for attribute AL to contain the RGB color definition at DS:SI.
; Reg CX input not required.
;
set_color:
        push cx
        mov cx,0F00h
        call set_color_partial
        pop cx
        ret

; ----- grade_color_partial ------------------------------------------
; This function creates a graded set of colors for attribute AL.
; CL contains a starting palette (0-14) and CH contains an ending
; palette (1-15, CH > CL).
;
; DS:SI points to the "terminal" color definition, which will be
; the definition in palette CH.  On exit, palettes CL-CH will contain
; "graded" color definitions for the attribute, so that the displayed
; color will change slowly from the base color (in palette CL) to the
; terminal color (in palette CH).  The color definition at DS:SI
; is three bytes long (one byte each for R, G, B intensity).  RGB
; values are modulated into the range 0-63.  The new palette is not
; sent to the VGA.  AX destroyed.
;
; The function does nothing if CL >= CH or either is not in the range
; 0-15.
;
grade_color_partial:

        push bx
        push cx
        push si
        push di

; Verify the palette numbers
        cmp ch,15                       ; CH > 15?
        ja G10                          ; Yes
        cmp cl,ch                       ; CL >= CH?
        jae G10                         ; Yes

; Address the base definition (palette CL) for this color
        call get_DAC_ptr
        push bx
        sub ch,cl                       ; CH = # of palettes graded
        mov cl,ch
        xor ch,ch                       ; Now CX
        mov di,offset red_scale
        call calc_scale_factors         ; Calc red scaling factors
        call calc_scale_factors         ;  "   grn   "       "
        call calc_scale_factors         ;  "   blue  "       "
        pop si                          ; SI -> initial definition

; Loop through the required number of palettes
gc_palette_loop:
            mov di,si                   ; SI/DI -> color def in palette n
            add di,16*3                 ; DI -> color def in pal n+1

            ; Augment RGB values for this video DAC color register
            mov bx,offset red_scale     ; Point to red scale factors
            call increment              ; Scale red
            call increment              ; Scale green
            call increment              ; Scale blue

            add si,16*3-3               ; Next palette
            loop gc_palette_loop

G10:
        pop di
        pop si
        pop cx
        pop bx
        ret

; ----- grade_color --------------------------------------------------
; This is the same as GRADE_COLOR_PARTIAL, except that a full 15-palette
; grade is automatic.  Reg CX input is not required.
;

grade_color:
        push cx
        mov cx,0F00h                    ; Grade palettes 0-15
        call grade_color_partial
        pop cx
        ret

; ----- blinker --------------------------------------------------
; This function creates a simulated "blinking" color for attribute
; AL.  Unlike most of the other functions, this one works with a
; full 8-bit attribute (bits 0-3=FG, 4-7=BG, as usual).  "Blinking"
; is accomplished by putting the BG color definition into palettes
; 8-15 for the selected FG color.
;
; Note that palettes 0-7 are not altered, so you can do whatever
; you want with the "visible" half of the blink text (like scaling it,
; as is done in the "softened blinking" demo.
;
; AX destroyed.  New palette not sent to VGA.
;
blinker:
        push bx
        push cx

; Get a pointer to the color definition for the BG attribute
        push ax
        mov cl,4                        ; Mov high nibble (BG) to low
        shr al,cl
        xor cl,cl                       ; Get ptr to def in palette 0
        call get_DAC_ptr
        mov si,bx                       ; SI->BG def, palette 0
        pop ax

; Now do a SET_COLOR for the FG attribute in palettes 8-15,
; using the color definition at DS:SI (which is the BG color)
        and al,0FH                      ; Mask the BG attribute number
        mov cx,0F08h                    ; Palettes 8-15
        call set_color_partial

        pop cx
        pop bx
        ret

; =======================================================================
;                             INTERNAL SUBROUTINES
; =======================================================================

; ----- dupe_palette0 -----------------------------------------------
; This function creates 16 "standard" palettes in NEWPALS.
; The palettes are not loaded into the VGA.
; Regs used: AX,CX,SI,DI
;
dupe_palette0:
        ; Copy the base palette into palette 0 of newpals.  Each color
        ; register contains 3 colors (R, G, and B), so the full palette
        ; is 16*3 bytes long
        mov si,offset new_base_pal
        mov di,offset newpals
        mov cx,16*3/2                  ; 256 colors, 3 RGB values each
        cld
        rep movsw

        ; Now duplicate pallete 0 (colors 0-15) to pals 1-15 (colors 16-255)
        ; We simplify this by allowing the copies to overlap.
        mov si,offset newpals           ; SI -> palette 0
        mov di,offset newpals+16*3      ; DI -> palette 1
        mov cx,15*16*3/2                ; 15 pals, 16 colors each, @ 3 bytes
        rep movsw

        ret


; ----- calc_scale_factors ---------------------------------------------
; This function generates the parameters for scaling a color from
; an initial value to a terminal value.  On entry, DS:BX points
; to an initial color value (0-63), DS:SI points to a terminal
; color value (0-63), and ES:DI points to a 3-byte interpolation
; factor storage area.  The function calculates the numbers needed
; to scale the color from the initial definition to the terminal
; definition over a span of CL palettes (normally 15).
;
; The 3-byte factor storage area is filled as follows:
;       byte signed integer: increment/palette
;       byte unsigned integer: number of extra increments required
;       byte signed integer: excess increment value (1 or -1)
;
; To scale a palette, start with palette 0 and add the increment/palette
; to each succeeding palette.  Also add the excess increment value (1 or -1)
; to the first n palettes (1-n), where n is the number of extra increments.
; For example, if the initial color value is 21 and the terminal is 63, the
; factor storage area would contain 2,12,1.  To scale from 21 to 63, start
; with the value in palette 0 and add 3 per palette (2+1) from 1-12 and two
; per palette from 13-15:
;       0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
;       21 24 27 30 33 36 39 42 45 48 51 54 57 59 61 63
; (Everything in the above assumes a 15-palette scale).
;
; On exit, BX and SI have been incremented by one, and DI by 3.  This
; conveniently points to the next color values and factor storage area.
; Other regs are preserved.
;
calc_scale_factors:

; Make sure CL is OK
        and cl,0FH
        or cl,cl
        jnz CSF10
          mov cl,15
CSF10:

; Get the initial color to AH and terminal color to AL
        mov al,[bx]                     ; Initial color value
        inc bx
        mov ah,al
        lodsb                           ; Terminal color value
        and al,3FH                      ; Force 0-63

; Compute increment/palette and number of excess increments needed
        sub al,ah                       ; AL = difference (term-init)
        cbw
        idiv cl                         ; AL = inc/pal, AL = excess
        mov [di.incr],al                ; Store increment/palette

; Decide whether the excess increment value is +1 or -1.  It will be
; -1 if the "excess" calculated above is negative; the excess count will
; also have to be made positive, if so.
        mov al,1                        ; Assume positive
        or ah,ah                        ; Is it negative?
        jns I1                          ; No, continue
          neg al                        ; Yes, make increment negative
          neg ah                        ; And count positive
I1:     mov [di.xs_count],ah            ; Store the values
        mov [di.xs_incr_val],al
        add di,type scale_factors       ; Next storage area

        ret

; ----- increment -----------------------------------------------------
; This subfunction increments a color value from palette n to palette
; n+1 using the scale factors at DS:BX (see CALC_SCALE_FACTORS).
; Entry: DS:BX->scale factors, DS:SI->palette n color value,
; ES:DI -> palette n+1 color value.  On exit, SI has been incremented
; (to point to the next color value), and BX is increased by 3 (to point
; to the next scale factor storage area).  The xs_incr field of the
; scale factor record is decremented if not already zero.
;
increment:
            lodsb                       ; Get original R/G/B value
            add al,[bx.incr]            ; Add per-palette increment
            test [bx.xs_count],-1       ; Any excess increments left?
            jz no_rem                   ; No
              dec [bx.xs_count]         ; Yes, dec remaining excess count
              add al,[bx.xs_incr_val]   ; And add the excess incrmt (1/-1)
no_rem:
            stosb                       ; Store the graded value
            add bx,type scale_factors
            ret

; ----- set_colors --------------------------------------------------
; This function sets the 256 video DAC color registers from the table
; at ES:DX, i.e., it loads the 256 colors definitions into the VGA.
;
set_colors:
        push ax
        push bx
        push cx
        xor bx,bx                       ; Start with register 0
        mov cx,256                      ; 256 colors
        palctrl _SET_DACS
        pop cx
        pop bx
        pop ax
        ret


; ----- get_DAC_ptr ----------------------------------------------
; Returns a pointer in BX to the color definition for attribute AL
; in palette CL of NEWPALS.  Other regs preserved.
;
get_DAC_ptr:
        push ax
        and ax,0FH                      ; Ensure range 0-15
        mov bx,ax
        mov al,newpalregs[bx]           ; Get palreg for this attrib
        mov bx,ax                       ; Triple it for offset into color tab
        shl bx,1
        add bx,ax                       ; BX = 3 * color #
        mov al,16*3                     ; Bytes/palette
        mul cl                          ; AX -> offset of palette CL
        add bx,ax                       ; BX -> offset of color def in NEWPALS
        add bx,offset newpals           ; BX -> base color definition
        pop ax
        ret

; =======================================================================
;                               TIMER INTERCEPT
; =======================================================================

Comment |
  This is the timer intercept.  On each timer tick, we decrement the
  countdown (if we are enabled).  If the count goes to zero, we go to
  the next palette.  The next palette is determined by the current
  palette (in pal_select) and the delta value; delta is added to
  the current value and range checked.  If the new palette is out of
  range, it's brought in range and the sign of delta is changed.
|

timer_int:
        assume cs:code,ds:nothing,es:nothing

; Is the flasher enabled?
        test flash_enabled,-1
        jz timer9                       ; No

; Dec count, skip rest if nonzero
        dec count
        jnz timer9

; Count has zeroed, switch palettes by adding the delta.  If the
; palette number goes out of range, reverse the sign of the delta
; and bring the palette number back into range.  PAL_SELECT has
; the current palette number.
        push ax
        push bx

        mov bh,pal_select               ; Get current palette

        add bh,delta                    ; Add the delta
        js P2                           ; Go if new palette not negative

P1:     cmp bh,15                       ; Check for positive out-of-range
        jbe pal_OK                      ; It's OK
P2:       neg delta                     ; Reverse the direction
          add bh,delta
          add bh,delta

pal_OK:
        mov pal_select,bh               ; Save new palette
if USE_BIOS
; Use BIOS to set color select register (palette)
        mov bl,1                        ; And send it to the VGA
        palctrl _SET_ATR_SELECT_STATE
else
; Use register-level programming of the attribute control reg (ACR)
        push dx

        ; Get port address of CRT status register
        xor ax,ax
        push ds
        mov ds,ax
        mov dx,ds:[463h]                ; DX = 3x8 register
        pop ds
        add dx,6                        ; DX = 3xA, CRT status reg

        ; Wait for a retrace
        push cx
        mov ah,5
        xor cx,cx
t_wait:     in al,dx
            test al,8
            jnz t_go
            loop t_wait
            dec ah
            jnz t_wait
t_go:   pop cx

        ; Do rest with ints off
        pushf
        cli

        ; Set color select
        in al,dx                        ; Set addr/data flipflop in ACR
        push dx                         ; Save CRT status reg port #

        mov dx,3C0H                     ; Select ACR reg 14h (color select)
        mov al,14h
        out dx,al
        jmp $+2

        mov al,bh                       ; Send color select data
        out dx,al

        pop dx                          ; Recover CRT status reg
        in al,dx                        ; Reset flipflop
        mov dx,3C0h                     ; ACR again
        mov al,20h                      ; Restore palette
        out dx,al

        popf                            ; Ints back on

        pop dx
endif

        mov ax,flash_reset_count        ; Reset the count
        mov count,ax

        pop bx
        pop ax

; Done, go do the real timer routine
timer9:
        jmp oldtimer

code ends
end
