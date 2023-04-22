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
#include "FpgaInterface.h"
#include "QamMod.h"
#include "c_Ifft.h"
#include "rtwtypes.h"
#include "log2.h"
#include "math.h"

#define DEBUG
//#define SAMPLE_DEBUG // Print out some freq domain samples

static FILE *TxMessageFile; // Message signal to transmit
static FILE *TxWriteFile; // Frequency domain data
// Message signal {0,M-1} - pilot density
static uint8_T 
  TxOfdmSymbolBinData[MAX_NFFT*MAX_MOD_ORDER*DATA_DENSITY*4];
// QAM Modulated signal
#ifdef FFT
static int16_T TxOfdmSymbolModData[MAX_NFFT*2*MAX_MOD_ORDER];
static unsigned *IfftBufferPtr = NULL; 
#endif
#ifdef DUC
static creal_T *IfftBufferPtr = NULL; // Pointer to IFFT input Buffer
static int32_T *DucBufferPtr = NULL;
#endif
#ifdef DAC
static creal_T *DucBufferPtr = NULL; // Pointer to DUC inuput Buffer
#endif
//static unsigned *TxBufferPtr = NULL; // Pointer to Tx CMA Buffer
static uint16_T DigitalGain;

static FILE *PilotDataFile; // Pilot code

static const int BIT_MASK_M2[8] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 
  0x02, 0x01};
static const int BIT_MASK_M4[4] = {0xC0, 0x30, 0x0C, 0x03};
static const int BIT_MASK_M16[2] = {0xF0, 0x0F};

void TxModulatePrintCrealType(creal_T Data)
{
  printf("\t\t%lf + j%lf\n", Data.re, Data.im);
}

ReturnStatusType TxModulateFileData(unsigned ModOrder, unsigned Nfft,
  unsigned OfdmSymbols, Calculated_Ofdm_Parameters *OfdmCalcParams)
{
  ReturnStatusType ReturnStatus;
  signed char MessageByte;
  creal_T ModData;
  creal_T ZeroComplex;
  unsigned NfftCount = 0;
  unsigned NfftZpCount = 0;
  unsigned ZpIndex = 0;
  unsigned PilotData;
  int i;

  ZeroComplex.re = 0.0;
  ZeroComplex.im = 0.0;

#ifdef FFT // Use CMA buffer in which DMA will access
  IfftBufferPtr = FpgaInterfaceClearTxBuffer();
#endif
#ifdef DUC
  IfftBufferPtr = (creal_T *)
    malloc((MAX_NFFT+MAX_CP_LEN)*MAX_OFDM_SYMBOLS*16);
  if (IfftBufferPtr == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateFileData: Could not malloc IfftBufferPtr\n");
    return ReturnStatus;
  }
  memset(IfftBufferPtr, 0, (MAX_NFFT+MAX_CP_LEN)*MAX_OFDM_SYMBOLS*16);
#endif

  if (TxMessageFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    perror("TxModulateFileData");
    sprintf(ReturnStatus.ErrString,
      "TxModulateFileData: Error no TX file exists\n");
    return ReturnStatus;
  }

  ReturnStatus = TxModulateGetPilotData(ModOrder);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
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
      if (ZpIndex < (OfdmCalcParams->FirstPilotCarrier) ||
        ZpIndex == (Nfft/2-1) || // ZP carrier at DC
        ZpIndex >= OfdmCalcParams->LastPilotCarrier)
      { // ZP Index
      }
      //else if (!(NfftCount % 4)) // Pilot carrier
      else if (!((ZpIndex-OfdmCalcParams->FirstPilotCarrier)%4))
      {
        if (fscanf(PilotDataFile, "%d\n", &PilotData) != 1)
        {
          ReturnStatus.Status = RETURN_STATUS_FAIL;
          perror("TxModulateFileData");
          sprintf(ReturnStatus.ErrString,
            "TxModulateFileData: Unexpected end of pilot data\n");
          return ReturnStatus;
        }
        //printf("Setting pilot\n");
        TxOfdmSymbolBinData[NfftCount] = PilotData;
      }
      else // Data carrier
      {
        //printf("Setting data\n");
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
              "TxModulateFileData: Error: Unsupported Mod Order\n");
            return ReturnStatus;
        }
        i++;
      }
#ifdef SAMPLE_DEBUG2
      if (NfftCount < NFFT_DEBUG_COUNT)
      {
        printf("NfftCount: %d, Data: %d\n", NfftCount,
        TxOfdmSymbolBinData[NfftCount]);
      }
