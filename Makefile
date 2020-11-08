CONFIG_DIR=./config
ISO_DIR=./iso

# Docker
DOCKER_IMAGE=kevincharm/x86_64-elf-gcc-toolchain:latest
DOCKER_SH=docker run -it --rm \
	-v `pwd`:/work \
	-w /work \
	--security-opt seccomp=unconfined \
	$(DOCKER_IMAGE) /bin/bash -c

# Compilers
AS=x86_64-elf-as
CC=x86_64-elf-gcc
LD=x86_64-elf-ld
CFLAGS=-Wall -fPIC -ffreestanding -fno-stack-protector -fno-stack-check -mno-red-zone

# Build info
GIT_COMMIT=$(shell git log -1 --pretty=format:"%H")
KERNEL_DEFINES=__ARGIR_BUILD_COMMIT__=\"$(GIT_COMMIT)\"

# Sources
SRC_DIR=./src
KERNEL_INCLUDE=$(SRC_DIR)/include
KERNEL_OBJS=\
	$(SRC_DIR)/kernel.o \
	$(SRC_DIR)/kernel/gdt.o \
	$(SRC_DIR)/kernel/pic.o \
	$(SRC_DIR)/kernel/idt.o \
	$(SRC_DIR)/kernel/interrupts.o \
	$(SRC_DIR)/kernel/isr.o \
	$(SRC_DIR)/kernel/keyboard.o \
	$(SRC_DIR)/kernel/terminal.o \
	$(SRC_DIR)/kernel/pci.o \
	$(SRC_DIR)/kernel/font_vga.o

KLIB_DIR=$(SRC_DIR)/klib
KLIB_INCLUDE=$(KLIB_DIR)/include
KLIB_OBJS=\
	$(KLIB_DIR)/ringbuf/ringbuf.o \
	$(KLIB_DIR)/memory/memset.o \
	$(KLIB_DIR)/stdio/putchar.o \
	$(KLIB_DIR)/stdio/printf.o \
	$(KLIB_DIR)/string/strlen.o

default: clean all

.PHONY: clean

all:
	$(DOCKER_SH) "make _all"

_all: argir.img

$(ISO_DIR)/sys/core: $(KERNEL_OBJS) $(KLIB_OBJS)
	rm -rf $(ISO_DIR)
	mkdir -p $(ISO_DIR)/sys
	$(LD) -nostdlib -nostartfiles -Tkernel.ld -I$(KLIB_INCLUDE) -I$(KERNEL_INCLUDE) -o $@ $(KERNEL_OBJS) $(KLIB_OBJS)

%.o: %.s
	$(AS) $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@ \
	-I$(KLIB_INCLUDE) -I$(KERNEL_INCLUDE) -D$(KERNEL_DEFINES)

# Disk image & Qemu
argir.img: $(ISO_DIR)/sys/core
	mkdir -p $(ISO_DIR)/EFI/BOOT
	# --- TEST ---
	# cp testkern.elf $(ISO_DIR)/sys/core
	cp $(SRC_DIR)/bootboot.efi $(ISO_DIR)/EFI/BOOT/BOOTX64.EFI
	mkbootimg mkbootimg.json $@

QEMU=qemu-system-x86_64 -cpu qemu64 -bios OVMF.fd -drive file=argir.img,format=raw \
	-netdev user,id=eth0 -device ne2k_pci,netdev=eth0 -serial stdio -d int,cpu_reset -D ./tmp/qemu.log

run: all
	$(QEMU)

debug: all
	$(QEMU) -d int,cpu_reset

clean:
	rm -f *.efi *.so *.cdr
	rm -rf $(ISO_DIR)
	find $(SRC_DIR) -type f -name '*.o' -delete

print_toolchain:
	$(DOCKER_SH) "make _print_toolchain"
_print_toolchain:
	$(CC) --version

sections:
	greadelf -hls $(ISO_DIR)/sys/core

objdump:
	objdump -d $(SRC_DIR)/kernel.o
	# objdump -d $(ISO_DIR)/sys/core
