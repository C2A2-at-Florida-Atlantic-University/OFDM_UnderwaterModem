//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include "ReturnStatus.h"
#include "FpgaInterface.h"
#include "TransmitChain.h"
#include "TxModulate.h"
#include "RxDemodulate.h"
#include "DacChain.h"
#include "rtwtypes.h"
#include "DirectDma.h"
#include "HwInterface.h"
#include "Ber.h"
#include "Power.h"

#define DEBUG

Ofdm_Parameters_Type OfdmParams;
Ofdm_Timing_Type OfdmTiming;
Calculated_Ofdm_Parameters OfdmCalcParams;
Dac_Parameters_Type DacParams;
static FILE *OfdmInfoFile;
static FILE *PresetFile = NULL;

int main(int argc, char **argv)
{
  //double GainSel;
  unsigned Selection;
  unsigned ScanfRet; // To get rid of warnings
  unsigned CenterFreq;
  unsigned NumBytes;
  unsigned LoopbackBytes;
  unsigned DmaLoopSel;
  unsigned SyncLoopSel;
  unsigned SyncGuardLoopSel;
  unsigned ScalarGain;
  unsigned RxThread;
  unsigned SyncThreshold;
  unsigned CwIqScale;
  unsigned PadSamples;
  unsigned FirCicIsFir;
  unsigned AdcSampleSave;
  unsigned DacSampleSave;
  unsigned FirSampleSave;
  unsigned SampleSave;
  double TxGainDbTime;
  double SyncSymbolGainDB;
  int SyncOffset;
  int TxGainDb;
  int RxGainDb;
  int DebugSelection;
  bool DebugMode;
  bool GlobalMute;
  bool SwSynchronization;
  char FileName[32];
  char PresetFileName[32];
  unsigned TxOff;
  ReturnStatusType ReturnStatus;

  printf("\n----- OFDM RADIO TEST APPLICATION -----\n\n");
  if (argc == 1)
  {
    printf("Warning: Did not select TX off/on\n");
    printf("\tEX: ofdm 0 - (PA + DAC always off)\n");
    printf("\tEX: ofdm 1 - (PA + DAC controlled)\n");
    printf("Exiting\n");
    return 1;
    //printf("Default to TX on\n");
    //TxOff = 0;
  }
  else if (argc >= 2)
  {
    if (!(atoi(argv[1])))
    {
      printf("\nSelected TX always off\n\n");
      TxOff = 1;
    }
    else if (atoi(argv[1]))
    {
      printf("\nSelected TX control\n\n");
      TxOff = 0;
    }
    else
    {
      printf("Error: Wrong arguments\n");
      printf("\tEX: ofdm 0\n");
      printf("\tEX: ofdm 1\n");
      return 1;
    }
  }
  else
  {
    printf("Error: Wrong arguments\n");
    printf("\tEX: ofdm TX\n");
    return 1;
  }

  if (argc == 3)
  {
    printf("Selecting preset %d\n", atoi(argv[2]));
    sprintf(PresetFileName,"files/preset/preset_%d.txt", 
      atoi(argv[2]));
    PresetFile = fopen(PresetFileName,"r");
    if (PresetFile == NULL)
    {
      printf("Error: Could not open %s, Exiting\n", PresetFileName);
      return 1;
    }
    ScanfRet = fscanf(PresetFile, "%d", &OfdmParams.Nfft);
    ScanfRet = fscanf(PresetFile, "%lf", &OfdmParams.BandWidth);
    ScanfRet = fscanf(PresetFile, "%d", &OfdmParams.CpLen);
    ScanfRet = fscanf(PresetFile, "%d", &OfdmParams.ModOrder);
    ScanfRet = fscanf(PresetFile, "%d", &OfdmParams.ZpDensity);
    ScanfRet = fscanf(PresetFile, "%d", &OfdmTiming.SymbolGuardPeriod);
    ScanfRet = fscanf(PresetFile, "%d", &OfdmTiming.FrameGuardPeriod);
    ScanfRet = fscanf(PresetFile, "%d", &OfdmTiming.OfdmSymbolsPerFrame);
    ScanfRet = fscanf(PresetFile, "%d", &TxGainDb);
    ScanfRet = fscanf(PresetFile, "%lf", &TxGainDbTime);
    ScanfRet = fscanf(PresetFile, "%lf", &SyncSymbolGainDB);
    ScanfRet = fscanf(PresetFile, "%d", &RxGainDb);
    ScanfRet = fscanf(PresetFile, "%X", &SyncThreshold);
    ScanfRet = fscanf(PresetFile, "%d", &SyncOffset);
    ScanfRet = fscanf(PresetFile, "%d", &CenterFreq);
    printf("\nPreset Config Parameters:\n");
  }
  else
  {
    printf("No preset selected, using default values\n");
    // Set default values
    OfdmParams.Nfft = DEFAULT_NFFT;
    OfdmParams.BandWidth = DEFAULT_BANDWIDTH;
    OfdmParams.CpLen = DEFAULT_CP_LEN;
    OfdmParams.ModOrder = DEFAULT_MOD_ORDER;
    OfdmParams.ZpDensity = DEFAULT_ZP_DENSITY;

    OfdmTiming.SymbolGuardPeriod = DEFAULT_SYMBOL_GUARD_PERIOD;
    OfdmTiming.FrameGuardPeriod = DEFAULT_FRAME_GUARD_PERIOD;
    OfdmTiming.OfdmSymbolsPerFrame = DEFAULT_SYMBOlS_PER_FRAME;

    TxGainDb = DEFAULT_FREQ_DIGITAL_GAIN_DBFS;
    TxGainDbTime = DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB;
    SyncSymbolGainDB = DEFAULT_ADDITIONAL_SYNCHRONIZATION_GAIN_DB;
    RxGainDb = DEFAULT_RX_GAIN_DB;

    SyncThreshold = DEFAULT_SYNC_THRESHOLD;
    SyncOffset = DEFAULT_SYNCHRONIZER_OFFSET;

    CenterFreq = DEFAULT_CENTER_FREQUENCY_KHZ;
    printf("\nDefault Config Parameters:\n");
  }
  printf("\tNfft: %d\n",OfdmParams.Nfft);
  printf("\tBandWidth: %lf kHz\n", OfdmParams.BandWidth);
  printf("\tCpLen: %d\n", OfdmParams.CpLen);
  printf("\tModOrder: %d\n", OfdmParams.ModOrder);
  printf("\tZpDensity: %d%%\n", OfdmParams.ZpDensity);
  printf("\tSymbol Guard Period: %d ms\n", OfdmTiming.SymbolGuardPeriod);
  printf("\tFrame Guard Period: %d ms \n", OfdmTiming.FrameGuardPeriod);
  printf("\tSymbols Per Frame: %d\n", OfdmTiming.OfdmSymbolsPerFrame);
  printf("\tIFFT gain: %ddB\n", TxGainDb);
  printf("\tTx Time Domain Gain: %lf dB\n", TxGainDbTime);
  printf("\tSynchronization Symbol Gain: %lf dB\n", SyncSymbolGainDB);
  printf("\tRx Gain: %d dB\n", RxGainDb);
  printf("\tSynchronization Threshold: 0x%X\n", SyncThreshold);
  printf("\tSynchronization Offset: %d samples\n", SyncOffset);
  printf("\tCenter Frequency: %d kHz\n\n", CenterFreq);

  SwSynchronization = false;
  SyncLoopSel = 0;
  FirCicIsFir = 1; // Select FIR by default
  AdcSampleSave = 0; // Select full demod path
  DacSampleSave = 0;
  FirSampleSave = 0;

  SwSynchronization = false;
  SyncLoopSel = 0;
  GpReg0 = 1; // Select FIR by default
  GpReg1 = 0; // Select full demod path

  ReturnStatus = FpgaInterfaceSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    return 1;
  }

  LoopbackBytes = 0;
  DmaLoopSel = 0;

