#ifndef __ARCH_I386_ATOMIC__
#define __ARCH_I386_ATOMIC__

#include <linux/config.h>

typedef struct { volatile int counter; } atomic_t;

#endif