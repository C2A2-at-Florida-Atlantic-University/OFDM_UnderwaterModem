//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef FPGA_INTERFACE_H_INCLUDED
#define FPGA_INTERFACE_H_INCLUDED

#include <stdbool.h>
#include "ReturnStatus.h"

#define DDR_REG_SPAN (1<<29) // Entire 512 MB of memory
#define FPGA_REG_SPAN (1<<31) // Covers FPGA IP address range
#define FPGA_REG_BASE_ADDR  (0x0)

#define TX_BUFFER_BASE  0x1F000000
#define BUFFER_SPAN 0x13FFFF // Contains int32 samples

ReturnStatusType FpgaInterfaceSetup(void);
void FpgaInterfaceRead32(unsigned addr, unsigned *pValue, bool mute);
void FpgaInterfaceWrite32(unsigned addr, unsigned value, bool mute);
void FpgaInterfaceWrite(unsigned addr, unsigned value, unsigned mask,
  bool mute);

#endif
