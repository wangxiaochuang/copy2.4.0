#ifndef __i386_UACCESS_H
#define __i386_UACCESS_H

/*
 * User space memory access functions
 */
#include <linux/config.h>
#include <linux/sched.h>
#include <asm/page.h>

#define VERIFY_READ 0
#define VERIFY_WRITE 1

struct exception_table_entry {
	unsigned long insn, fixup;
};

#endif