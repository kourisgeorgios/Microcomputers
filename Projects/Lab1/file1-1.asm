.include "m328PBdef.inc"
.DEF num = r16
.DEF A = r17
.DEF B = r18
.DEF C = r19
.DEF D = r20
.DEF F0 = r21
.DEF F1 = r22

reset:
    ldi r24, low(RAMEND) ; Initialize Stack Pointer
    out SPL, r24
    ldi r24, high(RAMEND)
    out SPH, r24

start:
    clr num
    out DDRB, num    ; Set PORTB as input
    ser num
    out PORTB, num   ; Enable pull-up resistors for PORTB
    ldi num, 0xFF
    out DDRC, num    ; Set PORTC as output

main:
    clr F0   ; Clear F0
    clr F1   ; Clear F1
    in num, PINB    ; Read inputs from PORTB
    mov A, num      ; Move A to LSB of register A
    lsr num
    mov B, num      ; Move B to LSB of register B
    lsr num
    mov C, num      ; Move C to LSB of register C
    lsr num
    mov D, num      ; Move D to LSB of register D
    
    ; Calculate F0 = (A * B + B' * D)
    and A, B         ; LSB(A) = A * B
    com B            ; B' = complement of B
    and B, D         ; LSB(B) = B' * D
    or F0, A         ; LSB(F0) = A * B
    or F0, B         ; LSB(F0) = A * B + B' * D
    
    ; Calculate F1 = (A' + C') * (B + D')
    com A            ; A' = complement of A
    com C            ; C' = complement of C
    or A, C          ; LSB(A) = A' + C'
    com B	     ; B''=B
    com D
    or B, D          ; LSB(B) = B + D'
    and F1, A        ; LSB(F1) = (A' + C') * (B + D')
    and F1, B        ; LSB(F1) = (A' + C') * (B + D')
    
    ; Output F0 and F1 to PORTC
    in num, PORTC   ; Read current value of PORTC
    andi num, 0xFC  ; Clear 2 LSBs of PORTC
    or num, F0      ; Set LSB of PORTC as F0
    or num, F1      ; Set 2nd LSB of PORTC as F1
    out PORTC, num  ; Write back to PORTC

    rjmp main


