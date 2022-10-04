; Step in X: 2.5 / 83
; 0000.0000 0111 1011
.define	inc_xh		0x00
.define	inc_xl		0x7B

; Step in Y: 2.32 / 47
; 0000.0000 1100 1010
.define	inc_yh		0x00
.define	inc_yl		0xCA

; Starting point X: -2
; 1110.0000 0000 0000
.define	start_xh	0xE0
.define	start_xl	0x00

; Starting point Y: -1.16
; 1110.1101 0111 0000
.define	start_yh	0xED
.define	start_yl	0x70

; Ending point X: 0.5
; Ending point Y: 1.16

; Max |z|: 4
; 0000 0100.0000 0000
.define	max_z_h		0x04
.define	max_z_l		0x00

mandelbrot_approximate_point:
	; Input: r16 - RL, r17 - RH, r18 - IL, r19 - IH
	; Output: r20 - approximation
	; Max iterations count = 255
	push	r21
	push	r22
	push	r23
	push	r24
	push	r25
	push	r26
	push	r27
	push	r28
	push	r29
	push	r30
	push	r31

	; iter_count - r20
	; z_real - r23:r22
	; z_imag - r25:r24
	; z_real_temp - r27:r26
	; z_imag_temp - r29:r28
	; z_abs - r31:r30 (format 8.8)

	; Initialize values
	ldi	r20,	0
	ldi	r23,	0
	ldi	r22,	0
	ldi	r25,	0
	ldi	r24,	0
__mandelbrot_approximate_point_loop:
	; z_real_temp = z_real * z_real - z_imag * z_imag
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21

	movw	r16,	r22
	movw	r18,	r22
	rcall	FP_mul
	movw	r26,	r20

	movw	r16,	r24
	movw	r18,	r24
	rcall	FP_mul

	movw	r16,	r26
	movw	r18,	r20
	rcall	FP_sub
	movw	r26,	r16

	pop	r21
	pop	r20
	pop	r19
	pop	r18
	pop	r17
	pop	r16

	; z_imag_temp = 2 * z_real * z_imag
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21

	movw	r16,	r22
	movw	r18,	r24
	rcall	FP_mul
	clc
	rol	r20
	rol	r21
	movw	r28,	r20

	pop	r21
	pop	r20
	pop	r19
	pop	r18
	pop	r17
	pop	r16

	; z_real = z_real_temp + R
	push	r16
	push	r17
	push	r18
	push	r19

	movw	r18,	r26
	rcall	FP_add
	movw	r22,	r16

	pop	r19
	pop	r18
	pop	r17
	pop	r16

	; z_imag = z_imag_temp + I
	push	r16
	push	r17

	movw	r16,	r28
	rcall	FP_add
	movw	r24,	r16

	pop	r17
	pop	r16

	; z_abs = z_real * z_real + z_imag * z_imag
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21

	movw	r16,	r22
	rcall	FP_4_12_to_8_8
	movw	r18,	r16
	rcall	FP_mul_8_8
	movw	r30,	r20

	movw	r16,	r24
	rcall	FP_4_12_to_8_8
	movw	r18,	r16
	rcall	FP_mul_8_8

	movw	r16,	r30
	movw	r18,	r20
	rcall	FP_add
	movw	r30,	r16

	pop	r21
	pop	r20
	pop	r19
	pop	r18
	pop	r17
	pop	r16

	; Check if z_abs < 4
	; Store result in r21
	push	r16
	push	r17
	push	r18
	push	r19

	movw	r16,	r30
	ldi	r19,	max_z_h
	ldi	r18,	max_z_l
	andi	r31,	0xFC
	tst	r31
	breq	__z_abs_less_than_4
	ldi	r21,	0
	rjmp	__z_abs_less_than_4_end
__z_abs_less_than_4:
	ldi	r21,	1
__z_abs_less_than_4_end:

	pop	r19
	pop	r18
	pop	r17
	pop	r16

	; Increment loop counter
	inc	r20

	; Loop if z_abs < 4
	cpi	r21,	1
	brne	__mandelbrot_approximate_point_end

	; Loop if iter_count < 255
	cpi	r20,	0xFF
	brne	__mandelbrot_approximate_point_loop_rjmp

__mandelbrot_approximate_point_end:
	pop	r31
	pop	r30
	pop	r29
	pop	r28
	pop	r27
	pop	r26
	pop	r25
	pop	r24
	pop	r23
	pop	r22
	pop	r21
	ret
__mandelbrot_approximate_point_loop_rjmp:
	rjmp	__mandelbrot_approximate_point_loop

mandelbrot:
	; Fill lcd_buffer with mandelbrot
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21
	push	r22

	ldi	r17,	start_xh
	ldi	r16,	start_xl
	ldi	r19,	start_yh
	ldi	r18,	start_yl

	; r21 - X
	; r22 - Y
	ldi	r21,	0
	ldi	r22,	0

__mandelbrot_loop:
	rcall	mandelbrot_approximate_point
	cpi	r20,	0x0A
	brsh	__mandelbrot_1
__mandelbrot_0:
	ldi	r20,	0
	rjmp	__mandelbrot_0_1_end
__mandelbrot_1:
	ldi	r20,	1
__mandelbrot_0_1_end:

	push	r16
	push	r17
	push	r18

	mov	r18,	r20
	mov	r16,	r21
	mov	r17,	r22
	rcall	LCD_set_pixel

	pop	r18
	pop	r17
	pop	r16

	inc	r22

	push	r16
	push	r17

	ldi	r17,	inc_yh
	ldi	r16,	inc_yl
	rcall	FP_add
	movw	r18,	r16

	pop	r17
	pop	r16

	cpi	r22,	48
	brne	__mandelbrot_loop

	ldi	r22,	0
	ldi	r19,	start_yh
	ldi	r18,	start_yl
	inc	r21

	push	r18
	push	r19

	ldi	r19,	inc_xh
	ldi	r18,	inc_xl
	rcall	FP_add

	pop	r19
	pop	r18

	cpi	r21,	84
	brne	__mandelbrot_loop

	pop	r22
	pop	r21
	pop	r20
	pop	r19
	pop	r18
	pop	r17
	pop	r16
	ret

