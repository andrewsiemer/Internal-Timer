; Internal Timer - Microprocessors Project (Fall 2019)
; main.asm
;
; Author : Andrew Siemer <andrew@siemer.org>
; Version: 11.14.19
;

.nolist
.include "./m328Pdef.inc"
.list

.def temp = r16
.def overflows = r17

.org 0x0000              ; memory (PC) location of reset handler
rjmp reset
.org 0x0020              ; memory location of Timer0 overflow handler
rjmp overflow_handler    ; go here if a timer0 overflow interrupt occurs 

reset: 
   ldi temp,  0b00000011 ; 011 - FCPU/64
   out TCCR0B, temp      ; set the clock selector bits CA02, CA01, CA00 to 011
                         ; this puts Timer Counter0, TCNT0 in to FCPU/64 mode
                         ; so it ticks at the CPU freq/64
   ldi temp, 0b00000001
   sts TIMSK0, temp      ; set the Timer Overflow Interrupt Enable (TOIE0) bit 
                         ; of the Timer Interrupt Mask Register (TIMSK0)

   sei                   ; enable global interrupts

   clr temp
   out TCNT0, temp       ; initialize the Timer/Counter to 0

   sbi DDRD, 4           ; set PD4 to output

start:
   sbi PORTD, 4          ; turn on PD4
   rcall delay           ; delay 1/2 second
   cbi PORTD, 4          ; turn off PD4
   rcall delay           ; delay 1/2 second
   rjmp start       ; loop back to the start
  
delay:
   clr overflows         ; set overflows to 0 
   sec_count:
     cpi overflows, 31   ; compare number of overflows and 31
   brne sec_count        ; branch to back to sec_count if not equal 
   ret                   ; if 31 overflows have occured return to squareWave

overflow_handler: 
   inc overflows         ; add 1 to the overflows variable
   cpi overflows, 61     ; compare with 61
   brne PC+2             ; Program Counter + 2 (skip next line) if not equal
   clr overflows         ; if 61 overflows occured reset the counter to zero
   reti                  ; return from interrupt