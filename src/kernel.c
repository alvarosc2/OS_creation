#include "kernel.h"

static int terminal_cursor_col = 0;
static int terminal_cursor_row = 0;

uint16_t terminal_put_char(char c, char color) {
    return (uint16_t)(c | (color << 8));
}

void terminal_initialize(void) {
    uint16_t* video_memory = (uint16_t*)VGA_MEMORY;

    for (int y = 0; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            video_memory[y * VGA_WIDTH + x] = terminal_put_char(' ', 0x0F);
        }
    }

    terminal_cursor_col = 0;
    terminal_cursor_row = 0;
}

void terminal_write_char_at(char c, int col, int row, char color) {
    uint16_t* video_memory = (uint16_t*)VGA_MEMORY;

    if (col >= 0 && col < VGA_WIDTH && row >= 0 && row < VGA_HEIGHT) {
        video_memory[row * VGA_WIDTH + col] = terminal_put_char(c, color);
    }
}

void terminal_write_string_at(const char* str, int col, int row, char color) {
    int current_col = col;
    int current_row = row;

    for (int i = 0; str[i] != '\0'; ++i) {
        if (str[i] == '\n') {
            current_col = col;
            current_row++;
            continue;
        }

        terminal_write_char_at(str[i], current_col, current_row, color);
        current_col++;

        if (current_col >= VGA_WIDTH) {
            current_col = 0;
            current_row++;
        }
    }
}

void terminal_write_string(const char* str, char color) {
    terminal_write_string_at(str, 0, 0, color);
}

size_t strlen(const char* str) {
    size_t len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}

void size_t_to_string(size_t value, char* buf) {
    char temp[32];
    int i = 0;

    if (value == 0) {
        buf[0] = '0';
        buf[1] = '\0';
        return;
    }

    while (value > 0) {
        temp[i++] = (char)('0' + (value % 10));
        value /= 10;
    }

    for (int j = 0; j < i; ++j) {
        buf[j] = temp[i - 1 - j];
    }

    buf[i] = '\0';
}

static void terminal_put_char_cursor(char c, char color) {
    if (c == '\n') {
        terminal_cursor_col = 0;
        terminal_cursor_row++;
        return;
    }

    if (terminal_cursor_col >= VGA_WIDTH) {
        terminal_cursor_col = 0;
        terminal_cursor_row++;
    }

    if (terminal_cursor_row >= VGA_HEIGHT) {
        terminal_cursor_row = VGA_HEIGHT - 1;
    }

    terminal_write_char_at(c, terminal_cursor_col, terminal_cursor_row, color);
    terminal_cursor_col++;
}

static void terminal_write_string_cursor(const char* str, char color) {
    for (int i = 0; str[i] != '\0'; ++i) {
        terminal_put_char_cursor(str[i], color);
    }
}

void terminal_print(char color, const char* format, ...) {
    va_list args;
    va_start(args, format);

    for (const char* p = format; *p != '\0'; ++p) {
        if (*p != '%') {
            terminal_put_char_cursor(*p, color);
            continue;
        }

        p++;
        if (*p == '\0') {
            break;
        }

        if (*p == 's') {
            const char* s = va_arg(args, const char*);
            terminal_write_string_cursor(s, color);
        }
        else if (*p == 'u') {
            size_t value = va_arg(args, size_t);
            char buf[32];
            size_t_to_string(value, buf);
            terminal_write_string_cursor(buf, color);
        }
        else if (*p == 'z' && p[1] == 'u') {
            p++;
            size_t value = va_arg(args, size_t);
            char buf[32];
            size_t_to_string(value, buf);
            terminal_write_string_cursor(buf, color);
        }
        else if (*p == '%') {
            terminal_put_char_cursor('%', color);
        }
        else {
            terminal_put_char_cursor(*p, color);
        }
    }

    va_end(args);
}

void kernel_main() {
    terminal_initialize();

    const char mensaje[] = "Hola desde el kernel!";
    terminal_print(0x0F, "Mensaje: %s\n", mensaje);
    terminal_print(0x0A, "Longitud: %u\n", strlen(mensaje));

    // Main loop
    while (1) {
        // Kernel tasks and operations
    }
}