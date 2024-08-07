//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////

#ifndef TX_MODULATE_H_INCLUDED
#define TX_MODULATE_H_INCLUDED

#include "ReturnStatus.h"
#include "rtwtypes.h"
#include "TransmitChain.h"

#define DEFAULT_FREQ_DIGITAL_GAIN_DBFS -4
#define DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB -12.0//For 4096 OFDM 16 Mod

//#define DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB 27.0//For 1024 OFDM 2 Mod
//#define DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB 23.0//For 1024 OFDM 4 Mod
//#define DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB 15.0//For 1024 OFDM 16 Mod
#define DEFAULT_ADDITIONAL_SYNCHRONIZATION_GAIN_DB 5.0

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
void             TxModulateSetIfftGain(double GainDB);
double           TxModulateGetIfftGain();
void             TxModulateSetSyncGain(double GainDB);
double           TxModulateGetSyncGain();
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
