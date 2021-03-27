
#ifndef _PERSONALITY_H
#define _PERSONALITY_H

#include <linux/linkage.h>
#include <linux/ptrace.h>
#include <asm/current.h>

typedef void (*lcall7_func)(int, struct pt_regs *);

struct exec_domain {
	const char *name;
	lcall7_func handler;
	unsigned char pers_low, pers_high;
	unsigned long * signal_map;
	unsigned long * signal_invmap;
	struct module * module;
	struct exec_domain *next;
};

extern struct exec_domain default_exec_domain;

#endif