//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ReturnStatus.h"
#include "Power.h"
#include "TxModulate.h"
#include "TransmitChain.h"
#include "HwInterface.h"
#include "Reyax.h"
#include "math.h"

static int32_T *DucBufferPtr = NULL;

ReturnStatusType PowerPeakDuc(void)
{
  ReturnStatusType ReturnStatus;
  ReturnStatusType ReturnStatus2;
  double Peak, PeakDbfs;

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;

  ReyaxTtyMessageSend(" ");

  Peak = HwInterfaceReadDucPeak();
  PeakDbfs = 10*log10(Peak/pow(2.0,MAX_BITS-1));
  // Mixer supports 16 bit samples but DAC only 14. Extra gain is
  // added before mixer so that at output of mixer data will 
  // be full scale 14 bits -- acounting for some loss in mixer
  PeakDbfs = PeakDbfs - 0.3;

  ReyaxTtyMessageSend("PowerPeakDuc: Peak DUC power: %lf dBFS", PeakDbfs);

  if (PeakDbfs > 0)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, "PowerPeakDuc: ERROR: Over range "
      "detected at DUC.\n");
  }

  ReturnStatus2 = PowerPeakDac();
  if (ReturnStatus2.Status == RETURN_STATUS_FAIL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
  }

  ReyaxTtyMessageSend(" ");

  return ReturnStatus;
}

ReturnStatusType PowerPeakDdc(void)
{
  ReturnStatusType ReturnStatus;
  double Peak, PeakDbfs;

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;

  Peak = HwInterfaceReadDdcPeak();
  PeakDbfs = 10*log10(Peak/pow(2.0,MAX_BITS-1));

  ReyaxTtyMessageSend("PowerPeakDdc: Peak DDC power: %lf dBFS", PeakDbfs);

  if (PeakDbfs > 0)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, "PowerPeakDdc: ERROR: Over range "
      "detected at DDC.\n");
  }

  PowerPeakAdc();

  ReyaxTtyMessageSend(" ");

  return ReturnStatus;
}

ReturnStatusType PowerPeakDac(void)
{
  ReturnStatusType ReturnStatus;
  unsigned MaxVal;
  double MaxValDbfs;

  MaxVal = HwInterfaceReadDacPeak();

  MaxValDbfs = 10*log10(((double)MaxVal)/pow(2.0,MAX_BITS-1));

  ReyaxTtyMessageSend("PowerPeakDac: Peak DAC power: (sample %d) = %lf "
    "dBFS", MaxVal, MaxValDbfs);

  if (MaxValDbfs > 0)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, "PowerPeakDac: ERROR: Over range "
      "detected at DAC. Reboot Modem\n");
    return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void PowerPeakAdc(void)
{
  unsigned MaxVal;
  double MaxValDbfs;

  MaxVal = HwInterfaceReadAdcPeak();

  MaxValDbfs = 10*log10(((double)MaxVal)/pow(2.0,MAX_BITS-1));

  ReyaxTtyMessageSend("PowerPeakAdc: Peak ADC power: (sample %d) = %lf "
    "dBFS", MaxVal, MaxValDbfs);

  if (MaxValDbfs == 0.0)
  {
    ReyaxTtyMessageSend("\tPowerPeakAdc: ERROR: ADC at max range - "
      "clipping signal");
  }
}

