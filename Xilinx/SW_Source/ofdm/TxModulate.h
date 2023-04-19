//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////

#ifndef TX_MODULATE_H_INCLUDED
#define TX_MODULATE_H_INCLUDED

#include "ReturnStatus.h"
#include "rtwtypes.h"
#include "TransmitChain.h"

#define DEFAULT_DIGITAL_GAIN_DBFS -25
#define MAX_SAMPLE_VALUE ((1 << 14)-1) // 14 bit IQ
#define IFFT_CONJUGATE 0x1

#define NFFT_DEBUG_COUNT 16

ReturnStatusType TxModulateGetFileData(unsigned FileNumber);
ReturnStatusType TxModulateGetPilotData(unsigned ModOrder);
ReturnStatusType TxModulateFileData(unsigned ModOrder, unsigned Nfft,
  unsigned OfdmSymbols, Calculated_Ofdm_Parameters *OfdmCalcParams);

void             TxModulatePrintCrealType(creal_T Data);
ReturnStatusType TxModulateDigitalGain(int GainDB);
uint16_T         TxModulateGetScalarGain(void);
ReturnStatusType TxModulateWriteToFile(unsigned FileNumber,
  Ofdm_Parameters_Type *OfdmParams, unsigned OfdmSymbols);

void TxModulateClose(void);
uint16_T TxModulateGetDigitalGain(void);
ReturnStatusType TxModulateIfft(bool DebugMode, unsigned FileNumber,
  unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols);

#ifdef DUC
int32_T *TxModulateGetTxBuffer(void);
#endif
#ifdef DAC
creal_T *TxModulateGetTxBuffer(void);
#endif
void TxModulateFreeTxBuffer(void);

#endif
