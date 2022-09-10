SPI_init:
	; Enable SPI, Master, set clock rate fck/16
	push	r16
	ldi	r16,	(1<<SPE)|(1<<MSTR)|(1<<SPR0)
	out	SPCR,	r16
	pop	r16
	ret

SPI_transmit:
	; Input: r16 - data
	out	SPDR,	r16
__SPI_transmit_wait:
	sbis	SPSR,	SPIF
	rjmp	__SPI_transmit_wait
	ret

