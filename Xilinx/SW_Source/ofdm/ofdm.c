//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include "ReturnStatus.h"
#include "FpgaInterface.h"
#include "TransmitChain.h"
#include "TxModulate.h"
#include "RxDemodulate.h"
#include "DacChain.h"
#include "AdcChain.h"
#include "rtwtypes.h"
#include "DirectDma.h"
#include "HwInterface.h"
#include "Ber.h"

#define DEBUG

Ofdm_Parameters_Type OfdmParams;
Ofdm_Timing_Type OfdmTiming;
Calculated_Ofdm_Parameters OfdmCalcParams;
Dac_Parameters_Type DacParams;
FILE *OfdmInfoFile;

int main(int argc, char **argv)
{
  unsigned Selection;
  unsigned ScanfRet; // To get rid of warnings
  unsigned FileNumber;
  unsigned CenterFreq;
  unsigned NumBytes;
  unsigned StartByte;
  unsigned DmaLoopSel;
  unsigned DucDdcLoopSel;
  unsigned ScalarGain;
  unsigned RxThread;
  unsigned SyncThreshold;
  unsigned RxShiftAtten;
  int SyncOffset;
  int TxGainDb;
  int RxGainDb;
  int DebugSelection;
  bool DebugMode;
  bool GlobalMute;
  bool SwSynchronization;
  bool SwSynchronizationTx;
  char FileName[32];
  ReturnStatusType ReturnStatus;

  printf("\n----- OFDM RADIO TEST APPLICATION -----\n\n");
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

  // Set default values
  OfdmParams.Nfft = DEFAULT_NFFT;
  OfdmParams.BandWidth = DEFAULT_BANDWIDTH;
  OfdmParams.CpLen = DEFAULT_CP_LEN;
  OfdmParams.ZpDensity = DEFAULT_ZP_DENSITY;
  OfdmParams.ModOrder = DEFAULT_MOD_ORDER;

  OfdmTiming.SymbolGuardPeriod = DEFAULT_SYMBOL_GUARD_PERIOD;
  OfdmTiming.FrameGuardPeriod = DEFAULT_FRAME_GUARD_PERIOD;
  OfdmTiming.OfdmSymbolsPerFrame = DEFAULT_SYMBOlS_PER_FRAME;

  TxGainDb = DEFAULT_DIGITAL_GAIN_DBFS;
  RxGainDb = DEFAULT_RX_GAIN_DB;

  SyncThreshold = DEFAULT_SYNC_THRESHOLD;
  SyncOffset = DEFAULT_SYNCHRONIZER_OFFSET;

  CenterFreq = DEFAULT_CENTER_FREQUENCY_KHZ;

  SwSynchronization = false;
  SwSynchronizationTx = true;

  ReturnStatus = FpgaInterfaceSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    return 1;
  }

#ifndef NO_DEVMEM                  // HW specific functions
  HwInterfaceSetGlobalMute(true);  // mute FPGA reg access prints
  DirectDmaSetGlobalMute(true);    // mute FPGA reg access prints
  DirectDmaPsToPlInit(0);          // Reset mm2s DMA
  DirectDmaPlToPsInit(0);          // Reset s2mm DMA
  DirectDmaMm2sIrqClear();         // Clear IRQ for mm2s DMA
  DirectDmaS2mmIrqClear();         // Clear IRQ for s2mm DMA
  DirectDmaMm2sStatus();           // DMA mm2s status
  DirectDmaS2mmStatus();           // DMA s2mm status
  HwInterfaceDmaLoopback(0);       // Disable DMA loopback 
  HwInterfaceDisableDac();         // Disable DAC and PA
  HwInterfaceDisableAdc();         // Disable ADC
  DirectDmaSetNumBytesForLoopback((OfdmParams.Nfft+
    OfdmParams.CpLen)*OfdmTiming.OfdmSymbolsPerFrame*4);
  ReturnStatus = HwInterfaceConfigureSynchronizer(OfdmParams.Nfft, 
    OfdmParams.CpLen, OfdmTiming.OfdmSymbolsPerFrame,
    SyncThreshold, SyncOffset);
  HwInterfaceSynchronizerStatus(false);
  ReturnStatus = DacChainSetDacParams(DEFAULT_BANDWIDTH,
    CenterFreq, false);
#endif

  ReturnStatus = TxModulateDigitalGain(TxGainDb);

