HEAD = head.o
SYSTEM = $(TOPDIR)/vmlinux

OBJECTS = $(HEAD) misc.o

CFLAGS = $(CPPFLAGS) -O2 -DSTDC_HEADERS
ZLDFLAGS = -e startup_32

ZIMAGE_OFFSET = 0x1000
BZIMAGE_OFFSET = 0x100000

ZLINKFLAGS = -Ttext $(ZIMAGE_OFFSET) $(ZLDFLAGS)
BZLINKFLAGS = -Ttext $(BZIMAGE_OFFSET) $(ZLDFLAGS)

all: vmlinux

vmlinux: piggy.o $(OBJECTS)
	$(LD) $(ZLINKFLAGS) -o vmlinux $(OBJECTS) piggy.o

bvmlinux: piggy.o $(OBJECTS)
	$(LD) $(BZLINKFLAGS) -o bvmlinux $(OBJECTS) piggy.o

piggy.o:	$(SYSTEM)
	tmppiggy=_tmp_$$$$piggy; \
	rm -f $$tmppiggy $$tmppiggy.gz $$tmppiggy.lnk; \
	$(OBJCOPY) $(SYSTEM) $$tmppiggy; \
	gzip -f -9 < $$tmppiggy > $$tmppiggy.gz; \
	echo "SECTIONS { .data : { input_len = .; LONG(input_data_end - input_data) input_data = .; *(.data) input_data_end = .; }}" > $$tmppiggy.lnk; \
	$(LD) -r -o piggy.o -b binary $$tmppiggy.gz -b elf32-i386 -T $$tmppiggy.lnk; \
	rm -f $$tmppiggy $$tmppiggy.gz $$tmppiggy.lnk

clean:
	rm -f vmlinux bvmlinux _tmp_*