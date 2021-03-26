#ifndef _LINUX_MODULE_H
#define _LINUX_MODULE_H

#include <linux/config.h>

#include <asm/atomic.h>

struct module_symbol {
	unsigned long value;
	const char *name;
};

struct module_ref {
	struct module *dep;	/* "parent" pointer */
	struct module *ref;	/* "child" pointer */
	struct module_ref *next_ref;
};

/* TBD */
struct module_persist;

struct module
{
	unsigned long size_of_struct;	/* == sizeof(module) */
	struct module *next;
	const char *name;
	unsigned long size;

	union
	{
		atomic_t usecount;
		long pad;
	} uc;				/* Needs to keep its size - so says rth */

	unsigned long flags;		/* AUTOCLEAN et al */

	unsigned nsyms;
	unsigned ndeps;

	struct module_symbol *syms;
	struct module_ref *deps;
	struct module_ref *refs;
	int (*init)(void);
	void (*cleanup)(void);
	const struct exception_table_entry *ex_table_start;
	const struct exception_table_entry *ex_table_end;
#ifdef __alpha__
	unsigned long gp;
#endif
	/* Members past this point are extensions to the basic
	   module support and are optional.  Use mod_member_present()
	   to examine them.  */
	const struct module_persist *persist_start;
	const struct module_persist *persist_end;
	int (*can_unload)(void);
	int runsize;			/* In modutils, not currently used */
	const char *kallsyms_start;	/* All symbols for kernel debugging */
	const char *kallsyms_end;
	const char *archdata_start;	/* arch specific data for module */
	const char *archdata_end;
	const char *kernel_data;	/* Reserved for kernel internal use */
};

#endif