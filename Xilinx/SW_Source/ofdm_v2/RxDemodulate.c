//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include "ReturnStatus.h"
#include "TxModulate.h"
#include "TransmitChain.h"
#include "Power.h"
#include "FpgaInterface.h"
#include "HwInterface.h"
#include "Ber.h"
#include "RxDemodulate.h"
#include "d_QamDemod.h"
#include "rtwtypes.h"
#include "Equalizer.h"
#include "DirectDma.h"
#include "f_Fft.h"
#include "log2.h"
#include "math.h"

#define DEBUG
//#define SAMPLE_DEBUG
//#define SYMBOL_DEBUG
//#define TIME_SAMPLE_DEBUG
//#define FREQ_SAMPLE_DEBUG
//#define EQ_SAMPLE_DEBUG

static creal_T *TxBufferPtrLoop = NULL;
//unsigned *RxBufferPtr = NULL;
static uint8_T DemodData[MAX_NFFT*MAX_MOD_ORDER*DATA_DENSITY];
static creal_T *FftOutArray;
static pthread_t DemodThread = (pthread_t)NULL;
static int pthreadState;

void RxDemodulatePrintCrealType(creal32_T Data)
{
  printf("\t%lf + j%lf\n", Data.re, Data.im);
}

ReturnStatusType RxDemodulateBufferData(bool DebugMode, bool DeleteSym1,
  unsigned ModOrder, unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  creal32_T IqData, IqDataEQ;
  creal32_T ChEst;
  //uint16_T DigitalGain;
  unsigned ZpCount = 0, PilotCount = 0, DataCount = 0;
  unsigned *ZpIndex = NULL;
  unsigned *PilotIndex = NULL;
  unsigned *DataIndex = NULL;
  char FileNameOut[64];
  char FileNameOut1[64];
  FILE *RxFreqFile = NULL;
  FILE *RxDemodFile = NULL;

  ZpIndex = TransmitChainZpIndex();
  PilotIndex = TransmitChainPilotIndex();
  DataIndex = TransmitChainDataIndex();
  if (ZpIndex==NULL||PilotIndex==NULL||DataIndex==NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxAllocateQamFileData: Unable to pull Carrier Indecies\n");
    return ReturnStatus;
  }

  if (DebugMode)
  {
    ReturnStatus = EqualizerChFileOpen();
    if (ReturnStatus.Status == RETURN_STATUS_SUCCESS)
    {
      return ReturnStatus;
    }

    // File containing FFT output data
    sprintf(FileNameOut, "files/RxFreqDataEQ%d.txt", 1);

    RxFreqFile = fopen(FileNameOut, "w");
    if (RxFreqFile == NULL)
    {
      perror("RxDemodulateBufferData");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateBufferData: Failed to open %s\n", FileNameOut);
      return ReturnStatus;
    }
    printf("RxDemodulateBufferData: Opened file %s\n", FileNameOut);
    // Write header information to file
    fprintf(RxFreqFile, "%d,\n%d,\n%d,\n", Nfft, ModOrder, OfdmSymbols);

    // File containing QAMDEMOD output
    sprintf(FileNameOut1, "files/RxDemodData%d.txt", ModOrder);

    RxDemodFile = fopen(FileNameOut1, "w");
    if (RxDemodFile == NULL)
    {
      perror("RxDemodulateBufferData");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateBufferData: Failed to open %s\n", FileNameOut1);
      return ReturnStatus;
    }
    printf("RxDemodulateBufferData: Opened file %s\n", FileNameOut1);
    // Write header information to file
    fprintf(RxDemodFile, "%d\n%d\n%d\n", Nfft, ModOrder, OfdmSymbols);
  }

  ReturnStatus = RxDemodulateFft(DebugMode, DeleteSym1, Nfft, CpLen,
    OfdmSymbols);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    return ReturnStatus;
  }

  TxBufferPtrLoop = FftOutArray;

  if (TxBufferPtrLoop == NULL)
  {
    perror("RxDemodulateBufferData");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "RxDemodulateBufferData: No Data on TX Buffer\n");
    return ReturnStatus;
  }
  //DigitalGain = TxModulateGetScalarGain();
  printf("RxDemodulateBufferData: ModOrder %d\n", ModOrder);
  ReturnStatus = EqualizerTxPilotOpen(ModOrder);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    return ReturnStatus;
  }

  for (unsigned OfdmSymbolCount = 0; OfdmSymbolCount < OfdmSymbols;
    OfdmSymbolCount++)
  {
    for (unsigned NfftCount = 0; NfftCount < Nfft; NfftCount++)
    {
      // ZP Carrier
      if (NfftCount == ZpIndex[ZpCount])
      {
        if (DebugMode)
        {
          fprintf(RxFreqFile, "%d, %d\n", 0, 0);
        }
          ZpCount++;
      }
      // Pilot Carrier
      else if (NfftCount == PilotIndex[PilotCount])
      {
        IqData.re = 
          TxBufferPtrLoop[(OfdmSymbolCount*Nfft)+NfftCount].re;
        IqData.im = 
          TxBufferPtrLoop[(OfdmSymbolCount*Nfft)+NfftCount].im;
        ReturnStatus = EqualizerChannelEstimate(DebugMode, ModOrder,
          IqData, &ChEst);
        EqualizerData(ChEst, IqData, &IqDataEQ);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          return ReturnStatus;
        }
        if (DebugMode)
        {
          fprintf(RxFreqFile, "%d, %d\n", (int)IqDataEQ.re,
            (int)IqDataEQ.im);
        }
        PilotCount++;
      }
      // Data Carrier
      else if (NfftCount == DataIndex[DataCount])
      {
        IqData.re = 
          TxBufferPtrLoop[(OfdmSymbolCount*Nfft)+NfftCount].re;
        IqData.im = 
          TxBufferPtrLoop[(OfdmSymbolCount*Nfft)+NfftCount].im;
        EqualizerData(ChEst, IqData, &IqDataEQ);
        DemodData[DataCount]=(uint8_T)QamDemod(IqDataEQ,(float)ModOrder);
        if (DebugMode)
        {
          fprintf(RxFreqFile, "%lf, %lf\n", IqDataEQ.re, IqDataEQ.im);
          fprintf(RxDemodFile, "%d\n", (unsigned) QamDemod(IqDataEQ,
            (float)ModOrder));
        }
        DataCount++;
      }
    }
    ZpCount = 0;
    PilotCount = 0;
    DataCount = 0;
  }

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
  }

  if (FftOutArray != NULL)
  {
    free(FftOutArray);
  }

  return ReturnStatus;
}

