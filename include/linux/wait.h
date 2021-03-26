#ifndef _LINUX_WAIT_H
#define _LINUX_WAIT_H

#define WNOHANG		0x00000001
#define WUNTRACED	0x00000002

#define __WNOTHREAD	0x20000000	/* Don't wait on children of other threads in this group */
#define __WALL		0x40000000	/* Wait on all children, regardless of type */
#define __WCLONE	0x80000000	/* Wait only on non-SIGCHLD children */

#ifdef __KERNEL__

#include <linux/kernel.h>
#include <linux/list.h>
#include <linux/stddef.h>
#include <linux/spinlock.h>

#include <asm/page.h>
#include <asm/processor.h>

#endif /* __KERNEL__ */

#endif