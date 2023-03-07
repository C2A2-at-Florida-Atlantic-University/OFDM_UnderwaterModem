//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdbool.h>
#include <math.h>
#include "ReturnStatus.h"
#include "TransmitChain.h"
#include "HwInterface.h"

#define DEBUG

static Calculated_Ofdm_Parameters OfdmCalcParams;

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
  OfdmCalcParams.NfftScaled = ceil(log2(OfdmParams->Nfft));
}

ReturnStatusType TransmitChainEnableDl(bool Continuous, 
  Ofdm_Parameters_Type *OfdmParams, Ofdm_Timing_Type *OfdmTiming)
{
  ReturnStatusType ReturnStatus;
 
  HwInterfaceConfigFftCore(OfdmParams, &OfdmCalcParams, OfdmTiming);
  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

Calculated_Ofdm_Parameters TransmitChainGetParams(void)
{
  return OfdmCalcParams;
}

ReturnStatusType TransmitChainParamCheck(Ofdm_Parameters_Type *OfdmParams)
{
  unsigned Nfft, BandWidth, ModOrder;
  ReturnStatusType ReturnStatus;

  Nfft = OfdmParams->Nfft;
  BandWidth = OfdmParams->BandWidth;
  ModOrder = OfdmParams->ModOrder;

  if (!(Nfft == 128 || Nfft == 256 || Nfft == 512 || Nfft == 1024 ||
    Nfft == 2048 || Nfft == 4096))
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, 
      "\nTransmitChainParamCheck: Not a supported NFFT value\n");
    return ReturnStatus;
  }

  if (!(BandWidth == 25 || BandWidth == 50 || BandWidth == 100 ||
    BandWidth == 150 || BandWidth == 200 || BandWidth == 250))
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "\nTransmitChainParamCheck: Not a supported BandWidth value\n");
    return ReturnStatus;
  }

  if (!(ModOrder == 2 || ModOrder == 4 || ModOrder == 16))
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "\nTransmitChainParamCheck: Not a supported Modulation order\n");
    return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}