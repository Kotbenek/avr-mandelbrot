.nolist
	.include	"m8def.inc"
.list

.dseg
	.define	lcd_buffer_size	504
	lcd_buffer:	.byte	lcd_buffer_size

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
; Initialize SPI
	rcall	SPI_init
; Initialize LCD
	rcall	LCD_init
; Test write to LCD
	rcall	LCD_clear_buffer
	rcall	mandelbrot
	rcall	LCD_write_buffer

LOOP:
	rjmp	LOOP

.include	"delay.asm"
.include	"lcd.asm"
.include	"spi.asm"
.include	"fixed_point.asm"
.include	"mandelbrot.asm"

