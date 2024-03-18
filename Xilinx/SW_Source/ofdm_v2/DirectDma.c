//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <signal.h>
#include <math.h>
#include "DirectDma.h"
#include "DacChain.h"
#include "FpgaInterface.h"
#include "TxModulate.h"
#include "HwInterface.h"
#include "rtwtypes.h"

#ifndef NO_DEVMEM
static pthread_t DmaThread = (pthread_t)NULL;
static unsigned DmaPlToPsComplete;
#endif
static unsigned LoopBackBytes;
static bool GlobalMute;

void DirectDmaSetGlobalMute(bool GlobalMuteSelect)
{
  GlobalMute = GlobalMuteSelect;
}

void DirectDmaMm2sIrqClear(void)
{
  FpgaInterfaceWrite(DMA_BASE_ADDR, DMA_CLEAR,
    DMA_IOC_IRQ_MASK, GlobalMute);
}

void DirectDmaS2mmIrqClear(void)
{
  FpgaInterfaceWrite(DMA_BASE_ADDR+DMAS_CONTROL_OFFSET, 
    DMA_CLEAR, DMA_IOC_IRQ_MASK, GlobalMute);
}

void DirectDmaMm2sStatus(void)
{
  unsigned RegVal;
  FpgaInterfaceRead32(DMA_BASE_ADDR, &RegVal, GlobalMute);
  printf("DirectDmaMm2sStatus: Status: 0x%X\n", RegVal);
}

void DirectDmaS2mmStatus(void)
{
  unsigned RegVal;
  FpgaInterfaceRead32(DMA_BASE_ADDR+DMAS_STATUS_OFFSET, &RegVal, 
    GlobalMute);
  printf("DirectDmaS2mmStatus: Status: 0x%X\n", RegVal);
}

unsigned DirectDmaBuffReadStatus(void)
{
#ifndef NO_DEVMEM
  return DmaPlToPsComplete;
#else
  return 1;
#endif
}

void DirectDmaSetNumBytesForLoopback(unsigned Bytes)
{
  LoopBackBytes = Bytes;
}

#ifndef NO_DEVMEM

void DirectDmaPsToPlInit(unsigned start) // Enable or Disable PS to PL DMA
{
  FpgaInterfaceWrite32(DMA_BASE_ADDR, DMA_RESET, GlobalMute); // Reset DMA
  FpgaInterfaceWrite32(DMA_BASE_ADDR, DMA_IOC_IRQ_MASK+start, GlobalMute);
}

