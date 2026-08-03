#ifndef KERNEL_H
#define KERNEL_H

#include <stdint.h>
#include <stddef.h>
#include <stdarg.h>

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_MEMORY 0xB8000

uint16_t terminal_put_char(char c, char color);
void terminal_initialize(void);
void terminal_write_char_at(char c, int col, int row, char color);
void terminal_write_string_at(const char* str, int col, int row, char color);
void terminal_write_string(const char* str, char color);
size_t strlen(const char* str);
void size_t_to_string(size_t value, char* buf);
void terminal_print(char color, const char* format, ...);
void kernel_main(void);

#endif // KERNEL_H