#ifdef SPI
  ReturnStatus = HwInterfaceGpioSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    return 1;
  }

  ReturnStatus = HwInterfaceSpiSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    return 1;
  }
  
  ReturnStatus = HwInterfaceSetVga(RxGainDb);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
  }
#endif

  printf("\nDebug Mode Enabled\n");
  DebugMode = true;

  do {
    usleep(1000); // Give some time for prints from threads
    printf("\n----- MODEM MENU -----\n");
    printf("0  - Exit\n");
    printf("1  - Set Debug Features\n");
    printf("2  - Enter OFDM Parameters\n");
    printf("3  - Enter OFDM Timing Parameters\n");
    printf("4  - Enter TX/RX Gain (dBFS)/(dB)\n");
    printf("5  - Enter Center Frequency\n");
    printf("6  - Enter Synchronizer Parameters\n");
    printf("7  - Display OFDM Parameters\n");
    printf("8  - Transmit Single OFDM Frame\n");
    printf("9  - Write Transmitted Sub-Carriers to File\n");
    printf("10 - Demod TX Buffer\n");
    printf("11 - Start/Stop RX Demod Thread\n");
    printf("12 - Demod RX Injection File\n");
    printf("13 - Compute BER/SER\n");
    printf("14 - Start S2MM DMA\n");
    printf("15 - Stop S2MM DMA\n");
    printf("16 - Set Loopback Mode\n");
    printf("17 - Enable/Disable SW Synchronization\n");
    printf("=> ");
    ScanfRet = scanf("%d", &Selection);
    printf("\n");

    switch (Selection) {
      case 0:
        break;

      case 1:
        printf("Set Glogal File Debug Mode (Save samples to file)\n");
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
        printf("Enable/Disable FPGA register read/write debug\n");
        printf("Enter Selection ('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &DebugSelection);
        if (DebugSelection == 1)
        {
          GlobalMute = false;
        }
        else
        {
          GlobalMute = true;
        }
        HwInterfaceSetGlobalMute(GlobalMute);
        DirectDmaSetGlobalMute(GlobalMute);
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
        printf("\tEnter ZP Carrier Density: ");
        ScanfRet = scanf("%d", &OfdmParams.ZpDensity);

        ReturnStatus = TransmitChainParamCheck(&OfdmParams);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          printf("\tERROR: Reseting OFDM Parameters back to defaults\n");
          OfdmParams.Nfft = DEFAULT_NFFT;
          OfdmParams.BandWidth = DEFAULT_BANDWIDTH;
          OfdmParams.CpLen = DEFAULT_CP_LEN;
          OfdmParams.ModOrder = DEFAULT_MOD_ORDER;
          OfdmParams.ZpDensity = DEFAULT_ZP_DENSITY;
        }

        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        ReturnStatus = DacChainSetDacParams(OfdmParams.BandWidth,
          CenterFreq, false);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          printf("Setting default center frequency\n");
          CenterFreq = DEFAULT_CENTER_FREQUENCY_KHZ;
        }
        DacParams = DacChainGetDacParams();
        DirectDmaSetNumBytesForLoopback((OfdmParams.Nfft+
          OfdmParams.CpLen)*OfdmTiming.OfdmSymbolsPerFrame*4);
        break;

      case 3:
        printf("\tEnter Symbol Guard Period in ms: ");
        ScanfRet = scanf("%d", &OfdmTiming.SymbolGuardPeriod);
        printf("\tEnter Frame Guard Period in ms: ");
        ScanfRet = scanf("%d", &OfdmTiming.FrameGuardPeriod);
        printf("\tEnter OFDM Symbols per Frame: ");
        ScanfRet = scanf("%d", &OfdmTiming.OfdmSymbolsPerFrame);
        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        DirectDmaSetNumBytesForLoopback((OfdmParams.Nfft+
          OfdmParams.CpLen)*OfdmTiming.OfdmSymbolsPerFrame*4);
        break;

      case 4:
        printf("\tEnter TX Digital Gain (dBFS): ");
        ScanfRet = scanf("%d", &TxGainDb);
        printf("\tEnter RX Gain (dB): ");
        ScanfRet = scanf("%d", &RxGainDb);
        ReturnStatus = TxModulateDigitalGain(TxGainDb);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          TxGainDb = DEFAULT_DIGITAL_GAIN_DBFS;
        }
#ifdef SPI
        ReturnStatus = HwInterfaceSetVga(RxGainDb);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
        }
