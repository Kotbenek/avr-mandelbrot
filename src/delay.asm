DELAY:
	; Input: r16 - delay loops count
	push	r24
	push	r25
__DELAY_LOOP_1:
	ldi	r25,	0xFF
	ldi	r24,	0xFF
__DELAY_LOOP_2:
	sbiw	r24,	1
	brne	__DELAY_LOOP_2
	dec	r16
	brne	__DELAY_LOOP_1
	pop	r25
	pop	r24
	ret

