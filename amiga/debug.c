/*
 * debug.c -- KPrintF for the elf-toolchain
 *
 * Bebbo's amiga-gcc ships clib/debug_protos.h + libdebug.a, which provide
 * KPrintF directly via -ldebug -mcrt=clib2. The Makefile takes that path
 * when TARGET=hunk-toolchain.
 *
 * Bartman's m68k-amiga-elf toolchain ships neither. We synthesize KPrintF
 * here using exec.library's RawDoFmt (printf-style formatting) plus
 * RawPutChar (single-byte serial debug output, LVO -516).
 *
 * Only compiled into DEBUG builds (see Makefile).
 */

#if DEBUG

#include <proto/exec.h>
#include <stdarg.h>

extern struct ExecBase *SysBase;

/*
 * Inline stub for RawPutChar (exec.library LVO -516). Not declared in
 * NDK 3.2 headers (private debug entry point), so we emit the JSR
 * ourselves.
 *
 * Note on percent-escaping: this is gcc extended asm (with operand list),
 * so literal % in instructions must be doubled (%%a6). GNU as for m68k
 * requires the % prefix on register names.
 */
static inline void raw_put_char(UBYTE c)
{
    register UBYTE c_in asm("d0") = c;
    register struct ExecBase *sysbase_in asm("a6") = SysBase;
    asm volatile (
        "jsr %%a6@(-516)"
        :
        : "d" (c_in), "a" (sysbase_in)
        : "d1", "cc", "memory"
    );
}

/*
 * RawDoFmt's per-character callback. Exec calls this with the byte in d0
 * and the user-data pointer in a3.
 */
static void putch(UBYTE c    asm("d0"),
                  APTR  data asm("a3"))
{
    (void)data;
    raw_put_char(c);
}

/*
 * KPrintF -- format via exec RawDoFmt, output via RawPutChar.
 *
 * IMPORTANT m68k gotcha: RawDoFmt's third-from-left arg is a DataStream --
 * a pointer to the format arguments laid out as CONTIGUOUS values in memory,
 * which it walks by advancing that pointer per format specifier. It is NOT a
 * va_list. Passing a gcc va_list directly happens to work for a single
 * argument on this toolchain but derails with multiple arguments (the second
 * and later reads walk off into wrong memory, hanging or faulting inside
 * RawDoFmt). So we marshal the varargs into a local contiguous ULONG array
 * with portable va_arg and hand RawDoFmt a pointer to that.
 *
 * Contract: every % specifier in a format string must consume one ULONG
 * (use %ld / %lx / %lu and cast each argument to ULONG at the call site,
 * which this codebase already does). MAX_ARGS caps the count per call.
 */
#define KPRINTF_MAX_ARGS 12

void KPrintF(CONST_STRPTR fmt, ...)
{
    ULONG args[KPRINTF_MAX_ARGS];
    int n = 0;
    const char *p = (const char *)fmt;
    va_list ap;

    /* Count % specifiers (excluding %% ) to know how many longs to pull. */
    while (*p && n < KPRINTF_MAX_ARGS) {
        if (*p++ == '%') {
            if (*p == '%') { p++; continue; }  /* literal %% */
            n++;
            /* skip the rest of this specifier's chars up to the conversion */
            while (*p && !((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z')))
                p++;
            if (*p) p++;                       /* the conversion letter */
        }
    }

    va_start(ap, fmt);
    for (int i = 0; i < n; i++)
        args[i] = va_arg(ap, ULONG);
    va_end(ap);

    RawDoFmt((STRPTR)fmt, (APTR)args, (void (*)())putch, NULL);
}

#endif /* DEBUG */
