#include <linux/config.h>

#define PARAM_CURSOR_POS	0x00
#define PARAM_VIDEO_PAGE	0x04
#define PARAM_VIDEO_MODE	0x06
#define PARAM_VIDEO_COLS	0x07
#define PARAM_VIDEO_EGA_BX	0x0a
#define PARAM_VIDEO_LINES	0x0e
#define PARAM_HAVE_VGA		0x0f
#define PARAM_FONT_POINTS	0x10

video:
    pushw   %ds
    pushw	%ds		# FS contains original DS
	popw	%fs
	pushw	%cs		# DS is equal to CS
	popw	%ds
	pushw	%cs		# ES is equal to CS
	popw	%es
	xorw	%ax, %ax
	movw	%ax, %gs	# GS is zero
	cld
	call	basic_detect
#ifdef CONFIG_VIDEO_SELECT
    hlt
#endif /* CONFIG_VIDEO_SELECT */
    call    mode_params
    popw    %ds
    ret

basic_detect:
    movb	$0, %fs:(PARAM_HAVE_VGA)
	movb	$0x12, %ah	# Check EGA/VGA
	movb	$0x10, %bl
	int	$0x10
    movw	%bx, %fs:(PARAM_VIDEO_EGA_BX)	# Identifies EGA to the kernel
	cmpb	$0x10, %bl			# No, it's a CGA/MDA/HGA card.
	je	basret

    incb    adapter
    movw    $0x1a00, %ax
    int $0x10
    cmpb    $0x1a, %al          # 1a means VGA
    jne basret

    incb    %fs:(PARAM_HAVE_VGA)
    incb    adapter
basret:
    ret

mode_params:
#ifdef CONFIG_VIDEO_SELECT
    hlt
#endif
    movb	$0x03, %ah			# Read cursor position
	xorb	%bh, %bh
	int	$0x10
	movw	%dx, %fs:(PARAM_CURSOR_POS)
	movb	$0x0f, %ah			# Read page/mode/width
	int	$0x10
	movw	%bx, %fs:(PARAM_VIDEO_PAGE)
	movw	%ax, %fs:(PARAM_VIDEO_MODE)	# Video mode and screen width
	cmpb	$0x7, %al			# MDA/HGA => segment differs
    jnz mopar0
    hlt
mopar0:
    movw	%gs:(0x485), %ax		# Font size
	movw	%ax, %fs:(PARAM_FONT_POINTS)	# (valid only on EGA/VGA)
	movw	force_size, %ax			# Forced size?
	orw     %ax, %ax
    jz mopar1
    hlt

mopar1:
    movb	$25, %al
	cmpb	$0, adapter			# If we are on CGA/MDA/HGA, the
	jz      mopar2				# screen must have 25 lines.

	movb	%gs:(0x484), %al		# On EGA/VGA, use the EGA+ BIOS
	incb	%al				# location of max lines.
mopar2:
    movb	%al, %fs:(PARAM_VIDEO_LINES)
	ret

# Other variables:
adapter:	.byte	0	# Video adapter: 0=CGA/MDA/HGA,1=EGA,2=VGA
video_segment:	.word	0xb800	# Video memory segment
force_size:	.word	0	# Use this size instead of the one in BIOS vars