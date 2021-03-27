#define __KERNEL_SYSCALLS__

#include <linux/linkage.h>
#include <linux/init.h>

asmlinkage void __init start_kernel(void) {
	char * command_line;
	unsigned long mempages;
	extern char saved_command_line[];
    for (;;) {}
}