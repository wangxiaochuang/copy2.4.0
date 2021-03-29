.text
#define __ASSEMBLY__
#include <linux/config.h>
#include <linux/threads.h>
#include <linux/linkage.h>
#include <asm/segment.h>
#include <asm/page.h>
#include <asm/pgtable.h>
#include <asm/desc.h>

#define OLD_CL_MAGIC_ADDR	0x90020
#define OLD_CL_MAGIC		0xA33F
#define OLD_CL_BASE_ADDR	0x90000
#define OLD_CL_OFFSET		0x90022
#define NEW_CL_POINTER		0x228	/* Relative to real mode data */

#define CPU_PARAMS	SYMBOL_NAME(boot_cpu_data)
#define X86		CPU_PARAMS+0
#define X86_VENDOR	CPU_PARAMS+1
#define X86_MODEL	CPU_PARAMS+2
#define X86_MASK	CPU_PARAMS+3
#define X86_HARD_MATH	CPU_PARAMS+6
#define X86_CPUID	CPU_PARAMS+8
#define X86_CAPABILITY	CPU_PARAMS+12
#define X86_VENDOR_ID	CPU_PARAMS+16

ENTRY(stext)
ENTRY(_stext)
startup_32:
	cld
	movl $__KERNEL_DS, %eax
	movl %eax, %ds
	movl %eax, %es
	movl %eax, %fs
	movl %eax, %gs

#ifdef CONFIG_SMP
	hlt
#endif
/*
 * Initialize page tables
 */
	movl $pg0 - __PAGE_OFFSET, %edi
	movl $007, %eax

2:	stosl					# edi从0x102000到0x104000，总共是两个页表8M内存
	add $0x1000, %eax
	cmp $empty_zero_page-__PAGE_OFFSET, %edi
	jne 2b
	
/*
 * Enable paging
 */
3:
	movl	$swapper_pg_dir - __PAGE_OFFSET, %eax
	movl	%eax, %cr3
	movl %cr0,%eax
	orl $0x80000000,%eax
	movl %eax,%cr0		/* ..and set paging (PG) bit */
	jmp 1f			/* flush the prefetch-queue */
1:
	movl $1f,%eax
	jmp *%eax		/* make sure eip is relocated */
1:
	/* Set up the stack pointer */
	lss stack_start, %esp

#ifdef CONFIG_SMP
	hlt
#endif

/*
 * Clear BSS first so that there are no surprises...
 * No need to cld as DF is already clear from cld above...
 */
	xorl %eax,%eax
	movl $ SYMBOL_NAME(__bss_start),%edi
	movl $ SYMBOL_NAME(_end),%ecx
	subl %edi,%ecx
	rep
	stosb

	call setup_idt

	pushl $0
	popfl
/*
 * Copy bootup parameters out of the way. First 2kB of
 * _empty_zero_page is for boot parameters, second 2kB
 * is for the command line.
 *
 * Note: %esi still has the pointer to the real-mode data.
 */
	movl $ SYMBOL_NAME(empty_zero_page),%edi
	movl $512,%ecx
	cld
	rep movsl			# 0x90000 -> empty_zero_page 2k
	xorl %eax,%eax
	movl $512,%ecx
	rep stosl			# set to zero for next 2k
	movl SYMBOL_NAME(empty_zero_page)+NEW_CL_POINTER,%esi
	andl %esi,%esi
	jnz 2f
	cmpw $OLD_CL_MAGIC,OLD_CL_MAGIC_ADDR
	jne 1f
	movzwl OLD_CL_OFFSET,%esi
	addl $OLD_CL_BASE_ADDR,%esi
2:
	movl $ SYMBOL_NAME(empty_zero_page)+2048,%edi
	movl $512,%ecx
	rep movsl
	hlt
1:
#ifdef CONFIG_SMP
checkCPUtype:
#endif
	movl $-1, X86_CPUID

