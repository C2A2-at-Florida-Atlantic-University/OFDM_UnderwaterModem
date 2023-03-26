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
#include "Equalizer.h"
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
static FILE *RxInjectFile;
static creal_T *FftOutArray;

static const int BIT_MASK_M2[8] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 
  0x02, 0x01};

static const int BIT_MASK_M4_1[4] = {0x40, 0x10, 0x04, 0x01};
static const int BIT_MASK_M4_2[4] = {0x80, 0x20, 0x08, 0x02};
static const int BIT_MASK_M4_3[4] = {0xC0, 0x30, 0x0C, 0x03};

static const int BIT_MASK_M16_1[2] = {0x10, 0x01};
static const int BIT_MASK_M16_2[2] = {0x20, 0x02};
static const int BIT_MASK_M16_3[2] = {0x30, 0x03};
static const int BIT_MASK_M16_4[2] = {0x40, 0x04};
static const int BIT_MASK_M16_5[2] = {0x50, 0x05};
static const int BIT_MASK_M16_6[2] = {0x60, 0x06};
static const int BIT_MASK_M16_7[2] = {0x70, 0x07};
static const int BIT_MASK_M16_8[2] = {0x80, 0x08};
static const int BIT_MASK_M16_9[2] = {0x90, 0x09};
static const int BIT_MASK_M16_10[2] = {0xA0, 0x0A};
static const int BIT_MASK_M16_11[2] = {0xB0, 0x0B};
static const int BIT_MASK_M16_12[2] = {0xC0, 0x0C};
static const int BIT_MASK_M16_13[2] = {0xD0, 0x0D};
static const int BIT_MASK_M16_14[2] = {0xE0, 0x0E};
static const int BIT_MASK_M16_15[2] = {0xF0, 0x0F};

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
#ifdef SAMPLE_DEBUG
        if (DataIndex < 12*8) 
        {
          printf("DemodData[%d] = %d\n", DataIndex, DemodData[DataIndex]);
        }
