//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////

#ifndef EQUALIZER_H_INCLUDED
#define EQUALIZER_H_INCLUDED

#include "ReturnStatus.h"
#include "rtwtypes.h"
#include <stdbool.h>

ReturnStatusType EqualizerChannelEstimate(bool DebugMode, unsigned
  ModOrder, creal32_T TxPilot, creal32_T *ChEst, unsigned Index);
ReturnStatusType EqualizerChFileOpen(unsigned FileNumber);
ReturnStatusType EqualizerTxPilotOpen(unsigned ModOrder);
void EqualizerChFileClose(void);
void EqualizerData(creal32_T ChEst, creal32_T Data,
  creal32_T *Result);

#endif
