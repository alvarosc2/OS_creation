# README

booting and switching to protected mode

- Setting up the stack and segments
- Enabling the A20 line (required for accessing memory above 1MB)
- Creating a Global Descriptor Table (GDT)
- Switching to 32-bit protected mode

## 16-bit Real Mode Section

- Sets up segments and stack
- Displays a boot message using BIOS interrupts
- Enables the A20 line (required for accessing memory above 1MB)
- Loads the Global Descriptor Table (GDT)
- Switches to protected mode by setting the PE bit in CR0
- Performs a far jump to flush the pipeline

## 32-bit Protected Mode Section

Sets up all segment registers with the data segment selector
Establishes a new stack at 0x90000
Writes directly to VGA text buffer (0xB8000) since BIOS interrupts are unavailable
Displays "Protected mode activated!" and halts
