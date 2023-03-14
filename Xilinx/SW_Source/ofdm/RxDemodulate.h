//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////

#ifndef RX_MODULATE_H_INCLUDED
#define RX_MODULATE_H_INCLUDED

#include "ReturnStatus.h"
#include <stdbool.h>
#include "rtwtypes.h"

ReturnStatusType RxDemodulateBufferData(bool Loopback,
  unsigned FileNumber, unsigned ModOrder, unsigned Nfft, 
  unsigned OfdmSymbols);
ReturnStatusType RxDemodulateFileData(char *FileName);

#endif