#endif
    switch (ModOrder) 
    {
      case 2:
        if (DemodData[DataIndex] == 1)
        {
          ch = ch + BIT_MASK_M2[CharCount];
        }
        break;
      
      case 4:
        switch(DemodData[DataIndex])
        {
          case 1:
            ch = ch + BIT_MASK_M4_1[CharCount];
            break;

          case 2:
            ch = ch + BIT_MASK_M4_2[CharCount];
            break;

          case 3:
            ch = ch + BIT_MASK_M4_3[CharCount];
            break;
        }
        break;

      case 16:
        switch(DemodData[DataIndex])
        {
          case 1:
            ch = ch + BIT_MASK_M16_1[CharCount];
            break;

          case 2:
            ch = ch + BIT_MASK_M16_2[CharCount];
            break;

          case 3:
            ch = ch + BIT_MASK_M16_3[CharCount];
            break;

          case 4:
            ch = ch + BIT_MASK_M16_4[CharCount];
            break;

          case 5:
            ch = ch + BIT_MASK_M16_5[CharCount];
            break;

          case 6:
            ch = ch + BIT_MASK_M16_6[CharCount];
            break;

          case 7:
            ch = ch + BIT_MASK_M16_7[CharCount];
            break;

          case 8:
            ch = ch + BIT_MASK_M16_8[CharCount];
            break;

          case 9:
            ch = ch + BIT_MASK_M16_9[CharCount];
            break;

          case 10:
            ch = ch + BIT_MASK_M16_10[CharCount];
            break;

          case 11:
            ch = ch + BIT_MASK_M16_11[CharCount];
            break;

          case 12:
            ch = ch + BIT_MASK_M16_12[CharCount];
            break;

          case 13:
            ch = ch + BIT_MASK_M16_13[CharCount];
            break;

          case 14:
            ch = ch + BIT_MASK_M16_14[CharCount];
            break;

          case 15:
            ch = ch + BIT_MASK_M16_15[CharCount];
            break;

        }
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

ReturnStatusType RxDemodulateBufferData(bool DebugMode, 
  unsigned LoopMethod, unsigned FileNumber, unsigned ModOrder, 
  unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  creal32_T IqData;
  creal32_T ChEst;
  creal32_T tmp;
  uint16_T DigitalGain;
  unsigned DataCount = 0;
  unsigned PilotCount = 0;
  char FileNameOut[64];
  char FileNameOut1[64];
  FILE *RxFreqFile;
  FILE *RxDemodFile;
 
  if (DebugMode)
  {
    ReturnStatus = EqualizerChFileOpen(FileNumber);
    if (ReturnStatus.Status == RETURN_STATUS_SUCCESS)
    {
      return ReturnStatus;
    }

    // File containing FFT output data
    sprintf(FileNameOut, "files/RxFreqDataEQ%d.txt", FileNumber);

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

  ReturnStatus = RxDemodulateFft(DebugMode, LoopMethod, FileNumber,
    Nfft, CpLen, OfdmSymbols);
    printf("Debug1\n");
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    return ReturnStatus;
  }

  if (LoopMethod == RX_DEMODULATE_TX_LOOPBACK)
  {
#ifdef FFT
    TxBufferPtrLoop = FpgaInterfaceGetTxBuffer();
#endif
#ifdef DUC
    TxBufferPtrLoop = FftOutArray;
#endif
  }
  else if (LoopMethod == RX_DEMODULATE_FILE_INJECTION)
  {
    TxBufferPtrLoop = FftOutArray;
  }
  if (TxBufferPtrLoop == NULL)
  {
    perror("RxDemodulateBufferData");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "RxDemodulateBufferData: No Data on TX Buffer\n");
    return ReturnStatus;
  }
  DigitalGain = TxModulateGetScalarGain();
  ReturnStatus = EqualizerTxPilotOpen(ModOrder);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    return ReturnStatus;
  }

  for (unsigned i = 0; i < OfdmSymbols*Nfft; i++) 
  {
    if (!(i % 4)||!((i+1) % Nfft)) // If currently on a pilot subcarrier
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
      //IqData.re = IqData.re/DigitalGain;
      //IqData.im = IqData.im/DigitalGain;
      PilotData[PilotCount] = IqData;
      ReturnStatus = EqualizerChannelEstimate(DebugMode, ModOrder,
        PilotData[PilotCount], &ChEst, i);
      if (ReturnStatus.Status == RETURN_STATUS_FAIL)
      {
        return ReturnStatus;
      }
      PilotCount++;
      if (DebugMode)
      {
        fprintf(RxFreqFile, "%d, %d\n", (int) IqData.re, (int)
          IqData.im);
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
      //IqData.re = IqData.re/DigitalGain;
      //IqData.im = IqData.im/DigitalGain;
      EqualizerData(ChEst, IqData, &tmp);
      IqData.re = tmp.re;
      IqData.im = tmp.im;
      //IqData.re = IqData.re/DigitalGain;
      //IqData.im = IqData.im/DigitalGain;
      DemodData[DataCount] = (uint8_T)QamDemod(IqData, (float)ModOrder);
      if (DebugMode)
      {
        fprintf(RxFreqFile,"%lf, %lf\n", IqData.re, IqData.im);
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
  
  if (DebugMode)
  {
    EqualizerChFileClose();
    if (RxFreqFile != NULL)
    {
      fclose(RxFreqFile);
    }
    if (RxDemodFile != NULL)
    {
      fclose(RxDemodFile);
    }
    if (LoopMethod == RX_DEMODULATE_FILE_INJECTION)
    {
      if (RxInjectFile != NULL)
      {
        fclose(RxInjectFile);
      }
    }
  }

  if (FftOutArray != NULL)
  {
    free(FftOutArray);
  }

  ReturnStatus = RxDemodulateRecoverMessage(FileNumber, ModOrder, Nfft,
    OfdmSymbols);
  return ReturnStatus;
}

ReturnStatusType RxDemodulateFft(bool DebugMode, unsigned LoopMethod,
  unsigned FileNumber, unsigned Nfft, unsigned CpLen,
  unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  FILE *FftFile = NULL;
  char FileName[32];
  creal_T *BufferInData = NULL;
  cint16_T *FftInData = NULL;
  creal_T *FftOutData = NULL;
  emxArray_creal_T *FftOutStruct = NULL;
  int NfftSize[1];
  int NfftInt = (int)Nfft;
  char FileNameOut2[64];
  unsigned ScanfRet;
  unsigned tmp;
  double tmp1,tmp2;

  FftOutStruct = (emxArray_creal_T *)malloc(sizeof(emxArray_creal_T));
  if (FftOutStruct == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "RxDemodulateFft: Could not malloc FftOutStruct\n");
    return ReturnStatus;
  }
  memset(FftOutStruct, 0, sizeof(emxArray_creal_T));
  FftOutData = (creal_T *)malloc(sizeof(creal_T)*MAX_NFFT);
  if (FftOutData == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "RxDemodulateFft: Could not malloc FftOutData\n");
    return ReturnStatus;
  }
  memset(FftOutData, 0, sizeof(creal_T)*MAX_NFFT);
  FftInData = (cint16_T *)malloc(sizeof(cint16_T)*MAX_NFFT);
  if (FftInData == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "RxDemodulateFft: Could not malloc FftInData\n");
    return ReturnStatus;
  }
  FftOutArray = (creal_T *)malloc(sizeof(creal_T)*Nfft*OfdmSymbols);
  if (FftOutArray == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "RxDemodulateFft: Could not malloc FftOutArray\n");
    return ReturnStatus;
  }
  NfftSize[0] = (int)Nfft;
  FftOutStruct->data = FftOutData;
  FftOutStruct->size = &NfftInt;
  FftOutStruct->allocatedSize = Nfft;
  FftOutStruct->numDimensions = 1;

