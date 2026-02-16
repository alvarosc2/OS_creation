# === Configuración ===

CC = gcc
AS = nasm
LD = ld
OBJCOPY = objcopy

CFLAGS = -m16 -ffreestanding -c
ASFLAGS = -f elf32
LDFLAGS = -m elf_i386 -T linker.ld

BUILD = build
TARGET = $(BUILD)/boot.bin

# === Reglas principales ===
all:
	mkdir -p ./build
	nasm -f bin ./boot.asm -o ./build/boot.bin

# === Ejecutar en QEMU ===
run: $(TARGET)
	sudo qemu-system-i386 -drive format=raw,file=$(TARGET)

# === Limpieza ===
clean:
	rm -rf ./build
