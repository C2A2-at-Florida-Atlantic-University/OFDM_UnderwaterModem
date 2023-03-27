//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef DAC_CHAIN_H_INCLUDED
#define DAC_CHAIN_H_INCLUDED

#include <stdbool.h>
#include "ReturnStatus.h"

#define DEFAULT_CENTER_FREQUENCY_KHZ 250

#define DAC_SAMPLE_RATE_KHZ 10000 // 10 Msps

#define CENTER_FREQUENCY_KHZ_MAX 400
#define CENTER_FREQUENCY_KHZ_MIN 100

typedef struct {
  unsigned BandWidth;
  unsigned Fs;
  unsigned Interp;
  unsigned Fc;
} Dac_Parameters_Type;

ReturnStatusType DacChainSetDacParams(unsigned BandWidth, unsigned Fc);
ReturnStatusType DacChainUpConversion(bool DebugMode, unsigned FileNumber);
Dac_Parameters_Type DacChainGetDacParams(void);

#endif
