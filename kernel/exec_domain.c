#include <linux/mm.h>
#include <linux/smp_lock.h>
#include <linux/module.h>

static asmlinkage void no_lcall7(int segment, struct pt_regs * regs);

static unsigned long ident_map[32] = {
	0,	1,	2,	3,	4,	5,	6,	7,
	8,	9,	10,	11,	12,	13,	14,	15,
	16,	17,	18,	19,	20,	21,	22,	23,
	24,	25,	26,	27,	28,	29,	30,	31
};

struct exec_domain default_exec_domain = {
	"Linux",	/* name */
	no_lcall7,	/* lcall7 causes a seg fault. */
	0, 0xff,	/* All personalities. */
	ident_map,	/* Identity map signals. */
	ident_map,	/*  - both ways. */
	NULL,		/* No usage counter. */
	NULL		/* Nothing after this in the list. */
};

static struct exec_domain *exec_domains = &default_exec_domain;

static asmlinkage void no_lcall7(int segment, struct pt_regs * regs) {

}