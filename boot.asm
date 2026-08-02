ORG 0x7C00
BITS 16

start:
    ; Clear interrupts and set up segments
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; Stack grows downward from bootloader
    
    ; Display boot message
    mov si, boot_msg
    call print_string
    
    ; Enable A20 line (method via keyboard controller)
    call enable_a20
    
    ; Load GDT
    lgdt [gdt_descriptor]
    
    ; Switch to protected mode
    mov eax, cr0
    or eax, 1               ; Set PE (Protection Enable) bit
    mov cr0, eax
    
    ; Far jump to clear pipeline and switch to 32-bit code segment
    jmp CODE_SEG:protected_mode_entry

; Print string function (16-bit real mode)
print_string:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp .loop
.done:
    popa
    ret

; Enable A20 line via keyboard controller
enable_a20:
    call .wait_input
    mov al, 0xAD            ; Disable keyboard
    out 0x64, al
    
    call .wait_input
    mov al, 0xD0            ; Read from input
    out 0x64, al
    
    call .wait_output
    in al, 0x60
    push ax
    
    call .wait_input
    mov al, 0xD1            ; Write to output
    out 0x64, al
    
    call .wait_input
    pop ax
    or al, 2                ; Enable A20 bit
    out 0x60, al
    
    call .wait_input
    mov al, 0xAE            ; Enable keyboard
    out 0x64, al
    
    call .wait_input
    ret

.wait_input:
    in al, 0x64
    test al, 2
    jnz .wait_input
    ret

.wait_output:
    in al, 0x64
    test al, 1
    jz .wait_output
    ret

; GDT - Global Descriptor Table
gdt_start:
    ; Null descriptor (required)
    dq 0x0

gdt_code:
    ; Code segment descriptor
    dw 0xFFFF               ; Limit (bits 0-15)
    dw 0x0                  ; Base (bits 0-15)
    db 0x0                  ; Base (bits 16-23)
    db 10011010b            ; Access byte: present, ring 0, code, executable, readable
    db 11001111b            ; Flags (4 bits) + Limit (bits 16-19): 4KB granularity, 32-bit
    db 0x0                  ; Base (bits 24-31)

gdt_data:
    ; Data segment descriptor
    dw 0xFFFF               ; Limit (bits 0-15)
    dw 0x0                  ; Base (bits 0-15)
    db 0x0                  ; Base (bits 16-23)
    db 10010010b            ; Access byte: present, ring 0, data, writable
    db 11001111b            ; Flags + Limit: 4KB granularity, 32-bit
    db 0x0                  ; Base (bits 24-31)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1    ; Size of GDT
    dd gdt_start                   ; Address of GDT

; Constants for segment selectors
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

boot_msg db 'Booting in 16-bit real mode...', 13, 10, 0

; 32-bit Protected Mode Code
BITS 32
protected_mode_entry:
    ; Set up segment registers for protected mode
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000        ; Set up stack in protected mode
    
    ; Print success message to video memory
    mov esi, protected_msg
    mov edi, 0xB8000        ; VGA text mode buffer
    mov ah, 0x0F            ; White on black
.print_loop:
    lodsb
    test al, al
    jz .done
    mov [edi], ax
    add edi, 2
    jmp .print_loop
.done:
    ; Halt the system
    hlt
    jmp $

protected_msg db 'Protected mode activated!', 0

; Boot sector signature
times 510 - ($ - $$) db 0
dw 0xAA55