ReturnStatusType RxDemodulateFft(bool DebugMode, bool DeleteSym1,
  unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  FILE *FftFile = NULL;
  FILE *TimeFile = NULL;
  char FileName[32];
  char FileName2[32];
  int32_T *BufferInData = NULL;
  int BufferSelect;
  bool BuffReadStatus0;
  bool BuffReadStatus1;
  bool BuffReadStatus2;
  bool CurrentReadStatus;
  cint16_T *FftInData = NULL;
  creal_T *FftOutData = NULL;
  emxArray_creal_T *FftOutStruct = NULL;
  int NfftSize[1];
  int NfftInt = (int)Nfft;
  unsigned ScanfRet = 0;
  unsigned LoopCount;
  unsigned i2, StartSample;

  if (DeleteSym1)
  { // Delete first symbol which will be the Synchronization symbol
    StartSample = NFFT_ZC;
  }
  else
  { // Synchronization symbol is taken out in PL
    StartSample = 0;
  }

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

  while (1)
  {
    if (pthreadState == 1)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString, "RxDemodulateFft: "
        "pthreadState end\n");
      return ReturnStatus;
    }

    BufferSelect = DirectDmaBuffReadStatus(&BuffReadStatus0, 
      &BuffReadStatus1, &BuffReadStatus2);
    switch (BufferSelect) {
      case (RX_BUFFER_0):
        CurrentReadStatus = BuffReadStatus0;
        break;
      case (RX_BUFFER_1):
        CurrentReadStatus = BuffReadStatus1;
        break;
      case (RX_BUFFER_2):
        CurrentReadStatus = BuffReadStatus2;
        break;
      case (TX_BUFFER_LOOPBACK):
        CurrentReadStatus = true;
        printf("RxDemodulateFft: Performing TX Buffer Loopback Demod\n");
        break;
    }
    if (CurrentReadStatus)
    {
      break;
    }
  }
  BufferInData = (int32_T *)FpgaInterfaceGetRxBuffer(BufferSelect);

  if (DebugMode)
  {
    sprintf(FileName, "files/RxFreqData%d.txt", 1);
    FftFile = fopen(FileName, "w");
    if (FftFile == NULL)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateFft: Failed to open %s\n", FileName);
      return ReturnStatus;
    }
    printf("RxDemodulateFft: Opened file %s\n", FileName);
    fprintf(FftFile, "%d,\n%d,\n%d,\n", Nfft, OfdmSymbols, CpLen);
    sprintf(FileName2, "files/RxFftSamples%d.txt", 1);
    TimeFile = fopen(FileName2, "w");
    if (TimeFile == NULL)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateFft: Failed to open %s\n", FileName2);
      return ReturnStatus;
    }
    printf("RxDemodulateFft: Opened file %s\n", FileName2);
  }

  LoopCount = OfdmSymbols;

  printf("RxDemodulateFft: Rx Power %lf (10x), %lf (20x), (%d dB)\n", 
    pow(10.0,(double)HwInterfaceGetVga()/10.0),
    pow(10.0,(double)HwInterfaceGetVga()/20.0),
    HwInterfaceGetVga());
  ReturnStatus = Power(Nfft, CpLen, OfdmSymbols,
    pow(10.0,(double)HwInterfaceGetVga()/10.0), 0, BufferInData);

  for (unsigned i = 0; i < LoopCount; i++)
  {
    for (unsigned j = 0; j < Nfft+CpLen; j++)
    {
      if (DebugMode)
      {
        fprintf(TimeFile, "%d, %d\n",(int16_t)
          (BufferInData[StartSample+(i*(CpLen+Nfft))+j]&0x0000FFFF),
          (int16_t)
          ((BufferInData
          [StartSample+(i*(CpLen+Nfft))+j]&0xFFFF0000)>>16));
      }
      // Remove cyclic prefix (CP)
      if (!(j < CpLen)) // Non CP sample
      {
        FftInData[j-CpLen].re = (int16_t)
          (BufferInData[StartSample+(i*(CpLen+Nfft))+j]&0x0000FFFF);
        FftInData[j-CpLen].im = (int16_t)
          ((BufferInData[StartSample+(i*(CpLen+Nfft))+j]&0xFFFF0000)>>16);
#ifdef TIME_SAMPLE_DEBUG
        if (i == 1 && j == CpLen)
        {
          printf("\nRxDemodulateFft: Time domain data:\n");
        }
        if (i == 1 && j < CpLen+12)
        {
          printf("\tSymbol %d: Nfft %d:\n\t%d+j%d\n",
            i, j-CpLen,FftInData[j-CpLen].re,FftInData[j-CpLen].im);
        }
#endif
      }
      else // Ignore CP sample
      {
      }
    }
    Fft(FftInData,NfftSize,Nfft,FftOutStruct);
    for (unsigned j = 0; j < Nfft; j++)
    {
      //FftOutArray[(i*Nfft)+j].re = FftOutData[j].re; // Normal
      //FftOutArray[(i*Nfft)+j].im = FftOutData[j].im;
      // FftShift:
      i2 = i;
      if (j < Nfft/2) // FFTSHIFT
      {
        FftOutArray[(i2*Nfft)+j+Nfft/2].re = FftOutData[j].re;
        FftOutArray[(i2*Nfft)+j+Nfft/2].im = FftOutData[j].im;
      }
      else
      {
        FftOutArray[(i2*Nfft)+j-Nfft/2].re = FftOutData[j].re;
        FftOutArray[(i2*Nfft)+j-Nfft/2].im = FftOutData[j].im;
      }
    }
  }

  if (DebugMode)
  {
    for (unsigned i = 0; i < OfdmSymbols*Nfft; i++)
    {
      fprintf(FftFile, "%lf, %lf\n", FftOutArray[i].re, 
        FftOutArray[i].im);
#ifdef FREQ_SAMPLE_DEBUG
      if (i == 0)
      {
        printf("\nRxDemodulateFft: Frequency domain data:\n");
      }
      if (i < 12)
      {
        printf("\tSymbol %d: Nfft %d:\n\t%lf+j%lf\n",
          0,i,FftOutData[i].re,FftOutData[i].im);
      }
#endif
    }
  }

  if (DebugMode)
  {
    if (FftFile != NULL)
    {
      fclose(FftFile);
    }
    if (TimeFile != NULL)
    {
      fclose(TimeFile);
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

ReturnStatusType RxDemodulateCheckThreadRunning(void)
{
  ReturnStatusType ReturnStatus;
  if (DemodThread != (pthread_t)NULL)
  {
    if (pthread_kill(DemodThread,0) == 0)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString, "RxDemodulateCheckThreadRunning: "
        "RX Demodulation Thread running\n");
      return ReturnStatus;
    }
    else
    {
      printf("RxDemodulateCheckThreadRunning: RX Demodulation Thread "
        "not Running\n");
    }
  }
  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void RxDemodulateCancelThread(void)
{
  ReturnStatusType ReturnStatus;
  ReturnStatus = RxDemodulateCheckThreadRunning();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    pthreadState = 1; // pthread stop state
    pthread_join(DemodThread, NULL);
  }
  else
  {
    printf("RxDemodulateCancelThread: Pthread already stopped\n");
  }
}

