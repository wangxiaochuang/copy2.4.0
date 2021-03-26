# ARCH := $(shell uname -m | sed -e s/i.86/i386/ -e s/sun4u/sparc64/ -e s/arm.*/arm/ -e s/sa110/arm/)
ARCH := i386

CONFIG_SHELL := $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
		else if [ -x /bin/bash ]; then echo /bin/bash; \
		else echo sh; fi; fi)
TOPDIR := $(shell if [ "$$PWD" != "" ]; then echo $$PWD; else pwd; fi)

HPATH		= $(TOPDIR)/include

HOSTCC  	= gcc
HOSTCFLAGS	= -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer

CROSS_COMPILE	=

AS              = $(CROSS_COMPILE)as
LD              = $(CROSS_COMPILE)ld
CC              = $(CROSS_COMPILE)gcc
CPP				= $(CC) -E
AR              = $(CROSS_COMPILE)ar
MAKEFILES       = $(TOPDIR)/.config
CFLAGS_KERNEL   =

export  VERSION PATCHLEVEL SUBLEVEL EXTRAVERSION KERNELRELEASE ARCH \
        CONFIG_SHELL TOPDIR HPATH HOSTCC HOSTCFLAGS CROSS_COMPILE AS LD CC \
        CPP AR NM STRIP OBJCOPY OBJDUMP MAKE MAKEFILES GENKSYMS MODFLAGS PERL

bochs:
	@bochs -qf debug/bochs.cnf

all:    do-it-all

ifeq (.config, $(wildcard .config))
    include .config
    ifeq (.depend, $(wildcard .depend))
        include .depend
        do-it-all:	vmlinux
    else
        CONFIGURATION = depend
        do-it-all:	depend
    endif
else
    CONFIGURATION = config
    do-it-all:	config
endif

CPPFLAGS := -D__KERNEL__ -I$(HPATH)

CFLAGS := $(CPPFLAGS) -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer -fno-strict-aliasing
AFLAGS := -D__ASSEMBLY__ $(CPPFLAGS)

export ROOT_DEV = 

SUBDIRS =

include arch/$(ARCH)/Makefile

export  CPPFLAGS CFLAGS AFLAGS

export  NETWORKS DRIVERS LIBS HEAD LDFLAGS LINKFLAGS MAKEBOOT ASFLAGS

boot: vmlinux
	@$(MAKE) CFLAGS="$(CFLAGS) $(CFLAGS_KERNEL)" -C arch/$(ARCH)/boot

vmlinux: $(CONFIGURATION) linuxsubdirs
	$(LD) $(LINKFLAGS) $(HEAD) -o vmlinux

symlinks:
	# rm -f include/asm
	# ( cd include; ln -sf asm-$(ARCH) asm )
	@if [ ! -d include/linux/modules ]; then \
		mkdir include/linux/modules; \
	fi

config: symlinks
	$(CONFIG_SHELL) scripts/Configure arch/$(ARCH)/config.in

linuxsubdirs: $(patsubst %, _dir_%, $(SUBDIRS))

$(patsubst %, _dir_%, $(SUBDIRS)) : dummy
	$(MAKE) CFLAGS="$(CFLAGS) $(CFLAGS_KERNEL)" -C $(patsubst _dir_%, %, $@)

clean:	archclean
	find . \( -name '*.[oas]' -o -name core -o -name '.*.flags' \) -type f -print \
		| grep -v lxdialog/ | xargs rm -f

ifdef CONFIGURATION
..$(CONFIGURATION):
	@echo
	@echo "You have a bad or nonexistent" .$(CONFIGURATION) ": running 'make" $(CONFIGURATION)"'"
	@echo
	$(MAKE) $(CONFIGURATION)
	@echo
	@echo "Successful. Try re-making (ignore the error that follows)"
	@echo
	exit 1
dummy:

else

dummy:

endif
