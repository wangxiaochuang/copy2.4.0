#ifndef _LINUX_KERNEL_H
#define _LINUX_KERNEL_H

#ifdef __KERNEL__

#include <stdarg.h>
#include <linux/linkage.h>
#include <linux/stddef.h>

# define NORET_TYPE    /**/
# define ATTRIB_NORET  __attribute__((noreturn))
# define NORET_AND     noreturn,

NORET_TYPE void mypanic(const char * fmt, ...)
	__attribute__ ((NORET_AND format (printf, 1, 2)));
NORET_TYPE void myprint(const char * fmt, ...)
	__attribute__ ((NORET_AND format (printf, 1, 2)));
extern unsigned long simple_strtoul(const char *,char **,unsigned int);
extern long simple_strtol(const char *,char **,unsigned int);
extern unsigned long long simple_strtoull(const char *,char **,unsigned int);
extern long long simple_strtoll(const char *,char **,unsigned int);
extern int sprintf(char * buf, const char * fmt, ...);
extern int vsprintf(char *buf, const char *, va_list);

asmlinkage int printk(const char * fmt, ...)
	__attribute__ ((format (printf, 1, 2)));

#endif

#endif