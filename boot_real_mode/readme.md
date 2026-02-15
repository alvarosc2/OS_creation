# Como compilar codigo de 16 bits en gcc

## Compilar C a 16 bits

gcc -m16 -ffreestanding -c boot.c -o boot.o

## Compilar NASM

nasm -f elf32 boot.asm -o boot_asm.o

## Enlazar

ld -m elf_i386 -T linker.ld -o boot.elf boot.o boot_asm.o

## Convertir a binario plano

objcopy -O binary boot.elf boot.bin
