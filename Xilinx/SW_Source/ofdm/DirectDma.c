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
  unsigned DmaInterrupt;
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

ReturnStatusType DirectDmaPlToPs(void)
{
  ReturnStatusType ReturnStatus;
  unsigned BufferSelect = 0;  // Select between 2 buffers
  unsigned DmaInterrupt;
  unsigned ActualBytes;

  DirectDmaPlToPsInit(1); // Start DMA s2mm

  // While DMA is filling up one buffer, the other one can 
  // be used for processing
  // 
  // There is a DMA interrupt for s2mm upon AXI TLAST regardless of 
  // whether or not DMAS_LENGTH register has reached zero. As a result,
  // we have to keep restarting the DMA transfer.
  while (1)
  {
    // Write physical address of DMA buffer location in memory
    if (BufferSelect)
    {
      FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_DEST_OFFSET, 
        RX_BUFFER_BASE1);
      BufferSelect = !BufferSelect;
    }
    else // BufferSelect = 0
    {
      FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_DEST_OFFSET,
        RX_BUFFER_BASE0);
      BufferSelect = !BufferSelect;
    }

    // As soon as length register is written to, the DMA transaction starts
    FpgaInterfaceWrite32(DMA_BASE_ADDR+DMAS_LENGTH_OFFSET,
      TX_BUFFER_SPAN);

    // Wait for buffer to fill or for tlast to be asserted
    while (1)
    {
      FpgaInterfaceRead32(DMA_BASE_ADDR+DMAS_STATUS_OFFSET, &DmaInterrupt);
      if ((DmaInterrupt & DMA_IOC_IRQ_MASK) == 0)
      {
        printf("DirectDmaPsToPl: DMAS Transaction loop %d complete\n", 0);
        // Clear Interrupt
        FpgaInterfaceWrite(DMA_BASE_ADDR+DMAS_STATUS_OFFSET,
          DMA_IOC_IRQ_MASK, DMA_IOC_IRQ_MASK);
        break;
      }
    }

    // Actual number of bytes is written back onto buffer length reg
    FpgaInterfaceRead32(DMA_BASE_ADDR+DMAS_LENGTH_OFFSET, &ActualBytes);
    if (ActualBytes != TX_BUFFER_SPAN)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString, "DirectDmaPlToPs: DMA ERROR: "
      "Number of bytes read does not match expected number of bytes\n");
      return ReturnStatus;
    }

#ifdef DEBUG
    printf("\t\tDirectDmaPlToPs: Wrote to buffer %d\n", !BufferSelect);
#endif
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
