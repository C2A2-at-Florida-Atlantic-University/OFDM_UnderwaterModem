//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////

#ifndef BER_H_INCLUDED
#define BER_H_INCLUDED

#include "ReturnStatus.h"

double BerCharCalculation(const char tx, const char rx);
ReturnStatusType Ber(bool Ber, unsigned FileNumber, unsigned ModOrder,
  unsigned Nfft, unsigned OfdmSymbols);
ReturnStatusType BerOpenFiles(bool Ber, unsigned FileNumber);

#endif
