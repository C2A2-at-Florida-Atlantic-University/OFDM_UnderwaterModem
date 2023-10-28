//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include "ReturnStatus.h"
#include "TransmitChain.h"
#include "HwInterface.h"

#define DEBUG
//#define INDEX_DEBUG

static Calculated_Ofdm_Parameters OfdmCalcParams;

// Index starts at 0 (0:Nfft-1)
static unsigned *ZpIndex = NULL;
static unsigned *PilotIndex = NULL;
static unsigned *DataIndex = NULL;

unsigned *TransmitChainZpIndex(void)
{
  return ZpIndex;
}

unsigned *TransmitChainPilotIndex(void)
{
  return PilotIndex;
}

unsigned *TransmitChainDataIndex(void)
{
  return DataIndex;
}

void TransmitChainCalcParams(Ofdm_Parameters_Type *OfdmParams, 
  Ofdm_Timing_Type *OfdmTiming)
{
  unsigned FirstPilotIsEven;
  if (ZpIndex != NULL)
  {
    free(ZpIndex);
    free(PilotIndex);
    free(DataIndex);
  }
  ZpIndex = (unsigned *)malloc(MAX_NFFT*4);
  PilotIndex = (unsigned *)malloc(MAX_NFFT*4);
  DataIndex = (unsigned *)malloc(MAX_NFFT*4);
  if (ZpIndex==NULL||PilotIndex==NULL||DataIndex==NULL)
  {
    printf("TransmitChainCalcParams: Error unable to mallox Index\n");
  }
  memset(ZpIndex, 0, MAX_NFFT*4);
  memset(PilotIndex, 0, MAX_NFFT*4);
  memset(DataIndex, 0, MAX_NFFT*4);

  OfdmCalcParams.Scs = 
    OfdmParams->BandWidth/(double)OfdmParams->Nfft*1000.0;

  OfdmCalcParams.Symbol.Samples = OfdmParams->Nfft+OfdmParams->CpLen;

  OfdmCalcParams.Symbol.Time = 
    1.0/OfdmParams->BandWidth*
    (double)OfdmCalcParams.Symbol.Samples;

  OfdmCalcParams.Symbol.FpgaClkSamples = (unsigned)((double)FpgaClkRate/
    (OfdmParams->BandWidth*1000.0));

  OfdmCalcParams.NumZpCarriers = floor((double)OfdmParams->Nfft*
    (double)OfdmParams->ZpDensity/100.0/2.0)*2.0;
  // Acount for 2 SC's at DC
  OfdmCalcParams.NumZpCarriers = OfdmCalcParams.NumZpCarriers + 2;

  OfdmCalcParams.NumPilotCarriers = 0;
  OfdmCalcParams.NumDataCarriers = 0;
  if ((OfdmCalcParams.NumZpCarriers/2-1) % 2 == 0)
  { // First Pilot Carrier is Even
    FirstPilotIsEven = 1;
  }
  else
  {
    FirstPilotIsEven = 0;
  }

  // Sub-carrier Allocation
  for (unsigned i = 0; i < OfdmParams->Nfft; i++)
  {
    if (i < OfdmCalcParams.NumZpCarriers/2 - 1)
    { // Lower ZP guard band
      ZpIndex[i] = i;
    }
    else if (i == OfdmParams->Nfft/2-1)
    { // First ZP sub-carrier at DC
      ZpIndex[OfdmCalcParams.NumZpCarriers/2-1] = i;
    }
    else if (i == OfdmParams->Nfft/2)
    { // Second ZP sub-carrier at DC
      ZpIndex[OfdmCalcParams.NumZpCarriers/2] = i;
    }
    else if (i >= OfdmParams->Nfft-OfdmCalcParams.NumZpCarriers/2+1)
    { // Upper ZP guard band
      ZpIndex[i+OfdmCalcParams.NumZpCarriers-OfdmParams->Nfft] = i;
    }
    else if (i == OfdmParams->Nfft/2-2)
    { // Last Pilot before DC
      PilotIndex[OfdmCalcParams.NumPilotCarriers] = i;
      OfdmCalcParams.NumPilotCarriers=OfdmCalcParams.NumPilotCarriers+1;
    }
    else if (i == OfdmParams->Nfft-OfdmCalcParams.NumZpCarriers/2)
    { // Last Pilot before upper ZP guard band
      PilotIndex[OfdmCalcParams.NumPilotCarriers] = i;
      OfdmCalcParams.NumPilotCarriers=OfdmCalcParams.NumPilotCarriers+1;
    }
    else if (i < OfdmParams->Nfft/2)
    { // Lower half of sub-carriers
      if (i%2 != FirstPilotIsEven)
      { // Pilot
        PilotIndex[OfdmCalcParams.NumPilotCarriers] = i;
        OfdmCalcParams.NumPilotCarriers=OfdmCalcParams.NumPilotCarriers+1;
      }
      else
      { // Data
        DataIndex[OfdmCalcParams.NumDataCarriers] = i;
        OfdmCalcParams.NumDataCarriers=OfdmCalcParams.NumDataCarriers+1;
      }
    }
    else if (i > OfdmParams->Nfft/2)
    { // Upper half of sub-carriers
      if (i%2 == FirstPilotIsEven)
      { // Pilot
        PilotIndex[OfdmCalcParams.NumPilotCarriers] = i;
        OfdmCalcParams.NumPilotCarriers=OfdmCalcParams.NumPilotCarriers+1;
      }
      else
      { // Data
        DataIndex[OfdmCalcParams.NumDataCarriers] = i;
        OfdmCalcParams.NumDataCarriers=OfdmCalcParams.NumDataCarriers+1;
      }
    }
  }

#ifdef INDEX_DEBUG
  printf("FirstPilotIsEven %d\n", FirstPilotIsEven);
  printf("\nZP Carriers\n");
  for (unsigned i = 0; i < OfdmCalcParams.NumZpCarriers; i++)
  {
    printf("%d,", ZpIndex[i]+1);
  }
  printf("\n\n");
  printf("Pilot Carriers\n");
  for (unsigned i = 0; i < OfdmCalcParams.NumPilotCarriers; i++)
  {
    printf("%d,", PilotIndex[i]+1);
  }
  printf("\n\n");
  printf("Data Carriers\n");
  for (unsigned i = 0; i < OfdmCalcParams.NumDataCarriers; i++)
  {
    printf("%d,", DataIndex[i]+1);
  }
  printf("\n\n");
#endif

  OfdmCalcParams.FirstPilotCarrier = PilotIndex[0];

  OfdmCalcParams.LastPilotCarrier = PilotIndex[
    OfdmCalcParams.NumPilotCarriers-1];

  OfdmCalcParams.SymbolDataRate = 
    (double)OfdmCalcParams.NumDataCarriers*
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

ReturnStatusType TransmitChainEnableDl( 
  Ofdm_Parameters_Type *OfdmParams, Ofdm_Timing_Type *OfdmTiming)
{
  ReturnStatusType ReturnStatus;

#ifdef FFT
  HwInterfaceConfigTxChain(OfdmParams, &OfdmCalcParams, OfdmTiming);
  HwInterfaceConfigFftCore();
  HwInterfaceStartTx();

  HwInterfaceStopTx();
#else // Get rid of compile warnings
  printf("%d %d\n", OfdmParams->Nfft, OfdmTiming->FrameGuardPeriod);
#endif


  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

Calculated_Ofdm_Parameters TransmitChainGetParams(void)
{
  return OfdmCalcParams;
}

ReturnStatusType TransmitChainParamCheck(Ofdm_Parameters_Type *OfdmParams)
{
  unsigned Nfft, ModOrder, CpLen;
  double BandWidth;
  ReturnStatusType ReturnStatus;

  Nfft = OfdmParams->Nfft;
  BandWidth = OfdmParams->BandWidth;
  CpLen = OfdmParams->CpLen;
  ModOrder = OfdmParams->ModOrder;

  if (!(Nfft == 128 || Nfft == 256 || Nfft == 512 || Nfft == 1024 ||
    Nfft == 2048 || Nfft == 4096 || Nfft == 8192 || Nfft == 16384))
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, 
      "\nTransmitChainParamCheck: Not a supported NFFT value\n");
    return ReturnStatus;
  }

  if (!(BandWidth == 25.0 || BandWidth == 50.0 || BandWidth == 100.0 ||
    BandWidth == 150.0 || BandWidth == 200.0 || BandWidth == 250.0 ||
    BandWidth == 312.5))
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "\nTransmitChainParamCheck: Not a supported BandWidth value\n");
    return ReturnStatus;
  }

  if (CpLen > 4096)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "\nTransmitChainParamCheck: Not a supported CP LEN value\n");
    return ReturnStatus;
  }

  if (!(ModOrder == 2 || ModOrder == 4 || ModOrder == 8 || ModOrder == 16))
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "\nTransmitChainParamCheck: Not a supported Modulation order\n");
    return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void TransmitChainPrintCalcParams(Calculated_Ofdm_Parameters
  *OfdmCalcParams)
{
  printf("\n\n");
  printf("TransmitChainPrintCalcParams: Scs %lf\n", OfdmCalcParams->Scs);
  printf("TransmitChainPrintCalcParams: Symbol Samples %d\n", 
    OfdmCalcParams->Symbol.Samples);
  printf("TransmitChainPrintCalcParams: Symbol FpgaClkSamples %d\n", 
    OfdmCalcParams->Symbol.FpgaClkSamples);
  printf("TransmitChainPrintCalcParams: Symbol Time %lf\n", 
    OfdmCalcParams->Symbol.Time);
  printf("TransmitChainPrintCalcParams: SymbolGuard Samples %d\n", 
    OfdmCalcParams->SymbolGuard.Samples);
  printf("TransmitChainPrintCalcParams: SymbolGuard FpgaClkSamples %d\n", 
    OfdmCalcParams->SymbolGuard.FpgaClkSamples);
  printf("TransmitChainPrintCalcParams: Symbol Guard Time %lf\n", 
    OfdmCalcParams->SymbolGuard.Time);
  printf("TransmitChainPrintCalcParams: FrameGuard Samples %d\n", 
    OfdmCalcParams->FrameGuard.Samples);
  printf("TransmitChainPrintCalcParams: FrameGuard FpgaClkSamples %d\n", 
    OfdmCalcParams->FrameGuard.FpgaClkSamples);
  printf("TransmitChainPrintCalcParams: FrameGuard Time %lf\n", 
    OfdmCalcParams->FrameGuard.Time);
  printf("TransmitChainPrintCalcParams: SymbolDataRate %lf\n", 
    OfdmCalcParams->SymbolDataRate);
  printf("TransmitChainPrintCalcParams: FrameDataRate %lf\n", 
    OfdmCalcParams->FrameDataRate);
  printf("TransmitChainPrintCalcParams: NfftScaled %d\n", 
    OfdmCalcParams->NfftScaled);
  printf("TransmitChainPrintCalcParams: FirstPilotCarrier %d\n",
    OfdmCalcParams->FirstPilotCarrier);
  printf("TransmitChainPrintCalcParams: LastPilotCarrier %d\n",
    OfdmCalcParams->LastPilotCarrier);
  printf("TransmitChainPrintCalcParams: NumDataCarriers %d\n",
    OfdmCalcParams->NumDataCarriers);
  printf("TransmitChainPrintCalcParams: NumPilotCarriers %d\n",
    OfdmCalcParams->NumPilotCarriers);
  printf("TransmitChainPrintCalcParams: NumZpCarriers %d\n",
    OfdmCalcParams->NumZpCarriers);
  printf("\n\n");
}

