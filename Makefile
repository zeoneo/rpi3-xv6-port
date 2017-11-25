###############################################################################
#	makefile
#	 by Alex Chadwick
#
#	A makefile script for generation of raspberry pi kernel images.
###############################################################################

# The toolchain to use. arm-none-eabi works, but there does exist 
# arm-bcm2708-linux-gnueabi.
ARMGNU ?= arm-none-eabi

# The intermediate directory for compiled object files.
BUILD = build/

# The directory in which source files are stored.
SOURCE = source/

# The name of the output file to generate.
TARGET = kernel.img

# The name of the assembler listing file to generate.
LIST = kernel.list

# The name of the map file to generate.
MAP = kernel.map

# The name of the linker script to use.
LINKER = source/linker.ld

# The names of libraries to use.
#LIBRARIES := csud

# The names of all object files that must be generated. Deduced from the 
# assembly code files in source.
OBJECTS := $(patsubst $(SOURCE)%.s,$(BUILD)%.o,$(wildcard $(SOURCE)*.s))

# Rule to make everything.


all: 

	arm-none-eabi-gcc -march=armv8-a+crc -mcpu=cortex-a53 -mtune=cortex-a53 -mfpu=crypto-neon-fp-armv8 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations -O2 -pipe -ffreestanding  -c source/boot.s -o build/boot.o
	arm-none-eabi-gcc -march=armv8-a+crc -mcpu=cortex-a53 -mtune=cortex-a53 -mfpu=crypto-neon-fp-armv8 -mfloat-abi=hard -ftree-vectorize -funsafe-math-optimizations -O2 -pipe -ffreestanding  -c source/kernel.c -o build/kernel.o
	arm-none-eabi-gcc -T source/linker.ld -o build/kernel.elf -ffreestanding -O2 -nostdlib build/boot.o build/kernel.o
	arm-none-eabi-objcopy build/kernel.elf -O binary build/kernel.img

# Rule to remake everything. Does not include clean.
rebuild: all

run:
	qemu-system-arm -m 256 -M raspi2 -serial stdio -kernel $(BUILD)kernel.elf

# Rule to clean files.
clean : 
	-rm -f $(BUILD)*
	-rm -f $(LIST)
	-rm -f $(MAP)