#ifndef NO_DEVMEM                  // HW specific functions
  usleep(1000);
  HwInterfaceSetGlobalMute(true);  // mute FPGA reg access prints
  DirectDmaSetGlobalMute(true);    // mute FPGA reg access prints
  DirectDmaPsToPlInit(0);          // Reset mm2s DMA
  DirectDmaPlToPsInit(0);          // Reset s2mm DMA
  DirectDmaMm2sIrqClear();         // Clear IRQ for mm2s DMA
  DirectDmaS2mmIrqClear();         // Clear IRQ for s2mm DMA
  DirectDmaMm2sStatus();           // DMA mm2s status
  DirectDmaS2mmStatus();           // DMA s2mm status
  HwInterfaceDmaLoopback(0);       // Disable DMA loopback 
  HwInterfaceSyncLoopback(0);      // Disable Synchronizer loopback
  HwInterfaceSyncGuardLoopback(0); // Disable Synchronizer loopback
  HwInterfaceDisableDac();         // Disable DAC and PA
  HwInterfaceDisableAdc();         // Disable ADC
  HwInterfaceResetTrigger();
  HwInterfaceGpReg0(1);
  HwInterfaceGpReg1(0);
  HwInterfaceSetDacSampleSave(DacSampleSave);
  HwInterfaceSetFirSampleSave(FirSampleSave);
  ReturnStatus = HwInterfaceConfigureSynchronizer(OfdmParams.Nfft, 
    OfdmParams.CpLen, OfdmTiming.OfdmSymbolsPerFrame,
    SyncThreshold, SyncOffset);
  HwInterfaceSynchronizerStatus(false);
  HwInterfaceSineToneSet(0);
