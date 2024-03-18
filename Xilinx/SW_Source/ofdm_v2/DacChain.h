//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef DAC_CHAIN_H_INCLUDED
#define DAC_CHAIN_H_INCLUDED

#include <stdbool.h>
#include "ReturnStatus.h"
#include "rtwtypes.h"

#define DEFAULT_CENTER_FREQUENCY_KHZ 275

#define DAC_SAMPLE_RATE_KHZ 10000 // 10 Msps
#define ADC_SAMPLE_RATE_KHZ 40000 // 40 Msps

#define CENTER_FREQUENCY_KHZ_MAX 550
#define CENTER_FREQUENCY_KHZ_MIN 0

typedef struct {
  double BandWidth;
  double Fs;
  unsigned Interp;
  unsigned Fc;
} Dac_Parameters_Type;

typedef struct {
  unsigned DacInterpolation;
  unsigned AdcDecimation;
  unsigned FcDds;
  unsigned FcDdsAdc;
} Hw_Parameters_Type;

ReturnStatusType DacChainSetDacParams(double BandWidth, unsigned Fc,
  bool Configure);
ReturnStatusType DacChainUpConversion(bool DebugMode, unsigned FileNumber,
  unsigned Nfft, unsigned CpLen, double BandWidth, unsigned OfdmSymbols);
Dac_Parameters_Type DacChainGetDacParams(void);
int16_T *DacChainGetDMABuff(void);
void DacChainClearDMABuff(void);

#endif
