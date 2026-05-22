/*
 * par2ser.device -- serial.device-compatible bridge over the Amiga parallel
 *                   port (Niklas Ekström's 2E par-to-spi protocol -> FT240X).
 *
 * Structure follows jbilander/SimpleDevice (Bartman m68k-amiga-elf toolchain):
 *   - _start returns -1, inline-asm romtag, RTF_AUTOINIT
 *   - plain-C do_* workers behind register-pinned asm entry points
 *   - KPrintF debug via debug.c (RawDoFmt + RawPutChar)
 *
 * Serial machinery ported from Iain Barclay's 8n1.device (43.5): a RAM receive
 * ring buffer fed by an interrupt, CMD_READ satisfied from that buffer, and
 * SDCMD_QUERY answering "bytes available" from a software counter. The streaming
 * semantics live here in RAM; the hardware only ever needs to say "byte ready".
 *
 * MILESTONE 1 (this file): load, open, and trace the full command set so you can
 * try `set line par2ser.device` in kermit and watch the negotiation over the
 * serial debug console. CMD_WRITE/READ go through a transport layer that is
 * currently STUBBED (see transport.c). Define PAR2SER_HW to compile in the
 * CIA-A FLAG (INTB_PORTS) receive interrupt server that drives the real adapter.
 */

#include <proto/exec.h>
#include <exec/resident.h>
#include <exec/errors.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <exec/lists.h>
#include <exec/interrupts.h>
#include <devices/serial.h>
#include <hardware/cia.h>
#include <hardware/intbits.h>
#include <libraries/dos.h>

#include "transport.h"

#if DEBUG
extern void KPrintF(CONST_STRPTR fmt, ...);
#define DBG(...) KPrintF((CONST_STRPTR)__VA_ARGS__)
#else
#define DBG(...)
#endif

#define STR(s) #s
#define XSTR(s) STR(s)

#define DEVICE_NAME      "par2ser.device"
#define DEVICE_DATE      "(22 May 2026)"
#define DEVICE_ID_STRING "par2ser " XSTR(DEVICE_VERSION) "." XSTR(DEVICE_REVISION) " " DEVICE_DATE
#define DEVICE_VERSION   1
#define DEVICE_REVISION  0
#define DEVICE_PRIORITY  0

/* Default receive buffer size if the client does not request one. */
#define DEFAULT_RBUF_LEN 4096

/* ------------------------------------------------------------------ *
 *  io_Status modem bits.  serial.device returns the raw (active-low)
 *  CIA-B PRA control lines here, so a 0 bit = signal ASSERTED.  We have
 *  no real CIA serial lines on the parallel port, so we SYNTHESIZE a
 *  "fully connected" line: CD/CTS/DSR asserted (= 0).
 *
 *  >>> CARRIER DEBUG KNOB <<<
 *  If kermit still reports NO CARRIER, the CD polarity is the first
 *  suspect -- flip ST_CARRIER_PRESENT below and rebuild.  The whole word
 *  is KPrintF'd in sdcmd_Query so you can see exactly what kermit reads.
 * ------------------------------------------------------------------ */
#define ST_DTR  (1 << CIAB_COMDTR)   /* bit 7 */
#define ST_RTS  (1 << CIAB_COMRTS)   /* bit 6 */
#define ST_CD   (1 << CIAB_COMCD)    /* bit 5 */
#define ST_CTS  (1 << CIAB_COMCTS)   /* bit 4 */
#define ST_DSR  (1 << CIAB_COMDSR)   /* bit 3 */

/* active-low: clear a bit to assert it. 0x00 = CD+CTS+DSR all asserted. */
#define ST_CARRIER_PRESENT  0

/* serial.device command numbers (devices/serial.h): SDCMD_QUERY=9,
 * SDCMD_BREAK=10, SDCMD_SETPARAMS=11, CMD_* per exec/io.h. */
#ifndef NSCMD_DEVICEQUERY
#define NSCMD_DEVICEQUERY 0x4000
#endif
#define NSDEVTYPE_SERIAL  11

