//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/types.h>
#include "FpgaInterface.h"

#define DEBUG
#define READ_DEBUG
#define WRITE_DEBUG
#define NO_DEVMEM

static int FpgaRegDevice;
static void *FpgaVirtualAddr;

ReturnStatusType FpgaInterfaceSetup(void)
{
  ReturnStatusType ReturnStatus;
 
#ifndef NO_DEVMEM
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
