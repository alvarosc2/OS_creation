FILES = ./build/kernel.asm.o ./build/kernel.o
INCLUDES = -I./src
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0

all: ./bin/boot.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

# 1. Generar ELF con símbolos
./build/kernel.elf: $(FILES)
	i686-elf-ld -m elf_i386 -g -T ./src/linker.ld -o ./build/kernel.elf $(FILES)

# 2. Convertir ELF → BIN
./bin/kernel.bin: ./build/kernel.elf
	i686-elf-objcopy -O binary ./build/kernel.elf ./bin/kernel.bin

./bin/boot.bin: ./src/boot/boot.asm
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

./build/kernel.asm.o: ./src/kernel.asm
	nasm -f elf32 -g ./src/kernel.asm -o ./build/kernel.asm.o

./build/kernel.o: ./src/kernel.c ./src/kernel.h
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/kernel.c -o ./build/kernel.o  

clean:
	rm -rf ./bin/boot.bin
	rm -rf ./bin/kernel.bin
	rm -rf ./bin/os.bin
	rm -rf ./build/kernel.asm.o
	rm -rf ${FILES}
	rm -rf ./build/kernel.elf

# ---------------------------
# Ejecutar QEMU en modo debug
# ---------------------------
debug: all
	qemu-system-i386 -S -gdb tcp::1234 -hda ./bin/os.bin

# ---------------------------
# Conectar GDB al kernel ELF
# ---------------------------
gdb:
	gdb ./build/kernel.elf -ex "target remote localhost:1234"
