/*
 * cia_protos.h -- cia.resource calls for the elf toolchain.
 *
 * AddICRVector / RemICRVector / AbleICR / SetICR, hand-rolled in
 * m68k-amiga-elf-gcc register-parameter syntax (the NDK's <proto/cia.h>
 * takes an implicit resource base; we pass it explicitly in a6, matching
 * the explicit-base style used in misc_protos.h and how the callers hold
 * the base from OpenResource).
 *
 * cia.resource LVOs:
 *   AddICRVector = -6, RemICRVector = -12, AbleICR = -18, SetICR = -24.
 *
 * Original VBCC stubs by Niklas Ekström; rewritten for gcc.
 */
#ifndef CIA_PROTOS_H
#define CIA_PROTOS_H

#include <exec/types.h>
#include <exec/interrupts.h>
#include <exec/libraries.h>

/* Install interrupt handler for one CIA ICR bit. Returns NULL on success,
 * or the current owner's struct Interrupt* if the bit is already taken. */
static inline struct Interrupt *AddICRVector(struct Library *resource asm("a6"),
                                             LONG iCRBit              asm("d0"),
                                             struct Interrupt *irq    asm("a1"))
{
    register struct Interrupt *ret asm("d0");
    register struct Library *r     asm("a6") = resource;
    register LONG b                asm("d0") = iCRBit;
    register struct Interrupt *i   asm("a1") = irq;
    __asm__ __volatile__ (
        "jsr    -6(%%a6)"
        : "=r" (ret)
        : "r" (r), "r" (b), "r" (i)
        : "d1", "a0", "cc", "memory");
    return ret;
}

static inline void RemICRVector(struct Library *resource asm("a6"),
                                LONG iCRBit              asm("d0"),
                                struct Interrupt *irq    asm("a1"))
{
    register struct Library *r   asm("a6") = resource;
    register LONG b              asm("d0") = iCRBit;
    register struct Interrupt *i asm("a1") = irq;
    __asm__ __volatile__ (
        "jsr    -12(%%a6)"
        :
        : "r" (r), "r" (b), "r" (i)
        : "d1", "a0", "cc", "memory");
}

/* Enable/disable ICR bits. mask bit 7 (CIAICRF_SETCLR) set = enable the
 * masked bits, clear = disable them. Returns previous enable mask. */
static inline WORD AbleICR(struct Library *resource asm("a6"),
                           LONG mask                asm("d0"))
{
    register WORD ret          asm("d0");
    register struct Library *r asm("a6") = resource;
    register LONG m            asm("d0") = mask;
    __asm__ __volatile__ (
        "jsr    -18(%%a6)"
        : "=r" (ret)
        : "r" (r), "r" (m)
        : "d1", "a0", "a1", "cc", "memory");
    return ret;
}

/* Set/clear ICR data bits (and read pending). Returns previous ICR data. */
static inline WORD SetICR(struct Library *resource asm("a6"),
                          LONG mask                asm("d0"))
{
    register WORD ret          asm("d0");
    register struct Library *r asm("a6") = resource;
    register LONG m            asm("d0") = mask;
    __asm__ __volatile__ (
        "jsr    -24(%%a6)"
        : "=r" (ret)
        : "r" (r), "r" (m)
        : "d1", "a0", "a1", "cc", "memory");
    return ret;
}

#endif /* CIA_PROTOS_H */