#ifdef DUC
  if (LoopMethod == RX_DEMODULATE_TX_LOOPBACK)
  {
    BufferInData = TxModulateGetTxBuffer();
  }
  else if (LoopMethod == RX_DEMODULATE_FILE_INJECTION)
  {
    sprintf(FileNameOut2, "files/RxFftInjectData%d.txt", FileNumber);
    RxInjectFile = fopen(FileNameOut2, "r");
    if (RxInjectFile == NULL)
    {
      perror("RxDemodulateBufferData");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateBufferData: Failed to open %s\n", FileNameOut2);
      return ReturnStatus;
    }
    // Check header information
    ScanfRet = fscanf(RxInjectFile, "%d,\n", &tmp);
    if (tmp != Nfft)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateBufferData: Error with header in file %s"
        "Nfft = %d, Header Nfft = %d\n", FileNameOut2, Nfft, tmp);
      return ReturnStatus;
    }
    ScanfRet = fscanf(RxInjectFile, "%d,\n", &tmp);
    if (tmp != CpLen)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateBufferData: Error with header in file %s"
        "CpLen = %d, Header CpLen = %d\n", FileNameOut2, CpLen, tmp);
      return ReturnStatus;
    }
    ScanfRet = fscanf(RxInjectFile, "%d,\n", &tmp);
    if (tmp != OfdmSymbols)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateBufferData: Error with header in file %s"
        "OfdmSymbols = %d, Header OfdmSymbols = %d\n", FileNameOut2, 
        OfdmSymbols, tmp);
      return ReturnStatus;
    }
  }
#endif

  if (DebugMode)
  {
    sprintf(FileName, "files/RxFreqData%d.txt", FileNumber);
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
      // Remove cyclic prefix (CP)
      if (!(j < CpLen)) // Non CP sample
      {
        if (LoopMethod == RX_DEMODULATE_TX_LOOPBACK)
        {
          FftInData[j-CpLen].re = (int16_t)
            BufferInData[(i*(CpLen+Nfft))+j].re;
          FftInData[j-CpLen].im = (int16_t)
            BufferInData[(i*(CpLen+Nfft))+j].im;
        }
        else if (LoopMethod == RX_DEMODULATE_FILE_INJECTION)
        {
          ScanfRet = fscanf(RxInjectFile, "%lf, %lf\n", 
            &tmp1, &tmp2);
          FftInData[j-CpLen].re = (int16_t)tmp1;
          FftInData[j-CpLen].im = (int16_t)tmp2;
        }
#ifdef SAMPLE_DEBUG
        if (i == 0 && j == CpLen)
        {
          printf("\nRxDemodulateFft: Time domain data:\n");
        }
        if (i == 0 && j < CpLen+12)
        {
          printf("\tSymbol %d: Nfft %d:\n\t%d+j%d\n",
            i, j-CpLen,FftInData[j-CpLen].re,FftInData[j-CpLen].im);
        }
#endif
      }
      else // CP sample
      {
        if (LoopMethod == RX_DEMODULATE_FILE_INJECTION)
        {
          ScanfRet = fscanf(RxInjectFile, "%lf, %lf\n", 
            &tmp1, &tmp2);
        }
      }
    }
    Fft(FftInData,NfftSize,Nfft,FftOutStruct);
    for (unsigned j = 0; j < Nfft; j++)
    {
      FftOutArray[(i*Nfft)+j].re = FftOutData[j].re;
      FftOutArray[(i*Nfft)+j].im = FftOutData[j].im;
      if (DebugMode)
      {
        fprintf(FftFile, "%lf, %lf\n", FftOutData[j].re,
          FftOutData[j].im);
#ifdef SAMPLE_DEBUG
        if (i == 0 && j == 0)
        {
          printf("\nRxDemodulateFft: Frequency domain data:\n");
        }
        if (i == 0 && j < 12)
        {
          printf("\tSymbol %d: Nfft %d:\n\t%lf+j%lf\n",
            i,j,FftOutData[j].re,FftOutData[j].im);
        }
#endif
      }
    }
  }

  if (DebugMode)
  {
    printf("RxDemodulateFft: Wrote to file %s\n", FileName);
    if (FftFile != NULL)
    {
      fclose(FftFile);
    }
  }

  if (BufferInData != NULL)
  {
    TxModulateFreeTxBuffer();
  }

  free(FftInData);
  free(FftOutData);
  free(FftOutStruct);
  printf("%d\n", ScanfRet); // Get rid of warnings

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
