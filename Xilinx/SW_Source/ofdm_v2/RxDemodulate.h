//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////

#ifndef RX_MODULATE_H_INCLUDED
#define RX_MODULATE_H_INCLUDED

#include "ReturnStatus.h"
#include "TransmitChain.h"
#include <stdbool.h>
#include "rtwtypes.h"

#define RX_DEMODULATE_DMA_BUFF 0
#define RX_DEMODULATE_TX_LOOPBACK 1
#define RX_DEMODULATE_FILE_INJECTION 2

struct thread_args {
  bool DebugMode;
  bool Sym1;
  unsigned ModOrder;
  unsigned Nfft;
  unsigned CpLen;
  unsigned OfdmSymbols;
  unsigned LoopBackBytes;
  Calculated_Ofdm_Parameters *OfdmCalcParams;
};

ReturnStatusType RxDemodulateBufferData(bool DebugMode, bool DeleteSym1,
  unsigned ModOrder, unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols);
ReturnStatusType RxDemodulateRecoverMessage(unsigned FileNumber,
  unsigned ModOrder, unsigned Nfft, unsigned OfdmSymbols);
void RxDemodulatePrintCrealType(creal32_T Data);
ReturnStatusType RxDemodulateFft(bool DebugMode, bool DeleteSym1,
  unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols);
ReturnStatusType RxDemodulateCreateThread(bool DebugMode, unsigned 
  ModOrder, unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols,
  Calculated_Ofdm_Parameters *OfdmCalcParams, bool DeleteSym1,
  unsigned LoopBackBytes);
void *RxDemodulateThread(void *arg);
void RxDemodulateCancelThread(void);
int32_T *RxDemodulateGetCurrentDmaBuffer(void);
ReturnStatusType RxDemodulateCheckThreadRunning(void);
ReturnStatusType RxDemodulateSaveRawAdcSamples(unsigned LoopBackBytes);

#endif
