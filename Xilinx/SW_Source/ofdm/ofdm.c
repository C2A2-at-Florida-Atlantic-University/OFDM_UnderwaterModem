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
#include "rtwtypes.h"

#define DEBUG

Ofdm_Parameters_Type OfdmParams;
Ofdm_Timing_Type OfdmTiming;
Calculated_Ofdm_Parameters OfdmCalcParams;

int main(int argc, char **argv)
{
  unsigned Selection;
  int TxGainDb = DEFAULT_DIGITAL_GAIN_DBFS;
  char FileName[20];
  ReturnStatusType ReturnStatus;

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

  do {
    printf("\n----- MODEM MENU -----\n");
    printf("0 - Exit\n");
    printf("1 - Enter OFDM Parameters\n");
    printf("2 - Enter OFDM Timing Parameters\n");
    printf("3 - Enter TX Digital Gain (dBFS)\n");
    printf("4 - Display OFDM Parameters\n");
    printf("5 - Transmit Single OFDM Frame from File\n");

    scanf("%d", &Selection);

    switch (Selection) {
      case 0:
        break;

      case 1:
        printf("\tEnter number of sub-carriers: ");
        scanf("%d", &OfdmParams.Nfft);
        printf("\tEnter BandWidth (Sample Frequency) in kHz: ");
        scanf("%d", &OfdmParams.BandWidth);
        printf("\tEnter CP length in Samples: ");
        scanf("%d", &OfdmParams.CpLen);
        printf("\tEnter modulation order: ");
        scanf("%d", &OfdmParams.ModOrder);

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

      case 2:
        printf("\tEnter Symbol Guard Period in ms: ");
        scanf("%d", &OfdmTiming.SymbolGuardPeriod);
        printf("\tEnter Frame Guard Period in ms: ");
        scanf("%d", &OfdmTiming.FrameGuardPeriod);
        printf("\tEnter OFDM Symbols per Frame: ");
        scanf("%d", &OfdmTiming.OfdmSymbolsPerFrame);
        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        break;

      case 3:
        printf("\tEnter TX Digital Gain (dBFS): ");
        scanf("%d", &TxGainDb);
        ReturnStatus = TxModulateDigitalGain(TxGainDb);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          TxGainDb = DEFAULT_DIGITAL_GAIN_DBFS;
        }
        break;

      case 4:
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

        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        OfdmCalcParams = TransmitChainGetParams();

        printf("\n");
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

        printf("\tTX Digital Gain:          %d dBFS = %d\n",
          TxGainDb, TxModulateGetScalarGain());
        break;

      case 5:
        printf("Enter file name: ");
        scanf("%s", FileName);
        ReturnStatus = TxModulateGetFileData(FileName);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        ReturnStatus = TxModulateFileData(OfdmParams.ModOrder, 
          OfdmParams.Nfft);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        ReturnStatus = TransmitChainEnableDl(false, &OfdmParams, 
          &OfdmTiming);
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

  return 0;
}