/*
 *  armboot - Startup Code for ARM926EJS CPU-core
 *
 *  Copyright (c) 2003  Texas Instruments
 *
 *  ----- Adapted for OMAP1610 from ARM925t code ------
 *
 *  Copyright (c) 2001	Marius Gr�ger <mag@sysgo.de>
 *  Copyright (c) 2002	Alex Z�pke <azu@sysgo.de>
 *  Copyright (c) 2002	Gary Jennejohn <gj@denx.de>
 *  Copyright (c) 2003	Richard Woodruff <r-woodruff2@ti.com>
 *  Copyright (c) 2003	Kshitij <kshitij@ti.com>
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */


#include <config.h>
#include <version.h>

#if defined(CONFIG_OMAP1610)
#include <./configs/omap1510.h>
#endif


/*
 *************************************************************************
 *
 * Jump vector table as in table 3.1 in [1]
 *
 *************************************************************************
 */


.globl _start
_start:
	b	reset
	ldr	pc, _undefined_instruction
	ldr	pc, _software_interrupt
	ldr	pc, _prefetch_abort
	ldr	pc, _data_abort
	ldr	pc, _not_used
	ldr	pc, _irq
	ldr	pc, _fiq

_undefined_instruction:
	.word undefined_instruction
_software_interrupt:
	.word software_interrupt
_prefetch_abort:
	.word prefetch_abort
_data_abort:
	.word data_abort
_not_used:
	.word not_used
_irq:
	.word irq
_fiq:
	.word fiq

	.balignl 16,0xdeadbeef


/*
 *************************************************************************
 *
 * Startup Code (reset vector)
 *
 * do important init only if we don't start from memory!
 * setup Memory and board specific bits prior to relocation.
 * relocate armboot to ram
 * setup stack
 *
 *************************************************************************
 */

_TEXT_BASE:
	.word	TEXT_BASE

.globl _armboot_start
_armboot_start:
	.word _start

/*
 * These are defined in the board-specific linker script.
 */
.globl _bss_start
_bss_start:
	.word __bss_start

.globl _bss_end
_bss_end:
	.word _end

#ifdef CONFIG_USE_IRQ
/* IRQ stack memory (calculated at run-time) */
.globl IRQ_STACK_START
IRQ_STACK_START:
	.word	0x0badc0de

/* IRQ stack memory (calculated at run-time) */
.globl FIQ_STACK_START
FIQ_STACK_START:
	.word 0x0badc0de
#endif


/*
 * the actual reset code
 */

        .extern __TEXT_END

reset:
	/*
	 * set the cpu to SVC32 mode
	 */
	mrs	r0,cpsr
	bic	r0,r0,#0x1f
	orr	r0,r0,#0xd3
	msr	cpsr,r0

	/*
	 * we do sys-critical inits only at reboot,
	 * not when booting from ram!
	 */

         
#ifdef CONFIG_INIT_CRITICAL
	bl	cpu_init_crit
#endif              