#endif
      if (!(ZpIndex < (OfdmCalcParams->FirstPilotCarrier) ||
        ZpIndex == (Nfft/2-1) || // ZP carrier at DC
        ZpIndex >= OfdmCalcParams->LastPilotCarrier))
      { // If Data or Pilot index
        NfftCount++;
          if (i == 8/b_log2(ModOrder))
          {
            MessageByte = fgetc(TxMessageFile);
          }
      }
      if (ZpIndex == Nfft-1)
      {
        ZpIndex = 0;
      }
      else
      {
        ZpIndex++;
      }
    }

    if (NfftCount >= (Nfft*OfdmSymbols))
    {
      break;
    }
  }

  // Return Error if remaining subcarriers after packing with data
  if (NfftCount < (Nfft*OfdmSymbols))
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
    "TxModulateFileData: Not enouph input data to fill packet\n"
    "TxModulateFileData: NfftCount = %d, Max = %d\n", NfftCount,
      Nfft*OfdmSymbols);
    return ReturnStatus;
  }
  // If there are remaining subcarriers due to message not filling up the 
  // entire OFDM symbol, fill the rest of the data subcarriers with 0
  //while (NfftCount < (Nfft*OfdmSymbols))
  //{
  //  TxOfdmSymbolBinData[NfftCount] = 0;
  //  NfftCount++;
  //}

  // Modulate
  NfftCount = 0;
  NfftZpCount = 0;
  ZpIndex = 0;
  while (NfftZpCount < (Nfft*OfdmSymbols))
  {
    if (ZpIndex < (OfdmCalcParams->FirstPilotCarrier) ||
      ZpIndex == (Nfft/2-1) || // ZP carrier at DC
      ZpIndex >= OfdmCalcParams->LastPilotCarrier) // ZP carrier
    {
      ModData = ZeroComplex;
      if (ZpIndex == (Nfft/2-1) && NfftZpCount < Nfft)
      {
        if ((NfftCount+1)%4 == 0)
        {
          printf("TxModulateFileData: WARNING: DC sub-carrier "
          "is pilot\n");
        }
        else
        {
          printf("TxModulateFileData: DC sub-carrier is data\n");
        }
        printf("ZpIndex = %d, NfftCount = %d, NfftZpCount = %d\n",
          ZpIndex, NfftCount, NfftZpCount);
      }
    }
    else // Pilot or Data subcarrier
    {
      ModData = QamMod(TxOfdmSymbolBinData[NfftCount], ModOrder);
      // Print out some Frequency domain data
#ifdef SAMPLE_DEBUG
      if (NfftCount < NFFT_DEBUG_COUNT)
      { 
        if (NfftCount == 0)
        {
          printf("TxModulateFileData: QamMod pilot or data carrier\n");
        }
        TxModulatePrintCrealType(ModData);
        if ((NfftCount+1)%(8/(int)b_log2(ModOrder)) == 0)
        {
          printf("\n");
        }
      }
#endif
#ifdef FFT
      TxOfdmSymbolModData[2*NfftCount] = (int16_T)ModData.re*DigitalGain;
      TxOfdmSymbolModData[(2*NfftCount)+1] = 
        (int16_T)ModData.im*DigitalGain;
      if ((int16_T)ModData.re*DigitalGain > U_DAC_ACCURACY || 
        (int16_T)ModData.im*DigitalGain > U_DAC_ACCURACY)
      {
        ReturnStatus.Status = RETURN_STATUS_FAIL;
        sprintf(ReturnStatus.ErrString, "TxModulateFileData: "
          "Signal Saturation with Scalar Gain of %d\n", DigitalGain);
        return ReturnStatus;
      }
#endif
      NfftCount++;
    }
#ifdef DUC
    if (NfftZpCount < Nfft/2+2)
    {
      //printf("NfftZpCount %d, %lf +j %lf\n", NfftZpCount,
      //  ModData.re*(double)DigitalGain, ModData.im*(double)DigitalGain);
    }
    IfftBufferPtr[NfftZpCount].re = ModData.re*(double)DigitalGain;
    IfftBufferPtr[NfftZpCount].im = ModData.im*(double)DigitalGain;
    if (IfftBufferPtr[NfftZpCount].re > U_DAC_ACCURACY || 
      IfftBufferPtr[NfftZpCount].im > U_DAC_ACCURACY)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString, "TxModulateFileData: "
        "Signal Saturation with Scalar Gain of %d\n", DigitalGain);
      return ReturnStatus;
    }
#endif
    NfftZpCount++;
    if (ZpIndex == Nfft-1)
    {
      ZpIndex = 0;
    }
    else
    {
      ZpIndex++;
    }
  }

  // Print out some Frequency domain data after being scaled
