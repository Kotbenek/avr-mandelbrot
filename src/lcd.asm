.define	RST_PORT	PORTB
.define	RST		PB0
.define	DC_PORT		PORTB
.define	DC		PB1
.define	SS_PORT		PORTB
.define	SS		PB2

LCD_init:
	push	r16
	push	r17
	push	r24
	push	r25

	; Reset LCD
	cbi	RST_PORT,	RST
	ldi	r16,		1
	rcall	DELAY
	sbi	RST_PORT,	RST

	; Enter extended commands mode
	ldi	r16,		0x21
	ldi	r17,		1
	rcall	LCD_write
	; Set bias n = 4 for 1:48 mux
	ldi	r16,		0x13
	rcall	LCD_write
	; Set VOP to 7V
	ldi	r16,		0xC2
	rcall	LCD_write
	; Set temperature coefficient to 2 (17mV/K)
	ldi	r16,		0x06
	rcall	LCD_write
	; Enter standard commands mode
	ldi	r16,		0x20
	rcall	LCD_write
	; Set display configuration to normal mode
	ldi	r16,		0x0C
	rcall	LCD_write

	; Clear LCD RAM
	ldi	r16,		0x80
	rcall	LCD_write
	ldi	r16,		0x40
	rcall	LCD_write

	ldi	r16,		0
	ldi	r17,		0
	ldi	r25,		HIGH(504)
	ldi	r24,		LOW(504)
__LCD_init_clear_RAM_loop:
	rcall	LCD_write
	sbiw	r24,		1
	brne	__LCD_init_clear_RAM_loop

	pop	r25
	pop	r24
	pop	r17
	pop	r16
	ret

LCD_write:
	; Input: r16 - data, r17 - is_cmd
	push	r18
	push	r19

	cbi	SS_PORT,	SS

	cpi	r17,		1
	brne	__LCD_write_not_cmd
__LCD_write_cmd:
	cbi	DC_PORT,	DC
	rjmp	__LCD_write_is_cmd_end
__LCD_write_not_cmd:
	sbi	DC_PORT,	DC
__LCD_write_is_cmd_end:
	rcall	SPI_transmit

	sbi	SS_PORT,	SS

	pop	r19
	pop	r18
	ret

LCD_test:
	push	r16
	push	r17
	push	r24
	push	r25

	ldi	r16,		0x80
	ldi	r17,		1
	rcall	LCD_write
	ldi	r16,		0x40
	rcall	LCD_write

	ldi	r16,		0xFF
	ldi	r17,		0
	ldi	r25,		HIGH(504)
	ldi	r24,		LOW(504)
__LCD_test_loop:
	rcall	LCD_write
	sbiw	r24,		1
	brne	__LCD_test_loop

	pop	r25
	pop	r24
	pop	r17
	pop	r16
	ret

