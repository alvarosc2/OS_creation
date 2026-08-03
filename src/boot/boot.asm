ORG 0x7C00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop

    times 33 db 0

start:
    jmp 0:step2

step2:
    cli ;clear interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti ;enable interrupts

.load_protected:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:load32

; GDT
gdt_start:
gdt_null:
    dq 0x0000000000000000      ; null descriptor

; OFFSET 0X08
gdt_code:         ; CS SHOULD POINT TO THIS
    dw 0xffff     ;segment limits
    dw 0x0000     ;segment base
    db 0x00       ;segment base
    db 0x9A       ;access byte
    db 11001111b  ;flags and limit
    db 0x00       ;segment base

; offset 0x10
gdt_data:         ; DS, SS, ES, FS, GS
    dw 0xffff     ;segment limits
    dw 0x0000     ;segment base
    db 0x00       ;segment base
    db 0x92       ;access byte
    db 11001111b  ;flags and limit
    db 0x00       ;segment base

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; size of GDT
    dd gdt_start                ; address of GDT

BITS 32
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax    ; back up the LBA
    shr eax, 24     ; Send the highes 8 bits of the LBA to the hard disk contoller
    OR EAX, 0xE0    ; Select the master drive
    mov dx, 0x1F6
    out dx, al

    mov eax, ecx    ; Send the number of sectors to read to the hard disk controller
    mov dx, 0x1F2
    out dx, al

    mov eax, ebx    ; Restore the bakup of the LBA and send more bits to the LBA
    mov dx, 0x1F3
    out dx, al

    mov dx, 0x1F4   ; Send more bits of the LBA
    mov eax, ebx    ; Restore the backup of the LBA
    shr eax, 8
    out dx, al

    mov dx, 0x1F5   ; Send the upper 16 bits of the LBA
    mov eax, ebx    ; Restore the backup of the LBA
    shr eax, 16
    out dx, al

    mov dx, 0x1F7   ; Send the command to read sectors
    mov al, 0x20    ; Read sectors command
    out dx, al

.next_sector:
    push ecx

.try_again:
    mov dx, 0x1F7
    in al, dx
    test al, 8
    jz .try_again

    ; We need to read 256 words (512 bytes) at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ret

times 510 - ($ - $$) db 0
dw 0xAA55