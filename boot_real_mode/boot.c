// boot.c — código C compilado con - m16

void putc(char c)
{
    volatile char *vid = (volatile char *)0xB8000;
    vid[0] = c;
    vid[1] = 0x07; // gris claro sobre negro
}

void _start(void)
{
    putc('A');

    for (;;)
        ; // cuelga la CPU
}
