.include "m128def.inc" ; ATmega128 .inc file

.def temp = r16

.dseg                 ; Data segment

.org 0x100            ; Set SRAM adress to 0x100
  suml: .byte 1       ; Allocate 1 byte for least significant bits of sum
  sumh: .byte 1       ; Allocate 1 byte for most significant bits of sum

.cseg                 ; Numbers to be sent to systemB, 0 means no more numbers
  nums: .db 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,0
  rjmp init

.org 0x46             ; Set program counter, place code at location 0x46

init:                 ; Init label
  ldi zh,high(nums<<1); Initalize Zh register
  ldi zl,low(nums<<1) ; Initalize Zl register
  ldi temp,0xff       ; Load 0xff in temp(R16)
  out ddrb,temp       ; Configure all pins in PORTB to output
  ldi temp,1          ; Load 1 (bit 0) in temp(R16)
  out ddrc,temp       ; Configure pin 0 in PORTC to output
  clr temp            ; Clear temp(R16)
  out portc,temp      ; Set PORTC pins to be 0
  sts suml,temp       ; Store content of temp(R16) in SRAM, initializes suml
  sts sumh,temp       ; Store content of temp(R16) in SRAM, initializes sumh

start:                ; Transfer numbers
  sbic pinc,1         ; Wait until signal bit 1 is set
  rjmp start
  lpm                 ; Read least significant byte from flash, saved in r0
  adiw zh:zl,1        ; Prepare next number for reading
  mov temp, r0        ; Save number in temp(r16)
  out portb, temp     ; Output number to system B
  sbi portc,0         ; Set signalbit 0

state1:               ; Go back to start until there are no more numbers
  sbis pinc,1         ; Wait until signal bit 1 is cleared
  rjmp state1
  cbi portc,0         ; Clear bit 0 in PORTC
  cpi temp,0          ; Compare temp with 0 (0 if no more numbers)
  brne start          ; Branch to start if not equal
  clr temp            ; Clear temp(R16)
  out ddrb,temp       ; Write 0 to PORTB, configure all PORTB pins to be input
  cbi portc,0         ; Clear signalbit 0

state2:               ; Save addition result from systemB(least significant bits)
  sbic pinc,1         ; Wait until signal bit 1 is set
  rjmp state2
  in r17,pinb         ; Save input from PortB in r17
  sts suml, r17       ; Store value in flash
  sbi portc,0         ; Set signalbit 0

state3:               ; Wait for signal to continue
  sbic pinc,1         ; Wait until signal bit 1 is set
  rjmp state3
  cbi portc,0         ; Clear signalbit 0

state4:               ; Save addition result from systemB(most significant bits)
  sbis pinc,1         ; Wait until signal bit 1 is cleared
  rjmp state4
  in r17,pinb         ; Save input from PortB in r17
  sts sumh, r17       ; Store value in flash
  sbi portc,0         ; Set signalbit 0

state5:               ; Wait for signal to continue
  sbic pinc,1         ; Skip next if bit 1 in PORTC is cleared
  rjmp state5
  cbi portc,0         ; Clear signalbit 0
