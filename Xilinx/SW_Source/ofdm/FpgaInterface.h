//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef FPGA_INTERFACE_H_INCLUDED
#define FPGA_INTERFACE_H_INCLUDED

#include "ReturnStatus.h"

#define FPGA_REG_SPAN (1<<29)
#define FPGA_REG_BASE_ADDR  (0x0)

#define TX_BUFFER_BASE 0x1F000000
#define RX_BUFFER_BASE 0x1F080000
#ifdef FFT
#define BUFFER_SPAN 0x3FFFF // (4096 carriers * 16 symbols max)
#endif
#ifdef DUC
#define BUFFER_SPAN 0x7FFFF // ((4096 carriers + 4096 cp) * 16 symbols max)
#endif


ReturnStatusType FpgaInterfaceSetup(void);
unsigned *FpgaInterfaceClearTxBuffer(void);
unsigned *FpgaInterfaceClearRxBuffer(void);
void FpgaInterfaceRead32(unsigned addr, unsigned *pValue);
void FpgaInterfaceWrite32(unsigned addr, unsigned value);
void FpgaInterfaceWrite(unsigned addr, unsigned value, unsigned mask);
unsigned *FpgaInterfaceGetTxBuffer(void);

#endif
