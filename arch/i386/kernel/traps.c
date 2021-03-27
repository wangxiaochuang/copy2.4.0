#include <linux/config.h>
#include <linux/sched.h>
#include <linux/kernel.h>
#include <linux/string.h>
#include <linux/errno.h>
#include <linux/ptrace.h>
#include <linux/timer.h>
#include <linux/mm.h>
#include <linux/init.h>
#include <linux/spinlock.h>
#include <linux/interrupt.h>

#ifdef CONFIG_MCA
#include <linux/mca.h>
#include <asm/processor.h>
#endif

#include <asm/system.h>
#include <asm/uaccess.h>
#include <asm/io.h>
#include <asm/atomic.h>
#include <asm/desc.h>

struct desc_struct idt_table[256] __attribute__((__section__(".data.idt"))) = { {0, 0}, };