#endif

  ReturnStatus = DacChainSetDacParams(OfdmParams.BandWidth,
    CenterFreq, false);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
  }
  ReturnStatus = TxModulateDigitalGain(TxGainDb);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
  }
  TxModulateSetIfftGain(TxGainDbTime);
  TxModulateSetSyncGain(SyncSymbolGainDB);
  ScalarGain = TxModulateGetScalarGain();
  TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
  OfdmCalcParams = TransmitChainGetParams();
  DacParams = DacChainGetDacParams();
  HwInterfaceSetGuardPeriod(
    OfdmCalcParams.SymbolGuard.FpgaClkSamples);


#ifndef NO_DEVMEM
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
#endif
  
  ReturnStatus = HwInterfaceSetVga(RxGainDb);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
  }

  printf("\n----- DEFAULTS -----\n");
  printf("Debug Mode Enabled\n");
  DebugMode = true;
  printf("FIR based DUC/DDC enabled by default\n");
  printf("--------------------\n\n");

  do {
    usleep(1000); // Give some time for prints from threads
    if (FirCicIsFir)
      printf("\nFIR based DUC/DDC selected\n");
    else
      printf("\nCIC based DUC/DDC selected\n");

    if (AdcSampleSave)
      printf("Saving raw ADC samples to SD card\n");
    else if (DacSampleSave)
      printf("Saving raw DAC samples to SD card\n");
    else
      printf("Full demod path selected\n");

    printf("\n----- MODEM MENU -----\n");
    printf("0  - Exit\n");
    printf("1  - Set Debug/HW Features\n");
    printf("2  - Enter OFDM Parameters\n");
    printf("3  - Enter OFDM Timing Parameters\n");
    printf("4  - Enter TX/RX Gain (dBFS)/(dB)\n");
    printf("5  - Enter Center Frequency\n");
    printf("6  - Enter Synchronizer Parameters\n");
    printf("7  - Display OFDM Parameters\n");
    printf("8  - Transmit Single OFDM Frame\n");
    printf("9  - Demod TX Buffer\n");
    printf("10 - Start/Stop RX Demod Thread\n");
    printf("11 - Start S2MM DMA\n");
    printf("12 - Stop S2MM DMA\n");
    printf("13 - Enable/Disable CW Tone\n");
    printf("14 - Set Loopback Mode\n");
    printf("15 - Set GP Regs\n");
    printf("=> ");
    ScanfRet = scanf("%d", &Selection);
    printf("\n");

    switch (Selection) {
      case 0:
        break;

//////////////////////////////////////////////////////////////////////////
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

//////////////////////////////////////////////////////////////////////////
      case 2:
        printf("\tEnter number of sub-carriers: ");
        ScanfRet = scanf("%d", &OfdmParams.Nfft);
        printf("\tEnter BandWidth (Sample Frequency) in kHz: ");
        ScanfRet = scanf("%lf", &OfdmParams.BandWidth);
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
        break;

//////////////////////////////////////////////////////////////////////////
      case 3:
        printf("\tEnter Symbol Guard Period in ms: ");
        ScanfRet = scanf("%d", &OfdmTiming.SymbolGuardPeriod);
        //printf("\tEnter Frame Guard Period in ms: ");
        //ScanfRet = scanf("%d", &OfdmTiming.FrameGuardPeriod);
        printf("\tEnter OFDM Symbols per Frame: ");
        ScanfRet = scanf("%d", &OfdmTiming.OfdmSymbolsPerFrame);
        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        OfdmCalcParams = TransmitChainGetParams();
        HwInterfaceSetGuardPeriod(
          OfdmCalcParams.SymbolGuard.FpgaClkSamples);
        break;

//////////////////////////////////////////////////////////////////////////
      case 4:
        printf("\tEnter TX Frequency Domain Digital Gain (Default: "
          "%d dBFS): ", DEFAULT_FREQ_DIGITAL_GAIN_DBFS);
        ScanfRet = scanf("%d", &TxGainDb);
        printf("\tEnter TX Time Domain Digital Gain (Default: "
          "%lf dB): ", DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB);
        ScanfRet = scanf("%lf", &TxGainDbTime);
        printf("\tEnter Extra Synchronization Symbol Gain (Default: "
          "%lf dB): ", DEFAULT_ADDITIONAL_SYNCHRONIZATION_GAIN_DB);
        ScanfRet = scanf("%lf", &SyncSymbolGainDB);
        printf("\tEnter RX Gain (Default: %d dB): ", DEFAULT_RX_GAIN_DB);
        ScanfRet = scanf("%d", &RxGainDb);
        ReturnStatus = TxModulateDigitalGain(TxGainDb);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          TxGainDb = DEFAULT_FREQ_DIGITAL_GAIN_DBFS;
        }
        TxModulateSetIfftGain(TxGainDbTime);
        TxModulateSetSyncGain(SyncSymbolGainDB);
#ifndef NO_DEVMEM
        ReturnStatus = HwInterfaceSetVga(RxGainDb);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
        }
