//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef FPGA_INTERFACE_H_INCLUDED
#define FPGA_INTERFACE_H_INCLUDED

#include "ReturnStatus.h"

#define FPGA_REG_SPAN (1<<29)
#define FPGA_REG_BASE_ADDR  (0x0)

#define TX_BUFFER_BASE 0x1F000000
#define RX_BUFFER_BASE 0x1F040000
#define BUFFER_SPAN 0x3FFFF // (4096 carriers * 16 symbols)


ReturnStatusType FpgaInterfaceSetup(void);
unsigned *FpgaInterfaceClearTxBuffer(void);
unsigned *FpgaInterfaceClearRxBuffer(void);
void FpgaInterfaceRead32(unsigned addr, unsigned *pValue);
void FpgaInterfaceWrite32(unsigned addr, unsigned value);
void FpgaInterfaceWrite(unsigned addr, unsigned value, unsigned mask);
unsigned *FpgaInterfaceGetTxBuffer(void);

#endif
