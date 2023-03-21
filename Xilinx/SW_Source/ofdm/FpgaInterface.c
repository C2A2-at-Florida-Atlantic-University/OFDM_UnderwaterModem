//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/types.h>
#include "FpgaInterface.h"

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
#else
  if ((FpgaRegDevice = open("/dev/mem", (O_RDWR | O_SYNC))) == -1)
  {
    sprintf(ReturnStatus.ErrString,
      "FpgaInterfaceSetup ERROR: Could not open \"/dev/mem\" ...\n");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    return ReturnStatus;
  }

  if (getuid() == 0)
  {
    // Process is running as root, drop privileges
    printf("Process is running as root\n");
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
#if defined (NO_DEVMEM) || !defined(FFT)
  printf("FpgaInterfaceGetTxBuffer: NO_DEVMEM or ~FFT defined\n");
  return FpgaVirtualAddr;
#else
  printf("FpgaInterfaceGetTxBuffer: ~NO_DEVMEM or FFT defined\n");
  return (unsigned *)(FpgaVirtualAddr+TX_BUFFER_BASE);
#endif
}

unsigned *FpgaInterfaceClearTxBuffer()
{
#ifdef DEBUG
  printf("FpgaInterfaceClearTxBuffer: Clear TX Buffer\n");
#endif
#if defined (NO_DEVMEM) || !defined(FFT)
  printf("FpgaInterfaceClearTxBuffer: NO_DEVMEM or ~FFT defined\n");
  memset(FpgaVirtualAddr, 0, BUFFER_SPAN);
  return FpgaVirtualAddr;
#else
  printf("FpgaInterfaceClearTxBuffer: ~NO_DEVMEM or FFT defined\n");
  memset((unsigned *)(FpgaVirtualAddr+TX_BUFFER_BASE), 0, BUFFER_SPAN);
  return (unsigned *)(FpgaVirtualAddr+TX_BUFFER_BASE);
#endif
}

unsigned *FpgaInterfaceClearRxBuffer()
{
#ifdef DEBUG
  printf("FpgaInterfaceClearRxBuffer: Clear RX Buffer\n");
#endif
#if defined(NO_DEVMEM) || !defined(FFT)
  printf("FpgaInterfaceClearRxBuffer: NO_DEVMEM or ~FFT defined\n");
  memset((unsigned *)(FpgaVirtualAddr+BUFFER_SPAN), 0, BUFFER_SPAN);
  return (unsigned *)(FpgaVirtualAddr+BUFFER_SPAN);
#else
  printf("FpgaInterfaceClearRxBuffer: ~NO_DEVMEM or FFT defined\n");
  memset((unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE), 0, BUFFER_SPAN);
  return(unsigned *)(FpgaVirtualAddr+RX_BUFFER_BASE);
#endif
}

void FpgaInterfaceRead32(unsigned addr, unsigned *pValue)
{
#ifdef READ_DEBUG
  printf("\tFpgaInterfaceRead32: About to read from addr 0x%X\n", addr);
#endif

  //*pValue = *((unsigned *)(FpgaVirtualAddr+addr));

#ifdef DEBUG
#ifdef NO_DEVMEM
  printf("\tFpgaInterfaceRead32: Read 0x%X from 0x%X\n",
    0xFFFFFFFF, addr);
#else
  printf("\tFpgaInterfaceRead32: Read 0x%X from 0x%X\n", *pValue, addr);
#endif
#endif
}

void FpgaInterfaceWrite32(unsigned addr, unsigned value)
{
#ifdef WRITE_DEBUG
  printf("\tFpgaInterfaceWrite32: About to write 0x%X to 0x%X\n", value,
    addr);
#endif

  //*((unsigned *)(FpgaVirtualAddr+addr)) = value;

#ifdef DEBUG
  printf("\tFpgaInterfaceWrite32: Wrote 0x%X to 0x%X\n", value, addr);
#endif
}

void FpgaInterfaceWrite(unsigned addr, unsigned value, unsigned mask)
{
  unsigned RegValue;

#if defined (WRITE_DEBUG) || defined (READ_DEBUG)
  printf("\tFpgaInterfaceWrite: Mask = 0x%X\n", mask);
#endif

  if (mask == 0xFFFFFFFF)
  {
    FpgaInterfaceWrite32(addr, value);
  }
  else
  {
    FpgaInterfaceRead32(addr, &RegValue);
#ifdef NO_DEVMEM
    RegValue = 0xFFFFFFFF; // Debug value
#endif
    RegValue &= (~mask);
    RegValue |= (value & mask);
    FpgaInterfaceWrite32(addr, RegValue);
  }
}
