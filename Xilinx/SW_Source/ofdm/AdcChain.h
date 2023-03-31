//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef ADC_CHAIN_H_INCLUDED
#define ADC_CHAIN_H_INCLUDED

#include <stdbool.h>
#include "ReturnStatus.h"
#include "DacChain.h"

ReturnStatusType AdcChainDownConversion(bool DebugMode, unsigned 
  FileNumber, unsigned Nfft, unsigned CpLen, unsigned BandWidth,
  unsigned OfdmSymbols);

#endif
