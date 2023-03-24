//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "ReturnStatus.h"
#include "FpgaInterface.h"
#include "TransmitChain.h"
#include "TxModulate.h"
#include "RxDemodulate.h"
#include "rtwtypes.h"
#include "Ber.h"

#define DEBUG

Ofdm_Parameters_Type OfdmParams;
Ofdm_Timing_Type OfdmTiming;
Calculated_Ofdm_Parameters OfdmCalcParams;

int main(int argc, char **argv)
{
  unsigned Selection;
  unsigned ScanfRet; // To get rid of warnings
  unsigned FileNumber;
  int TxGainDb = DEFAULT_DIGITAL_GAIN_DBFS;
  int DebugSelection;
  bool DebugMode;
  ReturnStatusType ReturnStatus;

  if (argc == 1)
  {
    printf("Warning: Did not select TX/RX\n");
    printf("\tEX: ofdm TX\n");
    printf("Default to TX\n");
  }
  else if (argc == 2)
  {
    if (!(strcmp(argv[1], "TX") && strcmp(argv[1], "Tx") && 
      strcmp(argv[1], "tx")))
    {
      printf("\nSelected TX Control\n\n");
    }
    else if (!(strcmp(argv[1], "RX") && strcmp(argv[1], "Rx") && 
      strcmp(argv[1], "rx")))
    {
      printf("\nSelected RX Control\n\n");
    }
    else
    {
      printf("Error: Wrong arguments\n");
      printf("\tEX: ofdm TX\n");
      return 1;
    }
  }
  else
  {
    printf("Error: Wrong arguments\n");
    printf("\tEX: ofdm TX\n");
    return 1;
  }

  OfdmParams.Nfft = DEFAULT_NFFT;
  OfdmParams.BandWidth = DEFAULT_BANDWIDTH;
  OfdmParams.CpLen = DEFAULT_CP_LEN;
  OfdmParams.ModOrder = DEFAULT_MOD_ORDER;

  OfdmTiming.SymbolGuardPeriod = DEFAULT_SYMBOL_GUARD_PERIOD;
  OfdmTiming.FrameGuardPeriod = DEFAULT_FRAME_GUARD_PERIOD;
  OfdmTiming.OfdmSymbolsPerFrame = DEFAULT_SYMBOlS_PER_FRAME;

  ReturnStatus = FpgaInterfaceSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    return 1;
  }

  ReturnStatus = TxModulateDigitalGain(TxGainDb);

  printf("\nDebug Mode Enabled\n");
  DebugMode = true;

  do {
    printf("\n----- MODEM MENU -----\n");
    printf("0  - Exit\n");
    printf("1  - Set Global Debug Mode\n");
    printf("2  - Enter OFDM Parameters\n");
    printf("3  - Enter OFDM Timing Parameters\n");
    printf("4  - Enter TX Digital Gain (dBFS)\n");
    printf("5  - Display OFDM Parameters\n");
    printf("6  - Transmit Single OFDM Frame from File\n");
    printf("7  - Write Transmitted Sub-Carriers to File\n");
    printf("8  - Demod TX Buffer to File\n");
    printf("9  - Demod RX Buffer to File\n");
    printf("10 - Compute BER/SER\n");
    printf("=> ");
    ScanfRet = scanf("%d", &Selection);
    printf("\n");

    switch (Selection) {
      case 0:
        break;

      case 1:
        printf("Enter Selection ('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &DebugSelection);
        if (DebugSelection == 1)
        {
          DebugMode = true;
        }
        else
        {
          DebugMode = false;
        }
        break;

      case 2:
        printf("\tEnter number of sub-carriers: ");
        ScanfRet = scanf("%d", &OfdmParams.Nfft);
        printf("\tEnter BandWidth (Sample Frequency) in kHz: ");
        ScanfRet = scanf("%d", &OfdmParams.BandWidth);
        printf("\tEnter CP length in Samples: ");
        ScanfRet = scanf("%d", &OfdmParams.CpLen);
        printf("\tEnter modulation order: ");
        ScanfRet = scanf("%d", &OfdmParams.ModOrder);

        ReturnStatus = TransmitChainParamCheck(&OfdmParams);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          printf("\tERROR: Reseting OFDM Parameters back to defaults\n");
          OfdmParams.Nfft = DEFAULT_NFFT;
          OfdmParams.BandWidth = DEFAULT_BANDWIDTH;
          OfdmParams.CpLen = DEFAULT_CP_LEN;
          OfdmParams.ModOrder = DEFAULT_MOD_ORDER;
        }

        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        break;

      case 3:
        printf("\tEnter Symbol Guard Period in ms: ");
        ScanfRet = scanf("%d", &OfdmTiming.SymbolGuardPeriod);
        printf("\tEnter Frame Guard Period in ms: ");
        ScanfRet = scanf("%d", &OfdmTiming.FrameGuardPeriod);
        printf("\tEnter OFDM Symbols per Frame: ");
        ScanfRet = scanf("%d", &OfdmTiming.OfdmSymbolsPerFrame);
        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        break;

      case 4:
        printf("\tEnter TX Digital Gain (dBFS): ");
        ScanfRet = scanf("%d", &TxGainDb);
        ReturnStatus = TxModulateDigitalGain(TxGainDb);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          TxGainDb = DEFAULT_DIGITAL_GAIN_DBFS;
        }
        break;

      case 5:
        printf("\t------ User Parameters ------\n");
        printf("\tNFFT:                     %d\n", OfdmParams.Nfft);
        printf("\tBandwidth:                %d kHz\n", 
          OfdmParams.BandWidth);
        printf("\tCP Length:                %d\n", OfdmParams.CpLen);
        printf("\tModulation Order:         %d\n\n", OfdmParams.ModOrder);
        printf("\tSymbol Guard Period:      %d ms\n",
          OfdmTiming.SymbolGuardPeriod);
        printf("\tFrame Guard Period:       %d ms\n", 
          OfdmTiming.FrameGuardPeriod);
        printf("\tSymbols per Frame         %d\n",
          OfdmTiming.OfdmSymbolsPerFrame);
        printf("\n\tTX Digital Gain:          %d dBFS = %d\n",
          TxGainDb, TxModulateGetScalarGain());

        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        OfdmCalcParams = TransmitChainGetParams();

        printf("\n");
        printf("\t------ Calculated Parameters ------\n");
        printf("\tSCS:                      %lf Hz\n", 
          OfdmCalcParams.Scs);
        printf("\tSamples per Symbol:       %d\n", 
          OfdmCalcParams.Symbol.Samples);
        printf("\tSymbol Period:            %lf ms\n", 
          OfdmCalcParams.Symbol.Time);
        printf("\tSymbol Data Rate:         %lf kbit/sec\n", 
          OfdmCalcParams.SymbolDataRate);
        printf("\tFrame Data Rate:          %lf kbit/sec\n",
          OfdmCalcParams.FrameDataRate);
        printf("\n\t100MHz Cycles per:\n");
        printf("\t  Sample:                 %d\n",
          OfdmCalcParams.Symbol.FpgaClkSamples);
        printf("\t  Symbol Guard Period:    %d\n",
          OfdmCalcParams.SymbolGuard.FpgaClkSamples);
        printf("\t  Frame Guard Period:     %d\n\n",
          OfdmCalcParams.FrameGuard.FpgaClkSamples);

        break;

      case 6:
        ReturnStatus = TransmitChainParamCheck(&OfdmParams);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }

        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        OfdmCalcParams = TransmitChainGetParams();

        printf("Write file number: ");
        ScanfRet = scanf("%d", &FileNumber);
        printf("\n");
        ReturnStatus = TxModulateGetFileData(FileNumber);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }

        ReturnStatus = TxModulateFileData(OfdmParams.ModOrder, 
          OfdmParams.Nfft, OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }

#ifdef DUC
        ReturnStatus = TxModulateIfft(DebugMode, FileNumber, 
          OfdmParams.Nfft, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
#endif

        ReturnStatus = TransmitChainEnableDl(false, &OfdmParams, 
          &OfdmTiming);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        break;

      case 7:
        printf("Write file number: ");
        ScanfRet = scanf("%d", &FileNumber);
        ReturnStatus = TxModulateWriteToFile(FileNumber, 
          &OfdmParams, OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        break;

      case 8:
        printf("Write file number: ");
        ScanfRet = scanf("%d", &FileNumber);
        ReturnStatus = RxDemodulateBufferData(DebugMode, true, FileNumber, 
          OfdmParams.ModOrder, OfdmParams.Nfft, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        break;

      case 9:
        break;

      case 10:
        printf("Write file number: ");
        ScanfRet = scanf("%d", &FileNumber);
        ReturnStatus = Ber(true, FileNumber, OfdmParams.ModOrder,
          OfdmParams.Nfft, OfdmTiming.OfdmSymbolsPerFrame);
        ReturnStatus = Ber(false, FileNumber, OfdmParams.ModOrder,
          OfdmParams.Nfft, OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        break;

      default:
        printf("Invalid selection\n");
    }
  } while (Selection);
  printf("\n");

  TxModulateClose();
  printf("%d\n", ScanfRet);
  return 0;
}
