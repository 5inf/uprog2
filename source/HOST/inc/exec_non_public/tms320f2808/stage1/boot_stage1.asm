	.include "registers.inc"

LED_1		.equ	0x0002
LED_2		.equ	0x0020


		;macros for LED setting
SET_LED_00	.macro
		movw	DP,#GPIO_DATA_DP		;set data pointer to GPIO-Data-registers start
		mov	@GPASET_L,#(LED_1 | LED_2)	;all off
		.endm

		;macros for LED setting
SET_LED_01	.macro
		movw	DP,#GPIO_DATA_DP		;set data pointer to GPIO-Data-registers start
		mov	@GPASET_L,#LED_2		;LED 2 off
		mov	@GPACLEAR_L,#LED_1		;LED 1 on
		.endm


		;macros for LED setting
SET_LED_10	.macro
		movw	DP,#GPIO_DATA_DP		;set data pointer to GPIO-Data-registers start
		mov	@GPASET_L,#LED_1		;LED 1 off
		mov	@GPACLEAR_L,#LED_2		;LED 2 on
		.endm


		;macros for LED setting
SET_LED_11	.macro
		movw	DP,#GPIO_DATA_DP		;set data pointer to GPIO-Data-registers start
		mov	@GPACLEAR_L,#(LED_1 | LED_2)	;all on
		.endm



SPX_CLKMASK	.equ	0x0080				;use GPIO23 as clock
SPX_DATMASK	.equ	0x0040				;use GPIO22 as data
SPX_DATMASKI	.equ	0xffbf				;use GPIO22 as data (inverted)

;.text:

	.setsect ".text",0x0040
start:		eallow
		dint
		movw	DP,#CLOCK_DP			;set data pointer to CLOCK-registers start
		mov	@WDCR,#0x006F			;
		mov	@PLLCR,#0x0005			;50MHz

		movw	DP,#GPIO_CTRL_DP		;set data pointer to GPIO-Control-registers start
		mov	@GPAMUX1,#0x0000		;
		mov	@GPAMUX2,#0x0000		;
		mov	@GPADIR_L,#0x0022		;
		mov	@GPADIR_H,#0x0000		;

		movw	DP,#CSM_DP			;set data pointer to CSM-registers start
		mov	AL,@CSMSCR
		asr	AL,1
		b	unlocked,NC

		.copy "unlock.asm"

		movw	DP,#0xFDFF			;set data pointer to CSM-registers start
		movw	AL,@0x38
		movw	AL,@0x39
		movw	AL,@0x3a
		movw	AL,@0x3b
		movw	AL,@0x3c
		movw	AL,@0x3d
		movw	AL,@0x3e
		movw	AL,@0x3f

		movw	DP,#CSM_DP			;set data pointer to CSM-registers start
		mov	AL,@CSMSCR
		asr	AL,1
		b	unlocked,NC


set_err:	SET_LED_11				;2 LED, error
err_end:	b	err_end,UNC

		;OK, we can start
unlocked:	dint
		SET_LED_01				;LED 1, OK

read_boot:	movl	XAR0,#0x003f8000
		movw	AR1,#0x13ff			;words to do -1

read_boot_1:	lc	read_word			;read word to AR2
		SET_LED_00				;LED OFF
		movw	*XAR0++,AR6			;store word to RAM
		banz	read_boot_1,AR1--		;loop until all words done

exit:		movw	DP,#GPIO_DATA_DP		;set data pointer to GPIO-Data-registers start

		movl	XAR0,#0x003f8000
		movw	AR1,#0x13fe			;words to do -1
		movw	AR2,#0				;start value
check_boot_1:	movw	AL,*XAR0++
		add	AL,AR2
		movw	AR2,AL
		banz	check_boot_1,AR1--		;loop until all words done
		movw	AL,*XAR0++			;this is the stored hexsum
		cmp	AL,AR2
		b	set_err,NEQ			;err if checksum failed

		SET_LED_10				;LED 1, OK
test1:	;	b	test1,UNC
		.copy "jump_to_c.asm"

read_word:	movw	DP,#GPIO_DATA_DP		;set data pointer to GPIO-Data-registers start

read_word_01:	movw	ACC,@GPADAT_H
		and	ACC,#SPX_CLKMASK
		b	read_word_10,EQ			;OK, clock is low
		movw	@GPASET_H,#SPX_DATMASK		;set data to HIGH
		movw	DP,#GPIO_CTRL_DP		;set data pointer to GPIO-control-registers start
		movw	ACC,@GPADIR_H			;set data to output
		or	ACC,#SPX_DATMASK
		movw	@GPADIR_H,ACC
		movw	DP,#GPIO_DATA_DP		;set data pointer to GPIO-Data-registers start
read_word_02:	movw	ACC,@GPADAT_H
		and	ACC,#SPX_CLKMASK
		b	read_word_02,NEQ		;wait for clock low
		movw	DP,#GPIO_CTRL_DP		;set data pointer to GPIO-control-registers start
		movw	ACC,@GPADIR_H			;set data to input
		and	ACC,#SPX_DATMASKI
		movw	@GPADIR_H,ACC
		movw	DP,#GPIO_DATA_DP		;set data pointer to GPIO-Data-registers start

read_word_10:	movw	AR5,#7				;loops -1

read_word_12:	movw	ACC,@GPADAT_H			;wait for clock high
		and	ACC,#SPX_CLKMASK
		b	read_word_12,EQ			;branch if clock is low
		movw	AL,AR6				;get data
		lsl	ACC,1				;shift
		movw	AR6,AL				;save current state
		movw	ACC,@GPADAT_H			;get data
		and	ACC,#SPX_DATMASK		;check data bit
		b	read_word_14,EQ			;branch if data bit is zero is low
		movw	AL,AR6				;get data
		inc	AL				;make bit 0 to one
		movw	AR6,AL				;save current state

read_word_14:	movw	ACC,@GPADAT_H			;wait for clock low
		and	ACC,#SPX_CLKMASK
		b	read_word_14,NEQ		;branch if clock is high
		movw	AL,AR6				;get data
		lsl	ACC,1				;shift
		movw	AR6,AL				;save current state
		movw	ACC,@GPADAT_H			;get data
		and	ACC,#SPX_DATMASK		;check data bit
		b	read_word_16,EQ			;branch if data bit is zero is low
		movw	AL,AR6				;get data
		inc	AL				;make bit 0 to one
		movw	AR6,AL				;save current state
read_word_16:	banz	read_word_12,AR5--

read_word_18:	movw	ACC,@GPADAT_H			;wait for clock high
		and	ACC,#SPX_CLKMASK
		b	read_word_18,EQ			;branch if clock is low

		movw	@GPASET_H,#SPX_DATMASK		;set data to HIGH
		movw	DP,#GPIO_CTRL_DP		;set data pointer to GPIO-control-registers start
		movw	ACC,@GPADIR_H			;set data to output
		or	ACC,#SPX_DATMASK
		movw	@GPADIR_H,ACC
		movw	DP,#GPIO_DATA_DP		;set data pointer to GPIO-Data-registers start
read_word_20:	movw	ACC,@GPADAT_H
		and	ACC,#SPX_CLKMASK
		b	read_word_20,NEQ		;wait for clock low
		movw	DP,#GPIO_CTRL_DP		;set data pointer to GPIO-control-registers start
		movw	ACC,@GPADIR_H			;set data to input
		and	ACC,#SPX_DATMASKI
		movw	@GPADIR_H,ACC

		lret					;OK, thats all

