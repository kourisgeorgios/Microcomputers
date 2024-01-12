.include "m328PBdef.inc"
.DEF leds = r16
.DEF var = r17
.DEF init = r18


; delay = (1000*F1+14) cycles (abougt DEL_mS in mSeconds)
.equ FOSC_MHZ=16    ;MHz
.equ DEL_mS=2000    ;mS
.equ F1=FOSC_MHZ*DEL_mS
 
    
    ldi r24, low(F1)	    ;   
    ldi r25, high(F1)
    
reset:
    ldi r24, low(RAMEND)
    out SPL, r24
    ldi r24, high(RAMEND)
    out SPH, r24
    
start:
    clr init
    ser init
    ldi var,0x01
    
    out DDRD,init
    
left:
    out PORTD,var
    lsl var
    
    rcall delay_outer
    sbrs var,7 
    rjmp left
    ;rcall delay_outer
right:
    out PORTD,var
    lsr var
    
    rcall delay_outer
    sbrs var,0 
    rjmp right
    ;rcall delay_outer
    rjmp left
    
;this routine is used to produce a delay 993 cycles
delay_inner:            
    ldi    r23, 247        ; (1 cycle)    
loop3:
    dec r23                ; 1 cycle
    nop                ; 1 cycle
    brne loop3            ; 1 or 2 cycles
    nop                ; 1 cycle
    ret                ; 4 cycles
    
;this routine is used to produce a delay of (1000*F1+14) cycles
delay_outer:
    push r24            ; (2 cycles)        
    push r25            ; (2 cycles) Save r24:r25  
    
loop4:
    rcall delay_inner        ; (3+993)=996 cycles
    sbiw r24 ,1            ; 2 cycles
    brne loop4            ; 1 or 2 cycles
    
    pop r25            ; (2 cycles)
    pop    r24            ; (2 cycles) Restore r24:r25
    ret                ;4 cycles
    
    ret


