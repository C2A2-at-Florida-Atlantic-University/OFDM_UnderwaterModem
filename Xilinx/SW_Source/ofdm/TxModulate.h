//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////

#ifndef TX_MODULATE_H_INCLUDED
#define TX_MODULATE_H_INCLUDED

#include "ReturnStatus.h"
#include "rtwtypes.h"

#define NFFT_DEBUG_COUNT 16
#define DEFAULT_DIGITAL_GAIN_DBFS -54
#define MAX_SAMPLE_VALUE ((1 << 14)-1) // 14 bit IQ

ReturnStatusType TxModulateGetFileData(char *FileName);
ReturnStatusType TxModulateFileData(unsigned ModOrder, unsigned Nfft);
void TxModulatePrintCrealType(creal_T Data);
ReturnStatusType TxModulateDigitalGain(int GainDB);
uint16_T TxModulateGetScalarGain(void);

#endif