#if 0                
	ldr	r12,    =0x8006c000
	ldr	r3,	=0x80000000		@ clear sft rst
	str	r3,	[r12, #0x8]
	ldr	r3,	=0x40000000		@ enable clk
	str	r3,	[r12, #0x8]
	ldr	r3,	=0x000d0470		@ set baudrate 180M/(16*38400)=292.96875=0x0124_3E70, 0x10070 for test
	str	r3,	[r12, #0x30]
	ldr	r3,	=0x201			@ enable rec
	str	r3,	[r12, #0x24]
	ldr	r3,	=0xc000			 @ clr hardware ctrl
	str	r3,	[r12, #0x28]	
#endif



	.equ	RamBase,	0x20680000
	.equ	ImageSize,	0x18000	@should be 0x800 2kB
	.equ	ApbBase,	0x80000000
	.equ	UartBase,	0x80010000
	.equ  CryptionCode, 0x55555555  @ use r5
	.equ  FlashBase,	0x00000000     

        @ for direct boot up
	b	stack_setup 
        
@       	mov	r0,	pc
@       	ands	r0,	r0,	#0xff000000
@       	beq	relocate
@       @loop:
@       @	ldr	r3,	=0x37
@       @	str	r3,	[r12, #0x50]
@       @	b	loop
@       	
@       uart_relocate:
@       @        ldr     r8,     =0x800000a0
@       @	ldr	r7,	=0xffffffff
@       @	str	r7,	[r8]
@       
@               ldr     r8,     =RamBase
@       	ldr	r7,	=UartBase		@ r12	= 0x8006c000
@               add     r9, r8 , #ImageSize
@       uart_ready_loop:
@       	ldr	r1,	[r7, #0x60]	@ Spin, if Rx FIFO is empty
@       	tst	r1,	#0x01000000
@       	bne	uart_ready_loop
@       
@       	@ read the data, store it, and accumulate checksum
@       	ldr	r0,	[r7, #0x50]		@ Read data
@       	strb	r0,	[r8],	#1		@ Save it in memory
@       	cmp	r8,	r9
@       	blt	uart_ready_loop
@       
@       	@ All received, send end flag
@       	mov	r0,	#EndFlag
@       	str	r0,	[r7, #0x50]
@       
@       
@       
@       	b	stack_setup






relocate:				/* relocate U-Boot to RAM	    */

@loop2:
@	ldr	r3,	=0x39
@	str	r3,	[r9, #0x50]
@	b	loop2

	adr	r0, _start		/* r0 <- current position of code   */
	ldr	r1, _TEXT_BASE		/* test if we run from flash or RAM */
	cmp     r0, r1                  /* don't reloc during debug         */
	beq     stack_setup

	ldr	r2, _armboot_start
	ldr	r3, _bss_start
	sub	r2, r3, r2		/* r2 <- size of armboot            */
	add	r2, r0, r2		/* r2 <- source end address         */

copy_loop:
	ldmia	r0!, {r3-r10}		/* copy from source address [r0]    */
	stmia	r1!, {r3-r10}		/* copy to   target address [r1]    */
	cmp	r0, r2			/* until source end addreee [r2]    */
	ble	copy_loop

	/* Set up the stack						    */
stack_setup:
	ldr	r0, _TEXT_BASE		/* upper 128 KiB: relocated uboot   */
	sub	r0, r0, #CFG_MALLOC_LEN	/* malloc area                      */
	sub	r0, r0, #CFG_GBL_DATA_SIZE /* bdinfo                        */
#ifdef CONFIG_USE_IRQ
	sub	r0, r0, #(CONFIG_STACKSIZE_IRQ+CONFIG_STACKSIZE_FIQ)
#endif
	sub	sp, r0, #12		/* leave 3 words for abort-stack    */

clear_bss:
	ldr	r0, _bss_start		/* find start of bss segment        */
	add	r0, r0, #4		/* start at first byte of bss       */
	ldr	r1, _bss_end		/* stop here                        */
	mov 	r2, #0x00000000		/* clear                            */

clbss_l:str	r2, [r0]		/* clear loop...                    */
	add	r0, r0, #4
	cmp	r0, r1
	bne	clbss_l
               
	ldr	pc, _start_armboot

_start_armboot:
	.word start_armboot


/*
 *************************************************************************
 *
 * CPU_init_critical registers
 *
 * setup important registers
 * setup memory timing
 *
 *************************************************************************
 */


cpu_init_crit:
	/*
	 * flush v4 I/D caches
	 */
	mov	r0, #0
	mcr	p15, 0, r0, c7, c7, 0	/* flush v3/v4 cache */
	mcr	p15, 0, r0, c8, c7, 0	/* flush v4 TLB */

	/*
	 * disable MMU stuff and caches
	 */
	mrc	p15, 0, r0, c1, c0, 0
	bic	r0, r0, #0x00002300	/* clear bits 13, 9:8 (--V- --RS) */
	bic	r0, r0, #0x00000087	/* clear bits 7, 2:0 (B--- -CAM) */
	orr	r0, r0, #0x00000002	/* set bit 2 (A) Align */
	orr	r0, r0, #0x00001000	/* set bit 12 (I) I-Cache */
	mcr	p15, 0, r0, c1, c0, 0

	/*
	 * Go setup Memory and board specific bits prior to relocation.
	 */
	 

        mov	ip, lr		/* perserve link reg across call */
	bl	init_sect	/* go setup pll,mux,memory */
	mov	lr, ip		/* restore link */
	mov	pc, lr		/* back to my caller */
	

#define MT_48LC32M 1
#define __HAVE_NOR_FLASH_

init_sect:

        /*  Pin assign  */
        
        /* GATE */         
	ldr		r9,	=0x80018000
	ldr		r0,	=0x3c000000			@HW_PINCTRL_CTRL
	str		r0,	[r9]
	str		r0,	[r9]

        /* UART */        
	ldr		r0,	=0xfff00fff			
	str		r0,	[r9,	#0x120]                 @HW_PINCTRL_MUXSEL3
        
        /* SDRAM*/
	mov		r0,	#0x0			
	str		r0,	[r9,	#0x210]                 @HW_PINCTRL_MUXSEL4
	str		r0,	[r9,	#0x220]                 @HW_PINCTRL_MUXSEL5
	ldr		r0,	=0x000fffff			
	str		r0,	[r9,	#0x318]                 @HW_PINCTRL_MUXSEL6_CLR

        /* GPMI*/
	mov		r0,	#0x0			
	str		r0,	[r9,	#0x10]                 @HW_PINCTRL_MUXSEL0
	str		r0,	[r9,	#0x20]                 @HW_PINCTRL_MUXSEL1
         

#ifdef __HAVE_NAND_FLASH_
	mov		r0,	#0x1			
	str		r0,	[r9,	#0x314]                 @HW_PINCTRL_MUXSEL6_SET
#endif /*__HAVE_NAND_FLASH_*/

#ifdef __HAVE_NOR_FLASH_
	mov		r0,	#0x3			
	str		r0,	[r9,	#0x318]                 @HW_PINCTRL_MUXSEL6_CLR
	ldr		r0,	=0x55550000			
	str		r0,	[r9,	#0x10]                 @HW_PINCTRL_MUXSEL0
	ldr		r0,	=0x00015040			
	str		r0,	[r9,	#0x20]                 @HW_PINCTRL_MUXSEL1
#endif /*__HAVE_NOR_FLASH_*/

                
	@init emi
	ldr		r9,	=0x80020000
	mov		r0,	#0xc				@HW_EMICTRL
	str		r0,	[r9]
	str		r0,	[r9]
	ldr		r0,	=0x300000			@HW_EMIDRAMCTRL
	str		r0,	[r9,	#0x90]
#ifdef  MT_48LC32M
	ldr		r0,	=0x1DA				@512Mb: r=13 c=10
	str		r0,	[r9,	#0xa0]
	mov		r0,	#0x30				@HW_EMIDRAMMODE
	str		r0,	[r9,	#0xb0]
#endif

#ifdef  SAMSUNG_K4S64
	ldr		r0,	=0x1c8				@64Mb: r=12 c=8
	str		r0,	[r9,	#0xa0]
	mov		r0,	#0x20				@HW_EMIDRAMMODE
	str		r0,	[r9,	#0xb0]
#endif

#ifdef  RAMOS_RC56S16
	ldr		r0,	=0x1DA				@256Mb: r=13 c=9
	str		r0,	[r9,	#0xa0]
	mov		r0,	#0x30				@HW_EMIDRAMMODE
	str		r0,	[r9,	#0xb0]
#endif


	ldr		r0,	=0x2C442271			@HW_EMIDRAMTIME
	str		r0,	[r9,	#0xc0]
	ldr		r0,	=0x02b00000			@HW_EMIDRAMTIME2
	str		r0,	[r9,	#0xd0]
	mov		r0,	#0x5				@HW_EMISTATICCTRL
	str		r0,	[r9,	#0x100]
	ldr		r0,	=0x03020a08			@HW_EMISTATICTIME
	str		r0,	[r9,	#0x110]
	mov		pc,	lr


/*
 *************************************************************************
 *
 * Interrupt handling
 *
 *************************************************************************
 */

@
@ IRQ stack frame.
@
#define S_FRAME_SIZE	72

#define S_OLD_R0	68
#define S_PSR		64
#define S_PC		60
#define S_LR		56
#define S_SP		52

#define S_IP		48
#define S_FP		44
#define S_R10		40
#define S_R9		36
#define S_R8		32
#define S_R7		28
#define S_R6		24
#define S_R5		20
#define S_R4		16
#define S_R3		12
#define S_R2		8
#define S_R1		4
#define S_R0		0

#define MODE_SVC 0x13
#define I_BIT	 0x80

/*
 * use bad_save_user_regs for abort/prefetch/undef/swi ...
 * use irq_save_user_regs / irq_restore_user_regs for IRQ/FIQ handling
 */

	.macro	bad_save_user_regs
	@ carve out a frame on current user stack
	sub	sp, sp, #S_FRAME_SIZE
	stmia	sp, {r0 - r12}	@ Save user registers (now in svc mode) r0-r12

	ldr	r2, _armboot_start
	sub	r2, r2, #(CONFIG_STACKSIZE+CFG_MALLOC_LEN)
	sub	r2, r2, #(CFG_GBL_DATA_SIZE+8)  @ set base 2 words into abort stack
	@ get values for "aborted" pc and cpsr (into parm regs)
	ldmia	r2, {r2 - r3}
	add	r0, sp, #S_FRAME_SIZE		@ grab pointer to old stack
	add	r5, sp, #S_SP
	mov	r1, lr
	stmia	r5, {r0 - r3}	@ save sp_SVC, lr_SVC, pc, cpsr
	mov	r0, sp		@ save current stack into r0 (param register)
	.endm

	.macro	irq_save_user_regs
	sub	sp, sp, #S_FRAME_SIZE
	stmia	sp, {r0 - r12}			@ Calling r0-r12
	@ !!!! R8 NEEDS to be saved !!!! a reserved stack spot would be good.
	add	r8, sp, #S_PC
	stmdb	r8, {sp, lr}^		@ Calling SP, LR
	str	lr, [r8, #0]		@ Save calling PC
	mrs	r6, spsr
	str	r6, [r8, #4]		@ Save CPSR
	str	r0, [r8, #8]		@ Save OLD_R0
	mov	r0, sp
	.endm

	.macro	irq_restore_user_regs
	ldmia	sp, {r0 - lr}^			@ Calling r0 - lr
	mov	r0, r0
	ldr	lr, [sp, #S_PC]			@ Get PC
	add	sp, sp, #S_FRAME_SIZE
	subs	pc, lr, #4		@ return & move spsr_svc into cpsr
	.endm

	.macro get_bad_stack
	ldr	r13, _armboot_start		@ setup our mode stack
	sub	r13, r13, #(CONFIG_STACKSIZE+CFG_MALLOC_LEN)
	sub	r13, r13, #(CFG_GBL_DATA_SIZE+8) @ reserved a couple spots in abort stack

	str	lr, [r13]	@ save caller lr in position 0 of saved stack
	mrs	lr, spsr	@ get the spsr
	str	lr, [r13, #4]	@ save spsr in position 1 of saved stack
	mov	r13, #MODE_SVC	@ prepare SVC-Mode
	@ msr	spsr_c, r13
	msr	spsr, r13	@ switch modes, make sure moves will execute
	mov	lr, pc		@ capture return pc
	movs	pc, lr		@ jump to next instruction & switch modes.
	.endm

	.macro get_irq_stack			@ setup IRQ stack
	ldr	sp, IRQ_STACK_START
	.endm

	.macro get_fiq_stack			@ setup FIQ stack
	ldr	sp, FIQ_STACK_START
	.endm

/*
 * exception handlers
 */
	.align  5
undefined_instruction:
	get_bad_stack
	bad_save_user_regs
	bl	do_undefined_instruction

	.align	5
software_interrupt:
	get_bad_stack
	bad_save_user_regs
	bl	do_software_interrupt

	.align	5
prefetch_abort:
	get_bad_stack
	bad_save_user_regs
	bl	do_prefetch_abort

	.align	5
data_abort:
	get_bad_stack
	bad_save_user_regs
	bl	do_data_abort

	.align	5
not_used:
	get_bad_stack
	bad_save_user_regs
	bl	do_not_used

#ifdef CONFIG_USE_IRQ

	.align	5
irq:
	get_irq_stack
	irq_save_user_regs
	bl 	do_irq
	irq_restore_user_regs

	.align	5
fiq:
	get_fiq_stack
	/* someone ought to write a more effiction fiq_save_user_regs */
	irq_save_user_regs
	bl 	do_fiq
	irq_restore_user_regs

#else

	.align	5
irq:
	get_bad_stack
	bad_save_user_regs
	bl	do_irq

	.align	5
fiq:
	get_bad_stack
	bad_save_user_regs
	bl	do_fiq

#endif

	.align	5
.globl reset_cpu
reset_cpu:
	ldr	r1, rstctl1	/* get clkm1 reset ctl */
	mov	r3, #0x0
	strh	r3, [r1]	/* clear it */
	mov	r3, #0x8
	strh	r3, [r1]	/* force dsp+arm reset */
_loop_forever:
	b	_loop_forever


rstctl1:
	.word	0xfffece10
