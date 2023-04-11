//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef DIRECT_DMA_H_INCLUDED
#define DIRECT_DMA_H_INCLUDED

#include <stdbool.h>

// PS to PL control and status registers
#define DMA_BASE_ADDR 0x40000000 // Same as DMA_CONTROL_REGISTER
#define DMA_STATUS_OFFSET 0x00000004
#define DMA_SOURCE_OFFSET 0x00000018
#define DMA_LENGTH_OFFSET 0x00000028

// PL to PS control and status registers
#define DMAS_CONTROL_OFFSET 0x00000030
#define DMAS_STATUS_OFFSET 0x00000034
#define DMAS_DEST_OFFSET 0x00000048
#define DMAS_LENGTH_OFFSET 0x00000058

#define DMA_RESET 0x4
#define DMA_IOC_IRQ_MASK 0x00001000
#define DMA_CLEAR 0x00000000

#define DMA_BUFFER_WIDTH_VAL 26 // Configured in DMA GUI

#include "ReturnStatus.h"

void DirectDmaPsToPlInit(unsigned start);
ReturnStatusType DirectDmaPsToPl(unsigned Bytes);
ReturnStatusType DirectDmaPlToPsThread(void);
void DirectDmaPlToPsInit(unsigned start);
void *DirectDmaPlToPs(void *arg);
void DirectDmaPlToPsThreadCancel(void);
void DirectDmaSetGlobalMute(bool GlobalMuteSelect);
void DirectDmaSetNumBytesForLoopback(unsigned Bytes);
int DirectDmaBuffReadStatus(bool *Status0, bool *Status1, bool
  *Status2);
void DirectDmaMm2sIrqClear(void);
void DirectDmaS2mmIrqClear(void);
void DirectDmaMm2sStatus(void);
void DirectDmaS2mmStatus(void);

#endif