/* check if it is 486 or 386. */
/*
 * XXX - this does a lot of unnecessary setup.  Alignment checks don't
 * apply at our cpl of 0 and the stack ought to be aligned already, and
 * we don't need to preserve eflags.
 */

	movl $3,X86		# at least 386
	pushfl			# push EFLAGS
	popl %eax		# get EFLAGS
	movl %eax,%ecx		# save original EFLAGS
	xorl $0x40000,%eax	# flip AC bit in EFLAGS
	pushl %eax		# copy to EFLAGS
	popfl			# set EFLAGS
	pushfl			# get new EFLAGS
	popl %eax		# put it in eax
	xorl %ecx,%eax		# change in flags
	andl $0x40000,%eax	# check if AC bit changed
	je is386

	movl $4,X86		# at least 486
	movl %ecx,%eax
	xorl $0x200000,%eax	# check ID flag
	pushl %eax
	popfl			# if we are on a straight 486DX, SX, or
	pushfl			# 487SX we can't change it
	popl %eax
	xorl %ecx,%eax
	pushl %ecx		# restore original EFLAGS
	popfl
	andl $0x200000,%eax
	je is486

	/* get vendor info */
	xorl %eax,%eax			# call CPUID with 0 -> return vendor ID
	cpuid
	movl %eax,X86_CPUID		# save CPUID level
	movl %ebx,X86_VENDOR_ID		# lo 4 chars
	movl %edx,X86_VENDOR_ID+4	# next 4 chars
	movl %ecx,X86_VENDOR_ID+8	# last 4 chars

	orl %eax,%eax			# do we have processor info as well?
	je is486

	movl $1,%eax		# Use the CPUID instruction to get CPU type
	cpuid
	movb %al,%cl		# save reg for future use
	andb $0x0f,%ah		# mask processor family
	movb %ah,X86
	andb $0xf0,%al		# mask model
	shrb $4,%al
	movb %al,X86_MODEL
	andb $0x0f,%cl		# mask mask revision
	movb %cl,X86_MASK
	movl %edx,X86_CAPABILITY

is486:
	movl %cr0,%eax		# 486 or better
	andl $0x80000011,%eax	# Save PG,PE,ET
	orl $0x50022,%eax	# set AM, WP, NE and MP
	jmp 2f

is386:
	hlt

2:
	movl %eax,%cr0
	call check_x87
#ifdef CONFIG_SMP
	incb ready
#endif
	lgdt gdt_descr
	lidt idt_descr
	ljmp $(__KERNEL_CS),$1f
1:	movl $(__KERNEL_DS),%eax	# reload all the segment registers
	movl %eax,%ds		# after changing gdt.
	movl %eax,%es
	movl %eax,%fs
	movl %eax,%gs
#ifdef CONFIG_SMP
	movl $(__KERNEL_DS), %eax
	movl %eax,%ss		# Reload the stack pointer (segment only)
#else
	lss stack_start,%esp	# Load processor stack
#endif
	xorl %eax,%eax
	lldt %ax
	cld			# gcc2 wants the direction flag cleared at all times
#ifdef CONFIG_SMP
	hlt
#endif
	call SYMBOL_NAME(start_kernel)
L6:
	jmp L6			# main should never return here, but
				# just in case, we know what happens.

#ifdef CONFIG_SMP
ready:	.byte 0
#endif

/*
 * We depend on ET to be correct. This checks for 287/387.
 */
check_x87:
	movb $0,X86_HARD_MATH
	clts
	fninit
	fstsw %ax
	cmpb $0,%al
	je 1f
	movl %cr0,%eax		/* no coprocessor: have to set bits */
	xorl $4,%eax		/* set EM */
	movl %eax,%cr0
	ret
	ALIGN
1:	movb $1,X86_HARD_MATH
	.byte 0xDB,0xE4		/* fsetpm for 287, ignored by 387 */
	ret

/*
 *  setup_idt
 *
 *  sets up a idt with 256 entries pointing to
 *  ignore_int, interrupt gates. It doesn't actually load
 *  idt - that can be done only after paging has been enabled
 *  and the kernel moved to PAGE_OFFSET. Interrupts
 *  are enabled elsewhere, when we can be relatively
 *  sure everything is ok.
 */
setup_idt:
	lea ignore_int, %edx
	movl $(__KERNEL_CS << 16), %eax
	movw %dx, %ax
	movw $0x8E00, %dx

	lea SYMBOL_NAME(idt_table), %edi
	mov $256, %ecx
rp_sidt:
	movl %eax, (%edi)
	movl %edx, 4(%edi)
	addl $8, %edi
	dec %ecx
	jne rp_sidt
	ret

