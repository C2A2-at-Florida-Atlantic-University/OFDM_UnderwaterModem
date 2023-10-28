//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/types.h>
#include "FpgaInterface.h"
#include "TxModulate.h"

#define DEBUG
#define READ_DEBUG
#define WRITE_DEBUG

static int FpgaRegDevice;
static void *FpgaVirtualAddr;

ReturnStatusType FpgaInterfaceSetup(void)
{
  ReturnStatusType ReturnStatus;
 
#ifdef NO_DEVMEM
  FpgaVirtualAddr = malloc(2*BUFFER_SPAN);
  if (FpgaVirtualAddr == NULL)
  {
    sprintf(ReturnStatus.ErrString,
      "FpgaInterfaceSetup ERROR: Could not malloc buffer\n");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    return ReturnStatus;
  }
  memset(FpgaVirtualAddr, 0, 2*BUFFER_SPAN);
  // Get rid of warnings:
  FpgaRegDevice = 0;
  printf("%d\n",FpgaRegDevice);
#else
  if ((FpgaRegDevice = open("/dev/mem", (O_RDWR | O_SYNC))) == -1)
  {
    sprintf(ReturnStatus.ErrString,
      "FpgaInterfaceSetup ERROR: Could not open \"/dev/mem\" ...\n");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    return ReturnStatus;
  }
  
  FpgaVirtualAddr = mmap(NULL, FPGA_REG_SPAN, (PROT_READ | PROT_WRITE),
    MAP_SHARED, FpgaRegDevice, FPGA_REG_BASE_ADDR);
  if (FpgaVirtualAddr == MAP_FAILED)
  {
    sprintf(ReturnStatus.ErrString,
      "FpgaInterfaceSetup ERROR: mmap() failed ...\n");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    return ReturnStatus;
  }

#ifdef DEBUG
  printf("FpgaInterfaceSetup: Allocated page size of 0x%X\n", 
    FPGA_REG_SPAN);
#endif
#endif

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

unsigned *FpgaInterfaceGetTxBuffer()
{
#ifdef NO_DEVMEM
  printf("FpgaInterfaceGetTxBuffer: NO_DEVMEM defined\n");
  return FpgaVirtualAddr;
#else
  printf("FpgaInterfaceGetTxBuffer: Returning CMA area\n");
  return (unsigned *)(FpgaVirtualAddr+TX_BUFFER_BASE);
#endif
}

unsigned *FpgaInterfaceClearTxBuffer()
{
#ifdef DEBUG
  printf("FpgaInterfaceClearTxBuffer: Clear TX Buffer\n");
#endif

#ifdef NO_DEVMEM
  printf("FpgaInterfaceClearTxBuffer: NO_DEVMEM defined\n");
  memset(FpgaVirtualAddr, 0, BUFFER_SPAN);
  return FpgaVirtualAddr;
#else
  printf("FpgaInterfaceClearTxBuffer: Clearing CMA area\n");
  memset((unsigned *)(FpgaVirtualAddr+TX_BUFFER_BASE), 0, BUFFER_SPAN);
  return (unsigned *)(FpgaVirtualAddr+TX_BUFFER_BASE);
#endif
}

unsigned *FpgaInterfaceGetReloadBuffer()
{
  return (unsigned *)(FpgaVirtualAddr+RELOAD_BUFFER_BASE);
}

unsigned *FpgaInterfaceGetRxBuffer(unsigned RxBufferSelect)
{
  switch (RxBufferSelect) {
    case (RX_BUFFER_0):
      return (unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE0);
    case (RX_BUFFER_1):
      return (unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE1);
    case (RX_BUFFER_2):
      return (unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE2);
    case (TX_BUFFER_LOOPBACK):
      return (unsigned *)TxModulateGetTxBuffer();
  }
  return NULL;
}

unsigned *FpgaInterfaceClearRxBuffer(unsigned RxBufferSelect)
{
#ifdef NO_DEVEM
  printf("FpgaInterfaceClearRxBuffer: NO_DEVMEM defined\n");
  memset((unsigned *)(FpgaVirtualAddr+BUFFER_SPAN), 0, BUFFER_SPAN);
  return (unsigned *)(FpgaVirtualAddr+BUFFER_SPAN);
#else
  printf("FpgaInterfaceClearRxBuffer: Clearing CMA RX %d area\n",
    RxBufferSelect);
  switch (RxBufferSelect) {
    case (RX_BUFFER_0):
      memset((unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE0), 0,
        BUFFER_SPAN);
      return(unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE0);
    case (RX_BUFFER_1):
      memset((unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE1), 0,
        BUFFER_SPAN);
      return(unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE1);
    case (RX_BUFFER_2):
      memset((unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE2), 0,
        BUFFER_SPAN);
      return(unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE2);
    default:
      return(unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE0);
  }
#endif
}

void FpgaInterfaceRead32(unsigned addr, unsigned *pValue, bool mute)
{
  if (!mute)
  {
    printf("\tFpgaInterfaceRead32: About to read from addr 0x%X\n", addr);
  }

#ifdef NO_DEVMEM
  *pValue = 0;
#else
  *pValue = *((unsigned *)(FpgaVirtualAddr+addr));
  if (!mute)
  {
    printf("\tFpgaInterfaceRead32: Read 0x%X from 0x%X\n", *pValue, addr);
  }
#endif
}

void FpgaInterfaceWrite32(unsigned addr, unsigned value, bool mute)
{
#ifdef WRITE_DEBUG
  if (!mute)
  {
    printf("\tFpgaInterfaceWrite32: About to write 0x%X to 0x%X\n", value,
      addr);
  }
#endif

#ifdef NO_DEVMEM
  value = 0;
#else
  *((unsigned *)(FpgaVirtualAddr+addr)) = value;
#ifdef DEBUG
  if (!mute)
  {
    printf("\tFpgaInterfaceWrite32: Wrote 0x%X to 0x%X\n", value, addr);
  }
#endif
#endif
}

void FpgaInterfaceWrite(unsigned addr, unsigned value, unsigned mask,
  bool mute)
{
  unsigned RegValue;

  if (mask == 0xFFFFFFFF)
  {
    FpgaInterfaceWrite32(addr, value, mute);
  }
  else
  {
    FpgaInterfaceRead32(addr, &RegValue, mute);
#ifdef NO_DEVMEM
    RegValue = 0xFFFFFFFF; // Debug value
#endif
    RegValue &= (~mask);
    RegValue |= (value & mask);
    FpgaInterfaceWrite32(addr, RegValue, mute);
  }
}