struct NSDeviceQueryResult {
    ULONG  DevQueryFormat;
    ULONG  SizeAvailable;
    UWORD  DeviceType;
    UWORD  DeviceSubType;
    const UWORD *SupportedCommands;
};

/* Private io_Flags bits for our own queue bookkeeping. NDK's serial.h here
 * doesn't export IOSERF_* (they're device-internal and SDK-dependent), so we
 * use our own. Bit 0 is IOB_QUICK (exec); bits 4/5 are safely ours. */
#define P2S_QUEUED  (1 << 4)
#define P2S_ACTIVE  (1 << 5)

/* NewList isn't prototyped in this NDK; do it inline (avoids the dependency). */
static inline void init_list(struct List *l)
{
    l->lh_Head     = (struct Node *)&l->lh_Tail;
    l->lh_Tail     = NULL;
    l->lh_TailPred = (struct Node *)&l->lh_Head;
}

/* ------------------------------------------------------------------ */

struct ExecBase *SysBase;
BPTR saved_seg_list;
BOOL is_open;

/* ---- serial state (global; single unit, mirrors 8n1's i_* globals) ---- */
static UBYTE        *rbuf;          /* receive ring buffer base            */
static ULONG         rbuf_len;      /* its size                            */
static UBYTE        *rb_in;         /* ISR write pointer                   */
static UBYTE        *rb_out;        /* reader pointer                      */
static UBYTE        *rb_end;        /* one past end (for wrap)             */
static volatile LONG rb_count;      /* bytes currently buffered            */
static volatile UBYTE rx_overrun;   /* set if ring overflowed              */

static struct IOExtSer *active_read;/* the one read being filled by the ISR*/
static struct List   read_q;        /* further reads waiting their turn    */

static ULONG  cur_baud   = 9600;    /* cosmetic: FT240X has no real baud   */
static ULONG  rbuf_req   = DEFAULT_RBUF_LEN;
static UBYTE  ser_flags;

static const UWORD supported_cmds[] = {
    CMD_RESET, CMD_READ, CMD_WRITE, CMD_CLEAR, CMD_FLUSH,
    SDCMD_QUERY, SDCMD_BREAK, SDCMD_SETPARAMS, NSCMD_DEVICEQUERY, 0
};

#ifdef PAR2SER_HW
static struct Interrupt rx_int;     /* INTB_PORTS server for CIA-A FLAG    */
static BOOL  rx_int_added;
#endif

/* ------------------------------------------------------------------ *
 *  romtag / boilerplate (identical pattern to SimpleDevice)
 * ------------------------------------------------------------------ */
int __attribute__((no_reorder)) _start(void) { return -1; }

asm("romtag:                                \n"
    "       dc.w    "XSTR(RTC_MATCHWORD)"   \n"
    "       dc.l    romtag                  \n"
    "       dc.l    endcode                 \n"
    "       dc.b    "XSTR(RTF_AUTOINIT)"    \n"
    "       dc.b    "XSTR(DEVICE_VERSION)"  \n"
    "       dc.b    "XSTR(NT_DEVICE)"       \n"
    "       dc.b    "XSTR(DEVICE_PRIORITY)" \n"
    "       dc.l    device_name             \n"
    "       dc.l    device_id_string        \n"
    "       dc.l    auto_init_tables        \n"
    "endcode:                               \n");

char device_name[]      = DEVICE_NAME;
char device_id_string[] = DEVICE_ID_STRING;

/* ------------------------------------------------------------------ *
 *  Receive ring buffer
 * ------------------------------------------------------------------ */
static void buffer_reset(void)
{
    rb_in = rb_out = rbuf;
    rb_end = rbuf ? rbuf + rbuf_len : NULL;
    rb_count = 0;
    rx_overrun = 0;
}

static BOOL buffer_alloc(ULONG len)
{
    if (len == 0)
        len = DEFAULT_RBUF_LEN;
    if (rbuf && rbuf_len == len) {     /* already the right size */
        buffer_reset();
        return TRUE;
    }
    if (rbuf) {
        FreeMem(rbuf, rbuf_len);
        rbuf = NULL;
    }
    rbuf = AllocMem(len, MEMF_PUBLIC);
    if (!rbuf) {
        rbuf_len = 0;
        return FALSE;
    }
    rbuf_len = len;
    buffer_reset();
    return TRUE;
}

