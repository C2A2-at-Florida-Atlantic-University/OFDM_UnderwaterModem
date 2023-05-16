//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef DAC_CHAIN_H_INCLUDED
#define DAC_CHAIN_H_INCLUDED

#include <stdbool.h>
#include "ReturnStatus.h"
#include "g_Interp.h"

#define DEFAULT_CENTER_FREQUENCY_KHZ 250

#define DAC_SAMPLE_RATE_KHZ 10000 // 10 Msps
#define ADC_SAMPLE_RATE_KHZ 40000 // 40 Msps

#define CENTER_FREQUENCY_KHZ_MAX 500
#define CENTER_FREQUENCY_KHZ_MIN 10

typedef struct {
  unsigned BandWidth;
  unsigned Fs;
  unsigned Interp;
  unsigned Fc;
} Dac_Parameters_Type;

typedef struct {
  unsigned DacInterpolation;
  unsigned AdcDecimation;
  unsigned FcDds;
  unsigned FcDdsAdc;
} Hw_Parameters_Type;

ReturnStatusType DacChainSetDacParams(unsigned BandWidth, unsigned Fc,
  bool Configure);
ReturnStatusType DacChainUpConversion(bool DebugMode, unsigned FileNumber,
  unsigned Nfft, unsigned CpLen, unsigned BandWidth, unsigned OfdmSymbols);
Dac_Parameters_Type DacChainGetDacParams(void);
int16_t *DacChainGetDMABuff(void);
void DacChainClearDMABuff(void);
void DacChainSetLoopback(unsigned Loop);
void DacChainSetLoopbackSync(unsigned Loop);

#endif