ReturnStatusType DirectDmaPsToPl(unsigned Bytes)
{
  ReturnStatusType ReturnStatus;
  unsigned LoopCount;
  unsigned BytesRemaining;
  unsigned DmaInterrupt;
  int32_T *BufferPtr;
  void *FpgaVirtBuff;
/*
  if (Bytes >= (unsigned)pow(2,DMA_BUFFER_WIDTH_VAL)-1)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DirectDmaPsToPl: Error: Number of bytes to large for single "
      "transaction\n");
    return ReturnStatus;
  }
*/
  if (Bytes >= BUFFER_SPAN)
  {
    LoopCount = (unsigned)ceil((double)Bytes/(double)BUFFER_SPAN);
    BytesRemaining = Bytes%BUFFER_SPAN;
  }
  else
  {
    LoopCount = 1;
    BytesRemaining = Bytes;
  }

  printf("DirectDmaPsToPl: Requested %d  = 0x%X byte DMA transaction\n",
    Bytes, Bytes);
  printf("DirectDmaPsToPl: Breaking into %d DMA transactions of <= "
    "%d = 0x%X Bytes\n", LoopCount, BUFFER_SPAN, BUFFER_SPAN);
  printf("DirectDmaPsToPl: Last DMA transaction: %d  = 0x%X bytes\n",
    BytesRemaining, BytesRemaining);

  FpgaInterfaceClearTxBuffer();
  // Get pointers to buffers
  BufferPtr = TxModulateGetTxBuffer();
  FpgaVirtBuff = FpgaInterfaceGetTxBuffer();

  DirectDmaMm2sIrqClear();
  DirectDmaPsToPlInit(1); // Start DMA

  for (unsigned i = 0; i < LoopCount; i++)
  {

    // Program address of CMA location to DMA
    FpgaInterfaceWrite32(DMA_BASE_ADDR+DMA_SOURCE_OFFSET, TX_BUFFER_BASE,
    GlobalMute);

    // As soon as Length register is written to, DMA transaction starts
    if (i == LoopCount-1)
    {
      // Copy data to physically contiguous memory (CMA) location
      memcpy((void *)(FpgaVirtBuff+i*BytesRemaining*2), 
        (const void *)(BufferPtr+i*BytesRemaining*2), BytesRemaining);
      FpgaInterfaceWrite32(DMA_BASE_ADDR+DMA_LENGTH_OFFSET,
        BytesRemaining, GlobalMute);
    }
    else
    {
      // Copy data to physically contiguous memory (CMA) location
      memcpy((void *)(FpgaVirtBuff+i*BUFFER_SPAN*2), 
        (const void *)(BufferPtr+i*BUFFER_SPAN*2), BytesRemaining);
      FpgaInterfaceWrite32(DMA_BASE_ADDR+DMA_LENGTH_OFFSET,
        BUFFER_SPAN, GlobalMute);
    }
    while (1)
    {
      FpgaInterfaceRead32(DMA_BASE_ADDR+DMA_STATUS_OFFSET, 
        &DmaInterrupt, true);
      if (!((DmaInterrupt & DMA_IOC_IRQ_MASK) == 0))
      {
        printf("DirectDmaPsToPl: DMA Transaction loop%d complete\n", i);
        // Clear Interrupt
        FpgaInterfaceWrite(DMA_BASE_ADDR+DMA_STATUS_OFFSET,
          DMA_IOC_IRQ_MASK, DMA_IOC_IRQ_MASK, GlobalMute);
        break;
      }
    }
  }

  DirectDmaPsToPlInit(0); // Stop DMA
  DirectDmaMm2sIrqClear();

  // free
  FpgaInterfaceClearTxBuffer();

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType DirectDmaCheckThreadRunning(void)
{
  ReturnStatusType ReturnStatus;
  if (DmaThread != (pthread_t)NULL)
  {
    if (pthread_kill(DmaThread,0) == 0)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString, "DirectDmaCheckThreadRunning: "
        "S2MM Thread running\n");
      return ReturnStatus;
    }
    else
    {
      printf("DirectDmacheckThreadRunning: S2MM Thread stopped\n");
    }
  }
  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType DirectDmaPlToPsThread(unsigned RawSampleSave)
{
  ReturnStatusType ReturnStatus;
  int RetVal;

  ReturnStatus = DirectDmaCheckThreadRunning();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    sprintf(ReturnStatus.ErrString, "DirectDmaPlToPsThread: "
      "ERROR: S2MM Thread already running\n");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
  }
  
  DmaPlToPsComplete = 0;

  RetVal = pthread_create(&DmaThread, NULL, DirectDmaPlToPs,
    (void *)RawSampleSave);
  if (RetVal != 0)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DirectDmaPlToPsThread: ERROR: Failed to create thread for "
      "DMA transaction. pthread_create returned %d\n", RetVal);
    return ReturnStatus;
  }
  else
  {
    printf("DirectDmaPlToPsThread: Started S2MM Thread\n");
  }
  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void DirectDmaPlToPsThreadCancel(void)
{
  ReturnStatusType ReturnStatus;
  ReturnStatus = DirectDmaCheckThreadRunning();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("DirectDmaPlToPsThreadCancel: Pthread still running\n");
  }
  else
  {
    printf("DirectDmaPlToPsThreadCancel: Pthread already stopped\n");
  }
}
  
void DirectDmaPlToPsInit(unsigned start) // Enable PL to PS
{
  FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_CONTROL_OFFSET, DMA_RESET,
    GlobalMute);
  FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_CONTROL_OFFSET,
    DMA_IOC_IRQ_MASK+start, GlobalMute);
}

