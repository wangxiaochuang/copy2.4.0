#define __KERNEL_SYSCALLS__

#include <linux/linkage.h>
#include <linux/init.h>
#include <linux/smp_lock.h>

extern char _stext, _etext;
extern char *linux_banner;

asmlinkage void __init start_kernel(void) {
	char * command_line;
	unsigned long mempages;
	extern char saved_command_line[];
	lock_kernel();
	printk(linux_banner);
	setup_arch(&command_line);
    for (;;) {}
}