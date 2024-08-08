//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include "ReturnStatus.h"
#include "TxModulate.h"
#include "TransmitChain.h"
#include "Reyax.h"
#include "QamMod.h"
#include "c_Ifft.h"
#include "rtwtypes.h"
#include "log2.h"
#include "math.h"

#define DEBUG
//#define SAMPLE_DEBUG // Print out some freq domain samples

// QAM Modulated signal
static creal_T *IfftBufferPtr = NULL; // Pointer to IFFT input Buffer
static int32_T *DucBufferPtr = NULL;
static uint16_T DigitalGain;
static double IfftGain;
static double SyncGain;

static FILE *PilotDataFile; // Pilot code

void TxModulatePrintCrealType(creal_T Data)
{
  //ReyaxTtyMessageSend("\t\t%lf + j%lf", Data.re, Data.im);
}

ReturnStatusType TxAllocateQamFileData(unsigned ModOrder, unsigned Nfft,
  unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  creal_T ModData;
  unsigned PilotData, ScanfRet;
  uint8_T SymbolData;
  unsigned ZpCount = 0, PilotCount = 0, DataCount = 0;
  unsigned *ZpIndex = NULL;
  unsigned *PilotIndex = NULL;
  unsigned *DataIndex = NULL;
  char FileNamePath[32];
  FILE *TxQamDataFile;

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

  sprintf(FileNamePath, "files/TxModData%d.txt", ModOrder);
  TxQamDataFile = fopen(FileNamePath,"r");
  if (TxQamDataFile == NULL)
  {
    perror("TxAllocateQamFileData");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, 
      "TxAllocateQamFileData: Unable to open file %s\n", FileNamePath);
    return ReturnStatus;
  }
  /*
  ReyaxTtyMessageSend("Opened file %s", 
    FileNamePath);
  */

  IfftBufferPtr = (creal_T *)
    malloc((MAX_NFFT+MAX_CP_LEN)*MAX_OFDM_SYMBOLS*16);
  if (IfftBufferPtr == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxAllocateQamFileData: Could not malloc IfftBufferPtr\n");
    return ReturnStatus;
  }
  memset(IfftBufferPtr, 0, (MAX_NFFT+MAX_CP_LEN)*MAX_OFDM_SYMBOLS*16);

  ReturnStatus = TxAllocateGetPilotData(ModOrder);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    return ReturnStatus;
  }

  // Allocate Sub-Carriers
  for (unsigned OfdmSymbolCount = 0; OfdmSymbolCount < OfdmSymbols;
    OfdmSymbolCount++)
  {
    for (unsigned NfftCount = 0; NfftCount < Nfft; NfftCount++)
    {
      // ZP Carrier
      if (NfftCount == ZpIndex[ZpCount])   
      {
        IfftBufferPtr[NfftCount+OfdmSymbolCount*Nfft].re = 0.0;
        IfftBufferPtr[NfftCount+OfdmSymbolCount*Nfft].im = 0.0;
        ZpCount++;
      }
      // Pilot Carrier
      else if (NfftCount == PilotIndex[PilotCount]) 
      {
        ScanfRet = fscanf(PilotDataFile, "%d\n", &PilotData);
        if (ScanfRet != 1)
        {
          ReturnStatus.Status = RETURN_STATUS_FAIL;
          perror("TxAllocateQamFileData");
          sprintf(ReturnStatus.ErrString,
            "TxAllocateQamFileData: Unexpected end of pilot data\n");
          return ReturnStatus;
        }
        ModData = QamMod(PilotData, ModOrder);
        IfftBufferPtr[NfftCount+OfdmSymbolCount*Nfft].re = ModData.re*
          (double)DigitalGain;
        IfftBufferPtr[NfftCount+OfdmSymbolCount*Nfft].im = ModData.im*
          (double)DigitalGain;
        PilotCount++;
      }
      // Data Carrier
      else if (NfftCount == DataIndex[DataCount])
      {
        ScanfRet = fscanf(TxQamDataFile, "%hhd\n", &SymbolData);
        if (ScanfRet != 1)
        {
          ReturnStatus.Status = RETURN_STATUS_FAIL;
          perror("TxAllocateQamFileData");
          sprintf(ReturnStatus.ErrString,
            "TxAllocateQamFileData: Unexpected end of symbol Data\n");
          return ReturnStatus;
        }
        ModData = QamMod(SymbolData, ModOrder);
        IfftBufferPtr[NfftCount+OfdmSymbolCount*Nfft].re = ModData.re*
          (double)DigitalGain;
        IfftBufferPtr[NfftCount+OfdmSymbolCount*Nfft].im = ModData.im*
          (double)DigitalGain;
        DataCount++;
      }
    }
    ZpCount = 0;
    PilotCount = 0;
    DataCount = 0;
  }

  fclose(TxQamDataFile);
  fclose(PilotDataFile);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
} // ReturnStatusType TxAllocateQamFileData

