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

SOURCES = $(wildcard $(SOURCE)*.s) $(wildcard $(SOURCE)*.c)
OBJECTS = $(filter %.o, \
	$(patsubst $(SOURCE)%.s, $(BUILD)%.o,$(SOURCES)) \
	$(patsubst $(SOURCE)%.c, $(BUILD)%.o,$(SOURCES)))

# The name of the output file to generate.
TARGET = kernel.img

.PHONY: all clean run

# Rule to make everything.
all: $(BUILD)$(TARGET)

# Rule to remake everything. Does not include clean.
rebuild: clean all 

#Rule to invoke qemu
run:
	qemu-system-arm -m 256 -M raspi2 -serial stdio -kernel $(BUILD)kernel.elf

$(BUILD)%.o : $(SOURCE)%.s
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)%.o : $(SOURCE)%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)$(TARGET): $(BUILD)kernel.elf
	arm-none-eabi-objcopy $< -O binary $@

$(BUILD)kernel.elf: $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

# Rule to clean files.
clean : 
	-rm -f $(BUILD)*
	-rm -f *.o
	-rm -f *.elf
	-rm -f *.img

