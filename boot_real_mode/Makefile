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

# === Archivos fuente ===

C_SRC = boot.c
ASM_SRC = boot.asm

C_OBJ = $(BUILD)/boot.o
ASM_OBJ = $(BUILD)/boot_asm.o
ELF = $(BUILD)/boot.elf

# === Reglas principales ===

all: $(TARGET)

$(BUILD):
	mkdir -p $(BUILD)

$(C_OBJ): $(C_SRC) | $(BUILD)
	$(CC) $(CFLAGS) $(C_SRC) -o $(C_OBJ)

$(ASM_OBJ): $(ASM_SRC) | $(BUILD)
	$(AS) $(ASFLAGS) $(ASM_SRC) -o $(ASM_OBJ)

$(ELF): $(C_OBJ) $(ASM_OBJ) linker.ld
	$(LD) $(LDFLAGS) -o $(ELF) $(C_OBJ) $(ASM_OBJ)

$(TARGET): $(ELF)
	$(OBJCOPY) -O binary $(ELF) $(TARGET)

# === Ejecutar en QEMU ===

run: $(TARGET)
	sudo qemu-system-i386 -drive format=raw,file=$(TARGET)

debug: $(TARGET)
	sudo qemu-system-i386 -drive format=raw,file=$(TARGET) -s -S &
	gdb -ex "target remote localhost:1234" \
		-ex "set architecture i8086" \
		-ex "break *0x7c00" \
		-ex "continue"

# === Limpieza ===

clean:
	rm -rf $(BUILD)

.PHONY: all clean run