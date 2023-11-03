//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////

#ifndef TX_MODULATE_H_INCLUDED
#define TX_MODULATE_H_INCLUDED

#include "ReturnStatus.h"
#include "rtwtypes.h"
#include "TransmitChain.h"

#define DEFAULT_FREQ_DIGITAL_GAIN_DBFS -7
#define DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB 4.915 //For 4096 OFDM 16 Mod

//#define DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB 27.0//For 1024 OFDM 2 Mod
//#define DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB 23.0//For 1024 OFDM 4 Mod
//#define DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB 15.0//For 1024 OFDM 16 Mod
#define DEFAULT_ADDITIONAL_SYNCHRONIZATION_GAIN_DB 5.7

#define MAX_BITS 14
#define MAX_FREQ_BITS 16
#define MAX_SAMPLE_VALUE ((1 << MAX_BITS)-1) // 14 bit IQ
#define MAX_FREQ_SAMPLE_VALUE ((1 << MAX_FREQ_BITS)-1) // 14 bit IQ
#define IFFT_CONJUGATE 0x1

#define NFFT_DEBUG_COUNT 16

ReturnStatusType TxAllocateGetPilotData(unsigned ModOrder);
ReturnStatusType TxAllocateQamFileData(unsigned ModOrder, unsigned Nfft,
  unsigned OfdmSymbols);

void             TxModulatePrintCrealType(creal_T Data);
ReturnStatusType TxModulateDigitalGain(int GainDB);
uint16_T         TxModulateGetScalarGain(void);
void             TxModulateSetIfftGain(double GainDB);
double           TxModulateGetIfftGain();
void             TxModulateSetSyncGain(double GainDB);
double           TxModulateGetSyncGain();

void TxModulateClose(void);
uint16_T TxModulateGetDigitalGain(void);
ReturnStatusType TxModulateIfft(bool DebugMode, unsigned Nfft,
  unsigned ModOrder, unsigned CpLen, unsigned OfdmSymbols,
  unsigned ZcRoot);

int32_T *TxModulateGetTxBuffer(void);
void TxModulateFreeTxBuffer(void);

#endif
