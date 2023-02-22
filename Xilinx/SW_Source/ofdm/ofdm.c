///////////////////////////////////////////////////////////////////////////////////////////
// Jared Hermans
///////////////////////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include "ReturnStatus.h"
#include "TransmitChain.h"

#define DEBUG

Ofdm_Parameters_Type OfdmParams;
Ofdm_Timing_Type OfdmTiming;
Calculated_Ofdm_Parameters OfdmCalcParams;

int main(int argc, char **argv)
{
  unsigned Selection;
  //ReturnStatusType ReturnStatus;

  OfdmParams.Nfft = DEFAULT_NFFT;
  OfdmParams.BandWidth = DEFAULT_BANDWIDTH;
  OfdmParams.CpLen = DEFAULT_CP_LEN;
  OfdmParams.ModOrder = DEFAULT_MOD_ORDER;

  OfdmTiming.SymbolGuardPeriod = DEFAULT_SYMBOL_GUARD_PERIOD;
  OfdmTiming.FrameGuardPeriod = DEFAULT_FRAME_GUARD_PERIOD;
  OfdmTiming.OfdmSymbolsPerFrame = DEFAULT_SYMBOlS_PER_FRAME;

  do {
    printf("\n----- MODEM MENU -----\n");
    printf("0 - Exit\n");
    printf("1 - Enter OFDM Parameters\n");
    printf("2 - Enter OFDM Timing Parameters\n");
    printf("3 - Display OFDM Parameters\n");

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
        break;

      case 2:
        printf("\tEnter Symbol Guard Period in ms: ");
        scanf("%d", &OfdmTiming.SymbolGuardPeriod);
        printf("\tEnter Frame Guard Period in ms: ");
        scanf("%d", &OfdmTiming.FrameGuardPeriod);
        printf("\tEnter OFDM Symbols per Frame: ");
        scanf("%d", &OfdmTiming.OfdmSymbolsPerFrame);
        break;

      case 3:
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
        printf("\t  Frame Guard Period:     %d\n",
          OfdmCalcParams.FrameGuard.FpgaClkSamples);
        break;

      default:
        printf("Invalid selection\n");
    }
  } while (Selection);
  printf("\n");

  return 0;
}
