//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef FPGA_INTERFACE_H_INCLUDED
#define FPGA_INTERFACE_H_INCLUDED

#include "ReturnStatus.h"

#define FPGA_REG_SPAN (1<<29)
#define FPGA_REG_BASE_ADDR  (0x0)

ReturnStatusType FpgaInterfaceSetup(void);
void FpgaInterfaceRead32(unsigned addr, unsigned *pValue);
void FpgaInterfaceWrite32(unsigned addr, unsigned value);
void FpgaInterfaceWrite(unsigned addr, unsigned value, unsigned mask);

#endif
