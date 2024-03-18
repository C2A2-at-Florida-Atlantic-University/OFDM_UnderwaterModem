//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef DIRECT_DMA_H_INCLUDED
#define DIRECT_DMA_H_INCLUDED

#include <stdbool.h>
#include "ReturnStatus.h"

void DirectDmaPsToPlInit(unsigned start);
ReturnStatusType DirectDmaPsToPl(unsigned Bytes);
ReturnStatusType DirectDmaPlToPsThread(unsigned RawSampleSave);
void DirectDmaPlToPsInit(unsigned start);
void *DirectDmaPlToPs(void *arg);
void DirectDmaPlToPsThreadCancel(void);
void DirectDmaSetGlobalMute(bool GlobalMuteSelect);
void DirectDmaSetNumBytesForLoopback(unsigned Bytes);
unsigned DirectDmaBuffReadStatus(void);
void DirectDmaMm2sIrqClear(void);
void DirectDmaS2mmIrqClear(void);
void DirectDmaMm2sStatus(void);
void DirectDmaS2mmStatus(void);
ReturnStatusType DirectDmaCheckThreadRunning(void);
//ReturnStatusType(void)

#endif