#endif
        break;

//////////////////////////////////////////////////////////////////////////
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
        printf("\tTurn DAC + PA on ('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &DebugSelection);
        if (DebugSelection == 1)
        {
          HwInterfaceEnableDac();
        }
        else
        {
          HwInterfaceDisableDac();
        }
        break;

//////////////////////////////////////////////////////////////////////////
      case 6:
        printf("\tEnter Synchronizer Threshold (DEFAULT: "
          "0x%X): ", DEFAULT_SYNC_THRESHOLD);
        ScanfRet = scanf("%x", &SyncThreshold);
        printf("\tEnter Synchronizer Offset (-1024:1024) (DEFAULT: "
          "%d): ", DEFAULT_SYNCHRONIZER_OFFSET);
        ScanfRet = scanf("%d", &SyncOffset);
        ReturnStatus = HwInterfaceConfigureSynchronizer(
          OfdmParams.Nfft, OfdmParams.CpLen, 
          OfdmTiming.OfdmSymbolsPerFrame, SyncThreshold, SyncOffset);
        HwInterfaceSynchronizerStatus(true);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
        }
        break;

//////////////////////////////////////////////////////////////////////////
      case 7:
        printf("\t------ User Parameters ------\n");
        printf("\tNFFT:                     %d\n", OfdmParams.Nfft);
        printf("\tBandwidth:                %lf kHz\n", 
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
        printf("\n\tSub-Carrers Digital Gain: %d dBFS = %d\n",
          TxGainDb, TxModulateGetScalarGain());
        printf("\tTX IFFT Gain:             %lf dB = %lf\n",
          TxGainDbTime, TxModulateGetIfftGain());
        printf("\tSync Symbol Extra Gain    %lf dB = %lf\n",
          SyncSymbolGainDB, TxModulateGetSyncGain());
        printf("\tRX Gain dB                %d dB\n",
          RxGainDb);
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
          (double)OfdmCalcParams.NumZpCarriers/
          (double)OfdmParams.Nfft*100.0);
        printf("\tFirst Pilot Carrier:      %d\n",
          OfdmCalcParams.FirstPilotCarrier+1);
        printf("\tLast Pilot Carrier:       %d\n",
          OfdmCalcParams.LastPilotCarrier);
        printf("\tNumber of Data Carriers:  %d\n",
          OfdmCalcParams.NumDataCarriers);
        printf("\tNumber of Pilot Carriers: %d\n",
          OfdmCalcParams.NumPilotCarriers);
        printf("\tNumber of ZP Carriers:    %d\n",
          OfdmCalcParams.NumZpCarriers);
        printf("\n\tInterpolation Value       %dx\n", DacParams.Interp);
        printf("\n\t100MHz Cycles per:\n");
        printf("\t  Sample:                 %d\n",
          OfdmCalcParams.Symbol.FpgaClkSamples);
        printf("\t  Symbol Guard Period:    %d\n",
          OfdmCalcParams.SymbolGuard.FpgaClkSamples);
        printf("\t  Frame Guard Period:     %d\n\n",
          OfdmCalcParams.FrameGuard.FpgaClkSamples);
        //TransmitChainPrintCalcParams(&OfdmCalcParams);
        break;