ENTRY(stack_start)
	.long SYMBOL_NAME(init_task_union)+8192
	.long __KERNEL_DS

int_msg:
	.asciz "Unknown interrupt\n"
	ALIGN
ignore_int:
	cld
	pushl %eax
	pushl %ecx
	pushl %edx
	pushl %es
	pushl %ds
	movl $(__KERNEL_DS),%eax
	movl %eax,%ds
	movl %eax,%es
	pushl $int_msg
	call SYMBOL_NAME(printk)
	popl %eax
	popl %ds
	popl %es
	popl %edx
	popl %ecx
	popl %eax
	iret

/*
 * The interrupt descriptor table has room for 256 idt's,
 * the global descriptor table is dependent on the number
 * of tasks we can have..
 */
#define IDT_ENTRIES	256
#define GDT_ENTRIES	(__TSS(NR_CPUS))


.globl SYMBOL_NAME(idt)
.globl SYMBOL_NAME(gdt)

	ALIGN
	.word 0
idt_descr:
	.word IDT_ENTRIES*8-1		# idt contains 256 entries
SYMBOL_NAME(idt):
	.long SYMBOL_NAME(idt_table)

	.word 0
gdt_descr:
	.word GDT_ENTRIES*8-1
SYMBOL_NAME(gdt):
	.long SYMBOL_NAME(gdt_table)

/*
 * This is initialized to create an identity-mapping at 0-8M (for bootup
 * purposes) and another mapping of the 0-8M area at virtual address
 * PAGE_OFFSET.
 */
.org 0x1000
ENTRY(swapper_pg_dir)
	.long 0x00102007
	.long 0x00103007
	.fill BOOT_USER_PGD_PTRS-2,4,0
	/* default: 766 entries */
	.long 0x00102007
	.long 0x00103007
	/* default: 254 entries */
	.fill BOOT_KERNEL_PGD_PTRS-2,4,0

/*
 * The page tables are initialized to only 8MB here - the final page
 * tables are set up later depending on memory size.
 */
.org 0x2000
ENTRY(pg0)

.org 0x3000
ENTRY(pg1)

/*
 * empty_zero_page must immediately follow the page tables ! (The
 * initialization loop counts until empty_zero_page)
 */

.org 0x4000
ENTRY(empty_zero_page)

.org 0x5000
ENTRY(empty_bad_page)

.org 0x6000
ENTRY(empty_bad_pte_table)

#if CONFIG_X86_PAE	

 .org 0x7000
 ENTRY(empty_bad_pmd_table)

 .org 0x8000

#else

.org 0x7000

#endif

.data

ALIGN
/*
 * This contains typically 140 quadwords, depending on NR_CPUS.
 *
 * NOTE! Make sure the gdt descriptor in head.S matches this if you
 * change anything.
 */
ENTRY(gdt_table)
	.quad 0x0000000000000000	/* NULL descriptor */
	.quad 0x0000000000000000	/* not used */
	.quad 0x00cf9a000000ffff	/* 0x10 kernel 4GB code at 0x00000000 */
	.quad 0x00cf92000000ffff	/* 0x18 kernel 4GB data at 0x00000000 */
	.quad 0x00cffa000000ffff	/* 0x23 user   4GB code at 0x00000000 */
	.quad 0x00cff2000000ffff	/* 0x2b user   4GB data at 0x00000000 */
	.quad 0x0000000000000000	/* not used */
	.quad 0x0000000000000000	/* not used */
	/*
	 * The APM segments have byte granularity and their bases
	 * and limits are set at run time.
	 */
	.quad 0x0040920000000000	/* 0x40 APM set up for bad BIOS's */
	.quad 0x00409a0000000000	/* 0x48 APM CS    code */
	.quad 0x00009a0000000000	/* 0x50 APM CS 16 code (16 bit) */
	.quad 0x0040920000000000	/* 0x58 APM DS    data */
	.fill NR_CPUS*4,8,0		/* space for TSS's and LDT's */

/*
 * This is to aid debugging, the various locking macros will be putting
 * code fragments here.  When an oops occurs we'd rather know that it's
 * inside the .text.lock section rather than as some offset from whatever
 * function happens to be last in the .text segment.
 */
.section .text.lock
ENTRY(stext_lock)