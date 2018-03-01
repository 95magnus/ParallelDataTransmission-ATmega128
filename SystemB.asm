.include "m128def.inc"

.def temp=r16

.dseg

.org 0x100
  suml: .byte 1
  sumh: .byte 1

.cseg
  rjmp init

.org 0x46

init:
  ldi temp,0
  out ddrb,temp
  ldi temp,2
  out ddrc,temp
  clr temp
  out portc,temp
  sts suml,temp
  sts sumh,temp

start:
  sbis pinc,0
  rjmp start
  in r17,pinb
  clr r18
  lds r19,suml
  lds r20,sumh
  add r19,r17
  adc r20,r18
  sts suml,r19
  sts sumh,r20
  sbi portc,1

state1: 
  sbic pinc,0
  rjmp state1
  cbi portc,1
  cpi r17,0
  brne start
  ldi temp,0xff
  out ddrb,temp
  lds temp,suml
  out portb,temp
  sbi portc,1

state2:
  sbis pinc,0
  rjmp state2
  cbi portc,1

state3:
  sbic pinc,0
  rjmp state3
  lds temp,sumh
  out portb,temp
  sbi portc,1

state4:
  sbis pinc,0
  rjmp state4
  cbi portc,1

state5:
  sbic pinc,0
  rjmp state5
  clr temp
  out portb,temp
  sbi portc,1

state6:
  sbis pinc,0
  rjmp state6
  cbi portc,1

state7:
  sbic pinc,0
  rjmp state7
  jmp init
