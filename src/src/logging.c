#include "stdio_impl.h"
#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <synthol/hypercalls.h>
#include <synthol/logging.h>

int synthol_nlogf(size_t n, const char *__restrict fmt, ...)
{
    char s[n];
    int ret;
    va_list ap;
    va_start(ap, fmt);
    ret = synthol_vnlogf(n, fmt, ap);
    va_end(ap);
    return ret;
}

int synthol_vnlogf(size_t n, const char *__restrict fmt, __isoc_va_list ap)
{
    char buf[n];
    int m, err;
    m = vsnprintf(buf, n, fmt, ap);
    err = HYPERCALL_console_io(CONSOLEIO_write, m, buf);
    return err;
}

int synthol_logf(const char *__restrict fmt, ...)
{
    int ret;
    va_list ap;
    va_start(ap, fmt);
    ret = synthol_vlogf(fmt, ap);
    va_end(ap);
    return ret;
}

#define MIN(a, b) ((a) < (b) ? (a) : (b))

static size_t vlogf_write(FILE *f, const unsigned char *s, size_t l)
{
    int err;
    err = HYPERCALL_console_io(CONSOLEIO_write, l, s);
    assert(!err);
    return l;
}

int synthol_vlogf(const char *__restrict fmt, __isoc_va_list ap)
{
    unsigned char buf[1];
    FILE f = {
        .lbf = '\n',
        .write = vlogf_write,
        .lock = -1,
        .buf = buf,
        .buf_size = 1,
    };
    return vfprintf(&f, fmt, ap);
}