/* Copy as much as possible from the ring into a read request's buffer.
 * Returns TRUE when the request is fully satisfied (io_Actual == io_Length).
 * Caller must hold Disable(). */
static BOOL read_copy(struct IOExtSer *io)
{
    UBYTE *dst = (UBYTE *)io->IOSer.io_Data + io->IOSer.io_Actual;
    LONG   want = (LONG)io->IOSer.io_Length - (LONG)io->IOSer.io_Actual;

    while (want > 0 && rb_count > 0) {
        *dst++ = *rb_out++;
        if (rb_out == rb_end)
            rb_out = rbuf;
        rb_count--;
        io->IOSer.io_Actual++;
        want--;
    }
    return (io->IOSer.io_Actual >= io->IOSer.io_Length);
}

/* ------------------------------------------------------------------ *
 *  Hardware receive path (real adapter).  Disabled until PAR2SER_HW.
 * ------------------------------------------------------------------ */
#ifdef PAR2SER_HW
/* Feed one received byte into the ring (called from the ISR). */
static void rx_feed(UBYTE c)
{
    if (rb_count >= (LONG)rbuf_len) {   /* full -> drop + flag overrun */
        rx_overrun = 1;
        return;
    }
    *rb_in++ = c;
    if (rb_in == rb_end)
        rb_in = rbuf;
    rb_count++;
}

/* Try to complete the active read (and promote the next queued one). */
static void service_reads(void)
{
    for (;;) {
        if (!active_read) {
            struct Node *n = RemHead(&read_q);
            if (!n)
                return;
            active_read = (struct IOExtSer *)n;
        }
        if (read_copy(active_read)) {
            struct IOExtSer *done = active_read;
            active_read = NULL;
            done->IOSer.io_Error = 0;
            ReplyMsg(&done->IOSer.io_Message);
            continue;            /* see if the next queued read can run too */
        }
        return;                  /* active read still hungry */
    }
}

/* INTB_PORTS server: CIA-A FLAG is pulsed by the adapter's IRQ line when
 * the FT240X RX FIFO is non-empty. Drain it into the ring and service reads.
 * Runs in supervisor/interrupt context: no AllocMem, no ReplyMsg-to-self
 * issues (ReplyMsg from an int server is fine). a1 = is_Data. */
static ULONG __attribute__((used)) rx_server(APTR data asm("a1"))
{
    UBYTE c;
    /* transport_poll_rx() returns 1 and stores a byte while RXF holds. */
    while (transport_poll_rx(&c))
        rx_feed(c);
    service_reads();
    return 0;        /* let other PORTS servers run too */
}

static void rx_install(void)
{
    if (rx_int_added)
        return;
    rx_int.is_Node.ln_Type = NT_INTERRUPT;
    rx_int.is_Node.ln_Pri  = 0;
    rx_int.is_Node.ln_Name = device_name;
    rx_int.is_Data = NULL;
    rx_int.is_Code = (void (*)())rx_server;
    AddIntServer(INTB_PORTS, &rx_int);
    rx_int_added = TRUE;
}

static void rx_remove(void)
{
    if (!rx_int_added)
        return;
    RemIntServer(INTB_PORTS, &rx_int);
    rx_int_added = FALSE;
}
#endif /* PAR2SER_HW */

/* ------------------------------------------------------------------ *
 *  Command handlers.  Each returns TRUE if the request is "pending"
 *  (do NOT reply yet -- an interrupt will finish it), FALSE if complete.
 * ------------------------------------------------------------------ */
