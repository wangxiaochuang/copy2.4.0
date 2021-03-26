.text
#include <linux/config.h>
#include <linux/threads.h>
#include <linux/linkage.h>
#include <asm/segment.h>
#include <asm/page.h>
#include <asm/pgtable.h>

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
	jmp .
	
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


ENTRY(stack_start)
	.long SYMBOL_NAME(init_task_union)+8192
	.long __KERNEL_DS

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