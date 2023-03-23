//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include "ReturnStatus.h"
#include "TxModulate.h"
#include "FpgaInterface.h"
#include "RxDemodulate.h"
#include "d_QamDemod.h"
#include "rtwtypes.h"
#include "f_Fft.h"
#include "log2.h"

#define DEBUG
#define SAMPLE_DEBUG

#ifdef FFT
static unsigned *TxBufferPtrLoop = NULL;
#endif
#ifdef DUC
static creal_T *TxBufferPtrLoop = NULL;
#endif
//unsigned *RxBufferPtr = NULL;
static uint8_T DemodData[MAX_NFFT*MAX_MOD_ORDER*DATA_DENSITY];
static creal32_T PilotData[MAX_NFFT*MAX_MOD_ORDER*PILOT_DENSITY];
static FILE *RxMessageFile;

static const int BIT_MASK_M2[8] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 
  0x02, 0x01};
static const int BIT_MASK_M4[4] = {0xC0, 0x30, 0x0C, 0x03};

void RxDemodulatePrintCrealType(creal32_T Data)
{
  printf("\t%lf + j%lf\n", Data.re, Data.im);
}

ReturnStatusType RxDemodulateWriteToFile(bool open, unsigned FileNumber)
{
  ReturnStatusType ReturnStatus;
  char FileNamePath[64];

  sprintf(FileNamePath, "files/RxDemodMessage%d.txt", FileNumber);

  if (open)
  {
    RxMessageFile = fopen(FileNamePath, "w");
    if (RxMessageFile == NULL)
    {
      perror("RxDemodulateWriteToFile");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateWriteToFile: Failed to open %s\n", FileNamePath);
      return ReturnStatus;
    }
  }
  else
  {
    fclose(RxMessageFile);
    printf("RxDemodulateWriteToFile: Wrote Demodulated Message to %s\n",
      FileNamePath);
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType RxDemodulateRecoverMessage(unsigned FileNumber,
  unsigned ModOrder, unsigned Nfft, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  unsigned CharCount = 0;
  char ch = 0;

  ReturnStatus = RxDemodulateWriteToFile(true, FileNumber);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    return ReturnStatus;
  }

  // Decode {0, M-1} bits into character message
  for (unsigned DataIndex = 0; DataIndex < Nfft*OfdmSymbols*DATA_DENSITY;
    DataIndex++)
  {
    switch (ModOrder) 
    {
      case 2:
#ifdef SAMPLE_DEBUG
        if (DataIndex < 12*8) 
        {
          printf("DemodData[%d] = %d\n", DataIndex, DemodData[DataIndex]);
        }
#endif
        if (DemodData[DataIndex] == 1)
        {
          ch = ch + BIT_MASK_M2[CharCount];
        }
        break;
      
      case 4:
        if (!(DemodData[DataIndex] == 0))
        {
          ch = ch + BIT_MASK_M4[CharCount];
        }
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

    if (CharCount == 8/((unsigned)b_log2(ModOrder)))
    {
      putc(ch, RxMessageFile); // Write recovered message data to file
#ifdef SAMPLE_DEBUG
      if (DataIndex < 12*8)
      {
        printf("RxDemodulateRecoverMessage: Decoded char: %c = 0x%X\n",
          ch, (signed) ch);
      }
#endif
      ch = 0;
      CharCount = 0;
    }
    else if (DataIndex ==
      (Nfft*OfdmSymbols*DATA_DENSITY/b_log2(ModOrder)-1))
    {
      printf("RxDemodulateRecoverMessage: Warning: Finished demodulating"
        " in\nthe middle of decoding a character\n");
    }
  }

  ReturnStatus = RxDemodulateWriteToFile(false, FileNumber);

  return ReturnStatus;
}

ReturnStatusType RxDemodulateBufferData(bool DebugMode, bool Loopback, 
  unsigned FileNumber, unsigned ModOrder, unsigned Nfft, 
  unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  creal32_T IqData;
  uint16_T DigitalGain;
  unsigned DataCount = 0;
  unsigned PilotCount = 0;
  char FileNameOut[64];
  char FileNameOut1[64];
  FILE *RxFreqFile;
  FILE *RxDemodFile;
 
  if (DebugMode)
  {
    // File containing FFT output data
    sprintf(FileNameOut, "files/RxFreqData%d.txt", FileNumber);

    RxFreqFile = fopen(FileNameOut, "w");
    if (RxFreqFile == NULL)
    {
      perror("RxDemodulateBufferData");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateBufferData: Failed to open %s\n", FileNameOut);
      return ReturnStatus;
    }
    // Write header information to file
    fprintf(RxFreqFile, "%d,\n%d,\n%d,\n", Nfft, ModOrder, OfdmSymbols);

    // File containing QAMDEMOD output
    sprintf(FileNameOut1, "files/RxDemodData%d.txt", FileNumber);

    RxDemodFile = fopen(FileNameOut1, "w");
    if (RxDemodFile == NULL)
    {
      perror("RxDemodulateBufferData");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateBufferData: Failed to open %s\n", FileNameOut1);
      return ReturnStatus;
    }
    // Write header information to file
    fprintf(RxDemodFile, "%d\n%d\n%d\n", Nfft, ModOrder, OfdmSymbols);
  }

  if (Loopback)
  {
#ifdef FFT
    TxBufferPtrLoop = FpgaInterfaceGetTxBuffer();
#endif
#ifdef DUC
    TxBufferPtrLoop = TxModulateGetTxBuffer();
#endif
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
#ifdef FFT
      IqData.re = (float)((int16_T)(*(TxBufferPtrLoop+i)));
      IqData.im = (float)
        (int16_T)((((int32_T)(*(TxBufferPtrLoop+i)))&0xFFFF0000)>>16);
#endif
#ifdef DUC
      IqData.re = TxBufferPtrLoop[i].re;
      IqData.im = TxBufferPtrLoop[i].im;
#endif
      if (Loopback)
      {
        IqData.re = IqData.re/DigitalGain;
        IqData.im = IqData.im/DigitalGain;
      }
      PilotData[PilotCount] = IqData;
      PilotCount++;
      if (DebugMode)
      {
        fprintf(RxFreqFile, "%d, %d\n", (int) IqData.re, (int)
          IqData.im);
        //fprintf(RxDemodFile, "%d\n", (unsigned)QamDemod(IqData, 
        //  (float)ModOrder));
      }
#ifdef SAMPLE_DEBUG
      if (i < 16)
      {
        printf("Pilot index %d removed: %d + j%d = bit %d\n", i,
          (int)IqData.re, (int)IqData.im, 
          (unsigned)QamDemod(IqData, (float)ModOrder));
      }
#endif
    }
    else // Data subcarrier
    {
#ifdef FFT
      IqData.re = (float)((int16_T)(*(TxBufferPtrLoop+i)));
      IqData.im = (float)
        (int16_T)((((int32_T)(*(TxBufferPtrLoop+i)))&0xFFFF0000)>>16);
#endif
#ifdef DUC
      IqData.re = TxBufferPtrLoop[i].re;
      IqData.im = TxBufferPtrLoop[i].im;
#endif
      if (Loopback)
      {
        IqData.re = IqData.re/DigitalGain;
        IqData.im = IqData.im/DigitalGain;
      }
      DemodData[DataCount] = (uint8_T)QamDemod(IqData, (float)ModOrder);
      if (DebugMode)
      {
        fprintf(RxFreqFile,"%d, %d\n", (int) IqData.re, (int)
          IqData.im);
        fprintf(RxDemodFile, "%d\n", (unsigned) QamDemod(IqData,
          (float)ModOrder));
      }
#ifdef SAMPLE_DEBUG
      if (i < 16)
      {
        RxDemodulatePrintCrealType(IqData);
        printf("\tDemodData[%d] = %d\n", i,
          DemodData[DataCount]);
      }
#endif
      DataCount++;
    }
  }

  printf("RxDemodulateBufferData: Wrote RX Freq Domain Data to %s\n",
    FileNameOut);
  printf("RxDemodulateBufferData: Wrote RX Demod Data to %s\n",
    FileNameOut1);

  fclose(RxFreqFile);
  fclose(RxDemodFile);

  ReturnStatus = RxDemodulateRecoverMessage(FileNumber, ModOrder, Nfft,
    OfdmSymbols);
  return ReturnStatus;
}

ReturnStatusType RxDemodulateFft(bool DebugMode, bool Loopback,
  unsigned FileNumber, unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  FILE *FftFile = NULL;
  char FileName[32];
  cint16_T *FftInData;
  creal_T *FftOutData;
  emxArray_creal_T *FftOutStruct;
  int NfftSize[1];
  int NfftInt = (int)Nfft;

  FftOutStruct = (emxArray_creal_T *)malloc(sizeof(emxArray_creal_T));
  memset(FftOutStruct, 0, sizeof(emxArray_creal_T));
  FftOutData = (creal_T *)malloc(sizeof(creal_T)*MAX_NFFT);
  memset(FftOutData, 0, sizeof(creal_T)*MAX_NFFT);
  NfftSize[0] = (int)Nfft;
  FftOutStruct->data = FftOutData;
  FftOutStruct->size = &NfftInt;
  FftOutStruct->allocatedSize = Nfft;
  FftOutStruct->numDimensions = 1;

#ifdef DUC
  if (Loopback)
  {
    FftInData = (cint16_T *)TxModulateGetTxBuffer();
  }
#endif

  if (DebugMode)
  {
    sprintf(FileName, "files/RxFftSamples%d.txt", FileNumber);
    FftFile = fopen(FileName, "w");
    if (FftFile == NULL)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateFft: Failed to open %s\n", FileName);
      return ReturnStatus;
    }
    fprintf(FftFile, "%d,\n%d,\n%d,\n", Nfft, OfdmSymbols, CpLen);
  }

  for (unsigned i = 0; i < OfdmSymbols; i++)
  {
    for (unsigned j = 0; j < Nfft+CpLen; j++)
    {

    }
    Fft(FftInData,NfftSize,Nfft,FftOutStruct);
  }

  if (DebugMode)
  {
    printf("RxDemodulateFft: Wrote to file %s\n", FileName);
    if (FftFile != NULL)
    {
      fclose(FftFile);
    }
  }

  free(FftOutData);
  free(FftOutStruct);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