static BOOL cmd_read(struct IOExtSer *io)
{
    io->IOSer.io_Actual = 0;
    if (io->IOSer.io_Length == 0)
        return FALSE;

    Disable();
    if (active_read) {
        /* a read is already in progress: queue this one */
        io->IOSer.io_Flags |= P2S_QUEUED;
        AddTail(&read_q, &io->IOSer.io_Message.mn_Node);
        Enable();
        DBG("  CMD_READ len=%ld -> queued\n", (ULONG)io->IOSer.io_Length);
        return TRUE;
    }
    if (read_copy(io)) {                 /* enough already buffered? */
        Enable();
        DBG("  CMD_READ len=%ld -> satisfied now\n", (ULONG)io->IOSer.io_Length);
        return FALSE;
    }
    /* not enough yet: become the active read, ISR will complete it */
    io->IOSer.io_Flags |= P2S_ACTIVE;
    active_read = io;
    Enable();
    DBG("  CMD_READ len=%ld got=%ld -> pending\n",
        (ULONG)io->IOSer.io_Length, (ULONG)io->IOSer.io_Actual);
    return TRUE;
}

static BOOL cmd_write(struct IOExtSer *io)
{
    LONG len = (LONG)io->IOSer.io_Length;
    io->IOSer.io_Actual = 0;

    if (len == -1) {                      /* NUL-terminated string */
        const UBYTE *p = io->IOSer.io_Data;
        len = 0;
        while (p[len]) len++;
        io->IOSer.io_Length = len;
    }
    if (len <= 0)
        return FALSE;

    /* Blocking 2E transfer to the adapter (FT240X TX FIFO, gated by TXE). */
    io->IOSer.io_Actual = (ULONG)transport_write(io->IOSer.io_Data, (ULONG)len);
    DBG("  CMD_WRITE len=%ld wrote=%ld\n", (ULONG)len, io->IOSer.io_Actual);
    return FALSE;                         /* complete */
}

static void cmd_query(struct IOExtSer *io)
{
    UWORD status;
    Disable();
    io->IOSer.io_Actual = (ULONG)rb_count;     /* bytes available to read */
    status = (UWORD)ST_CARRIER_PRESENT;
    if (rx_overrun)
        status |= (1 << 8);                    /* bit 8 = read overrun */
    io->io_Status = status;
    Enable();
    DBG("  SDCMD_QUERY -> status=$%lx actual=%ld\n",
        (ULONG)status, io->IOSer.io_Actual);
}

static void cmd_setparams(struct IOExtSer *io)
{
    DBG("  SDCMD_SETPARAMS baud=%ld rbuf=%ld rd=%ld wr=%ld stop=%ld flags=$%lx\n",
        (ULONG)io->io_Baud, (ULONG)io->io_RBufLen,
        (ULONG)io->io_ReadLen, (ULONG)io->io_WriteLen,
        (ULONG)io->io_StopBits, (ULONG)io->io_SerFlags);

    /* We are an 8N1 pipe. Warn (don't fail) on anything exotic so kermit's
     * negotiation still goes through; tighten this once the line is up. */
    if (io->io_ReadLen != 8 || io->io_WriteLen != 8 || io->io_StopBits != 1)
        DBG("    note: non-8N1 params requested; accepting anyway\n");

    cur_baud  = io->io_Baud ? io->io_Baud : cur_baud;   /* cosmetic only */
    ser_flags = io->io_SerFlags;

    if (io->io_RBufLen && io->io_RBufLen != rbuf_len) {
        rbuf_req = io->io_RBufLen;
        Disable();
        buffer_alloc(rbuf_req);            /* note: discards buffered data */
        Enable();
    }
    io->IOSer.io_Error = 0;
}

static void cmd_clear(void)
{
    Disable();
    buffer_reset();
    Enable();
}

/* ------------------------------------------------------------------ *
 *  do_* workers
 * ------------------------------------------------------------------ */
static BPTR do_expunge(struct Library *dev)
{
    DBG("running do_expunge()\n");
    if (dev->lib_OpenCnt != 0) {
        dev->lib_Flags |= LIBF_DELEXP;
        return 0;
    }
    BPTR seg_list = saved_seg_list;
    Remove(&dev->lib_Node);
    FreeMem((char *)dev - dev->lib_NegSize, dev->lib_NegSize + dev->lib_PosSize);
    return seg_list;
}

