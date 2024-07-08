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
#include "Reyax.h"

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
    ReyaxTtyMessageSend("Error unable to "
      "mallox Index");
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
      if (!FirstPilotIsEven)
      {
        FirstPilotIsEven = 1;
      }
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
  ReyaxTtyMessageSend("FirstPilotIsEven %d", FirstPilotIsEven);
  ReyaxTtyMessageSend("\nZP Carriers");
  for (unsigned i = 0; i < OfdmCalcParams.NumZpCarriers; i++)
  {
    ReyaxTtyMessageSend("%d,", ZpIndex[i]+1);
  }
  ReyaxTtyMessageSend("\n");
  ReyaxTtyMessageSend("Pilot Carriers");
  for (unsigned i = 0; i < OfdmCalcParams.NumPilotCarriers; i++)
  {
    ReyaxTtyMessageSend("%d,", PilotIndex[i]+1);
  }
  ReyaxTtyMessageSend("\n");
  ReyaxTtyMessageSend("Data Carriers");
  for (unsigned i = 0; i < OfdmCalcParams.NumDataCarriers; i++)
  {
    ReyaxTtyMessageSend("%d,", DataIndex[i]+1);
  }
  ReyaxTtyMessageSend("\n");
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
  ReyaxTtyMessageSend("%d %d", OfdmParams->Nfft, 
    OfdmTiming->FrameGuardPeriod);
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
  ReyaxTtyMessageSend("\n\n");
  ReyaxTtyMessageSend("Scs %lf", 
    OfdmCalcParams->Scs);
  ReyaxTtyMessageSend("Symbol Samples "
    "%d", OfdmCalcParams->Symbol.Samples);
  ReyaxTtyMessageSend("Symbol "
    "FpgaClkSamples %d\n", OfdmCalcParams->Symbol.FpgaClkSamples);
  ReyaxTtyMessageSend("Symbol Time %lf", 
    OfdmCalcParams->Symbol.Time);
  ReyaxTtyMessageSend("SymbolGuard "
    "Samples %d", OfdmCalcParams->SymbolGuard.Samples);
  ReyaxTtyMessageSend("SymbolGuard "
    "FpgaClkSamples %d", OfdmCalcParams->SymbolGuard.FpgaClkSamples);
  ReyaxTtyMessageSend("Symbol Guard Time "
    "%lf", OfdmCalcParams->SymbolGuard.Time);
  ReyaxTtyMessageSend("FrameGuard Samples "
    "%d", OfdmCalcParams->FrameGuard.Samples);
  ReyaxTtyMessageSend("FrameGuard "
    "FpgaClkSamples %d", OfdmCalcParams->FrameGuard.FpgaClkSamples);
  ReyaxTtyMessageSend("FrameGuard Time "
    "%lf", OfdmCalcParams->FrameGuard.Time);
  ReyaxTtyMessageSend("SymbolDataRate "
    "%lf", OfdmCalcParams->SymbolDataRate);
  ReyaxTtyMessageSend("FrameDataRate "
    "%lf", OfdmCalcParams->FrameDataRate);
  ReyaxTtyMessageSend("NfftScaled %d", 
    OfdmCalcParams->NfftScaled);
  ReyaxTtyMessageSend("FirstPilotCarrier "
    "%d", OfdmCalcParams->FirstPilotCarrier);
  ReyaxTtyMessageSend("LastPilotCarrier "
    "%d", OfdmCalcParams->LastPilotCarrier);
  ReyaxTtyMessageSend("NumDataCarriers "
    "%d", OfdmCalcParams->NumDataCarriers);
  ReyaxTtyMessageSend("NumPilotCarriers "
    "%d", OfdmCalcParams->NumPilotCarriers);
  ReyaxTtyMessageSend("NumZpCarriers %d",
    OfdmCalcParams->NumZpCarriers);
  ReyaxTtyMessageSend("\n");
}