ReturnStatusType Power(unsigned Nfft, unsigned CpLen, unsigned 
  OfdmSymbols, double TxGain, unsigned TxSel, int32_T *RxBuffPtr)
{
  ReturnStatusType ReturnStatus;
  long double SumVal = 0.0;
  const long double FullScale = 
    (Nfft+CpLen)*pow(pow(2.0,(double)MAX_BITS-1.0),2.0);
  const long double FullScaleSync =
    (NFFT_ZC)*pow(pow(2.0,(double)MAX_BITS-1.0),2.0);
  double CurrentVal, MaxVal = 0.0, MaxValTotal = -250.0, abs, SyncValDbfs;
  double a, b, a2, b2, SumValDbfs[OfdmSymbols], MaxValDbfs[OfdmSymbols];
  double MaxSyncDbfs, TxGainDb, SumValTotalDbfs = 0.0;
  unsigned Start;
  char Text[4];

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  TxGainDb = 10*log10(TxGain);

  if (TxSel)
  {
    strcpy(Text,"TX");
    Start = NFFT_ZC;
    DucBufferPtr = TxModulateGetTxBuffer();
    for (unsigned ZcSymbolCount=0; ZcSymbolCount<NFFT_ZC; ZcSymbolCount++)
    {
      a = (double)((int16_T)(0x0000FFFF & DucBufferPtr[ZcSymbolCount]));
      b = (double)((int16_T)((0xFFFF0000 & DucBufferPtr[ZcSymbolCount])
        >>16));

      a2 = pow(a,2.0) - pow(b,2.0);
      b2 = 2.0 * a * b;

      abs = sqrt(pow(a2,2.0) + pow(b2,2.0));

      SumVal = SumVal + abs;

      CurrentVal = sqrt(pow(a,2.0)+pow(b,2.0));
      if (CurrentVal > MaxVal)
      {
        MaxVal = CurrentVal;
      }
    }
    SyncValDbfs = 10*log10(SumVal/FullScaleSync);
    MaxSyncDbfs = 10*log10(MaxVal/pow(2,MAX_BITS-1));
    SumVal = 0;
    MaxVal = 0;
  }
  else
  {
    strcpy(Text,"RX");
    SyncValDbfs = 0;
    MaxSyncDbfs = 0;
    Start = 0;
    DucBufferPtr = RxBuffPtr;
  }

  for (unsigned OfdmSymbolCount = 0; OfdmSymbolCount < OfdmSymbols;
    OfdmSymbolCount++)
  { 
    for (unsigned NfftCount = 0; NfftCount < Nfft+CpLen; NfftCount++)
    {
      a = (double)((int16_T)(0x0000FFFF & 
        DucBufferPtr[Start+(OfdmSymbolCount*(Nfft+CpLen))+NfftCount]));
      b = (double)((int16_T)((0xFFFF0000 & 
        DucBufferPtr[Start+(OfdmSymbolCount*(Nfft+CpLen))+NfftCount])
        >>16));

      a2 = pow(a,2.0) - pow(b,2.0);
      b2 = 2.0 * a * b;

      abs = sqrt(pow(a2,2.0) + pow(b2,2.0));
      
      SumVal=SumVal + abs;

      CurrentVal = sqrt(pow(a,2.0)+pow(b,2.0));
      if (CurrentVal > MaxVal)
      {
        MaxVal = CurrentVal;
      }
    }
    SumValDbfs[OfdmSymbolCount] = 10*log10(SumVal/FullScale);
    MaxValDbfs[OfdmSymbolCount] = 10*log10(MaxVal/pow(2,MAX_BITS-1));
    SumVal = 0;
    MaxVal = 0;
  }

  if (TxSel)
  {
    ReyaxTtyMessageSend(" ");
    ReyaxTtyMessageSend("  Sync Symbol:       \tPower: "
      "%8.5lf dBFS \tPeak: %8.5lf dBFS \tPAPR: %8.5lf dB ",
    SyncValDbfs, MaxSyncDbfs, MaxSyncDbfs - SyncValDbfs);
    if (SyncValDbfs > 0 || MaxSyncDbfs > 0)
    {
      ReyaxTtyMessageSend("\tERROR: Power too high");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString, "Power: ERROR: Power too high. "
        "Turning off TX and stopping transmission\n");
    }
  }
  ReyaxTtyMessageSend(" ");
  for (unsigned OfdmSymbolCount = 0; OfdmSymbolCount < OfdmSymbols;
    OfdmSymbolCount++)
  {
    SumValTotalDbfs = SumValTotalDbfs + SumValDbfs[OfdmSymbolCount];
    ReyaxTtyMessageSend("  OFDM Symbol %2d: \tPower: %8.5lf dBFS \t"
      "Peak: %8.5lf dBFS "
      "\tPAPR: %8.5lf dB ",OfdmSymbolCount, SumValDbfs[OfdmSymbolCount],
      MaxValDbfs[OfdmSymbolCount], MaxValDbfs[OfdmSymbolCount] -
      SumValDbfs[OfdmSymbolCount]);
    if (SumValDbfs[OfdmSymbolCount] > 0 ||
      MaxValDbfs[OfdmSymbolCount] > 0)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      if (TxSel)
      {
        sprintf(ReturnStatus.ErrString, "Power: ERROR: Power too high. "
          "Turning off TX and stopping transmission\n");
      }
      else
      {
        sprintf(ReturnStatus.ErrString, "Power: ERROR: Power too high. "
          "Continue demod\n");
      }
      ReyaxTtyMessageSend("\tERROR: Power too high");
    }
    else
    {
      ReyaxTtyMessageSend(" ");
    }
    if (MaxValDbfs[OfdmSymbolCount] > MaxValTotal)
    {
      MaxValTotal = MaxValDbfs[OfdmSymbolCount];
    }
  }

  ReyaxTtyMessageSend(" ");
  if (TxSel)
  {
    if (MaxValTotal < MaxSyncDbfs)
    {
      MaxValTotal = MaxSyncDbfs;
    }
  }

  SumValTotalDbfs = SumValTotalDbfs/OfdmSymbols;
  ReyaxTtyMessageSend("Power: OFDM Frame Avg   dBFS %8.5lf", 
    SumValTotalDbfs);
  ReyaxTtyMessageSend("Power: OFDM Frame Peak  dBFS %8.5lf", MaxValTotal);
  ReyaxTtyMessageSend("Power: OFDM Frame PAPR  dB   %8.5lf\n", 
    MaxValTotal - SumValTotalDbfs);
  ReyaxTtyMessageSend("Power: Current %s gain: %lf (%lf dB), "
    "Recommend Adjustment "
    "by %lf dB (Total: %lf dB)\n", Text, TxGain, TxGainDb,
    -1.0*MaxValTotal, TxGainDb-MaxValTotal);

  return ReturnStatus;
}

void PowerExtraTxGain(double GaindB, unsigned Samples)
{
  double Gain;
  double a, b;

  Gain = pow(10.0,GaindB/10.0);
  DucBufferPtr = TxModulateGetTxBuffer();

  for (unsigned i = 0; i < Samples; i++)
  {
    a = (double)((int16_T)(0x0000FFFF & DucBufferPtr[i])) * Gain;
    b = (double)((int16_T)((0xFFFF0000 & DucBufferPtr[i])>>16));
    DucBufferPtr[i] = ((((__int32_t)b)<<16)&0xFFFF0000)+((__int16_t)a);
  }
}