//////////////////////////////////////////////////////////////////////////
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

        ReturnStatus = TxAllocateQamFileData(OfdmParams.ModOrder, 
          OfdmParams.Nfft, OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }

        ReturnStatus = TxModulateIfft(DebugMode, OfdmParams.Nfft,
          OfdmParams.ModOrder, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame, 13);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }

        ReturnStatus = Power(OfdmParams.Nfft, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame, TxModulateGetIfftGain(), 1,
          NULL);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          TxModulateFreeTxBuffer();
          break;
        }
        
        NumBytes = ((OfdmParams.Nfft+OfdmParams.CpLen)*
          (OfdmTiming.OfdmSymbolsPerFrame)+NFFT_ZC+OfdmParams.CpLen)*4;
        if (DmaLoopSel)
        {
          printf("Setting Pad samples to 0 for DMA loopback\n");
          PadSamples = 0;
        }
        else
        {
          printf("Allocating Pad samples for FIR filter\n");
          PadSamples = NUM_DUC_DDC_COEF/2 + NUM_PAD_SAMPLES;
        }
        NumBytes = NumBytes + (PadSamples * 4);
/*
        if (TxOff)
        {
          DirectDmaSetTxBufferLoop(1);
          printf("Skipping TX transmission and exiting. "
            "Buffer available for demodulation\n");
          break;
        }
*/
#ifndef NO_DEVMEM
        HwInterfaceSetTrigger();
        ReturnStatus = DacChainSetDacParams(OfdmParams.BandWidth,
          CenterFreq, true);
        ReturnStatus = HwInterfaceConfigureSynchronizer(
          OfdmParams.Nfft, OfdmParams.CpLen, 
          OfdmTiming.OfdmSymbolsPerFrame, SyncThreshold,
          SyncOffset);
        HwInterfaceSynchronizerStatus(true);
        HwInterfaceEnableDac();
        if (FirCicIsFir == 0)
        {
          //HwInterfaceSetMixerGain(2);  // Validated For CIC
          //PowerExtraTxGain(2.9,NumBytes/4); // Validated 
          HwInterfaceSetMixerGain(1);// For CIC
          //PowerExtraTxGain(2.8,NumBytes/4); // 6dB loss in Mixer
          PowerExtraTxGain(0,NumBytes/4); // 6dB loss in Mixer
        }
        else
        {
          //printf("Enter FIR gain (default 2): ");
          //ScanfRet = scanf("%lf", &GainSel);
          //HwInterfaceSetFirGain((unsigned)GainSel);
          //printf("Enter TX gain (default 0): ");
          //ScanfRet = scanf("%lf", &GainSel);
          //PowerExtraTxGain(GainSel,NumBytes/4); // 6dB loss in DUC FIR
          //printf("Enter mixer gain (default 2): ");
          //ScanfRet = scanf("%lf", &GainSel);
          //HwInterfaceSetMixerGain((unsigned)GainSel);// For FIR
          if (OfdmParams.BandWidth == 250.0)
          {
            HwInterfaceSetMixerGain(2);// For FIR
            PowerExtraTxGain(0.0,NumBytes/4); // 6dB loss in DUC FIR
            HwInterfaceSetFirGain(2);
          }
          else if (OfdmParams.BandWidth == 100.0)
          {
            HwInterfaceSetMixerGain(2);// For FIR
            PowerExtraTxGain(0.0,NumBytes/4); // 6dB loss in DUC FIR
            HwInterfaceSetFirGain(1);
          }
          else if (OfdmParams.BandWidth == 50.0)
          {
            HwInterfaceSetMixerGain(2);
            PowerExtraTxGain(0.0,NumBytes/4); // 6dB loss in DUC FIR
            HwInterfaceSetFirGain(1);
          }
          else
          {
            HwInterfaceSetMixerGain(2);// For FIR
            PowerExtraTxGain(0.0,NumBytes/4); // 6dB loss in DUC FIR
            HwInterfaceSetFirGain(2);
          }
        }
        HwInterfaceTxOn(~TxOff);
        HwInterfaceGpReg0(FirCicIsFir);
        ReturnStatus = DirectDmaPsToPl(NumBytes);
        printf("Wait for %lfus to finish Transmission ... \n",
          OfdmCalcParams.Symbol.Time*(OfdmTiming.OfdmSymbolsPerFrame+
          1)*2*1000);
        usleep(OfdmCalcParams.Symbol.Time*(
          OfdmTiming.OfdmSymbolsPerFrame+1)*2*1000);
        if (TxOff)
        {
          printf("\n\tTX transmission turned off -- no output\n");
        }
        //HwInterfaceDisableDac();
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
        }
        ReturnStatus = PowerPeakDuc();
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
        }
        printf("Finished\n");
       break;