void *DirectDmaPlToPs(void *arg)
{
  unsigned DmaInterrupt;
  unsigned ActualBytes;
  unsigned RegValue;

  DirectDmaS2mmIrqClear();
  DirectDmaPlToPsInit(1); // Start DMA s2mm

  FpgaInterfaceClearRxBuffer();
  FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_DEST_OFFSET, 
  RX_BUFFER_BASE, GlobalMute);
        
  // Read if transfer was a mm2s => s2mm loopback
  FpgaInterfaceRead32(GPIO_1_BASE_ADDR+DMA_LOOPBACK_OFFSET, 
    &RegValue, GlobalMute);
  RegValue &= DMA_LOOPBACK_MASK;
  if (RegValue)
  {
    printf("DirectDmaPlToPs: DMA loopback detected, programming %d "
      "byte transaction\n", LoopBackBytes);
    FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_LENGTH_OFFSET,
      LoopBackBytes, GlobalMute);
  // As soon as length register is written to, the DMA transaction 
  // starts
  }
  else
  {
    if ((int)arg)
    {
      printf("DirectDmaPlToPs: Saving %d bytes of raw DAC/ADC samples\n",
        LoopBackBytes);
      if (LoopBackBytes > RX_BUFFER_SPAN)
      {
        printf("DirectDmaPlToPs: ERROR: Requested DMA transaction "
          "is too large, max %d bytes\n", RX_BUFFER_SPAN);
        return NULL;
      }
      FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_LENGTH_OFFSET,
        LoopBackBytes, GlobalMute);
    }
    else // Normal Demod path
    {
      FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_LENGTH_OFFSET,
        BUFFER_SPAN, GlobalMute);
    }
  }

  // Wait for buffer to fill or for tlast to be asserted
  while (1)
  {
    FpgaInterfaceRead32(DMA_BASE_ADDR+DMAS_STATUS_OFFSET, 
      &DmaInterrupt, true);
    if (!((DmaInterrupt & DMA_IOC_IRQ_MASK) == 0))
    {
      //printf("DirectDmaPsToPl: DMAS loop %d complete\n", 0);
      // Clear Interrupt
      FpgaInterfaceWrite(DMA_BASE_ADDR+DMAS_STATUS_OFFSET,
        DMA_IOC_IRQ_MASK, DMA_IOC_IRQ_MASK, GlobalMute);
      break;
    }
  }

  // Actual number of bytes is written back onto buffer length reg
  FpgaInterfaceRead32(DMA_BASE_ADDR+DMAS_LENGTH_OFFSET, &ActualBytes,
    GlobalMute);
#ifdef DEBUG
  printf("DirectDmaPlToPs: Read %d bytes\n", ActualBytes);
#endif

  if (ActualBytes != BUFFER_SPAN)
  {
    printf("DirectDmaPlToPs: DMA ERROR: "
    "Number of bytes read, %d,\n\tdoes not match expected number of "
    "bytes %d, pthread closing ...\n", ActualBytes, BUFFER_SPAN);
  }

#ifdef DEBUG
  printf("\t\tDirectDmaPlToPs: Wrote to buffer\n");
#endif

  DirectDmaPlToPsInit(0);
  DirectDmaS2mmIrqClear();
  DmaPlToPsComplete = 1;

  printf("DirectDmaPlToPs: PL to PS transaction finished\n");
  // Read if transfer was a mm2s => s2mm loopback
  FpgaInterfaceRead32(GPIO_1_BASE_ADDR+DMA_LOOPBACK_OFFSET, 
    &RegValue, GlobalMute);
  RegValue &= DMA_LOOPBACK_MASK;
  if (RegValue)
  {
    printf("DirectDmaPlToPs: DMA Loopback complete. Exiting thread\n");
  }

  if ((int)arg)
  {
    printf("DirectDmaPlToPs: Raw ADC sample save complete. Exiting "
      "thread\n");
  }

  return NULL;
}

#endif
