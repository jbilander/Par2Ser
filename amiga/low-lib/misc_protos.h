/*
 * misc_protos.h -- AllocMiscResource / FreeMiscResource for the elf toolchain.
 *
 * Prefer the NDK's own <proto/misc.h> when present (it provides these the
 * gcc way). Fall back to hand-rolled gcc-syntax inline stubs otherwise.
 *
 * Original VBCC stubs were by Niklas Ekström; rewritten here in
 * m68k-amiga-elf-gcc register-parameter syntax (`type name asm("aN")`),
 * matching the house style in par2ser.c, because the VBCC `__reg(...)` +
 * `="\tjsr\t-N(a6)"` form does not compile under gcc.
 */
#ifndef MISC_PROTOS_H
#define MISC_PROTOS_H

#include <exec/types.h>
#include <exec/libraries.h>

#if defined(__has_include)
#  if __has_include(<proto/misc.h>)
#    include <proto/misc.h>
#    define ADAPTER_HAVE_PROTO_MISC 1
#  endif
#endif

#ifndef ADAPTER_HAVE_PROTO_MISC
/* Hand-rolled fallback. MiscBase is passed explicitly in a6. LVOs:
 *   AllocMiscResource = -6, FreeMiscResource = -12. */
static inline UBYTE *AllocMiscResource(struct Library *resource asm("a6"),
                                       ULONG unitNum            asm("d0"),
                                       const char *name         asm("a1"))
{
    register UBYTE *ret     asm("d0");
    register struct Library *r asm("a6") = resource;
    register ULONG u        asm("d0")    = unitNum;
    register const char *n  asm("a1")    = name;
    asm volatile ("jsr %%a6@(-6)"
                  : "=r" (ret)
                  : "r" (r), "r" (u), "r" (n)
                  : "d1", "a0", "cc", "memory");
    return ret;
}

static inline void FreeMiscResource(struct Library *resource asm("a6"),
                                    ULONG unitNum            asm("d0"))
{
    register struct Library *r asm("a6") = resource;
    register ULONG u        asm("d0")    = unitNum;
    asm volatile ("jsr %%a6@(-12)"
                  :
                  : "r" (r), "r" (u)
                  : "d0", "d1", "a0", "a1", "cc", "memory");
}
#endif /* !ADAPTER_HAVE_PROTO_MISC */

#endif /* MISC_PROTOS_H */
