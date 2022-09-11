.nolist
	.include	"m8def.inc"
.list

.cseg
.org 0
RESET:
	rjmp	START		; RESET
	rjmp	BAD_INTERRUPT	; INT0
	rjmp	BAD_INTERRUPT	; INT1
	rjmp	BAD_INTERRUPT	; TIMER2 COMP
	rjmp	BAD_INTERRUPT	; TIMER2 OVF
	rjmp	BAD_INTERRUPT	; TIMER1 CAPT
	rjmp	BAD_INTERRUPT	; TIMER1 COMPA
	rjmp	BAD_INTERRUPT	; TIMER1 COMPB
	rjmp	BAD_INTERRUPT	; TIMER1 OVF
	rjmp	BAD_INTERRUPT	; TIMER0 OVF
	rjmp	BAD_INTERRUPT	; SPI STC
	rjmp	BAD_INTERRUPT	; USART RXC
	rjmp	BAD_INTERRUPT	; USART UDRE
	rjmp	BAD_INTERRUPT	; UART TXC
	rjmp	BAD_INTERRUPT	; ADC
	rjmp	BAD_INTERRUPT	; EE_RDY
	rjmp	BAD_INTERRUPT	; ANA_COMP
	rjmp	BAD_INTERRUPT	; TWI
	rjmp	BAD_INTERRUPT	; SPM_RDY

BAD_INTERRUPT:
	rjmp	RESET

START:
; Initialize Stack Pointer
	ldi	r16,	high(RAMEND)
	out	SPH,	r16
	ldi	r16,	low(RAMEND)
	out	SPL,	r16
; Initialize IO
	ldi	r16,	0b00101111
	out	DDRB,	r16
	ldi	r16,	0b10000000
	out	DDRD,	r16
; Initialize SPI
	rcall	SPI_init
; Initialize LCD
	rcall	LCD_init
; Test write to LCD
	rcall	LCD_test

; Blink LED
LOOP:
	ldi	r16,	0b10000000
	in	r17,	PORTD
	eor	r17,	r16
	out	PORTD,	r17
	ldi	r16,	0x10
	rcall	DELAY
	rjmp	LOOP

.include	"delay.asm"
.include	"lcd.asm"
.include	"spi.asm"

