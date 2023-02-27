//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "ReturnStatus.h"
#include "TxModulate.h"
#include "TransmitChain.h"
#include "QamMod.h"
#include "rtwtypes.h"
#include "log2.h"
#include "math.h"

#define DEBUG
#define EXTRA_DEBUG

static FILE *TxMessageFile; // Message signal to transmit
static uint8_T TxOfdmSymbolBinData[MAX_NFFT]; // Message signal {0,M-1}
static int16_T TxOfdmSymbolModData[MAX_NFFT*2]; // QAM Modulated signal
static uint16_T DigitalGain;

static const int BIT_MASK_M2[8] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 
  0x02, 0x01};
static const int BIT_MASK_M4[4] = {0xC0, 0x30, 0x0C, 0x03};
static const int BIT_MASK_M16[2] = {0xF0, 0x0F};

void TxModulatePrintCrealType(creal_T Data)
{
  printf("\t\t%lf + j%lf\n", Data.re, Data.im);
}

ReturnStatusType TxModulateFileData(unsigned ModOrder, unsigned Nfft)
{
  ReturnStatusType ReturnStatus;
  signed char MessageByte;
  creal_T ModData;
  unsigned NfftCount = 0;
  int i;

  if (TxMessageFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateFileData: Error no TX file exists\n");
    return ReturnStatus;
  }

  // Encode Message signal takes as characters from a text file into
  // an array of uint8 x nfft each containing data for 1 QAM symbol
  // depending on the modulation order M.
  // Formula: TxOfdmSymbolBinData[nfft_index] = 0:M-1
  MessageByte = fgetc(TxMessageFile);
  while (MessageByte != EOF)
  {
    i = 0;
    while (i < 8/b_log2(ModOrder))
    {
      switch (ModOrder) {
        case 2:
          TxOfdmSymbolBinData[NfftCount] = 
            ((MessageByte & BIT_MASK_M2[i]) >> (7-i));
          break;

        case 4:
          TxOfdmSymbolBinData[NfftCount] = 
            ((MessageByte & BIT_MASK_M4[i]) >> (6-i*2));
          break;

        case 16:
          TxOfdmSymbolBinData[NfftCount] = 
            ((MessageByte & BIT_MASK_M16[i]) >> (4-i*4));
          break;
        
        default:
          ReturnStatus.Status = RETURN_STATUS_FAIL;
          sprintf(ReturnStatus.ErrString,
            "TxModulateFileData: Error: Unsupported Modulation Order\n");
          return ReturnStatus;
      }

      // Print out some digital data after factoring the modulation order
#ifdef EXTRA_DEBUG
      if (NfftCount < NFFT_DEBUG_COUNT)
      {
        printf("TxModulateFileData: TxOfdmSymbolBinData[%d] = %d\n",
          NfftCount, TxOfdmSymbolBinData[NfftCount]);
        if ((NfftCount+1)%(8/(int)b_log2(ModOrder)) == 0)
        {
          printf("\n");
        }
      }
#endif
      i++;
      NfftCount++;
    }

    if (NfftCount == Nfft)
    {
      break;
    }

    MessageByte = fgetc(TxMessageFile);
  }

  // If there are remaining subcarriers due to message not filling up the 
  // entire OFDM symbol, fill the rest of the data subcarriers with 0
  while (NfftCount < Nfft)
  {
    TxOfdmSymbolBinData[NfftCount] = 0;
    NfftCount++;
  }

  // Modulate
  NfftCount = 0;
  while (NfftCount < Nfft)
  {
    ModData = QamMod(TxOfdmSymbolBinData[NfftCount], ModOrder);
    // Print out some Frequency domain data
#ifdef EXTRA_DEBUG
    if (NfftCount < NFFT_DEBUG_COUNT)
    {
      TxModulatePrintCrealType(ModData);
      if ((NfftCount+1)%(8/(int)b_log2(ModOrder)) == 0)
      {
        printf("\n");
      }
    }
#endif
    TxOfdmSymbolModData[2*NfftCount] = (int16_T)ModData.re*DigitalGain;
    TxOfdmSymbolModData[(2*NfftCount)+1] = (int16_T)ModData.im*DigitalGain;
    NfftCount++;
  }

  // Print out some Frequency domain data after being scaled
#ifdef EXTRA_DEBUG
  NfftCount = 0;
  printf("TxModulateFileData: Scaled Frequency Domain Data:\n");
  while (NfftCount < NFFT_DEBUG_COUNT)
  {
    printf("\t\t%d + j%d\n", TxOfdmSymbolModData[2*NfftCount], 
      TxOfdmSymbolModData[(2*NfftCount)+1]);
    if ((NfftCount+1)%(8/(int)b_log2(ModOrder)) == 0)
    {
      printf("\n");
    }
    NfftCount++;
  }
#endif

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType TxModulateGetFileData(char *FileName)
{
  ReturnStatusType ReturnStatus;

  TxMessageFile = fopen(FileName, "r");
  if (TxMessageFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateGetFileData: Failed to open %s\n", FileName);
    return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType TxModulateDigitalGain(int GainDB)
{
  ReturnStatusType ReturnStatus;
  double Pow;

  // dBFS = 20*log10(Value/MaxValue)
  // Value = MaxValue*10^(dBFS/20)
  if (GainDB >= -250 && GainDB <= 0)
  {
    Pow = pow(10.0,(double)GainDB/20);
    DigitalGain = (uint16_T)(((double)MAX_SAMPLE_VALUE)*Pow);
#ifdef DEBUG
    printf("TxModulateDigitalGain: Set Digital gain to %d dBFS = %d\n",
      GainDB, DigitalGain);
#endif
  }
  else
  {
    DigitalGain = MAX_SAMPLE_VALUE*pow(10,DEFAULT_DIGITAL_GAIN_DBFS/20);
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateDigitalGain: dBFS gain of %d is invalid, set to %d\n"
        , GainDB, DEFAULT_DIGITAL_GAIN_DBFS);
    return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

uint16_T TxModulateGetScalarGain(void)
{
  return DigitalGain;
}