#else
        printf("Skipped DMA transfer of : %d Bytes\n", NumBytes);
#endif
        break;

//////////////////////////////////////////////////////////////////////////
      case 9:
        ReturnStatus = RxDemodulateBufferData(DebugMode, true,
          OfdmParams.ModOrder, OfdmParams.Nfft, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }

        ReturnStatus = Ber(false, OfdmParams.ModOrder,
          OfdmTiming.OfdmSymbolsPerFrame, &OfdmCalcParams);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        break;

//////////////////////////////////////////////////////////////////////////
      case 10:
        printf("Enter Thread Selection ('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &RxThread);
#ifndef NO_DEVMEM
        if (SyncLoopSel)
        {
          if (SyncGuardLoopSel)
          {
            HwInterfaceSetGuardPeriod(
              OfdmCalcParams.SymbolGuard.FpgaClkSamples);
          }
          else
          {
            printf("Setting Guard Period to 0 for DMA loopback\n");
            // Set guard period to 2 samples, 0 will mess up state machine
            HwInterfaceSetGuardPeriod(0);
          }
        }
        else
        {
          HwInterfaceSetGuardPeriod(
            OfdmCalcParams.SymbolGuard.FpgaClkSamples);
        }
        ReturnStatus = HwInterfaceConfigureSynchronizer(
          OfdmParams.Nfft, OfdmParams.CpLen, 
          OfdmTiming.OfdmSymbolsPerFrame, SyncThreshold,
          SyncOffset);
        HwInterfaceSynchronizerStatus(true);
        ReturnStatus = HwInterfaceLoadZcSequence(OfdmParams.Nfft, 0,
          OfdmParams.BandWidth);
        ReturnStatus = HwInterfaceLoadZcSequence(OfdmParams.Nfft, 1,
          OfdmParams.BandWidth);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
          break;
        }
        HwInterfaceEnableAdc();
        HwInterfaceSetMixerGain(2); // 6dB loss in Mixer
        if (FirCicIsFir == 0)
        {
          HwInterfaceSetFirGain(2);
          HwInterfaceSetDdcGain(1);
        }
        else
        {
          if (OfdmParams.BandWidth == 250.0)
          {
            HwInterfaceSetFirGain(3);
            HwInterfaceSetDdcGain(1);
          }
          else if (OfdmParams.BandWidth == 100.0)
          {
            HwInterfaceSetFirGain(3);
            HwInterfaceSetDdcGain(0);
          }
          else if (OfdmParams.BandWidth == 50.0)
          {
            HwInterfaceSetFirGain(3);
            HwInterfaceSetDdcGain(0);
          }
          else
          {
            HwInterfaceSetFirGain(3);
            HwInterfaceSetDdcGain(1);
          }
        }
        HwInterfaceSetTrigger();
        ReturnStatus = DacChainSetDacParams(OfdmParams.BandWidth,
          CenterFreq, true);
        HwInterfaceGpReg0(FirCicIsFir);
