[bits 16]
global _start16

extern _start

_start16:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    call _start     ; llama a la función C

hang:
    hlt
    jmp hang

; Boot sector signature
times 510 - ($ - $$) db 0
dw 0xAA55