#ifdef SAMPLE_DEBUG
  NfftCount = 0;
  printf("TxModulateFileData: Scaled Frequency Domain Data:\n");
  while (NfftCount >= OfdmCalcParams->FirstPilotCarrier && 
    NfftCount < (NFFT_DEBUG_COUNT+OfdmCalcParams->FirstPilotCarrier))
  {
#ifdef FFT
    printf("\t\tIndex %d: %d + j%d\n", NfftCount,
      TxOfdmSymbolModData[2*NfftCount], 
      TxOfdmSymbolModData[(2*NfftCount)+1]);
#endif
#ifdef DUC
    printf("\t\tIndex %d: %lf + j%lf\n", NfftCount, 
      IfftBufferPtr[NfftCount].re,
      IfftBufferPtr[NfftCount].im);
#endif
    if ((NfftCount+1)%(8/(int)b_log2(ModOrder)) == 0)
    {
      printf("\n");
    }
    NfftCount++;
  }
#endif

#ifdef FFT
  // Fill buffer with frequency domain data
  memcpy((void *) IfftBufferPtr, (const void *) &TxOfdmSymbolModData,
    Nfft*OfdmSymbols*4);
#endif

  fclose(TxMessageFile);
  fclose(PilotDataFile);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
} // ReturnStatusType TxModulateFileData

