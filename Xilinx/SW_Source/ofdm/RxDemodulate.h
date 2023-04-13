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
  unsigned FileNumber;
  unsigned ModOrder;
  unsigned Nfft;
  unsigned CpLen;
  unsigned OfdmSymbols;
  Calculated_Ofdm_Parameters *OfdmCalcParams;
  bool SwSync;
};

ReturnStatusType RxDemodulateBufferData(bool DebugMode,
  unsigned LoopMethod, unsigned FileNumber, unsigned ModOrder, 
  unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols,
  Calculated_Ofdm_Parameters *OfdmCalcParams, bool SwSync);
ReturnStatusType RxDemodulateFileData(char *FileName);
ReturnStatusType RxDemodulateRecoverMessage(unsigned FileNumber,
  unsigned ModOrder, unsigned Nfft, unsigned OfdmSymbols);
void RxDemodulatePrintCrealType(creal32_T Data);
ReturnStatusType RxDemodulateWriteToFile(bool open, unsigned FileNumber);
ReturnStatusType RxDemodulateFft(bool DebugMode, unsigned LoopMethod,
  unsigned FileNumber, unsigned Nfft, unsigned CpLen, 
  unsigned OfdmSymbols);
ReturnStatusType RxDemodulateCreateThread(bool DebugMode, unsigned
  FileNumber, unsigned ModOrder, unsigned Nfft, unsigned CpLen,
  unsigned OfdmSymbols, Calculated_Ofdm_Parameters *OfdmCalcParams,
  bool SwSync);
void *RxDemodulateThread(void *arg);
void RxDemodulateCancelThread(void);
int32_T *RxDemodulateGetCurrentDmaBuffer(void);
ReturnStatusType RxDemodulateCheckThreadRunning(void);

#endif
