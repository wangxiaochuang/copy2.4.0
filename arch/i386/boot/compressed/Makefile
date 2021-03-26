HEAD = head.o
SYSTEM =

OBJECTS = $(HEAD)

CFLAGS = $(CPPFLAGS) -O2 -DSTDC_HEADERS
ZLDFLAGS = -e startup_32

ZIMAGE_OFFSET = 0x1000
BZIMAGE_OFFSET = 0x100000

ZLINKFLAGS = -Ttext $(ZIMAGE_OFFSET) $(ZLDFLAGS)
BZLINKFLAGS = -Ttext $(BZIMAGE_OFFSET) $(ZLDFLAGS)

all: vmlinux

vmlinux: $(OBJECTS)
	$(LD) $(ZLINKFLAGS) -o vmlinux $(OBJECTS)

bvmlinux: piggy.o $(OBJECTS)
	$(LD) $(BZLINKFLAGS) -o bvmlinux $(OBJECTS) piggy.o

clean:
	rm -f vmlinux bvmlinux _tmp_*