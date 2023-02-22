//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <math.h>
#include "ReturnStatus.h"
#include "TransmitChain.h"

#define DEBUG

Calculated_Ofdm_Parameters OfdmCalcParams;

void TransmitChainCalcParams(Ofdm_Parameters_Type
  *OfdmParams, Ofdm_Timing_Type *OfdmTiming)
{
  OfdmCalcParams.Scs = 
    (double)OfdmParams->BandWidth/(double)OfdmParams->Nfft*1000.0;
  OfdmCalcParams.Symbol.Samples = OfdmParams->Nfft+OfdmParams->CpLen;
  OfdmCalcParams.Symbol.Time = 
    1.0/(double)OfdmParams->BandWidth*
    (double)OfdmCalcParams.Symbol.Samples;
  OfdmCalcParams.SymbolDataRate = 
    (double)(1.0-(double)PILOT_DENSITY)*(double)OfdmParams->Nfft*
    log2(OfdmParams->ModOrder)/OfdmCalcParams.Symbol.Time;
  OfdmCalcParams.FrameDataRate = OfdmCalcParams.SymbolDataRate*
    (1.0-(double)OfdmTiming->SymbolGuardPeriod/
    ((double)OfdmTiming->SymbolGuardPeriod+OfdmCalcParams.Symbol.Time));

  printf("\n");
  printf("\tSCS:                 %lf Hz\n", OfdmCalcParams.Scs);
  printf("\tSamples per Symbol:  %d\n", OfdmCalcParams.Symbol.Samples);
  printf("\tSymbol Period:       %lf ms\n", OfdmCalcParams.Symbol.Time);
  printf("\tSymbol Data Rate:    %lf kbit/sec\n", 
    OfdmCalcParams.SymbolDataRate);
  printf("\tFrame Data Rate:     %lf kbit/sec\n",
    OfdmCalcParams.FrameDataRate);
}
