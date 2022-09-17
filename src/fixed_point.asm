; 16-bit fixed-point arithmetic in 4.12 and 8.8 format

FP_add:
	; Operation: X = X + Y
	; Input: r16 - XL, r17 - XH, r18 - YL, r19 - YH
	add	r16,	r18
	adc	r17,	r19
	ret

FP_sub:
	; Operation: X = X - Y
	; Input: r16 - XL, r17 - XH, r18 - YL, r19 - YH
	sub	r16,	r18
	sbc	r17,	r19
	ret

FP_mul:
	; Operation: Z = X * Y
	; Input: r16 - XL, r17 - XH, r18 - YL, r19 - YH
	; Output: r20 - ZL, r21 - ZH
	; Format: 4.12

	; (16b) Z = ((X * Y) >> 12) + (((X * Y) >> 11) & 1)

	push	r22
	push	r23
	push	r24
	push	r25
	push	r26

	; Calculate X * Y in r25:r24:r23:r22
	rcall	MUL_16

	; Save rounding bit in r22
	mov	r22,	r23
	lsr	r22
	lsr	r22
	lsr	r22
	ldi	r26,	1
	and	r22,	r26

	; Move to Z

	ldi	r21,	0
	ldi	r20,	0

	; r23(7:4) -> r20(3:0)
	mov	r20,	r23
	swap	r20
	ldi	r26,	0x0F
	and	r20,	r26

	; r24(3:0) -> r20(7:4)
	mov	r23,	r24
	swap	r23
	ldi	r26,	0xF0
	and	r23,	r26
	or	r20,	r23

	; r24(7:4) -> r21(3:0)
	swap	r24
	ldi	r26,	0x0F
	and	r24,	r26
	or	r21,	r24

	; r25(3:0) -> r21(7:4)
	swap	r25
	ldi	r26,	0xF0
	and	r25,	r26
	or	r21,	r25

	; Add rounding bit
	ldi	r26,	0
	add	r20,	r22
	adc	r21,	r26

	pop	r26
	pop	r25
	pop	r24
	pop	r23
	pop	r22
	ret

FP_4_12_to_8_8:
	; Operation: X(4.12) -> X(8.8)
	; Input: r16 - XL, r17 - XH
	push	r18
	swap	r16
	andi	r16,	0x0F
	mov	r18,	r17
	swap	r17
	andi	r17,	0xF0
	or	r16,	r17
	swap	r18
	andi	r18,	0x0F
	mov	r17,	r18
	
	andi	r18,	0x08
	cpi	r18,	0x08
	brne	__FP_4_12_to_8_8_end

	ori	r17,	0xF0

__FP_4_12_to_8_8_end:
	pop	r18
	ret

FP_mul_8_8:
	; Operation: Z = X * Y
	; Input: r16 - XL, r17 - XH, r18 - YL, r19 - YH
	; Output: r20 - ZL, r21 - ZH
	; Format: 8.8

	; (16b) Z = ((X * Y) >> 8) + (((X * Y) >> 7) & 1)

	push	r22
	push	r23
	push	r24
	push	r25
	push	r26

	; Calculate X * Y in r25:r24:r23:r22
	rcall	MUL_16

	; Save rounding bit in r22
	lsr	r22
	lsr	r22
	lsr	r22
	lsr	r22
	lsr	r22
	lsr	r22
	lsr	r22
	ldi	r26,	1
	and	r22,	r26

	; Move to Z
	mov	r20,	r23
	mov	r21,	r24

	; Add rounding bit
	add	r20,	r22
	ldi	r25,	0
	adc	r21,	r25

	pop	r26
	pop	r25
	pop	r24
	pop	r23
	pop	r22
	ret

MUL_16:
	; Input: r16 - XL, r17 - XH, r18 - YL, r19 - YH
	; (32b) X * Y = XL * YL        +
	;              (XH * YL) << 8  +
	;              (XL * YH) << 8  +
	;              (XH * YH) << 16 +
	;              (XS * YL) << 16 +
	;              (YS * XL) << 16 +
	;              (XS * YL) << 24 +
	;              (YH * XS) << 24 +
	;              (YS * XH) << 24 +
	;              (YS * XL) << 24

	push	r27
	push	r28
	
	; Store extended sign
	; XS - r27
	; YS - r28
	mov	r27,	r17
	andi	r27,	0x80
	cpi	r27,	0x80
	brne	__MUL_16_XS_0
__MUL_16_XS_1:
	ldi	r27,	0xFF
	rjmp	__MUL_16_XS_end
__MUL_16_XS_0:
	ldi	r27,	0
__MUL_16_XS_end:
	mov	r28,	r19
	andi	r28,	0x80
	cpi	r28,	0x80
	brne	__MUL_16_YS_0
__MUL_16_YS_1:
	ldi	r28,	0xFF
	rjmp	__MUL_16_YS_end
__MUL_16_YS_0:
	ldi	r28,	0
__MUL_16_YS_end:

	; Calculate X * Y in r25:r24:r23:r22
	ldi	r26,	0
	ldi	r25,	0
	ldi	r24,	0

	; XL * YL
	mul	r16,	r18
	movw	r22,	r0

	; (XL * YH) << 8
	mul	r16,	r19
	add	r23,	r0
	adc	r24,	r1
	adc	r25,	r26

	; (XH * YL) << 8
	mul	r17,	r18
	add	r23,	r0
	adc	r24,	r1
	adc	r25,	r26

	; (XH * YH) << 16
	mul	r17,	r19
	add	r24,	r0
	adc	r25,	r1

	; (XS * YL) << 16
	mul	r27,	r18
	add	r24,	r0
	adc	r25,	r1

	; (YS * XL) << 16
	mul	r28,	r16
	add	r24,	r0
	adc	r25,	r1

	; (XS * YL) << 24
	mul	r27,	r18
	add	r25,	r0

	; (YH * XS) << 24
	mul	r19,	r27
	add	r25,	r0

	; (YS * XH) << 24
	mul	r28,	r17
	add	r25,	r0

	; (YS * XL) << 24
	mul	r28,	r16
	add	r25,	r0

	pop	r28
	pop	r27
	ret

