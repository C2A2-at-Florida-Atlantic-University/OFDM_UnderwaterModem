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

static pthread_t DmaThread = (pthread_t)NULL;
static int pthreadState;
static bool GlobalMute;
static bool BuffReadStatus0 = false;
static bool BuffReadStatus1 = false;
static bool BuffReadStatus2 = false;
static unsigned BufferSelect;
static unsigned LoopBackBytes;

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

int DirectDmaBuffReadStatus(bool *Status0, bool *Status1, bool
  *Status2)
{
  *Status0 = BuffReadStatus0;
  *Status1 = BuffReadStatus1;
  *Status2 = BuffReadStatus2;
  switch (BufferSelect) {
    case (RX_BUFFER_1):
      return RX_BUFFER_0;
    case (RX_BUFFER_2):
      return RX_BUFFER_1;
    case (RX_BUFFER_0):
      return RX_BUFFER_2;
    default:
      return -1;
  }
}

void DirectDmaSetNumBytesForLoopback(unsigned Bytes)
{
  LoopBackBytes = Bytes;
}

void DirectDmaSetGlobalMute(bool GlobalMuteSelect)
{
  GlobalMute = GlobalMuteSelect;
}

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

  // Get pointers to buffers
#ifdef DUC
  BufferPtr = TxModulateGetTxBuffer();
#endif
#ifdef DAC
  BufferPtr = DacChainGetDMABuff();
#endif
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
#ifdef DUC
  TxModulateClose();
#endif
#ifdef DAC
  DacChainClearDMABuff();
#endif

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

ReturnStatusType DirectDmaPlToPsThread(void)
{
  ReturnStatusType ReturnStatus;
  int RetVal;
  int Single = 0; // Change to 1 for a single DMA transaction

  ReturnStatus = DirectDmaCheckThreadRunning();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    sprintf(ReturnStatus.ErrString, "DirectDmaPlToPsThread: "
      "ERROR: S2MM Thread already running\n");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
  }

  pthreadState = 0; // pthread normal state

  RetVal = pthread_create(&DmaThread, NULL, DirectDmaPlToPs,
    (void *)Single);
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
    pthreadState = 1; // pthread stop state
    printf("DirectDmaPlToPsThreadCancel: Closing Pthread\n");
    pthread_join(DmaThread, NULL);
    printf("DirectDmaPlToPsThreadCancel: Pthread closed\n");
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
  BufferSelect = RX_BUFFER_0;

  // While DMA is filling up one buffer, the other one can 
  // be used for processing
  // 
  // There is a DMA interrupt for s2mm upon AXI TLAST regardless of 
  // whether or not DMAS_LENGTH register has reached zero. As a result,
  // we have to keep restarting the DMA transfer.
  while (1)
  {
    // Write physical address of DMA buffer location in memory
    // Switch between 3 buffers
    switch (BufferSelect) {
      case (RX_BUFFER_0):
        FpgaInterfaceClearRxBuffer(RX_BUFFER_0);
        FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_DEST_OFFSET, 
          RX_BUFFER_BASE0, GlobalMute);
        BuffReadStatus0 = false;
        BufferSelect = RX_BUFFER_1;
        break;

      case (RX_BUFFER_1):
        FpgaInterfaceClearRxBuffer(RX_BUFFER_1);
        FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_DEST_OFFSET, 
          RX_BUFFER_BASE1, GlobalMute);
        BuffReadStatus1 = false;
        BufferSelect = RX_BUFFER_2;
        break;

      case (RX_BUFFER_2):
        FpgaInterfaceClearRxBuffer(RX_BUFFER_2);
        FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_DEST_OFFSET, 
          RX_BUFFER_BASE2, GlobalMute);
        BuffReadStatus2 = false;
        BufferSelect = RX_BUFFER_0;
        break;

      default :
        printf("DirectDmaPsToPl: Invalid RX Buffer. Exiting thread\n");
        return NULL;
    }
        
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
      FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_LENGTH_OFFSET,
        BUFFER_SPAN, GlobalMute);
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

    switch (BufferSelect) {
      case (RX_BUFFER_1):
        BuffReadStatus0 = true;
        break;
      case (RX_BUFFER_2):
        BuffReadStatus1 = true;
        break;
      case (RX_BUFFER_0):
        BuffReadStatus2 = true;
        break;
      default:
        printf("DirectDmaPlToPs: Buffer Invalid. Exiting thread\n");
        return NULL;
    }

    // Actual number of bytes is written back onto buffer length reg
    FpgaInterfaceRead32(DMA_BASE_ADDR+DMAS_LENGTH_OFFSET, &ActualBytes,
      GlobalMute);
#ifdef DEBUG
    printf("DirectDmaPlToPs: Read %d bytes\n", ActualBytes);
#endif

    // Read if transfer was a mm2s => s2mm loopback
    FpgaInterfaceRead32(GPIO_1_BASE_ADDR+DMA_LOOPBACK_OFFSET, 
      &RegValue, GlobalMute);
    RegValue &= DMA_LOOPBACK_MASK;
    if (RegValue)
    {
      printf("DirectDmaPlToPs: DMA Loopback complete. Exiting thread\n");
      return NULL;
    }

    // Actual number of bytes is written back onto buffer length reg
    FpgaInterfaceRead32(DMA_BASE_ADDR+DMAS_LENGTH_OFFSET, &ActualBytes,
      GlobalMute);
    if (ActualBytes != BUFFER_SPAN)
    {
      printf("DirectDmaPlToPs: DMA ERROR: "
      "Number of bytes read does not match expected number of "
      "bytes, pthread closing ...\n");
      return NULL;
    }

#ifdef DEBUG
    printf("\t\tDirectDmaPlToPs: Wrote to buffer, Current buffer %d\n",
      BufferSelect);
#endif

    // Check if should continue pthread
    if (pthreadState || (int)arg)
    {
      printf("DirectDmaPlToPs: Stopping pthread\n");
      break;
    }
  }

  DirectDmaPlToPsInit(0);
  DirectDmaS2mmIrqClear();

  printf("DirectDmaPlToPs: PL to PS transaction finished\n");
  return NULL;
}
