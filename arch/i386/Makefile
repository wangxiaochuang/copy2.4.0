LD=$(CROSS_COMPILE)ld -m elf_i386
OBJCOPY=$(CROSS_COMPILE)objcopy -O binary -R .note -R .comment -S
LDFLAGS=-e stext
LINKFLAGS =-T $(TOPDIR)/arch/i386/vmlinux.lds $(LDFLAGS)

CFLAGS += -pipe

CFLAGS += $(shell if $(CC) -mpreferred-stack-boundary=2 -S -o /dev/null -xc /dev/null >/dev/null 2>&1; then echo "-mpreferred-stack-boundary=2"; fi)

HEAD := arch/i386/kernel/head.o arch/i386/kernel/init_task.o

SUBDIRS += arch/i386/kernel

CORE_FILES := arch/i386/kernel/kernel.o $(CORE_FILES)

arch/i386/kernel: dummy
	$(MAKE) linuxsubdirs SUBDIRS=arch/i386/kernel

MAKEBOOT = $(MAKE) -C arch/$(ARCH)/boot

vmlinux: arch/i386/vmlinux.lds

FORCE: ;

.PHONY: zImage

zImage: vmlinux
	@$(MAKEBOOT) zImage

zdisk: vmlinux
	@$(MAKEBOOT) BOOTIMAGE=zImage zdisk

archclean:
	@$(MAKEBOOT) clean