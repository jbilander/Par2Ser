/*
 * misc_protos.h -- AllocMiscResource / FreeMiscResource for the elf toolchain.
 *
 * We deliberately DO NOT include <proto/misc.h> here. The NDK's proto/inline
 * version takes an implicit library base (AllocMiscResource(unitNum, name) /
 * FreeMiscResource(unitNum)) sourced from a global MiscBase, which we would
 * then have to declare and populate. misc.resource is obtained via
 * OpenResource(), not OpenLibrary(), so there is no auto-managed MiscBase.
 *
 * Instead we hand-roll gcc-syntax inline stubs that take the resource base
 * explicitly in a6 -- the same explicit-base model spi.c used, and the model
 * adapter.c is written around (it holds `miscbase` and passes it in).
 *
 * misc.resource LVOs (per NDK fd / Niklas's original):
 *   AllocMiscResource = -6, FreeMiscResource = -12.
 *
 * Original VBCC stubs by Niklas Ekström; rewritten in m68k-amiga-elf-gcc
 * register-parameter syntax (`type name asm("aN")`), matching par2ser.c.
 */
#ifndef MISC_PROTOS_H
#define MISC_PROTOS_H

#include <exec/types.h>
#include <exec/libraries.h>

/* Returns NULL on success, non-NULL (the resource base) on failure -- matches
 * misc.resource semantics: a non-NULL return means the bits were already
 * allocated by someone else. */
static inline UBYTE *AllocMiscResource(struct Library *resource asm("a6"),
                                       ULONG unitNum            asm("d0"),
                                       const char *name         asm("a1"))
{
    register UBYTE *ret        asm("d0");
    register struct Library *r asm("a6") = resource;
    register ULONG u           asm("d0") = unitNum;
    register const char *n     asm("a1") = name;
    __asm__ __volatile__ (
        "jsr    -6(%%a6)"
        : "=r" (ret)
        : "r" (r), "r" (u), "r" (n)
        : "d1", "a0", "cc", "memory");
    return ret;
}

static inline void FreeMiscResource(struct Library *resource asm("a6"),
                                    ULONG unitNum            asm("d0"))
{
    register struct Library *r asm("a6") = resource;
    register ULONG u           asm("d0") = unitNum;
    __asm__ __volatile__ (
        "jsr    -12(%%a6)"
        :
        : "r" (r), "r" (u)
        : "d1", "a0", "a1", "cc", "memory");
}

#endif /* MISC_PROTOS_H */