static void do_open(struct Library *dev, struct IORequest *ioreq,
                    ULONG unitnum, ULONG flags)
{
    struct IOExtSer *io = (struct IOExtSer *)ioreq;
    DBG("running do_open() unit=%ld\n", unitnum);

    ioreq->io_Error = IOERR_OPENFAIL;
    ioreq->io_Message.mn_Node.ln_Type = NT_REPLYMSG;

    /* Must be a serial-sized request, unit 0 only. */
    if (ioreq->io_Message.mn_Length < (UWORD)sizeof(struct IOExtSer)) {
        DBG("  reject: IORequest too small (%ld < %ld)\n",
            (ULONG)ioreq->io_Message.mn_Length, (ULONG)sizeof(struct IOExtSer));
        return;
    }
    if (unitnum != 0)
        return;

    if (!is_open) {
        if (!buffer_alloc(rbuf_req)) {
            DBG("  reject: receive buffer alloc failed\n");
            return;
        }
        if (!transport_init()) {
            DBG("  reject: transport_init failed\n");
            FreeMem(rbuf, rbuf_len); rbuf = NULL; rbuf_len = 0;
            return;
        }
        active_read = NULL;
        init_list(&read_q);
#ifdef PAR2SER_HW
        rx_install();
#endif
        is_open = TRUE;
    }

    ser_flags = io->io_SerFlags;

    /* Hand back sane serial defaults (the client usually SETPARAMS next). */
    io->io_Status   = (UWORD)ST_CARRIER_PRESENT;
    io->io_Baud     = cur_baud;
    io->io_RBufLen  = rbuf_len;
    io->io_ReadLen  = 8;
    io->io_WriteLen = 8;
    io->io_StopBits = 1;
    io->io_ExtFlags = 0;

    ioreq->io_Unit = (struct Unit *)dev;   /* any non-NULL unit token */
    dev->lib_OpenCnt++;
    ioreq->io_Error = 0;
    DBG("  open OK (cnt=%ld)\n", (ULONG)dev->lib_OpenCnt);
}

static BPTR do_close(struct Library *dev, struct IORequest *ioreq)
{
    DBG("running do_close()\n");

    ioreq->io_Device = NULL;
    ioreq->io_Unit   = NULL;

    if (--dev->lib_OpenCnt == 0) {
#ifdef PAR2SER_HW
        rx_remove();
#endif
        transport_shutdown();
        if (rbuf) { FreeMem(rbuf, rbuf_len); rbuf = NULL; rbuf_len = 0; }
        is_open = FALSE;

        if (dev->lib_Flags & LIBF_DELEXP)
            return do_expunge(dev);
    }
    return 0;
}

static void do_begin_io(struct Library *dev, struct IORequest *ioreq)
{
    struct IOExtSer *io = (struct IOExtSer *)ioreq;
    BOOL pending = FALSE;

    ioreq->io_Message.mn_Node.ln_Type = NT_MESSAGE;
    ioreq->io_Error = 0;
    io->IOSer.io_Flags &= ~(P2S_QUEUED | P2S_ACTIVE);

    DBG("BeginIO cmd=%ld\n", (ULONG)ioreq->io_Command);

    switch (ioreq->io_Command) {
    case CMD_READ:        pending = cmd_read(io);              break;
    case CMD_WRITE:       pending = cmd_write(io);             break;
    case SDCMD_QUERY:     cmd_query(io);                       break;
    case SDCMD_SETPARAMS: cmd_setparams(io);                   break;
    case CMD_CLEAR:
    case CMD_FLUSH:       cmd_clear();                         break;
    case CMD_RESET:
        cmd_clear();
        cur_baud = 9600; ser_flags = 0;
        break;
    case SDCMD_BREAK:
        DBG("  SDCMD_BREAK (no-op on FT240X pipe)\n");
        break;
    case CMD_START:
    case CMD_STOP:
        /* X-ON/X-OFF flow control toggles -- accepted as no-ops for now. */
        break;
    case NSCMD_DEVICEQUERY: {
        struct NSDeviceQueryResult *r =
            (struct NSDeviceQueryResult *)io->IOSer.io_Data;
        r->DevQueryFormat    = 0;
        r->SizeAvailable     = sizeof(struct NSDeviceQueryResult);
        r->DeviceType        = NSDEVTYPE_SERIAL;
        r->DeviceSubType     = 0;
        r->SupportedCommands = supported_cmds;
        io->IOSer.io_Actual  = sizeof(struct NSDeviceQueryResult);
        break;
    }
    default:
        DBG("  unsupported cmd=%ld -> IOERR_NOCMD\n", (ULONG)ioreq->io_Command);
        ioreq->io_Error = IOERR_NOCMD;
        break;
    }

    if (pending) {
        /* queued/active: reply will come from the interrupt path. Clear QUICK
         * so the client Wait()s on its reply port. */
        ioreq->io_Flags &= ~IOF_QUICK;
        return;
    }
    if (!(ioreq->io_Flags & IOF_QUICK))
        ReplyMsg(&ioreq->io_Message);
}

