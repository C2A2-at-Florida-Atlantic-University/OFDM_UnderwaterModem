//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include "ReturnStatus.h"
#include "TxModulate.h"
#include "d_QamDemod.h"
#include "rtwtypes.h"
#include "log2.h"

#define DEBUG
#define SAMPLE_DEBUG

static unsigned *TxBufferPtrLoop = NULL;
//unsigned *RxBufferPtr = NULL;
static uint8_T DemodData[MAX_NFFT*MAX_MOD_ORDER*DATA_DENSITY];

static const int BIT_MASK_M2[8] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 
  0x02, 0x01};

void RxDemodulatePrintCrealType(creal32_T Data)
{
  printf("\t%lf + j%lf\n", Data.re, Data.im);
}

ReturnStatusType RxDemodulateRecoverMessage(unsigned FileNumber,
  unsigned ModOrder, unsigned Nfft, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  unsigned CharCount = 0;
  char ch = 0;

  // Decode {0, M-1} bits into character message
  for (unsigned DataIndex = 0; DataIndex < 
    Nfft*OfdmSymbols*DATA_DENSITY/b_log2(ModOrder); DataIndex++)
  {
    switch (ModOrder) {
      case 2:
        if (DataIndex < 12) {
        printf("DemodData[%d] = %d\n", DataIndex, DemodData[DataIndex]);
        }
        if (DemodData[DataIndex] == 1)
        {
          ch = ch + BIT_MASK_M2[DataIndex];
        }
        break;
      
      case 4:
        printf("Hello\n");
        DataIndex++;
        break;

      case 16:
        printf("Hello2\n");
        DataIndex+=3;
        break;

      default:
        ReturnStatus.Status = RETURN_STATUS_FAIL;
        sprintf(ReturnStatus.ErrString,
          "RxDemodulateRecoverMessage: Error: Unsupported ModOrder\n");
        return ReturnStatus;
    }
    
    CharCount++;
    if (CharCount = 8/b_log2(ModOrder))
    {
#ifdef SAMPLE_DEBUG
    if (DataIndex < 12)
    {
      printf("RxDemodulateRecoverMessage: Decoded character %c\n",
        ch);
    }
#endif
      ch = 0;
      CharCount = 0;
    }
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType RxDemodulateBufferData(bool Loopback, 
  unsigned FileNumber, unsigned ModOrder, unsigned Nfft, 
  unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  creal32_T IqData;
  uint16_T DigitalGain;

  if (Loopback)
  {
    TxBufferPtrLoop = TxModulateGetTxBuffer();
    if (TxBufferPtrLoop == NULL)
    {
      perror("RxDemodulateBufferData");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateBufferData: No Data on TX Buffer\n");
      return ReturnStatus;
    }
    DigitalGain = TxModulateGetScalarGain();
  }

  for (unsigned i = 0; i < OfdmSymbols*Nfft; i++) 
  {
    if (!(i % 4)) // If currently on a pilot subcarrier
    {

    }
    else // Data subcarrier
    {
      IqData.re = (float)((int16_T)(*(TxBufferPtrLoop+i)));
      IqData.im = (float)
        (int16_T)((((int32_T)(*(TxBufferPtrLoop+i)))&0xFFFF0000)>>16);
      if (Loopback)
      {
        IqData.re = IqData.re/DigitalGain;
        IqData.im = IqData.im/DigitalGain;
      }
      DemodData[i] = (uint8_T)QamDemod(IqData, (float)ModOrder);
#ifdef SAMPLE_DEBUG
      if (i < 10)
      {
        RxDemodulatePrintCrealType(IqData);
        printf("\tDemodData[%d] = %d\n", i,
          DemodData[i]);
      }
#endif
    }
  }
printf("\n");  
  IqData.re = (float)1.0;
  IqData.im = (float)0;
        RxDemodulatePrintCrealType(IqData);
  printf("Bit = %lf\n", QamDemod(IqData,(float)2));
  IqData.re = (float)-1.0;
        RxDemodulatePrintCrealType(IqData);
  printf("Bit = %lf\n", QamDemod(IqData,(float)2));
printf("\n");  

  ReturnStatus = RxDemodulateRecoverMessage(FileNumber, ModOrder, Nfft,
    OfdmSymbols);
  return ReturnStatus;
}

