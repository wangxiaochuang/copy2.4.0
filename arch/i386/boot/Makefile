zImage: $(CONFIGURE) bootsect
	@echo "build bootsect"

#bootsect: bootsect.S
#	$(CC) -I$(HPATH) -c -o $@.o $<
#	$(LD) -Ttext 0x0 -s --oformat binary $@.o -o $@
	
bootsect: bootsect.o
	$(LD) -Ttext 0x0 -s --oformat binary $< -o $@