static ULONG do_abort_io(struct Library *dev, struct IORequest *ioreq)
{
    struct IOExtSer *io = (struct IOExtSer *)ioreq;
    DBG("running do_abort_io() cmd=%ld\n", (ULONG)ioreq->io_Command);

    Disable();
    if (active_read == io) {
        active_read = NULL;
    } else if (io->IOSer.io_Flags & P2S_QUEUED) {
        Remove(&io->IOSer.io_Message.mn_Node);   /* pull from read_q */
    } else {
        Enable();
        return IOERR_NOCMD;                       /* not ours / already done */
    }
    io->IOSer.io_Flags &= ~(P2S_QUEUED | P2S_ACTIVE);
    io->IOSer.io_Error = IOERR_ABORTED;
    Enable();

    if (!(ioreq->io_Flags & IOF_QUICK))
        ReplyMsg(&ioreq->io_Message);
    return 0;
}

/* ------------------------------------------------------------------ *
 *  AUTOINIT entry points (register-pinned, identical pattern to SimpleDevice)
 * ------------------------------------------------------------------ */
static struct Library __attribute__((used)) *
init_device(struct ExecBase *sys_base asm("a6"),
            BPTR seg_list asm("a0"),
            struct Library *dev asm("d0"))
{
    SysBase = sys_base;                 /* before any DBG -- KPrintF needs it */
    DBG("running init_device()\n");

    saved_seg_list = seg_list;
    dev->lib_Node.ln_Type = NT_DEVICE;
    dev->lib_Node.ln_Name = device_name;
    dev->lib_Flags        = LIBF_SUMUSED | LIBF_CHANGED;
    dev->lib_Version      = DEVICE_VERSION;
    dev->lib_Revision     = DEVICE_REVISION;
    dev->lib_IdString     = (APTR)device_id_string;

    is_open = FALSE;
    return dev;
}

static BPTR __attribute__((used)) expunge(struct Library *dev asm("a6"))
{ return do_expunge(dev); }

static void __attribute__((used)) open(struct Library *dev asm("a6"),
                                       struct IORequest *ioreq asm("a1"),
                                       ULONG unitnum asm("d0"),
                                       ULONG flags asm("d1"))
{ do_open(dev, ioreq, unitnum, flags); }

static BPTR __attribute__((used)) close(struct Library *dev asm("a6"),
                                        struct IORequest *ioreq asm("a1"))
{ return do_close(dev, ioreq); }

static void __attribute__((used)) begin_io(struct Library *dev asm("a6"),
                                           struct IORequest *ioreq asm("a1"))
{ do_begin_io(dev, ioreq); }

static ULONG __attribute__((used)) abort_io(struct Library *dev asm("a6"),
                                            struct IORequest *ioreq asm("a1"))
{ return do_abort_io(dev, ioreq); }

static ULONG device_vectors[] = {
    (ULONG)open,
    (ULONG)close,
    (ULONG)expunge,
    0,
    (ULONG)begin_io,
    (ULONG)abort_io,
    -1
};

const ULONG auto_init_tables[4] = {
    sizeof(struct Library),
    (ULONG)device_vectors,
    0,
    (ULONG)init_device
};
