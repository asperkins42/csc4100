.global		box

			// external references to functions from libos.h
.extern 	term_txtheight
.extern		term_txtwidth
.extern		putc_to
.extern		print_to
box:

	// standard entry: save link and stack frame registers (x29 and x30)
	// load the stack frame with the pointer to current frame. 
	
	stp x29, x30, [sp, -16]!
	
	// Save the arguments. Called functions may overwrite x0-x3
	sub sp, sp, 32
	stp x0, x1, [sp]
	stp x2, x3, [sp, 16]
	
	// start row in w0, start column in w1, end row in w2, end column in w3
	// Make sure the arguments are valid
	
	bl _box_check_box_
	cmp x0, 0
	beq _box_error_
	
	// first draw the corners!
	// +		+
	// + 		+
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, 16]
	bl _box_draw_corners_
	
	// now, draw the top and bottom!
	// +------------+
	// +------------+
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, 16]
	bl _box_draw_top_bottom_
	
	// and the left and right sides!
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, 16]
	bl _box_draw_right_left_
	
	mov x0, 0
	b _box_exit_
	

_box_check_box_:

	sub sp, sp, 128
	str x30, [sp]
	
	// if end row <= to start row OR end column <= start column, throw an error and call it a day.
	cmp w2, w0
	ble _box_error_
	cmp w3, w1
	ble _box_error_

	// now start row is in w4 so w0 can be overwritten without worry
	mov w4, w0

	// get the width in columns of the screen and store in w0, compare against end columns value
	bl term_txtwidth
	cmp w0, w3
	bge _box_error_

	//get the height in rows of the screen and store in w0, compare against end rows value
	bl term_txtheight
	cmp w0, w2
	bge _box_error_

	ldr x30, [sp]
	add sp, sp, 128
	ret


_box_draw_corners_:

	sub sp, sp, 128
	str x30, [sp]

	// move w0-w3 into w4-w7
	mov w4, w0					// start row
	mov w5, w1					// start col
	mov w6, w2					// end row
	mov w7, w3					// end col

	// load '+' into w5!
	mov w8, '+'

	// get registers ready for first call
	mov w0, w4					// start row
	mov w1, w5					// start col
	mov w2, w8					// +
	bl putc_to
	
	// get registers ready for second call
	mov w0, w4					// start row
	mov w1, w6					// end col
	//mov w2, w8					// +
	bl putc_to
	
	// get registers ready for third call
	mov w0, w6					// end row
	mov w1, w5					// start col
	//mov w2, w8					// +
	bl putc_to
	
	// get registers ready for last call
	mov w0, w6					// end row
	mov w1, w7					// end col
	//mov w2, w8					// +
	bl putc_to

	ldr x30, [sp]
	add sp, sp, 128
	ret

_box_draw_top_bottom_:

_box_draw_right_left_:

_box_error_:
	mov w0, 1
	b _box_exit_
_box_exit_:
	add sp, sp, 32					// sp=sp+32 -- this gets us to where we can pull x29 and x30 from the stack.
	ldp x29, x30, [sp], 16			// load values at sp into x29 and x30 THEN update sp = sp+16
	ret
	