ReturnStatusType TxAllocateGetPilotData(unsigned ModOrder)
{
  ReturnStatusType ReturnStatus;
  char FileName[32];
  
  sprintf(FileName, "files/PilotDataM%d.txt", ModOrder);

  PilotDataFile = fopen(FileName, "r");
  if (PilotDataFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    perror("TxAllocateGetPilotData");
    sprintf(ReturnStatus.ErrString,
      "TxAllocateGetPilotData: Failed to open %s\n", FileName);
    return ReturnStatus;
  }

#ifdef DEBUG
  /*
  ReyaxTtyMessageSend("Opened File %s", FileName);
  */
#endif

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
    //DigitalGain = (uint16_T)(((double)MAX_SAMPLE_VALUE)*Pow);
    DigitalGain = (uint16_T)(((double)MAX_FREQ_SAMPLE_VALUE)*Pow);
#ifdef DEBUG
    //ReyaxTtyMessageSend("Set Digital gain to %d "
    //"dBFS = %d", GainDB, DigitalGain);
#endif
  }
  else
  {
    //DigitalGain = MAX_SAMPLE_VALUE*pow(10,
    DigitalGain = MAX_FREQ_SAMPLE_VALUE*pow(10,
      DEFAULT_FREQ_DIGITAL_GAIN_DBFS/20);
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateDigitalGain: dBFS gain of %d is invalid, set to %d\n"
        , GainDB, DEFAULT_FREQ_DIGITAL_GAIN_DBFS);
    return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

uint16_T TxModulateGetScalarGain(void)
{
  return DigitalGain;
}

void TxModulateSetIfftGain(double GainDB)
{
  IfftGain = pow(10.0,GainDB/10.0);
  //ReyaxTtyMessageSend("Ifft Gain = %lf dB = %lf",
    //GainDB, IfftGain);
}

double TxModulateGetIfftGain()
{
  return IfftGain;
}

void TxModulateSetSyncGain(double GainDB)
{
  SyncGain = pow(10.0,GainDB/10.0);
  //ReyaxTtyMessageSend("Sync Symbol Extra Gain = "
    //"%lf dB = %lf", GainDB, SyncGain);
}

double TxModulateGetSyncGain()
{
  return SyncGain;
}