#endif
#ifndef NO_DEVMEM
        printf("\tEnter Rx Shift Attenuation in bits: ");
        ScanfRet = scanf("%d", &RxShiftAtten);
        //HwInterfaceConfigRxShiftAtten(RxShiftAtten);
#endif
        break;

      case 5:
        printf("\tEnter Center Frequency (kHz): ");
        ScanfRet = scanf("%d", &CenterFreq);
        ReturnStatus = DacChainSetDacParams(OfdmParams.BandWidth,
          CenterFreq, false);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          printf("Setting default center frequency\n");
          CenterFreq = DEFAULT_CENTER_FREQUENCY_KHZ;
        }
        break;

      case 6:
        printf("\tEnter Synchronizer Threshold (DEFAULT: "
          "0x%X): ", DEFAULT_SYNC_THRESHOLD);
        ScanfRet = scanf("%x", &SyncThreshold);
        printf("\tEnter Synchronizer Offset (-1024:1024): ");
        ScanfRet = scanf("%d", &SyncOffset);
        ReturnStatus = HwInterfaceConfigureSynchronizer(
          OfdmParams.Nfft, OfdmParams.CpLen, 
          OfdmTiming.OfdmSymbolsPerFrame, SyncThreshold, SyncOffset);
        HwInterfaceSynchronizerStatus(false);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
        }
        break;

      case 7:
        printf("\t------ User Parameters ------\n");
        printf("\tNFFT:                     %d\n", OfdmParams.Nfft);
        printf("\tBandwidth:                %d kHz\n", 
          OfdmParams.BandWidth);
        printf("\tCP Length:                %d\n", OfdmParams.CpLen);
        printf("\tModulation Order:         %d\n", OfdmParams.ModOrder);
        printf("\tZP Pilot Density:         %d%%\n\n", 
          OfdmParams.ZpDensity);
        printf("\tSymbol Guard Period:      %d ms\n",
          OfdmTiming.SymbolGuardPeriod);
        printf("\tFrame Guard Period:       %d ms\n", 
          OfdmTiming.FrameGuardPeriod);
        printf("\tSymbols per Frame         %d\n",
          OfdmTiming.OfdmSymbolsPerFrame);
        printf("\n\tTX Digital Gain:          %d dBFS = %d\n",
          TxGainDb, TxModulateGetScalarGain());
        printf("\n\tCenter Frequency:         %d kHz\n", CenterFreq);
        printf("\n\tSynchronizer Threshold    0x%X = %d\n",
          SyncThreshold, SyncThreshold);
        printf("\tSynchronizer Offset       %d\n", SyncOffset);

        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        OfdmCalcParams = TransmitChainGetParams();
        DacParams = DacChainGetDacParams();

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
        printf("\n\tActual ZP Pilot Density:  %lf%%\n",
          (((double)OfdmCalcParams.FirstPilotCarrier*2.0)+1)/
          (double)OfdmParams.Nfft*100.0);
        printf("\tFirst Pilot Carrier:      %d\n",
          OfdmCalcParams.FirstPilotCarrier+1);
        printf("\tLast Pilot Carrier:       %d\n",
          OfdmCalcParams.LastPilotCarrier);
        printf("\tNumber of Data Carriers:  %d\n",
          OfdmCalcParams.NumDataCarriers);
        printf("\tNumber of Pilot Carriers: %d\n",
          OfdmCalcParams.NumPilotCarriers);
        printf("\n\tInterpolation Value       %dx\n", DacParams.Interp);
        printf("\n\t100MHz Cycles per:\n");
        printf("\t  Sample:                 %d\n",
          OfdmCalcParams.Symbol.FpgaClkSamples);
        printf("\t  Symbol Guard Period:    %d\n",
          OfdmCalcParams.SymbolGuard.FpgaClkSamples);
        printf("\t  Frame Guard Period:     %d\n\n",
          OfdmCalcParams.FrameGuard.FpgaClkSamples);

        break;

      case 8:
        ReturnStatus = TransmitChainParamCheck(&OfdmParams);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }

        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        OfdmCalcParams = TransmitChainGetParams();
        DacParams = DacChainGetDacParams();
        ScalarGain = TxModulateGetScalarGain();

        printf("Write file number: ");
        ScanfRet = scanf("%d", &FileNumber);
        printf("\n");
        ReturnStatus = TxModulateGetFileData(FileNumber);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }

        sprintf(FileName, "files/OfdmInfo%d.txt", FileNumber);
        OfdmInfoFile = fopen(FileName,"w");
        if (OfdmInfoFile == NULL)
        {
          printf("Failed to write to OfdmInfoFile\n");
          break;
        }
        fprintf(OfdmInfoFile, "%d,\n%d,\n%d,\n%d,\n%d,\n%d,\n%d,"
          "\n%d,\n%d,\n%d\n",
          OfdmParams.Nfft, OfdmParams.BandWidth, OfdmParams.CpLen,
          OfdmParams.ModOrder, OfdmParams.ZpDensity,
          OfdmTiming.SymbolGuardPeriod, OfdmTiming.FrameGuardPeriod,
          OfdmTiming.OfdmSymbolsPerFrame, CenterFreq, ScalarGain);

        ReturnStatus = TxModulateFileData(OfdmParams.ModOrder, 
          OfdmParams.Nfft, OfdmTiming.OfdmSymbolsPerFrame,
          &OfdmCalcParams);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }

        ReturnStatus = TxModulateIfft(DebugMode, FileNumber, 
          OfdmParams.Nfft, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }

#ifdef DAC
        ReturnStatus = DacChainUpConversion(true, FileNumber,
          OfdmParams.Nfft, OfdmParams.CpLen, OfdmParams.BandWidth,
          OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        NumBytes = (OfdmParams.Nfft+OfdmParams.CpLen)*
          OfdmTiming.OfdmSymbolsPerFrame*DacParams.Interp*2;
#else
        if (SwSynchronizationTx)
        {
          NumBytes = (OfdmParams.Nfft+OfdmParams.CpLen)*
            (OfdmTiming.OfdmSymbolsPerFrame+1)*4;
          StartByte = 0;
        }
        else
        {
          NumBytes = (OfdmParams.Nfft+OfdmParams.CpLen)*
            (OfdmTiming.OfdmSymbolsPerFrame+1)*4;
          StartByte = (OfdmParams.Nfft+OfdmParams.CpLen)*4;
          printf("Skipping Synchronization Symbol\n");
        }
#endif

#ifndef NO_DEVMEM
          ReturnStatus = DacChainSetDacParams(OfdmParams.BandWidth,
            CenterFreq, true);
          ReturnStatus = HwInterfaceConfigureSynchronizer(
            OfdmParams.Nfft, OfdmParams.CpLen, 
            OfdmTiming.OfdmSymbolsPerFrame, SyncThreshold,
            SyncOffset);
          HwInterfaceSynchronizerStatus(true);
          HwInterfaceEnableDac();
          ReturnStatus = DirectDmaPsToPl(NumBytes, StartByte);
          HwInterfaceDisableDac();
          if (ReturnStatus.Status == RETURN_STATUS_FAIL)
          {
            printf("%s", ReturnStatus.ErrString);
           }
           break;
#else
          printf("Skipped DMA transfer of : %d Bytes\n", NumBytes);
#endif

//        ReturnStatus = TransmitChainEnableDl(&OfdmParams, 
//          &OfdmTiming);
//        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
//        {
//          printf("%s", ReturnStatus.ErrString);
//          break;
//        }
        break;

      case 9:
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

      case 10:
        printf("Write file number: ");
        ScanfRet = scanf("%d", &FileNumber);
#ifdef DAC
        ReturnStatus = AdcChainDownConversion(DebugMode, FileNumber,
          OfdmParams.Nfft, OfdmParams.CpLen, OfdmParams.BandWidth,
          OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
#endif
#ifndef NO_DEVMEM
        ReturnStatus = HwInterfaceConfigureSynchronizer(
          OfdmParams.Nfft, OfdmParams.CpLen, 
          OfdmTiming.OfdmSymbolsPerFrame, SyncThreshold,
          SyncOffset);
        HwInterfaceSynchronizerStatus(true);
#endif

        ReturnStatus = RxDemodulateBufferData(DebugMode,
          RX_DEMODULATE_TX_LOOPBACK, FileNumber, 
          OfdmParams.ModOrder, OfdmParams.Nfft, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame, &OfdmCalcParams,
          SwSynchronization);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        break;

      case 11:
        printf("Write file number: ");
        ScanfRet = scanf("%d", &FileNumber);
        printf("Enter Thread Selection ('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &RxThread);
#ifndef NO_DEVMEM
        ReturnStatus = HwInterfaceConfigureSynchronizer(
          OfdmParams.Nfft, OfdmParams.CpLen, 
          OfdmTiming.OfdmSymbolsPerFrame, SyncThreshold,
          SyncOffset);
        HwInterfaceSynchronizerStatus(true);
        HwInterfaceEnableAdc();
        ReturnStatus = DacChainSetDacParams(OfdmParams.BandWidth,
          CenterFreq, true);
#endif
        if (RxThread == 1)
        {
          ReturnStatus = RxDemodulateCreateThread(DebugMode, FileNumber,
            OfdmParams.ModOrder, OfdmParams.Nfft, OfdmParams.CpLen,
            OfdmTiming.OfdmSymbolsPerFrame, &OfdmCalcParams,
            SwSynchronization);
          if (ReturnStatus.Status == RETURN_STATUS_FAIL)
          {
            printf("%s", ReturnStatus.ErrString);
          }
        }
        else
        {
          RxDemodulateCancelThread();
        }
        break;

      case 12:
        printf("Write file number: ");
        ScanfRet = scanf("%d", &FileNumber);
#ifndef NO_DEVMEM
        HwInterfaceConfigureSynchronizer(OfdmParams.Nfft, 
          OfdmParams.CpLen, OfdmTiming.OfdmSymbolsPerFrame,
          SyncThreshold, SyncOffset);
        HwInterfaceSynchronizerStatus(true);
#endif
        ReturnStatus = RxDemodulateBufferData(DebugMode, 
          RX_DEMODULATE_FILE_INJECTION, FileNumber, OfdmParams.ModOrder,
          OfdmParams.Nfft, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame, &OfdmCalcParams,
          SwSynchronization);
        break;

      case 13:
        printf("Write file number: ");
        ScanfRet = scanf("%d", &FileNumber);
        ReturnStatus = Ber(true, FileNumber, OfdmParams.ModOrder,
          OfdmTiming.OfdmSymbolsPerFrame, &OfdmCalcParams);
        ReturnStatus = Ber(false, FileNumber, OfdmParams.ModOrder,
          OfdmTiming.OfdmSymbolsPerFrame, &OfdmCalcParams);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        break;

      case 14:
        ReturnStatus = DirectDmaPlToPsThread();
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
        }
        break;

      case 15:
        DirectDmaPlToPsThreadCancel();
        break;

      case 16:
        printf("Enable/Disable DMA loopback ('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &DmaLoopSel);
        HwInterfaceDmaLoopback(DmaLoopSel);
        printf("Enable/Disable Synchronizer Loopback "
          "('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &DmaLoopSel);
        HwInterfaceSyncLoopback(DmaLoopSel);
        printf("Enable/Disable Internal DUC/DDC Loopback (WARNING: "
          "Need Special Bitstream) ('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &DucDdcLoopSel);
        DacChainSetLoopback(DucDdcLoopSel);
#ifndef NO_DEVMEM
        if (DucDdcLoopSel == 1)
        {
          HwInterfaceSetDmaTlastGen(DucDdcLoopSel,(OfdmParams.Nfft+
            OfdmParams.CpLen)*(OfdmTiming.OfdmSymbolsPerFrame+1));
        }
        else
        {
          HwInterfaceSetDmaTlastGen(DucDdcLoopSel,0);
        }
#endif
        break;

      case 17:
        printf("SW RX Synchronization Symbol ('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &DebugSelection);
        if (DebugSelection == 1)
        {
          SwSynchronization = true;
          DirectDmaSetNumBytesForLoopback((OfdmParams.Nfft+
            OfdmParams.CpLen)*(OfdmTiming.OfdmSymbolsPerFrame+1)*4);
        }
        else
        {
          SwSynchronization = false;
          DirectDmaSetNumBytesForLoopback((OfdmParams.Nfft+
            OfdmParams.CpLen)*OfdmTiming.OfdmSymbolsPerFrame*4);
        }
        printf("SW TX Synchronization Symbol ('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &DebugSelection);
        if (DebugSelection == 1)
        {
          SwSynchronizationTx = true;
        }
        else
        {
          SwSynchronizationTx = false;
        }
        break;

      default:
        printf("Invalid selection\n");
    }
  } while (Selection);

  // Cleanup
  printf("%d\n", ScanfRet);
  DirectDmaPlToPsThreadCancel();
  RxDemodulateCancelThread();
  DirectDmaMm2sStatus();
  DirectDmaS2mmStatus();
  HwInterfaceDisableDac();         // Disable DAC and PA
  HwInterfaceDisableAdc();         // Disable ADC
  HwInterfaceSynchronizerStatus(false);

  return 0;
}
