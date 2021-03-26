.global startup_32

.text

#include <linux/linkage.h>
#include <asm/segment.h>

.globl startup_32

startup_32:
    cld
    cli
    movl $__KERNEL_DS, %eax
    movl %eax,%ds
	movl %eax,%es
	movl %eax,%fs
	movl %eax,%gs

    lss SYMBOL_NAME(stack_start),%esp
    xorl %eax,%eax
1:	incl %eax		# check that A20 really IS enabled
	movl %eax,0x000000	# loop forever if it isn't
	cmpl %eax,0x100000
	je 1b

    pushl $0
	popfl

/*
 * Clear BSS
 */
	xorl %eax, %eax
	movl $ SYMBOL_NAME(_edata), %edi
	movl $ SYMBOL_NAME(_end), %ecx
	subl %edi, %ecx
	cld
    rep stosb

/*
 * Do the decompression, and jump to the new kernel
 */
    subl $16, %esp
    movl %esp, %eax
	pushl %esi	# real mode pointer as second arg
	pushl %eax	# address of structure as first arg
	call SYMBOL_NAME(decompress_kernel)
	orl  %eax, %eax 
	jnz  3f
	popl %esi	# discard address
	popl %esi	# real mode pointer
	xorl %ebx, %ebx
	ljmp $(__KERNEL_CS), $0x100000

3:
    hlt