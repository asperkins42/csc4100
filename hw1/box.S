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
	cmp w0, 0
	bne _box_error_
	
	// first draw the corners!
	// +		+
	// + 		+
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, 16]
	bl _box_draw_corners_

	// top and bottom
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, 16]
	bl _box_draw_top_bottom_
	
	// left and right
	ldp x0, x1, [sp]
	ldp x2, x3, [sp, 16]
	bl _box_draw_left_right_
	
	mov w0, 0
	b _box_exit_
	
 _box_check_box_:

	//load values into x4-x7 from the stack, store x30 elsewhere in the stack, readjust sp
	ldp x4, x5, [sp]
	ldp x6, x7, [sp, 16]
	sub sp, sp, 16
	str x30, [sp]
	add sp, sp, 16	

	// get max_height and store in w0. Load end_row into x6 from the stack
	bl term_txtheight
	ldp x6, x7, [sp, 16]

	// my attempt at absolute value, errors probably arise when dividing by zero.
	// doing the compare without the mul and udiv instructions causes the program not to run
	mul x0, x0, x0
	udiv x0, x0, x0

	// compare max_rows to end_row, if end_row is greater or equal, branch to _box_error_
	cmp x0, x6
	bge _box_error_

	// very similar to above, but for max_cols and end_cols
	bl term_txtwidth
	ldp x6, x7, [sp, 16]
	mul x0, x0, x0
	udiv x0, x0, x0
	cmp x0, x7
	bge _box_error_

	// these two sanity checks don't have any gross "absolute value" stuff going on because they're both
	// unsigned and would not cause the program to crash.

	// compare end and start cols, throw error if start is >= to end
	ldp x4, x5, [sp]
	cmp x5, x7
	bge _box_error_

	// compare end and start cols, throw error if start is >= to end
	cmp x4, x6
	bge _box_error_

	// if we are here, then we have sane inputs, return a 0 in w0. adjust sp and pull return address, then adjust sp 1 more time
	// my stack management is GARBAGE and I am sorry :smile: I will get better as class goes on 
	mov x0, 0
	sub sp, sp, 16
	ldr x30, [sp]
	add sp, sp, 16
	ret

	

_box_draw_corners_:

	// save my parameters into w4-w7, uncertain if w0-w3 will be overwritten. adjust sp and place return address on stack
	mov w4, w0	
	mov w5, w1				
	mov w6, w2				
	mov w7, w3
	sub sp, sp, 16
	str x30, [sp]					

	// load '+' into w8! then put it in w2. need to keep doing this everytime I think
	// also values are already in w0, w1 from initial load so start row start col are taken care of. call putc
	mov  w8, '+'
	mov w2, w8
	bl putc_to
	
	// set start row and end col
	mov w0, w4					// start row
	mov w1, w7					// end col
	mov w2, w8					// +
	bl putc_to
	
	// set end row and start col 
	mov w0, w6					// end row
	mov w1, w5					// start col
	mov w2, w8					// +
	bl putc_to
	
	// set end row and end col
	mov w0, w6					// end row
	mov w1, w7					// end col
	mov w2, w8					// +
	bl putc_to

	//pull return address from stack and adjust sp, then return
	ldr x30, [sp]
	add sp, sp, 16
	ret

_box_draw_left_right_:

	// adjust stack pointer and save return address
	sub sp, sp, 16
	str x30, [sp]

	// pull values from stack (starting to understand it now :big_smile:)
	ldp x4, x5, [sp, 16]
	ldp x6, x7, [sp, 32]

	// decrement end row
	sub x6, x6, 1
_box_draw_left_right_loop_: 

	// increment start row. put sr and sc into along with char into regs to send to putc_to
	add x4, x4, 1
	mov x0, x4
	mov x1, x5
	mov x2, '|'
	bl putc_to

	// start row, end column, and char to regs to send to putc_to
	mov x0, x4
	mov x1, x7
	mov x2, '|'
	bl putc_to

	// if loop isn't finished, loop again. otherwise, done
	cmp x4, x6
	bne _box_draw_left_right_loop_
	b _box_draw_left_right_done_

_box_draw_left_right_done_: 

	// load return address back into x30 and adjust stack
	ldr x30, [sp]
	add sp, sp, 16
	ret
	
		
_box_draw_top_bottom_:

	// not going to comment this entirely. EXTREMELY similar to _box_draw_left_right_
	sub sp, sp, 16
	str x30, [sp]
	ldp x4, x5, [sp, 16]
	ldp x6, x7, [sp, 32]
	sub x7, x7, 1
_box_draw_top_bottom_loop_: 
	add x5, x5, 1
	mov x0, x4
	mov x1, x5
	mov x2, '-'
	bl putc_to
	
	mov x0, x6
	mov x1, x5
	mov x2, '-'
	bl putc_to
	
	cmp x5, x7
	bne _box_draw_top_bottom_loop_
	b _box_draw_top_bottom_done_

_box_draw_top_bottom_done_: 
	ldr x30, [sp]
	add sp, sp, 16
	ret	

_box_error_:

	// if error is thrown, load w0 with a 1 to return to C
	mov w0, 1
	b _box_exit_
_box_exit_:

	// return to C by pulling original x30 return address off of the stack
	add sp, sp, 32
	ldp x29, x30, [sp], 16
	ret
	
