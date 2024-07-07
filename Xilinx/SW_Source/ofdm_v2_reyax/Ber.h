//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////

#ifndef BER_H_INCLUDED
#define BER_H_INCLUDED

#include "ReturnStatus.h"
#include "TransmitChain.h"

double BerCharCalculation(const char tx, const char rx);
ReturnStatusType Ber(bool Ber, unsigned ModOrder, unsigned OfdmSymbols,
  Calculated_Ofdm_Parameters *OfdmCalcParams);
ReturnStatusType BerOpenFiles(bool Ber, unsigned ModOrder);

#endif