ReturnStatusType TxModulateGetFileData(unsigned FileNumber)
{
  ReturnStatusType ReturnStatus;
  char FileNamePath[64];

  sprintf(FileNamePath, "files/TxModMessage%d.txt", FileNumber);
  TxMessageFile = fopen(FileNamePath, "r");
  if (TxMessageFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateGetFileData: Failed to open %s\n", FileNamePath);
    return ReturnStatus;
  }
#ifdef DEBUG
  printf("TxModulateGetFileData: Opened File %s\n", FileNamePath);
#endif

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType TxModulateGetPilotData(unsigned ModOrder)
{
  ReturnStatusType ReturnStatus;
  char FileName[32];
  
  sprintf(FileName, "files/PilotDataM%d.txt", ModOrder);

  PilotDataFile = fopen(FileName, "r");
  if (PilotDataFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    perror("TxModulateGetPilotData");
    sprintf(ReturnStatus.ErrString,
      "TxModulateGetPilotData: Failed to open %s\n", FileName);
    return ReturnStatus;
  }

#ifdef DEBUG
  printf("TxModulateGetPilotData: Opened File %s\n", FileName);
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

ReturnStatusType TxModulateWriteToFile(unsigned FileNumber,
  Ofdm_Parameters_Type *OfdmParams, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  char FileNameConverted[64];
  char FileNamePath[64];
  signed char MessageByte;
  unsigned i;

  sprintf(FileNamePath, "files/TxModMessage%d.txt", FileNumber);
  TxMessageFile = fopen(FileNamePath, "r");
  if (TxMessageFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateGetFileData: Failed to open %s\n", FileNamePath);
    return ReturnStatus;
  }
#ifdef DEBUG
  printf("TxModulateGetFileData: Opened File %s\n", FileNamePath);
#endif
  
  sprintf(FileNameConverted, "files/TxModData%d.txt", 
    FileNumber);

  TxWriteFile = fopen(FileNameConverted, "w");
  if (TxWriteFile == NULL)
  {
    perror("TxModulateWriteToFile");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateWriteToFile: Failed to open %s\n", FileNameConverted);
    return ReturnStatus;
  }

  // Write header information:
  fprintf(TxWriteFile, "%d\n%d\n%d\n", OfdmParams->Nfft, 
    OfdmParams->ModOrder, OfdmSymbols);

  MessageByte = fgetc(TxMessageFile);
  while (MessageByte != EOF)
  {
    i = 0;
    while (i < 8/b_log2(OfdmParams->ModOrder))
    {
      switch (OfdmParams->ModOrder) {
        case 2:
          fprintf(TxWriteFile, "%d\n",
            ((MessageByte & BIT_MASK_M2[i]) >> (7-i)));
          break;

        case 4:
          fprintf(TxWriteFile, "%d\n",
            ((MessageByte & BIT_MASK_M4[i]) >> (6-i*2)));
          break;

        case 16:
          fprintf(TxWriteFile, "%d\n",
            ((MessageByte & BIT_MASK_M16[i]) >> (4-i*4)));
          break;
      
        default:
          ReturnStatus.Status = RETURN_STATUS_FAIL;
          sprintf(ReturnStatus.ErrString,
            "TxModulateFileData: Error: Unsupported Mod Order\n");
          return ReturnStatus;
      }
      i++;
    }
    MessageByte = fgetc(TxMessageFile);
  }

  printf("TxModulateWriteToFile: Wrote to file %s\n", FileNameConverted);

  fclose(TxWriteFile);
  fclose(TxMessageFile);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
} // ReturnStatusType TxModulateWriteToFile()

ReturnStatusType TxModulateIfft(bool DebugMode, unsigned FileNumber,
  unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  FILE *IfftFile = NULL;
  FILE *IfftFileInt = NULL;
  FILE *ZcFile = NULL;
  FILE *TxWriteFile = NULL;
  cint16_T IfftInData[MAX_NFFT];
  emxArray_creal_T *IfftOutStruct;
  char FileName[64];
  char FileNameZc[64];
  int NfftSize[1];
  int NfftInt = (int)Nfft;
  unsigned tmp_i, tmp_q;
  unsigned ScanfRet;
  creal_T *IfftOutData;

#ifdef DUC
  DucBufferPtr = (int32_T *)malloc((CpLen+Nfft)*(OfdmSymbols+1)*16);
#endif
#ifdef DAC
  DucBufferPtr = (creal_T *)malloc((CpLen+Nfft)*(OfdmSymbols+1)*16);
#endif
  if (DucBufferPtr == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateIfft: Could not malloc DucBufferPtr\n");
    return ReturnStatus;
  }
  memset(DucBufferPtr, 0, (CpLen+Nfft)*(OfdmSymbols+1)*16);

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
    sprintf(FileName, "files/TxIfftSamplesInt%d.txt", FileNumber);
    IfftFileInt = fopen(FileName, "w");
    if (IfftFileInt == NULL)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "TxModulateIfft: Failed to open %s\n", FileName);
      return ReturnStatus;
    }
    fprintf(IfftFileInt, "%d,\n%d,\n%d,\n", Nfft, OfdmSymbols, CpLen);
    sprintf(FileName, "files/TxIfftSamples%d.txt", FileNumber);
    IfftFile = fopen(FileName, "w");
    if (IfftFile == NULL)
    {
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "TxModulateIfft: Failed to open %s\n", FileName);
      return ReturnStatus;
    }
    fprintf(IfftFile, "%d,\n%d,\n%d,\n", Nfft, OfdmSymbols, CpLen);
    sprintf(FileName, "files/TxFreqData%d.txt", FileNumber);
    TxWriteFile = fopen(FileName, "w");
    if (TxWriteFile == NULL)
    {
      perror("TxModulateWriteToFile");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "TxModulateWriteToFile: Failed to open %s\n", FileName);
      return ReturnStatus;
    }
    fprintf(TxWriteFile, "%d,\n%d,\n%d,\n", Nfft, OfdmSymbols, CpLen);
  }
  sprintf(FileNameZc, "files/zc_seq_time_%d_nfft_%d_ZC_13_root.txt",
    Nfft, Nfft/2);
  ZcFile = fopen(FileNameZc, "r");
  if (ZcFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateIfft: Failed to open %s\n", FileNameZc);
    return ReturnStatus;
  }
  printf("TxModulateIfft: Opened file %s\n", FileNameZc);

  for (unsigned i = 0; i < OfdmSymbols+1; i++)
  {
    if (i == 0) // Synchronization symbol
    {
    }
    else // Data symbols
    {
      for (unsigned j = 0; j < Nfft; j++)
      {
#ifdef FFT
        IfftInData[j].re = ((int16_T)(*(IfftBufferPtr+j+(Nfft*i))));
        IfftInData[j].im = 
          (int16_T)
          ((((int32_T)(*(IfftBufferPtr+j+(Nfft*i))))&0xFFFF0000)>>16);
#endif
#ifdef DUC
        //IfftInData[j].re = IfftBufferPtr[j+(Nfft*i)].re; // Normal
        //IfftInData[j].im = IfftBufferPtr[j+(Nfft*i)].im;
        //FftShift
        if (j < Nfft/2)
        {
          IfftInData[j+Nfft/2].re = IfftBufferPtr[j+(Nfft*(i-1))].re;
          IfftInData[j+Nfft/2].im = IfftBufferPtr[j+(Nfft*(i-1))].im;
        }
        else
        {
          IfftInData[j-Nfft/2].re = IfftBufferPtr[j+(Nfft*(i-1))].re;
          IfftInData[j-Nfft/2].im = IfftBufferPtr[j+(Nfft*(i-1))].im;
        }
        if (DebugMode)
        {
          fprintf(TxWriteFile, "%lf, %lf\n",
            IfftBufferPtr[j+(Nfft*(i-1))].re,
            IfftBufferPtr[j+(Nfft*(i-1))].im);
        }
#endif
      }
    Ifft(IfftInData,NfftSize,Nfft,IfftOutStruct);
    }
    for (unsigned j = 0; j < Nfft; j++)
    {
      if (i == 0) // Synchronization symbol
      {
        // Instead of putting the CP at the beginning of the 
        // synchronization symbol, put a guard period (same
        // length as CP) at the end of the synchronization symbol
        if (j < (CpLen))
        {
          DucBufferPtr[j+Nfft] = 0x00000000;
        }
        ScanfRet = fscanf(ZcFile,"%d, %d\n", &tmp_i, &tmp_q);
        DucBufferPtr[j] = ((((int32_T)tmp_q)<<16)&0xFFFF0000)+
          (int16_T)tmp_i;
      }
      else // Data symbols
      {
        // Apply cyclic prefix (CP)
        if (j >= (Nfft - CpLen))
        {
#ifdef DUC
          DucBufferPtr[(i*(CpLen+Nfft))+j-(Nfft-CpLen)] = 
            ((((int32_T)IfftOutData[j].im)<<16)&0xFFFF0000)+
            ((int16_T)IfftOutData[j].re);
#endif
#ifdef DAC
          DucBufferPtr[(i*(CpLen+Nfft))+j-(Nfft-CpLen)].re = 
            IfftOutData[j].re;
          DucBufferPtr[(i*(CpLen+Nfft))+j-(Nfft-CpLen)].im = 
            IfftOutData[j].im;
#endif
        }
#ifdef DUC
        DucBufferPtr[(i*(CpLen+Nfft))+j+CpLen] = 
          ((((int32_T)IfftOutData[j].im)<<16)&0xFFFF0000)+
          ((int16_T)IfftOutData[j].re);
#endif
#ifdef DAC
        DucBufferPtr[(i*(CpLen+Nfft))+j+CpLen].re = IfftOutData[j].re;
        DucBufferPtr[(i*(CpLen+Nfft))+j+CpLen].im = IfftOutData[j].im;
#endif
      }

      // Check for saturation
      if (IfftOutData[j].re > U_DAC_ACCURACY || 
        IfftOutData[j].im > U_DAC_ACCURACY)
      {
        ReturnStatus.Status = RETURN_STATUS_FAIL;
        sprintf(ReturnStatus.ErrString, "TxModulateFileData: "
          "Signal Saturation with Scalar Gain of %d, "
          "symbol %d, sample %d\n", DigitalGain, i, j);
        return ReturnStatus;
      }
#ifdef SAMPLE_DEBUG
      if (i == 0 && j == 0)
      {
        printf("\nTxModulateIfft: Time domain data:\n");
      }
      if (j < 12 && i == 1)
      {
        printf("\tSymbol %d: Nfft %d: \n\t%lf+j%lf\n",
          i,j,IfftOutData[j].re,IfftOutData[j].im);
      }
#endif
    }
  }

  // Print IFFT output to file
  if (DebugMode)
  {
    for (unsigned i = 0; i < (Nfft+CpLen)*(OfdmSymbols+1); i++)
    {
#ifdef DUC
      fprintf(IfftFile, "%d, %d\n", 
        (int16_T)(DucBufferPtr[i]&0x0000FFFF),
        (int16_T)((((int32_T)DucBufferPtr[i])&0xFFFF0000)>>16));
      fprintf(IfftFileInt, "%d, %d\n", 
        (int16_T)(DucBufferPtr[i]&0x0000FFFF),
        (int16_T)((((int32_T)DucBufferPtr[i])&0xFFFF0000)>>16));
#endif
#ifdef DAC
      fprintf(IfftFile, "%lf, %lf\n", DucBufferPtr[i].re,
        DucBufferPtr[i].im);
      fprintf(IfftFileInt, "%d, %d\n", (int)DucBufferPtr[i].re,
        (int)DucBufferPtr[i].im);
#endif
    }
  }

  if (DebugMode)
  {
    printf("TxModulateIfft: Wrote to file %s\n", FileName);
    if (IfftFileInt != NULL)
    {
      fclose(IfftFileInt);
    }
    if (IfftFile != NULL)
    {
      fclose(IfftFile);
    }
  }
  if (ZcFile != NULL)
  {
    fclose(ZcFile);
  }

  printf("%d\n", ScanfRet); // Get rid of warnings

  free(IfftOutData);
  free(IfftOutStruct);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
} // ReturnStatusType TxMOdulateIfft

#ifdef DUC
int32_T *TxModulateGetTxBuffer(void)
#endif
#ifdef DAC
creal_T *TxModulateGetTxBuffer(void)
#endif
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