ReturnStatusType TxModulateIfft(bool DebugMode, unsigned Nfft, 
  unsigned ModOrder, unsigned CpLen, unsigned OfdmSymbols,
  unsigned ZcRoot)
{
  ReturnStatusType ReturnStatus;
  FILE *IfftFile = NULL;
  FILE *IfftFileInt = NULL;
  FILE *TxFreqIfftInput = NULL;
  cint16_T IfftInData[MAX_NFFT];
  creal_T ZcFreqSequence[NFFT_ZC];
  emxArray_creal_T *IfftOutStruct;
  char FileName[64];
  int NfftSize[1];
  int NfftInt = (int)Nfft;
  double tmp_i1, tmp_q1;
  unsigned ScanfRet = 0;
  creal_T *IfftOutData;

  // Buffer going to DMA to DUC
  DucBufferPtr = (int32_T *)malloc((((CpLen+Nfft)*OfdmSymbols)+
    NFFT_ZC+CpLen)*16);
  if (DucBufferPtr == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateIfft: Could not malloc DucBufferPtr\n");
    return ReturnStatus;
  }
  memset(DucBufferPtr, 0, (((CpLen+Nfft)*OfdmSymbols)+NFFT_ZC+CpLen)*16);

  // Set up structs for Ifft function
  IfftOutStruct = (emxArray_creal_T *)malloc(sizeof(emxArray_creal_T));
  if (IfftOutStruct == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateIfft: Could not malloc IfftOutStruct\n");
    return ReturnStatus;
  }
  memset(IfftOutStruct, 0, sizeof(emxArray_creal_T));
  IfftOutData = (creal_T *)malloc(sizeof(creal_T)*MAX_NFFT);
  if (IfftOutData == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateIfft: Could not malloc IfftOutData\n");
    return ReturnStatus;
  }
  memset(IfftOutData, 0, sizeof(creal_T)*MAX_NFFT);
  NfftSize[0] = (int)Nfft;
  IfftOutStruct->data = IfftOutData;
  IfftOutStruct->size = &NfftInt;
  IfftOutStruct->allocatedSize = Nfft;
  IfftOutStruct->numDimensions = 1;

  if (DebugMode)
  {
    sprintf(FileName, "files/TxIfftSamplesInt%d.txt", 1);
    IfftFileInt = fopen(FileName, "w");
    if (IfftFileInt == NULL)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "TxModulateIfft: Failed to open %s\n", FileName);
      return ReturnStatus;
    }
    /*
    ReyaxTtyMessageSend("Opened file %s", FileName);
    */
    fprintf(IfftFileInt, "%d,\n%d,\n%d,\n", Nfft, OfdmSymbols, CpLen);
    sprintf(FileName, "files/TxIfftSamples%d.txt", 1);
    IfftFile = fopen(FileName, "w");
    if (IfftFile == NULL)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "TxModulateIfft: Failed to open %s\n", FileName);
      return ReturnStatus;
    }
    /*
    ReyaxTtyMessageSend("Opened file %s", FileName);
    */
    fprintf(IfftFile, "%d,\n%d,\n%d,\n", Nfft, OfdmSymbols, CpLen);
    sprintf(FileName, "files/TxFreqData%d.txt", 1);
    TxFreqIfftInput = fopen(FileName, "w");
    if (TxFreqIfftInput == NULL)
    {
      perror("TxModulateIfft");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "TxModulateIfft: Failed to open %s\n", FileName);
      return ReturnStatus;
    }
    /*
    ReyaxTtyMessageSend("Opened file %s", FileName);
    */
    fprintf(TxFreqIfftInput, "%d,\n%d,\n%d,\n", Nfft, OfdmSymbols, CpLen);
  }

  for (unsigned i = 0; i < OfdmSymbols; i++)
  {
    for (unsigned j = 0; j < Nfft; j++)
    {
      //IfftInData[j].re = IfftBufferPtr[j+(Nfft*i)].re; // Normal
      //IfftInData[j].im = IfftBufferPtr[j+(Nfft*i)].im;

      //FftShift
      if (j < Nfft/2)
      {
        IfftInData[j+Nfft/2].re = IfftBufferPtr[j+(Nfft*i)].re;
        IfftInData[j+Nfft/2].im = IfftBufferPtr[j+(Nfft*i)].im;
      }
      else
      {
        IfftInData[j-Nfft/2].re = IfftBufferPtr[j+(Nfft*i)].re;
        IfftInData[j-Nfft/2].im = IfftBufferPtr[j+(Nfft*i)].im;
      }
      if (DebugMode)
      {
        fprintf(TxFreqIfftInput, "%lf, %lf\n",
          IfftBufferPtr[j+(Nfft*i)].re,
          IfftBufferPtr[j+(Nfft*i)].im);
      }
    }
    Ifft(IfftInData,NfftSize,Nfft,IfftOutStruct);
    for (unsigned j = 0; j < Nfft; j++)
    {
      IfftOutData[j].re = IfftOutData[j].re * IfftGain;
      IfftOutData[j].im = IfftOutData[j].im * IfftGain;
      // Apply cyclic prefix (CP)
      if (j >= (Nfft - CpLen))
      {
        DucBufferPtr
          [NFFT_ZC+CpLen+(i*(CpLen+Nfft))+j-(Nfft-CpLen)]=
          ((((int32_T)IfftOutData[j].im)<<16)
          &0xFFFF0000)+
          ((int16_T)IfftOutData[j].re);
      }
      DucBufferPtr[NFFT_ZC+CpLen+(i*(CpLen+Nfft))+j+CpLen] = 
        ((((int32_T)IfftOutData[j].im)<<16)
        &0xFFFF0000)+
        ((int16_T)IfftOutData[j].re);

      // Check for saturation
      if (IfftOutData[j].re > U_DAC_ACCURACY || 
        IfftOutData[j].im > U_DAC_ACCURACY)
      {
        //ReturnStatus.Status = RETURN_STATUS_FAIL;
        sprintf(ReturnStatus.ErrString, "TxAllocateQamFileData: "
          "Signal Saturation with Scalar Gain of %d, "
          "symbol %d, sample %d\n", DigitalGain, i, j);
        //return ReturnStatus;
      }
#ifdef SAMPLE_DEBUG
      if (i == 0 && j == 0)
      {
        //ReyaxTtyMessageSend("\nTime domain data:");
      }
      if (j < 12 && i == 1)
      {
        //ReyaxTtyMessageSend("\tSymbol %d: Nfft %d: \n\t%lf+j%lf",
        //  i,j,IfftOutData[j].re,
        //  IfftOutData[j].im);
      }
#endif
    }
  }

  memset(IfftOutData, 0, sizeof(creal_T)*MAX_NFFT);
  NfftSize[0] = (int)NFFT_ZC;
  IfftOutStruct->data = IfftOutData;
  NfftInt = (int)NFFT_ZC;
  IfftOutStruct->size = &NfftInt;
  IfftOutStruct->allocatedSize = NFFT_ZC;
  IfftOutStruct->numDimensions = 1;

  // Create ZC sequence in freq domain
  for (unsigned i = 0; i < NFFT_ZC; i++)
  {
    if (i < NFFT_ZC/4)
    {
      ZcFreqSequence[i].re = 0.0;
      ZcFreqSequence[i].im = 0.0;
    }
    else if (i < 3*NFFT_ZC/4)
    {
      //ZcFreqSequence[i].re = log2(ModOrder)/sqrt(2)*(double)DigitalGain*
      ZcFreqSequence[i].re = (double)DigitalGain*
        cos(M_PI*ZcRoot*((double)i+1.0-(double)NFFT_ZC/4.0)*
        ((double)i+2.0-(double)NFFT_ZC/4.0)/(double)NFFT_ZC*2.0);
      //ZcFreqSequence[i].im = log2(ModOrder)/sqrt(2)*(double)DigitalGain*
      ZcFreqSequence[i].im = (double)DigitalGain*
        -sin(M_PI*ZcRoot*((double)i+1.0-(double)NFFT_ZC/4.0)*
        ((double)i+2.0-(double)NFFT_ZC/4.0)/(double)NFFT_ZC*2.0);
    }
    else
    {
      ZcFreqSequence[i].re = 0.0;
      ZcFreqSequence[i].im = 0.0;
    }
  }

  // Take FFTSHIFT of ZC sequence
  for (unsigned i = 0; i < NFFT_ZC; i++)
  {
    if (i < NFFT_ZC/2)
    {
      IfftInData[i+NFFT_ZC/2].re = (int16_t)ZcFreqSequence[i].re;
      IfftInData[i+NFFT_ZC/2].im = (int16_t)ZcFreqSequence[i].im; 
    }
    else
    {
      IfftInData[i-NFFT_ZC/2].re = (int16_t)ZcFreqSequence[i].re;
      IfftInData[i-NFFT_ZC/2].im = (int16_t)ZcFreqSequence[i].im; 
    }
  }

  // IFFT
  Ifft(IfftInData,NfftSize,NFFT_ZC,IfftOutStruct);

  for (unsigned i = 0; i < NFFT_ZC+CpLen; i++)
  {
    if (i < NFFT_ZC) // Add ZC sequence to FPGA buffer
    {
      tmp_i1 = IfftOutData[i].re * IfftGain * SyncGain;
      tmp_q1 = IfftOutData[i].im * IfftGain * SyncGain;
      DucBufferPtr[i] = ((((int32_T)tmp_q1)<<16)&0xFFFF0000)+
        (int16_T)tmp_i1;
    }
    else // Add CP samples of zero after ZC sequence
    {
      DucBufferPtr[i] = 0x00000000;
    }
  }

  // Print IFFT output to file
  if (DebugMode)
  {
    for (unsigned i = 0; i < (Nfft+CpLen)*(OfdmSymbols)
      +NFFT_ZC+CpLen; i++)
    {
      fprintf(IfftFile, "%d, %d\n", 
        (int16_T)(DucBufferPtr[i]&0x0000FFFF),
        (int16_T)((((int32_T)DucBufferPtr[i])&0xFFFF0000)>>16));
      fprintf(IfftFileInt, "%d, %d\n", 
        (int16_T)(DucBufferPtr[i]&0x0000FFFF),
        (int16_T)((((int32_T)DucBufferPtr[i])&0xFFFF0000)>>16));
    }
  }

  if (DebugMode)
  {
    if (IfftFileInt != NULL)
    {
      fclose(IfftFileInt);
    }
    if (IfftFile != NULL)
    {
      fclose(IfftFile);
    }
    if (TxFreqIfftInput != NULL)
    {
      fclose(TxFreqIfftInput);
    }
  }

  free(IfftOutData);
  free(IfftOutStruct);
  TxModulateClose();

  // Get rid of warnings
  //ReyaxTtyMessageSend("%d, %d", ScanfRet, ModOrder);
  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
} // ReturnStatusType TxModulateIfft

int32_T *TxModulateGetTxBuffer(void)
{
  return DucBufferPtr;
}

void TxModulateFreeTxBuffer(void)
{
  free(DucBufferPtr);
}

void TxModulateClose(void)
{
  free(IfftBufferPtr);
}
