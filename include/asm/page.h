#ifndef _I386_PAGE_H
#define _I386_PAGE_H

#define __PAGE_OFFSET		(0xC0000000)

#define PAGE_OFFSET		((unsigned long)__PAGE_OFFSET)

#define __pa(x)			((unsigned long)(x)-PAGE_OFFSET)
#define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))

#endif