all:
	nasm -f bin ./boot/boot.asm -o ./bin/boot.bin

clean:
	rm -rf ./bin/boot.bin