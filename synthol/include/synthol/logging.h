#ifndef _SYNTHOL_LOGGING_H
#define _SYNTHOL_LOGGING_H

#include <features.h>

#define __NEED___isoc_va_list
#define __NEED_size_t

#if defined(_POSIX_SOURCE) || defined(_POSIX_C_SOURCE) \
 || defined(_XOPEN_SOURCE) || defined(_GNU_SOURCE) \
 || defined(_BSD_SOURCE)
#define __NEED_ssize_t
#define __NEED_off_t
#define __NEED_va_list
#endif

#include <bits/alltypes.h>

#define SYNTHOL_LOGF_DEFAULT_BUFFER_SIZE 1024

// atomic (one hypercall)
int synthol_nlogf(size_t n, const char *__restrict fmt, ...);
int synthol_vnlogf(size_t n, const char *__restrict fmt, __isoc_va_list);

// not atomic (any number of hypercalls)
int synthol_logf(const char *__restrict fmt, ...);
int synthol_vlogf(const char *__restrict fmt, __isoc_va_list);

#endif
