#include <linux/config.h>
#include <linux/sched.h>

static void raw_print(const char * b) {
    unsigned char c;
    unsigned char *video = (unsigned char *) 0xb8000 + 24*160;
    while ((c = *(b++)) != 0) {
        video[0] = c;
        video[1] = 0x07;
        video += 2;
    }
}

NORET_TYPE void myprint(const char * fmt, ...) {
    static char mymybuf[32] = {'[', '['};
    va_list args;
    int len = 0;

    va_start(args, fmt);
    len = vsprintf(mymybuf+2, fmt, args);
    va_end(args);
    mymybuf[len + 2] = ']';
    mymybuf[len + 3] = ']';
    mymybuf[len + 4] = '\0';
    raw_print(mymybuf);
}
NORET_TYPE void mypanic(const char * fmt, ...) {
    static char mybuf[128] = {'[', '['};
    va_list args;
    int len = 0;

    va_start(args, fmt);
    len = vsprintf(mybuf+2, fmt, args);
    va_end(args);
    mybuf[len + 2] = ']';
    mybuf[len + 3] = ']';
    mybuf[len + 4] = '\0';
    raw_print(mybuf);
    for(;;) {
        __asm__("hlt");
    };
}