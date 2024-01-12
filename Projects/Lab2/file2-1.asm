.include "m328PBdef.inc"




.org 0x0
rjmp reset

.org 0x4
rjmp ISR1

reset:
    ; Initialize ports
    ldi r16, 0xFF   ; Set PORTB pins as outputs
    out DDRC, r16
    ldi r16, 0x04   ; Set PD3 pin as input
    out DDRD, r16
    ser r16
    ldi r16, 0xFF   ; Enable internal pull-up on PD7, 8? ????
    out PORTD, r16

    ; Set up external interrupt INT1
    ldi r16, (1 << ISC11) | (1 << ISC10)   ; Interrupt at falling edge of INT1
    sts EICRA, r16                          ; Set EICRA register

    ; Enable the INT1 interrupt
    ldi r16, (1 << INT1)
    out EIMSK, r16

    ; Initialize interrupt count
    ldi r17, 0

    ; Enable global interrupts
    sei 
    
main:
    ; Check PD7 pushbutton state
    sbis PIND, PIND7          ; Skip if PD7 is low (pushbutton pressed) cli
    rjmp main               ; Jump back to main loop
    
ISR1:
    ; Increment interrupt count
    sbis PIND, PIND3
    inc r17
wait:
   
    sbis PIND, PIND3       
    rjmp wait 
    
    ; Check if count exceeds 31
    cpi r17, 32
    brlo continue            ; If count is less than 32, continue

    ; Count exceeded 31, reset count to 0
    ldi r17, 0

continue:
    ; Display count on PC4-PC0 LEDs
    out PORTC, r17
    ;rcall delay_outer
    jmp main