ReturnStatusType RxDemodulateCreateThread(bool DebugMode,
  unsigned ModOrder, unsigned Nfft, unsigned CpLen, unsigned 
  OfdmSymbols, Calculated_Ofdm_Parameters *OfdmCalcParams)
{
  ReturnStatusType ReturnStatus;
  int RetVal;
  struct thread_args *args;

  args = (struct thread_args *)malloc(SIZE_OF_CALC_OFDM_PARAMS32);

  args->DebugMode = DebugMode;
  args->ModOrder = ModOrder;
  args->Nfft = Nfft;
  args->CpLen = CpLen;
  args->OfdmSymbols = OfdmSymbols;
  args->OfdmCalcParams = OfdmCalcParams;

  ReturnStatus = RxDemodulateCheckThreadRunning();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    sprintf(ReturnStatus.ErrString, "RxDemodulateCreateThread: "
      "ERROR: RX Demodulation Thread already running\n");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    return ReturnStatus;
  }

  pthreadState = 0; // pthread normal statue

  RetVal = pthread_create(&DemodThread, NULL, RxDemodulateThread,
    args);
  if (RetVal != 0)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, "RxDemodulateCreateThread: "
      " ERROR: Failed to create thread for demodulation\n");
    return ReturnStatus;
  }
  printf("RxDemodulateCreateThread: Started Demod Thread\n");
  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void *RxDemodulateThread(void *arg)
{
  ReturnStatusType ReturnStatus;
  struct thread_args *args = (struct thread_args *) arg;

  ReturnStatus = RxDemodulateBufferData(args->DebugMode, 
    false, args->ModOrder, args->Nfft, args->CpLen,
    args->OfdmSymbols);

  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    printf("RxDemodulateThread: FAIL: Exiting Thread\n");
    return NULL;
  }

  HwInterfaceReturnAdcStatus();
  HwInterfaceDisableAdc();

  ReturnStatus = Ber(false, args->ModOrder, args->OfdmSymbols,
    args->OfdmCalcParams);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
  }

  printf("RxDemodulateThread: SUCCESS: Exiting Thread\n");
  return NULL;
}