#endif
        if (RxThread == 1)
        {
          ReturnStatus = RxDemodulateCreateThread(DebugMode,
            OfdmParams.ModOrder, OfdmParams.Nfft, OfdmParams.CpLen,
            OfdmTiming.OfdmSymbolsPerFrame, &OfdmCalcParams,
            SwSynchronization, LoopbackBytes, DacSampleSave);
          if (ReturnStatus.Status == RETURN_STATUS_FAIL)
          {
            printf("%s", ReturnStatus.ErrString);
            break;
          }
        }
        else
        {
          RxDemodulateCancelThread();
        }
        break;

//////////////////////////////////////////////////////////////////////////
#ifndef NO_DEVMEM
      case 11:
        HwInterfaceResetTrigger();
        printf("AdcSave = %d, DacSave = %d\n", AdcSampleSave,
          DacSampleSave);
        ReturnStatus=DirectDmaPlToPsThread(AdcSampleSave||DacSampleSave);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          printf("%s", ReturnStatus.ErrString);
        }
        break;

//////////////////////////////////////////////////////////////////////////
      case 12:
        DirectDmaPlToPsThreadCancel();
        break;

//////////////////////////////////////////////////////////////////////////
      case 13:
        printf("Enable Sine Tone at Fc ('0'-Off / '1'On): ");
        ScanfRet = scanf("%d", &DebugSelection);
        if (DebugSelection == 1)
        {
          printf("Enter 32-bit IQ Scalar Value: ");
          ScanfRet = scanf("%x", &CwIqScale);
          HwInterfaceSineToneSet(CwIqScale);
        }
        else
        {
          HwInterfaceSineToneSet(0);
        }
        break;
#endif

