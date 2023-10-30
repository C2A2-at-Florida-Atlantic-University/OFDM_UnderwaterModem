//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef POWER_H_INCLUDED
#define POWER_H_INCLUDED

#include "ReturnStatus.h"
#include "TxModulate.h"

ReturnStatusType PowerPeakDuc(void);
ReturnStatusType PowerPeakDac(void);
ReturnStatusType PowerPeakDdc(void);
ReturnStatusType PowerPeakAdc(void);
ReturnStatusType Power(unsigned Nfft, unsigned CpLen, unsigned
  OfdmSymbols, double TxGain, unsigned TxSel, int32_T *RxBuffPtr);
void PowerExtraTxGain(double GaindB, unsigned Samples);

#endif
