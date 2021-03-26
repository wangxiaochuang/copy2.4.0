BOOT_INCL =	$(TOPDIR)/include/linux/config.h \
		$(TOPDIR)/include/linux/autoconf.h \
		$(TOPDIR)/include/asm/boot.h

zImage: $(CONFIGURE) bootsect setup compressed/vmlinux tools/build
	$(OBJCOPY) compressed/vmlinux compressed/vmlinux.out
	tools/build bootsect setup compressed/vmlinux.out $(ROOT_DEV) > zImage

compressed/vmlinux: $(TOPDIR)/vmlinux
	@$(MAKE) -C compressed vmlinux


zdisk: $(BOOTIMAGE)
	dd conv=notrunc bs=8192 if=$(BOOTIMAGE) of=$(TOPDIR)/../myfd.img

tools/build: tools/build.c
	$(HOSTCC) $(HOSTCFLAGS) -o $@ $< -I$(TOPDIR)/include

bootsect: bootsect.o
	$(LD) -Ttext 0x0 -s --oformat binary $< -o $@

setup: setup.o video.S Makefile $(BOOT_INCL) $(TOPDIR)/include/linux/version.h
	$(LD) -Ttext 0x0 -s --oformat binary -e begtext -o $@ $<

dep:

clean:
	rm -f tools/build
	rm -f setup bootsect zImage compressed/vmlinux.out
	rm -f bsetup bbootsect bzImage compressed/bvmlinux.out
	@$(MAKE) -C compressed clean