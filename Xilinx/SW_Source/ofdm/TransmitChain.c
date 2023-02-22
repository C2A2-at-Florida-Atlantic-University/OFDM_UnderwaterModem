//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <math.h>
#include "ReturnStatus.h"
#include "TransmitChain.h"
#include "HwInterface.h"

#define DEBUG

Calculated_Ofdm_Parameters OfdmCalcParams;

void TransmitChainCalcParams(Ofdm_Parameters_Type *OfdmParams, 
  Ofdm_Timing_Type *OfdmTiming)
{
  OfdmCalcParams.Scs = 
    (double)OfdmParams->BandWidth/(double)OfdmParams->Nfft*1000.0;
  OfdmCalcParams.Symbol.Samples = OfdmParams->Nfft+OfdmParams->CpLen;
  OfdmCalcParams.Symbol.Time = 
    1.0/(double)OfdmParams->BandWidth*
    (double)OfdmCalcParams.Symbol.Samples;
  OfdmCalcParams.Symbol.FpgaClkSamples = FpgaClkRate/
    OfdmParams->BandWidth/1000;
  OfdmCalcParams.SymbolDataRate = 
    (double)(1.0-(double)PILOT_DENSITY)*(double)OfdmParams->Nfft*
    log2(OfdmParams->ModOrder)/OfdmCalcParams.Symbol.Time;
  OfdmCalcParams.FrameDataRate = OfdmCalcParams.SymbolDataRate*
    (1.0-(double)OfdmTiming->SymbolGuardPeriod/
    ((double)OfdmTiming->SymbolGuardPeriod+OfdmCalcParams.Symbol.Time));
  OfdmCalcParams.SymbolGuard.FpgaClkSamples = FpgaClkRate*
    OfdmTiming->SymbolGuardPeriod/1000;
  OfdmCalcParams.FrameGuard.FpgaClkSamples = FpgaClkRate*
    OfdmTiming->FrameGuardPeriod/1000;
}

Calculated_Ofdm_Parameters TransmitChainGetParams(void)
{
  return OfdmCalcParams;
}
