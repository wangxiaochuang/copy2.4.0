#include <linux/config.h>
#include <asm/boot.h>

SETUPSECS	= 4			/* default nr of setup-sectors */
BOOTSEG		= 0x07C0		/* original address of boot-sector */
INITSEG		= DEF_INITSEG		/* we move boot here - out of the way */
SETUPSEG	= DEF_SETUPSEG		/* setup starts here */
SYSSEG		= DEF_SYSSEG		/* system loaded at 0x10000 (65536) */
SYSSIZE		= DEF_SYSSIZE		/* system size: # of 16-byte clicks */

ROOT_DEV	= 0 			/* ROOT_DEV is now written by "build" */
SWAP_DEV	= 0			/* SWAP_DEV is now written by "build" */

#ifndef SVGA_MODE
#define SVGA_MODE ASK_VGA
#endif

#ifndef RAMDISK
#define RAMDISK 0
#endif 

#ifndef CONFIG_ROOT_RDONLY
#define CONFIG_ROOT_RDONLY 1
#endif

.code16
.text

.global _start
_start:
	movw $BOOTSEG, %ax
	movw %ax, %ds
	movw $INITSEG, %ax
	movw %ax, %es			// es=0x9000
	movw $256, %cx
	xorw %si, %si
	xorw %di, %di
	cld
	rep movsw
	ljmp $INITSEG, $go

go:
	movw	$0x4000-12, %di
	movw	%ax, %ds		// ds=0x9000
	movw	%ax, %ss
	movw	%di, %sp

	movw	%cx, %fs		// set fs to 0
	movw	$0x78, %bx
	pushw	%ds
	ldsw	%fs:(%bx), %si	// 修改 ds和si的值
	movb	$6, %cl
	pushw	%di
	rep movsw				// ds:si => es:di  0x9000:0x4000-12
	popw	%di
	popw	%ds
	movb	$36, 0x4(%di)
	movw	%di, %fs:(%bx)
	movw	%es, %fs:2(%bx)	// 修改硬盘参数

load_setup:
	xorb	%ah, %ah		// reset FDC
	xorb	%dl, %dl
	int	$0x13
	xorw	%dx, %dx		// drive 0, head 0
	movb	$0x02, %cl		// sector 2, track 0
	movw	$0x0200, %bx	// read to 0x90200
	movb	$0x02, %ah		// service 2, read sector
	movb	setup_sects, %al	// assume all on head 0, track 0, 4 sectors
	int $0x13
	jnc ok_load_setup
	hlt
ok_load_setup:
	movw	$disksizes, %si
probe_loop:
	lodsb					// ds:si => al
	cbtw					// extend byte to word
	movw	%ax, sectors
	cmpw	$disksizes+4, %si
	jae got_sectors

	xchgw	%cx, %ax		// cx = track and sector
	xorw	%dx, %dx		// drive 0, head 0
	xorb	%bl, %bl
	movb	setup_sects, %bh
	incb	%bh
	shlb	%bh
	movw	$0x0201, %ax	// service 2, read 1 sector
	int $0x13
	jc probe_loop

got_sectors:
	movw	$INITSEG, %ax
	movw	%ax, %es
	movb	$0x03, %ah		// read cursor pos
	xorb	%bh, %bh
	int $0x10
	movw	$9, %cx
	movw	$0x0007, %bx	// page 0, attribute 7 (normal)
	movw	$msg1, %bp
	movw	$0x1301, %ax	// write string, move cursor
	int $0x10
	movw	$SYSSEG, %ax
	movw	%ax, %es		// load system at 0x1000:0
	jmp .
	movw sectors, %ax

sectors:	.word 0
disksizes:	.byte 36, 18, 15, 9
msg1:		.byte 13, 10
		.ascii "Loading"

.org 497
setup_sects:	.byte SETUPSECS
root_flags:	.word CONFIG_ROOT_RDONLY
syssize:	.word SYSSIZE
swap_dev:	.word SWAP_DEV
ram_size:	.word RAMDISK
vid_mode:	.word SVGA_MODE
root_dev:	.word ROOT_DEV
boot_flag:	.word 0xAA55