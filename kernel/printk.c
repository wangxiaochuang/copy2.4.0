#include <linux/mm.h>
#include <linux/smp_lock.h>
#include <linux/init.h>

#include <asm/uaccess.h>

asmlinkage int printk(const char *fmt, ...) {
    return 0;
}