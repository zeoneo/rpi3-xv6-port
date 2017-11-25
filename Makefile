###############################################################################
#
#	A makefile script for generation of raspberry pi kernel images.
#
###############################################################################

# The toolchain to use. arm-none-eabi works, but there does exist 
CC = arm-none-eabi-gcc
LD = arm-none-eabi-gcc

# The intermediate directory for compiled object files.
BUILD = build/

# The directory in which source files are stored.
SOURCE = source/

CFLAGS =	-march=armv8-a+crc \
			-mcpu=cortex-a53 \
			-mtune=cortex-a53 \
			-mfpu=crypto-neon-fp-armv8 \
			-mfloat-abi=hard \
			-ftree-vectorize \
			-funsafe-math-optimizations \
			-O2 -pipe -ffreestanding
			
LDFLAGS = -T $(SOURCE)linker.ld -ffreestanding -O2 -nostdlib


# The name of the output file to generate.
TARGET = kernel.img

.PHONY: all clean run

# Rule to make everything.
all: $(TARGET)

# Rule to remake everything. Does not include clean.
rebuild: clean all 

#Rule to invoke qemu
run:
	qemu-system-arm -m 256 -M raspi2 -serial stdio -kernel $(BUILD)kernel.elf

$(TARGET): kernel.elf
	arm-none-eabi-objcopy $(BUILD)kernel.elf -O binary $(BUILD)kernel.img

kernel.elf: boot.o kernel.o
	$(LD)   $(LDFLAGS) -o $(BUILD)kernel.elf $(BUILD)boot.o $(BUILD)kernel.o

boot.o: $(SOURCE)boot.s
	$(CC) $(CFLAGS) -c $(SOURCE)boot.s -o $(BUILD)boot.o

kernel.o: $(SOURCE)boot.s
	$(CC) $(CFLAGS) -c $(SOURCE)kernel.c -o $(BUILD)kernel.o

# Rule to clean files.
clean : 
	-rm -f $(BUILD)*
	-rm -f *.o
	-rm -f *.elf
	-rm -f *.img

