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

#define RX_BUFFER_BASE0 0x1F080000
#define RX_BUFFER_BASE1 0x1F100000
#define RX_BUFFER_BASE2 0x1F180000

#define RELOAD_BUFFER_BASE 0x1F200000

#ifdef NO_DEVMEM
#define BUFFER_SPAN 0x3FFFFF
#else
// ((4096 carriers + 4096 cp) * 16 symbols max * 4(int32))
#define BUFFER_SPAN 0x7FFFF // Contains int32 samples
#endif

// RX Buffers get filled continuously. Read and process one
// while the other gets filled
#define RX_BUFFER_0 0
#define RX_BUFFER_1 1
#define RX_BUFFER_2 2

ReturnStatusType FpgaInterfaceSetup(void);
unsigned *FpgaInterfaceClearTxBuffer(void);
unsigned *FpgaInterfaceGetRxBuffer(unsigned BufferSelect);
unsigned *FpgaInterfaceClearRxBuffer(unsigned BufferSelect);
void FpgaInterfaceRead32(unsigned addr, unsigned *pValue, bool mute);
void FpgaInterfaceWrite32(unsigned addr, unsigned value, bool mute);
void FpgaInterfaceWrite(unsigned addr, unsigned value, unsigned mask,
  bool mute);
unsigned *FpgaInterfaceGetTxBuffer(void);
unsigned *FpgaInterfaceGetReloadBuffer(void);

#endif