//////////////////////////////////////////////////////////////////////////
      case 14:
        printf("Enable/Disable DMA loopback ('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &DmaLoopSel);
        if (DmaLoopSel)
        {
          DirectDmaSetNumBytesForLoopback(((OfdmParams.Nfft+
            OfdmParams.CpLen)*(OfdmTiming.OfdmSymbolsPerFrame+1)+
            NFFT_ZC+OfdmParams.CpLen)*4);
          SwSynchronization = true;
        }
        else
        {
          SwSynchronization = false;
        }
        HwInterfaceDmaLoopback(DmaLoopSel);
        printf("Enable/Disable Synchronizer Loopback "
          "('0'-Off / '1'-On): ");
        ScanfRet = scanf("%d", &SyncLoopSel);
        HwInterfaceSyncLoopback(SyncLoopSel);
        if (SyncLoopSel)
        {
          printf("Enable/Disable guard module in sync loopback: "
            "('0'-Off / '1'-On): ");
          ScanfRet = scanf("%d", &SyncGuardLoopSel);
          HwInterfaceSyncGuardLoopback(SyncGuardLoopSel);
        }
        else
        {
          HwInterfaceSyncGuardLoopback(0);
        }
        break;

//////////////////////////////////////////////////////////////////////////
      case 15:
        printf("GP Reg 0 ('0'-CIC / '1'-FIR DUC/DDC): ");
        ScanfRet = scanf("%d", &FirCicIsFir);
        HwInterfaceGpReg0(FirCicIsFir);
        printf("GP Reg 0 ('0'-Normal Demod Path / '1'-Save Raw "
          "ADC/DAC samples): ");
        ScanfRet = scanf("%d", &SampleSave);
        if (SampleSave)
        {
          printf("Save Raw ADC samples: ('0'-Off / '1'-On): ");
          ScanfRet = scanf("%d", &AdcSampleSave);
          HwInterfaceGpReg1(AdcSampleSave);
          printf("Save Raw DAC samples: ('0'-Off / '1'-On): ");
          ScanfRet = scanf("%d", &DacSampleSave);
          HwInterfaceSetDacSampleSave(DacSampleSave);
          if (AdcSampleSave) // Save ADC samples
          {
            LoopbackBytes = (OfdmParams.Nfft+
              OfdmParams.CpLen)*(OfdmTiming.OfdmSymbolsPerFrame)*4*
              DacParams.Interp*4;
            DirectDmaSetNumBytesForLoopback(LoopbackBytes);
          }
          else if (DacSampleSave)
          {
            printf("Save samples at interpolator output: "
              "('0'-No / '1'-Yes): ");
            ScanfRet = scanf("%d", &FirSampleSave);
            HwInterfaceSetFirSampleSave(FirSampleSave);
            if (FirSampleSave)
            {
              HwInterfaceSetFirstDacSampleSave((NFFT_ZC+
                OfdmParams.CpLen)*DacParams.Interp);
              LoopbackBytes = (OfdmParams.Nfft+
                OfdmParams.CpLen)*(OfdmTiming.OfdmSymbolsPerFrame)*4*2*
                DacParams.Interp;
            }
            else
            {
              HwInterfaceSetFirstDacSampleSave((NFFT_ZC+
                OfdmParams.CpLen)*DacParams.Interp);
              LoopbackBytes = (OfdmParams.Nfft+
                OfdmParams.CpLen)*(OfdmTiming.OfdmSymbolsPerFrame)*4*
                DacParams.Interp;
            }
            DirectDmaSetNumBytesForLoopback(LoopbackBytes);
          }
          else
            LoopbackBytes = 0;
        }
        break;

//////////////////////////////////////////////////////////////////////////
      default:
        printf("Invalid selection\n");
    }

    sprintf(FileName, "files/OfdmInfo%d.txt", 1);
    OfdmInfoFile = fopen(FileName,"w");
    if (OfdmInfoFile == NULL)
    {
      printf("Failed to write to OfdmInfoFile\n");
      break;
    }
    fprintf(OfdmInfoFile, "%d,\n%lf,\n%d,\n%d,\n%d,\n%d,\n%d,"
      "\n%d,\n%d,\n%d,\n%lf,\n%lf\n",
      OfdmParams.Nfft, OfdmParams.BandWidth, OfdmParams.CpLen,
      OfdmParams.ModOrder, OfdmParams.ZpDensity,
      OfdmTiming.SymbolGuardPeriod, OfdmTiming.FrameGuardPeriod,
      OfdmTiming.OfdmSymbolsPerFrame, CenterFreq, ScalarGain,
      TxModulateGetIfftGain(), TxModulateGetSyncGain());
    fclose(OfdmInfoFile);

    if (ReturnStatus.Status == RETURN_STATUS_FAIL)
    {
      printf("ERROR: Continue OFDM Radio Test? ('0'-No / '1'-Yes): ");
      ScanfRet = scanf("%d", &DebugSelection);
      if (!(DebugSelection == 1))
      {
        printf("Exiting ... \n");
        break;
      }
      ReturnStatus.Status = RETURN_STATUS_SUCCESS;
    }

  } while (Selection);

  // Cleanup
  printf("%d\n", ScanfRet);
  printf("%d\n", TxOff);
#ifndef NO_DEVMEM
  DirectDmaPlToPsThreadCancel();
  RxDemodulateCancelThread();
  DirectDmaMm2sStatus();
  DirectDmaS2mmStatus();
  HwInterfaceDisableDac();         // Disable DAC and PA
  HwInterfaceDisableAdc();         // Disable ADC
#endif
  HwInterfaceSynchronizerStatus(false);

  return 0;
}
