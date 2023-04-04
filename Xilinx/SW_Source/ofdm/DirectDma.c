//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include "DirectDma.h"
#include "DacChain.h"
#include "FpgaInterface.h"
#include "rtwtypes.h"

void DirectDmaPsToPlInit(unsigned start) // Enable PS to PL
{
  FpgaInterfaceWrite32(DMA_BASE_ADDR, DMA_RESET);
  FpgaInterfaceWrite32(DMA_BASE_ADDR, DMA_IOC_IRQ_MASK+start);
}

ReturnStatusType DirectDmaPsToPl(unsigned Bytes)
{
  ReturnStatusType ReturnStatus;
  unsigned LoopCount;
  unsigned BytesRemaining;
  int16_t *DucBufferPtr;
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
  if (Bytes >= TX_BUFFER_SPAN)
  {
    LoopCount = (unsigned)ceil((double)Bytes/(double)TX_BUFFER_SPAN);
    BytesRemaining = Bytes%TX_BUFFER_SPAN;
  }
  else
  {
    LoopCount = 1;
    BytesRemaining = Bytes;
  }

  printf("DirectDmaPsToPl: Requested %d byte DMA transaction\n", Bytes);
  printf("DirectDmaPsToPl: Breaking into %d DMA transactions of "
    "%d Bytes\n", LoopCount, TX_BUFFER_SPAN);
  printf("DirectDmaPsToPl: Last DMA transaction: %d bytes\n",
    BytesRemaining);

  // Get pointers to buffers
  DucBufferPtr = DacChainGetDMABuff();
  FpgaVirtBuff = FpgaInterfaceGetTxBuffer();

  DirectDmaPsToPlInit(1); // Start DMA

  for (unsigned i = 0; i < LoopCount; i++)
  {

    // Program address of CMA location to DMA
    FpgaInterfaceWrite(DMA_BASE_ADDR+DMA_SOURCE_OFFSET, TX_BUFFER_BASE,
      0xFFFFFFFF);

    // As soon as Length register is written to, DMA transaction starts
    if (i == LoopCount-1)
    {
      // Copy data to physically contiguous memory (CMA) location
      memcpy((void *)(FpgaVirtBuff+i*BytesRemaining*2), 
        (const void *)(DucBufferPtr+i*BytesRemaining*2), BytesRemaining);
      FpgaInterfaceWrite(DMA_BASE_ADDR+DMA_LENGTH_OFFSET,
        BytesRemaining,0xFFFFFFFF);
    }
    else
    {
      // Copy data to physically contiguous memory (CMA) location
      memcpy((void *)(FpgaVirtBuff+i*TX_BUFFER_SPAN*2), 
        (const void *)(DucBufferPtr+i*TX_BUFFER_SPAN*2), BytesRemaining);
      FpgaInterfaceWrite(DMA_BASE_ADDR+DMA_LENGTH_OFFSET,
        TX_BUFFER_SPAN,0xFFFFFFFF);
    }
    while (1)
    {
      unsigned DmaInterrupt;
      FpgaInterfaceRead32(DMA_BASE_ADDR+DMA_STATUS_OFFSET, &DmaInterrupt);
      if ((DmaInterrupt & DMA_IOC_IRQ_MASK) == 0)
      {
        printf("DirectDmaPsToPl: DMA Transaction loop %d complete\n", i);
        // Clear Interrupt
        FpgaInterfaceWrite(DMA_BASE_ADDR+DMA_STATUS_OFFSET,
          DMA_IOC_IRQ_MASK, DMA_IOC_IRQ_MASK);
        break;
      }
    }
  }

  DirectDmaPsToPlInit(0); // Stop DMA

  // free
  FpgaInterfaceClearTxBuffer();
  DacChainClearDMABuff();

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void DirectDmaPlToPsInit(unsigned start) // Enable PL to PS
{
  FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_CONTROL_OFFSET, DMA_RESET);
  FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_CONTROL_OFFSET,
    DMA_IOC_IRQ_MASK+start);
}

ReturnStatusType DirectDmaPlToPs(unsigned Bytes, unsigned *ActualBytes)
{
  ReturnStatusType ReturnStatus;
  //unsigned 

  if (Bytes >= RX_BUFFER_SPAN)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DirectDmaPlToPs: Error: Number of bytes %d too large for"
      "CMA buffer\n", Bytes);
    return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
