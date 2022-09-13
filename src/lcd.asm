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

LCD_write_buffer:
	push	r16
	push	r17
	push	r28
	push	r29
	push	r30
	push	r31

	ldi	r16,		0x80
	ldi	r17,		1
	rcall	LCD_write
	ldi	r16,		0x40
	rcall	LCD_write

	ldi	r17,		0
	ldi	r29,		HIGH(504)
	ldi	r28,		LOW(504)

	ldi	r31,		HIGH(lcd_buffer)
	ldi	r30,		LOW(lcd_buffer)

__LCD_write_buffer_loop:
	ld	r16,		Z+
	rcall	LCD_write
	sbiw	r28,		1
	brne	__LCD_write_buffer_loop

	pop	r31
	pop	r30
	pop	r29
	pop	r28
	pop	r17
	pop	r16
	ret

LCD_set_pixel:
	; Input: r16 - x, r17 - y, r18 - on(1)/off(0)
	push	r24
	push	r25
	push	r28
	push	r29
	push	r30
	push	r31

	; Get pixel from buffer
	ldi	r31,		HIGH(lcd_buffer)
	ldi	r30,		LOW(lcd_buffer)

	; Index: (y >> 3) * 84 + x
	mov	r28,		r17
	lsr	r28
	lsr	r28
	lsr	r28
	ldi	r29,		84
	mul	r28,		r29
	movw	r28,		r0
	add	r28,		r16
	ldi	r24,		0
	adc	r29,		r24

	add	r30,		r28
	adc	r31,		r29

	ld	r24,		Z

	; Set pixel
	; (y & 0x07)
	mov	r25,		r17
	andi	r25,		0x07
	ldi	r28,		1
	tst	r25
	breq	__LCD_set_pixel_loop_end
__LCD_set_pixel_loop:
	lsl	r28
	dec	r25
	brne	__LCD_set_pixel_loop
__LCD_set_pixel_loop_end:
	cpi	r18,		1
	breq	__LCD_set_pixel_set
	com	r28
	and	r24,		r28
	rjmp	__LCD_set_pixel_set_end
__LCD_set_pixel_set:
	or	r24,		r28
__LCD_set_pixel_set_end:
	; Store pixel in buffer
	st	Z,		r24

	pop	r31
	pop	r30
	pop	r29
	pop	r28
	pop	r25
	pop	r24
	ret

LCD_clear_buffer:
	push	r16
	push	r24
	push	r25
	push	r30
	push	r31

	ldi	r31,		HIGH(lcd_buffer)
	ldi	r30,		LOW(lcd_buffer)

	ldi	r25,		HIGH(504)
	ldi	r24,		LOW(504)

	ldi	r16,		0
__LCD_clear_buffer_loop:
	st	Z+,		r16
	sbiw	r24,		1
	brne	__LCD_clear_buffer_loop

	pop	r31
	pop	r30
	pop	r25
	pop	r24
	pop	r16
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

