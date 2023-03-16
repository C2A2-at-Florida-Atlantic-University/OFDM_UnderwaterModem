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
#include "rtwtypes.h"
#include "log2.h"
#include "math.h"

#define DEBUG
#define EXTRA_DEBUG
//#define SAMPLE_DEBUG // Print out some freq domain samples

static FILE *TxMessageFile; // Message signal to transmit
static FILE *TxWriteFile; // Frequency domain data
// Message signal {0,M-1} - pilot density
static uint8_T TxOfdmSymbolBinData[MAX_NFFT*MAX_MOD_ORDER*DATA_DENSITY];
// QAM Modulated signal
static int16_T TxOfdmSymbolModData[MAX_NFFT*2*MAX_MOD_ORDER];
unsigned *TxBufferPtr = NULL; // Pointer to TX CMA Buffer
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
  unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  signed char MessageByte;
  creal_T ModData;
  unsigned NfftCount = 0;
  unsigned PilotData;
  int i;

  TxBufferPtr = FpgaInterfaceClearTxBuffer();

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
      if (!(NfftCount % 4))
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
      else
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
#ifdef SAMPLE_DEBUG
      if (NfftCount < NFFT_DEBUG_COUNT)
      {
        printf("Data: %d\n", TxOfdmSymbolBinData[NfftCount]);
      }
#endif
      NfftCount++;
    }

    if (NfftCount == (Nfft*OfdmSymbols))
    {
      break;
    }

    MessageByte = fgetc(TxMessageFile);
  }

  // If there are remaining subcarriers due to message not filling up the 
  // entire OFDM symbol, fill the rest of the data subcarriers with 0
#ifdef DEBUG
  if (NfftCount < (Nfft*OfdmSymbols))
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
    "TxModulateFileData: Not enouph input data to fill packet\n"
    "TxModulateFileData: NfftCount = %d, Max = %d\n", NfftCount,
      Nfft*OfdmSymbols);
    return ReturnStatus;
  }
#endif
  while (NfftCount < (Nfft*OfdmSymbols))
  {
    TxOfdmSymbolBinData[NfftCount] = 0;
    NfftCount++;
  }

  // Modulate
  NfftCount = 0;
  while (NfftCount < (Nfft*OfdmSymbols))
  {
    ModData = QamMod(TxOfdmSymbolBinData[NfftCount], ModOrder);
    // Print out some Frequency domain data
#ifdef SAMPLE_DEBUG
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
#ifdef SAMPLE_DEBUG
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
 
  // Fill buffer with frequency domain data to be sent to FPGA
  memcpy((void *) TxBufferPtr, (const void *) &TxOfdmSymbolModData,
    Nfft*OfdmSymbols*4);

  fclose(TxMessageFile);
  fclose(PilotDataFile);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType TxModulateGetFileData(unsigned FileNumber)
{
  ReturnStatusType ReturnStatus;
  char FileNamePath[64];

  sprintf(FileNamePath, "files/TxModData%d.txt", FileNumber);
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
  char FileName[1024];
  //char cwd[1024];
  
  //if (getcwd(cwd, sizeof(cwd)) == NULL)
  //{
  //  ReturnStatus.Status = RETURN_STATUS_FAIL;
  //  perror("TxModulateGetPilotData");
  //  return ReturnStatus;
  //}
    
  //sprintf(FileName, "%s/files/PilotDataM%d.txt", cwd, ModOrder);
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
  char FileNameOut[64];
  char FileNamePath[64];
  signed char MessageByte;
  unsigned i;

  sprintf(FileNamePath, "files/TxModData%d.txt", FileNumber);
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
  
  sprintf(FileNameConverted, "files/TxModData%dConverted.txt", FileNumber);

  TxWriteFile = fopen(FileNameConverted, "w");
  if (TxWriteFile == NULL)
  {
    perror("TxModulateWriteToFile");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateWriteToFile: Failed to open %s\n", FileNameConverted);
    return ReturnStatus;
  }

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

#ifdef DEBUG
  printf("TxModulateWriteToFile: Wrote to file %s\n", FileNameConverted);
#endif

  fclose(TxWriteFile);
  fclose(TxMessageFile);

  sprintf(FileNameOut, "files/TxFreqData%d.txt", FileNumber);

  TxWriteFile = fopen(FileNameOut, "w");
  if (TxWriteFile == NULL)
  {
    perror("TxModulateWriteToFile");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "TxModulateWriteToFile: Failed to open %s\n", FileNameOut);
    return ReturnStatus;
  }

  // Header information
  fprintf(TxWriteFile,"%d,\n%d,\n%d,\n%d,\n%d,\n%d,\n", OfdmParams->Nfft, 
    1000*OfdmParams->BandWidth, OfdmParams->CpLen, OfdmParams->ModOrder, 
    OfdmSymbols, DigitalGain);

  for (unsigned i = 0; i < OfdmParams->Nfft*OfdmSymbols; i++)
  {
    fprintf(TxWriteFile, "%d, %d\n",
      ((int16_T)(*(TxBufferPtr+i))),
      (int16_T)((((int32_T)(*(TxBufferPtr+i))) & 0xFFFF0000)>>16));
  }

#ifdef DEBUG
  printf("TxModulateWriteToFile: Wrote to file %s\n", FileNameOut);
#endif

  fclose(TxWriteFile);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void TxModulateClose(void)
{
  free(TxBufferPtr);
}

unsigned *TxModulateGetTxBuffer()
{
  return TxBufferPtr;
}
