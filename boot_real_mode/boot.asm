[bits 16]
global _start16

_start16:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Load sector 2+ from disk to 0x7E00
    mov ah, 0x02    ; read sectors
    mov al, 1       ; number of sectors
    mov ch, 0       ; cylinder
    mov cl, 2       ; sector (starts at 1, so 2 is second sector)
    mov dh, 0       ; head
    mov bx, 0x7E00  ; destination
    int 0x13
    
    jmp 0x0000:0x7E00  ; jump to loaded code

times 510 - ($ - $$) db 0
dw 0xAA55