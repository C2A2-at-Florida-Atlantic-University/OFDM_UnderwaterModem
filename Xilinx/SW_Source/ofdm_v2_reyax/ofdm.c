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
#include "Reyax.h"

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
  unsigned ScanfRet = 1; // To get rid of warnings
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
  int ReyaxAddress = -1;
  int ReyaxNetworkID = -1;
  bool DebugMode;
  bool GlobalMute;
  bool SwSynchronization;
  char FileName[32];
  char PresetFileName[32];
  unsigned TxOff;
  ReturnStatusType ReturnStatus;

  ReturnStatus = ReyaxSerialSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
    return 1;
  }
  ReturnStatus = ReyaxSetup(ReyaxAddress,ReyaxNetworkID);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
    return 1;
  }
  ReyaxInitMessage();

  ReyaxTtyMessageSend("\n----- OFDM RADIO TEST APPLICATION -----\n");
  if (argc == 1)
  {
    ReyaxTtyMessageSend("Warning: Did not select TX off/on");
    ReyaxTtyMessageSend("Usage: ./ofdm <PA 0/1> "
      "<Preset#> --address=<value> ");
    ReyaxTtyMessageSend("--networkID=<value>");
    ReyaxTtyMessageSend("\tEX: ofdm 0 - (PA + DAC always off)");
    ReyaxTtyMessageSend("\tEX: ofdm 1 - (PA + DAC controlled)");
    ReyaxTtyMessageSend("Exiting");
    return 1;
  }
  else if (argc >= 2)
  {
    if (!(atoi(argv[1])))
    {
      ReyaxTtyMessageSend("\nSelected TX always off\n");
      TxOff = 1;
    }
    else if (atoi(argv[1]))
    {
      ReyaxTtyMessageSend("\nSelected TX control\n");
      TxOff = 0;
    }
    else
    {
      ReyaxTtyMessageSend("Error: Wrong arguments");
      ReyaxTtyMessageSend("\tEX: ofdm 0");
      ReyaxTtyMessageSend("\tEX: ofdm 1");
      return 1;
    }
  }
  else
  {
    ReyaxTtyMessageSend("Error: Wrong arguments");
    ReyaxTtyMessageSend("\tEX: ofdm TX");
    return 1;
  }

  if (argc == 3)
  {
    ReyaxTtyMessageSend("Selecting preset %d", atoi(argv[2]));
    sprintf(PresetFileName,"files/preset/preset_%d.txt", 
      atoi(argv[2]));
    PresetFile = fopen(PresetFileName,"r");
    if (PresetFile == NULL)
    {
      ReyaxTtyMessageSend("Error: Could not open %s, Exiting", 
        PresetFileName);
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
    ReyaxTtyMessageSend("\nPreset Config Parameters:");
  }
  else
  {
    ReyaxTtyMessageSend("No preset selected, using default values");
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
    ReyaxTtyMessageSend("\nDefault Config Parameters:\n");
  }

  for (int i = 1; i < argc; i++)
  {
    // Check for --address option
    if (strncmp(argv[i], "--address=", 10) == 0)
      sscanf(argv[i] + 10, "%d", &ReyaxAddress);
    else if (strncmp(argv[i], "--networkID=", 12) == 0)
    {
      char *value_str = argv[i]+12;
      ReyaxNetworkID = atoi(value_str);
    }
  }

  ReyaxTtyMessageSend("\tNfft: %d",OfdmParams.Nfft);
  ReyaxTtyMessageSend("\tBandWidth: %lf kHz", OfdmParams.BandWidth);
  ReyaxTtyMessageSend("\tCpLen: %d", OfdmParams.CpLen);
  ReyaxTtyMessageSend("\tModOrder: %d", OfdmParams.ModOrder);
  ReyaxTtyMessageSend("\tZpDensity: %d%%", OfdmParams.ZpDensity);
  ReyaxTtyMessageSend("\tSymbol Guard Period: %d ms", 
    OfdmTiming.SymbolGuardPeriod);
  ReyaxTtyMessageSend("\tFrame Guard Period: %d ms ", 
    OfdmTiming.FrameGuardPeriod);
  ReyaxTtyMessageSend("\tSymbols Per Frame: %d", 
    OfdmTiming.OfdmSymbolsPerFrame);
  ReyaxTtyMessageSend("\tIFFT gain: %ddB", TxGainDb);
  ReyaxTtyMessageSend("\tTx Time Domain Gain: %lf dB", TxGainDbTime);
  ReyaxTtyMessageSend("\tSynchronization Symbol Gain: %lf dB", 
    SyncSymbolGainDB);
  ReyaxTtyMessageSend("\tRx Gain: %d dB", RxGainDb);
  ReyaxTtyMessageSend("\tSynchronization Threshold: 0x%X", SyncThreshold);
  ReyaxTtyMessageSend("\tSynchronization Offset: %d samples", SyncOffset);
  ReyaxTtyMessageSend("\tCenter Frequency: %d kHz\n", CenterFreq);

  SwSynchronization = false;
  SyncLoopSel = 0;
  FirCicIsFir = 1; // Select FIR by default
  AdcSampleSave = 0; // Select full demod path
  DacSampleSave = 0;
  FirSampleSave = 0;

  SwSynchronization = false;
  SyncLoopSel = 0;

  ReturnStatus = FpgaInterfaceSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
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
    ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
  }
  ReturnStatus = TxModulateDigitalGain(TxGainDb);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
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
    ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
    return 1;
  }

  ReturnStatus = HwInterfaceSpiSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
    return 1;
  }
#endif
  
  ReturnStatus = HwInterfaceSetVga(RxGainDb);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
  }

  ReyaxTtyMessageSend("\n----- DEFAULTS -----");
  ReyaxTtyMessageSend("Debug Mode Enabled");
  DebugMode = true;
  ReyaxTtyMessageSend("FIR based DUC/DDC enabled by default");
  ReyaxTtyMessageSend("--------------------\n");

  do {
    usleep(1000); // Give some time for prints from threads
    if (FirCicIsFir)
      ReyaxTtyMessageSend("\nFIR based DUC/DDC selected");
    else
      ReyaxTtyMessageSend("\nCIC based DUC/DDC selected");

    if (AdcSampleSave)
      ReyaxTtyMessageSend("Saving raw ADC samples to SD card");
    else if (DacSampleSave)
      ReyaxTtyMessageSend("Saving raw DAC samples to SD card");
    else
      ReyaxTtyMessageSend("Full demod path selected");

    ReyaxTtyMessageSend("\n----- MODEM MENU -----");
    ReyaxTtyMessageSend("0  - Exit");
    ReyaxTtyMessageSend("1  - Set Debug/HW Features");
    ReyaxTtyMessageSend("2  - Enter OFDM Parameters");
    ReyaxTtyMessageSend("3  - Enter OFDM Timing Parameters");
    ReyaxTtyMessageSend("4  - Enter TX/RX Gain (dBFS)/(dB)");
    ReyaxTtyMessageSend("5  - Enter Center Frequency");
    ReyaxTtyMessageSend("6  - Enter Synchronizer Parameters");
    ReyaxTtyMessageSend("7  - Display OFDM Parameters");
    ReyaxTtyMessageSend("8  - Transmit Single OFDM Frame");
    ReyaxTtyMessageSend("9  - Demod TX Buffer");
    ReyaxTtyMessageSend("10 - Start/Stop RX Demod Thread");
    ReyaxTtyMessageSend("11 - Start S2MM DMA");
    ReyaxTtyMessageSend("12 - Stop S2MM DMA");
    ReyaxTtyMessageSend("13 - Enable/Disable CW Tone");
    ReyaxTtyMessageSend("14 - Set Loopback Mode");
    ReyaxTtyMessageSend("15 - Set GP Regs");
    ReyaxTtyMessageSend("=> ");
    ReturnStatus = ReyaxTtyDataRead(&Selection, UNSIGNED_READ);
    if (ReturnStatus.Status == RETURN_STATUS_FAIL) return 1;
    ReyaxTtyMessageSend("\n");

    switch (Selection) {
      case 0:
        break;

//////////////////////////////////////////////////////////////////////////
      case 1:
        ReyaxTtyMessageSend("Set Global File Debug Mode (Save samples "
          "to file)");
        ReyaxTtyMessageSend("Enter Selection ('0'-Off / '1'-On): ");
        ReturnStatus = ReyaxTtyDataRead(&DebugSelection, INT_READ);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL) return 1;
        if (DebugSelection == 1)
        {
          DebugMode = true;
        }
        else
        {
          DebugMode = false;
        }
        ReyaxTtyMessageSend("Enable/Disable FPGA register read/write "
          "debug");
        ReyaxTtyMessageSend("Enter Selection ('0'-Off / '1'-On): ");
        ReturnStatus = ReyaxTtyDataRead(&DebugSelection, INT_READ);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL) return 1;
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
        ReyaxTtyMessageSend("\tEnter number of sub-carriers: ");
        ReturnStatus = ReyaxTtyDataRead(&OfdmParams.Nfft, UNSIGNED_READ);
        ReyaxTtyMessageSend("\tEnter BandWidth (Sample Frequency) "
          "in kHz: ");
        ReturnStatus = ReyaxTtyDataRead(&OfdmParams.BandWidth, 
          DOUBLE_READ);
        ReyaxTtyMessageSend("\tEnter CP length in Samples: ");
        ReturnStatus = ReyaxTtyDataRead(&OfdmParams.CpLen, UNSIGNED_READ);
        ReyaxTtyMessageSend("\tEnter modulation order: ");
        ReturnStatus = ReyaxTtyDataRead(&OfdmParams.ModOrder, 
          UNSIGNED_READ);
        ReyaxTtyMessageSend("\tEnter ZP Carrier Density: ");
        ReturnStatus = ReyaxTtyDataRead(&OfdmParams.ZpDensity, 
          UNSIGNED_READ);

        ReturnStatus = TransmitChainParamCheck(&OfdmParams);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
          ReyaxTtyMessageSend("\tERROR: Reseting OFDM Parameters back "
            "to defaults");
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
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
          ReyaxTtyMessageSend("Setting default center frequency");
          CenterFreq = DEFAULT_CENTER_FREQUENCY_KHZ;
        }
        DacParams = DacChainGetDacParams();
        break;

//////////////////////////////////////////////////////////////////////////
      case 3:
        ReyaxTtyMessageSend("\tEnter Symbol Guard Period in ms: ");
        ReturnStatus = ReyaxTtyDataRead(&OfdmTiming.SymbolGuardPeriod,
          UNSIGNED_READ);
        //printf("\tEnter Frame Guard Period in ms: ");
        //ScanfRet = scanf("%d", &OfdmTiming.FrameGuardPeriod);
        ReyaxTtyMessageSend("\tEnter OFDM Symbols per Frame: ");
        ReturnStatus = ReyaxTtyDataRead(&OfdmTiming.OfdmSymbolsPerFrame,
          UNSIGNED_READ);
        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        OfdmCalcParams = TransmitChainGetParams();
        HwInterfaceSetGuardPeriod(
          OfdmCalcParams.SymbolGuard.FpgaClkSamples);
        break;

//////////////////////////////////////////////////////////////////////////
      case 4:
        ReyaxTtyMessageSend("\tEnter TX Freq Dig Gain (Def: "
          "%d dBFS): ", DEFAULT_FREQ_DIGITAL_GAIN_DBFS);
        ReyaxTtyDataRead(&TxGainDb, INT_READ);
        ReyaxTtyMessageSend("\tEnter TX Time Dig Gain "
          "(Def: %lf dB): ", DEFAULT_ADDITIONAL_TIME_DOMAIN_GAIN_DB);
        ReyaxTtyDataRead(&TxGainDbTime, DOUBLE_READ);
        ReyaxTtyMessageSend("\tEnter Extra Sync Sym Gain (Def: "
          "%lf dB): ", DEFAULT_ADDITIONAL_SYNCHRONIZATION_GAIN_DB);
        ReyaxTtyDataRead(&SyncSymbolGainDB, DOUBLE_READ);
        ReyaxTtyMessageSend("\tEnter RX Gain (Default: %d dB): ", 
          DEFAULT_RX_GAIN_DB);
        ReyaxTtyDataRead(&RxGainDb, INT_READ);
        ReturnStatus = TxModulateDigitalGain(TxGainDb);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
          TxGainDb = DEFAULT_FREQ_DIGITAL_GAIN_DBFS;
        }
        TxModulateSetIfftGain(TxGainDbTime);
        TxModulateSetSyncGain(SyncSymbolGainDB);
#ifndef NO_DEVMEM
        ReturnStatus = HwInterfaceSetVga(RxGainDb);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
        }
#endif
        break;

//////////////////////////////////////////////////////////////////////////
      case 5:
        ReyaxTtyMessageSend("\tEnter Center Frequency (kHz): ");
        ReyaxTtyDataRead(&CenterFreq, UNSIGNED_READ);
        ReturnStatus = DacChainSetDacParams(OfdmParams.BandWidth,
          CenterFreq, false);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
          ReyaxTtyMessageSend("Setting default center frequency");
          CenterFreq = DEFAULT_CENTER_FREQUENCY_KHZ;
        }
        ReyaxTtyMessageSend("\tTurn DAC + PA on ('0'-Off / '1'-On): ");
        ReyaxTtyDataRead(&DebugSelection, INT_READ);
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
        ReyaxTtyMessageSend("\tEnter Synchronizer Threshold (DEFAULT: "
          "0x%X): ", DEFAULT_SYNC_THRESHOLD);
        ReyaxTtyDataRead(&SyncThreshold, UNSIGNED_HEX_READ);
        ReyaxTtyMessageSend("\tEnter Synchronizer Offset (-1024:1024) "
          "(DEFAULT: %d): ", DEFAULT_SYNCHRONIZER_OFFSET);
        ReyaxTtyDataRead(&SyncOffset, INT_READ);
        ReturnStatus = HwInterfaceConfigureSynchronizer(
          OfdmParams.Nfft, OfdmParams.CpLen, 
          OfdmTiming.OfdmSymbolsPerFrame, SyncThreshold, SyncOffset);
        HwInterfaceSynchronizerStatus(true);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
        }
        break;

//////////////////////////////////////////////////////////////////////////
      case 7:
        ReyaxTtyMessageSend("\t------ User Parameters ------");
        ReyaxTtyMessageSend("\tNFFT:                     %d", 
          OfdmParams.Nfft);
        ReyaxTtyMessageSend("\tBandwidth:                %lf kHz", 
          OfdmParams.BandWidth);
        ReyaxTtyMessageSend("\tCP Length:                %d", 
          OfdmParams.CpLen);
        ReyaxTtyMessageSend("\tModulation Order:         %d", 
          OfdmParams.ModOrder);
        ReyaxTtyMessageSend("\tZP Pilot Density:         %d%%\n", 
          OfdmParams.ZpDensity);
        ReyaxTtyMessageSend("\tSymbol Guard Period:      %d ms",
          OfdmTiming.SymbolGuardPeriod);
        ReyaxTtyMessageSend("\tFrame Guard Period:       %d ms", 
          OfdmTiming.FrameGuardPeriod);
        ReyaxTtyMessageSend("\tSymbols per Frame         %d",
          OfdmTiming.OfdmSymbolsPerFrame);
        ReyaxTtyMessageSend("\n\tSub-Carrers Digital Gain: %d dBFS = %d",
          TxGainDb, TxModulateGetScalarGain());
        ReyaxTtyMessageSend("\tTX IFFT Gain:             %lf dB",
          TxGainDbTime);
        ReyaxTtyMessageSend("\tTX IFFT Gain:             %lf",
          TxModulateGetIfftGain());
        ReyaxTtyMessageSend("\tSync Symbol Extra Gain    %lf dB = %lf",
          SyncSymbolGainDB, TxModulateGetSyncGain());
        ReyaxTtyMessageSend("\tRX Gain dB                %d dB",
          RxGainDb);
        ReyaxTtyMessageSend("\n\tCenter Frequency:         %d kHz", 
          CenterFreq);
        ReyaxTtyMessageSend("\n\tSynchronizer Threshold    0x%X = %d",
          SyncThreshold, SyncThreshold);
        ReyaxTtyMessageSend("\tSynchronizer Offset       %d", SyncOffset);

        TransmitChainCalcParams(&OfdmParams, &OfdmTiming);
        OfdmCalcParams = TransmitChainGetParams();
        DacParams = DacChainGetDacParams();

        ReyaxTtyMessageSend("\n");
        ReyaxTtyMessageSend("\t------ Calculated Parameters ------");
        ReyaxTtyMessageSend("\tSCS:                      %lf Hz", 
          OfdmCalcParams.Scs);
        ReyaxTtyMessageSend("\tSamples per Symbol:       %d", 
          OfdmCalcParams.Symbol.Samples);
        ReyaxTtyMessageSend("\tSymbol Period:            %lf ms", 
          OfdmCalcParams.Symbol.Time);
        ReyaxTtyMessageSend("\tSymbol Data Rate:         %lf kbit/sec", 
          OfdmCalcParams.SymbolDataRate);
        ReyaxTtyMessageSend("\tFrame Data Rate:          %lf kbit/sec",
          OfdmCalcParams.FrameDataRate);
        ReyaxTtyMessageSend("\n\tActual ZP Pilot Density:  %lf%%",
          (double)OfdmCalcParams.NumZpCarriers/
          (double)OfdmParams.Nfft*100.0);
        ReyaxTtyMessageSend("\tFirst Pilot Carrier:      %d",
          OfdmCalcParams.FirstPilotCarrier+1);
        ReyaxTtyMessageSend("\tLast Pilot Carrier:       %d",
          OfdmCalcParams.LastPilotCarrier);
        ReyaxTtyMessageSend("\tNumber of Data Carriers:  %d",
          OfdmCalcParams.NumDataCarriers);
        ReyaxTtyMessageSend("\tNumber of Pilot Carriers: %d",
          OfdmCalcParams.NumPilotCarriers);
        ReyaxTtyMessageSend("\tNumber of ZP Carriers:    %d",
          OfdmCalcParams.NumZpCarriers);
        ReyaxTtyMessageSend("\n\tInterpolation Value       %dx", 
          DacParams.Interp);
        ReyaxTtyMessageSend("\n\t100MHz Cycles per:\n");
        ReyaxTtyMessageSend("\t  Sample:                 %d",
          OfdmCalcParams.Symbol.FpgaClkSamples);
        ReyaxTtyMessageSend("\t  Symbol Guard Period:    %d",
          OfdmCalcParams.SymbolGuard.FpgaClkSamples);
        ReyaxTtyMessageSend("\t  Frame Guard Period:     %d\n",
          OfdmCalcParams.FrameGuard.FpgaClkSamples);
        //TransmitChainPrintCalcParams(&OfdmCalcParams);
        break;

//////////////////////////////////////////////////////////////////////////
      case 8:
        ReturnStatus = TransmitChainParamCheck(&OfdmParams);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
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
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
          break;
        }

        ReturnStatus = TxModulateIfft(DebugMode, OfdmParams.Nfft,
          OfdmParams.ModOrder, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame, 13);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
          break;
        }

        ReturnStatus = Power(OfdmParams.Nfft, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame, TxModulateGetIfftGain(), 1,
          NULL);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
          TxModulateFreeTxBuffer();
          break;
        }
        
        NumBytes = ((OfdmParams.Nfft+OfdmParams.CpLen)*
          (OfdmTiming.OfdmSymbolsPerFrame)+NFFT_ZC+OfdmParams.CpLen)*4;
        if (DmaLoopSel)
        {
          ReyaxTtyMessageSend("Setting Pad samples to 0 for DMA "
            "loopback");
          PadSamples = 0;
        }
        else
        {
          ReyaxTtyMessageSend("Allocating Pad samples for FIR filter");
          PadSamples = NUM_DUC_DDC_COEF/2 + NUM_PAD_SAMPLES;
        }
        NumBytes = NumBytes + (PadSamples * 4);
/*
        if (TxOff)
        {
          DirectDmaSetTxBufferLoop(1);
          ReyaxTtyMessageSend("Skipping TX transmission and exiting. "
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
        ReyaxTtyMessageSend("Wait for %lfus to finish Transmission",
          OfdmCalcParams.Symbol.Time*(OfdmTiming.OfdmSymbolsPerFrame+
          1)*2*1000);
        usleep(OfdmCalcParams.Symbol.Time*(
          OfdmTiming.OfdmSymbolsPerFrame+1)*2*1000);
        if (TxOff)
        {
          ReyaxTtyMessageSend("\n\tTX transmission turned off -- no "
            "output");
        }
        //HwInterfaceDisableDac();
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
        }
        ReturnStatus = PowerPeakDuc();
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
        }
        ReyaxTtyMessageSend("Finished");
       break;
#else
        ReyaxTtyMessageSend("Skipped DMA transfer of : %d Bytes", 
          NumBytes);
#endif
        break;

//////////////////////////////////////////////////////////////////////////
      case 9:
        ReturnStatus = RxDemodulateBufferData(DebugMode, true,
          OfdmParams.ModOrder, OfdmParams.Nfft, OfdmParams.CpLen,
          OfdmTiming.OfdmSymbolsPerFrame);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
          break;
        }

        ReturnStatus = Ber(false, OfdmParams.ModOrder,
          OfdmTiming.OfdmSymbolsPerFrame, &OfdmCalcParams);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
          break;
        }
        break;

//////////////////////////////////////////////////////////////////////////
      case 10:
        ReyaxTtyMessageSend("Enter Thread Selection ('0'-Off/'1'-On): ");
        ReyaxTtyDataRead(&RxThread, UNSIGNED_READ);
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
            ReyaxTtyMessageSend("Setting Guard Period to 0 for DMA "
              "loopback");
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
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
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
            ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
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
        ReyaxTtyMessageSend("AdcSave = %d, DacSave = %d\n", AdcSampleSave,
          DacSampleSave);
        ReturnStatus=DirectDmaPlToPsThread(AdcSampleSave||DacSampleSave);
        if (ReturnStatus.Status == RETURN_STATUS_FAIL)
        {
          ReyaxTtyMessageSend("%s", ReturnStatus.ErrString);
        }
        break;

//////////////////////////////////////////////////////////////////////////
      case 12:
        DirectDmaPlToPsThreadCancel();
        break;

//////////////////////////////////////////////////////////////////////////
      case 13:
        ReyaxTtyMessageSend("Enable Sine Tone at Fc ('0'-Off / '1'On): ");
        ReyaxTtyDataRead(&DebugSelection, INT_READ);
        if (DebugSelection == 1)
        {
          ReyaxTtyMessageSend("Enter 32-bit IQ Scalar Value: ");
          ReyaxTtyDataRead(&CwIqScale, UNSIGNED_READ);
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
        ReyaxTtyMessageSend("Enable/Disable DMA loopback "
          "('0'-Off / '1'-On): ");
        ReyaxTtyDataRead(&DmaLoopSel, UNSIGNED_READ);
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
        ReyaxTtyMessageSend("Enable/Disable Synchronizer Loopback "
          "('0'-Off / '1'-On): ");
        ReyaxTtyDataRead(&SyncLoopSel, UNSIGNED_READ);
        HwInterfaceSyncLoopback(SyncLoopSel);
        if (SyncLoopSel)
        {
          ReyaxTtyMessageSend("Enable/Disable guard module in sync "
            "loopback: ('0'-Off / '1'-On): ");
          ReyaxTtyDataRead(&SyncGuardLoopSel, UNSIGNED_READ);
          HwInterfaceSyncGuardLoopback(SyncGuardLoopSel);
        }
        else
        {
          HwInterfaceSyncGuardLoopback(0);
        }
        break;

//////////////////////////////////////////////////////////////////////////
      case 15:
        ReyaxTtyMessageSend("GP Reg 0 ('0'-CIC / '1'-FIR DUC/DDC): ");
        ReyaxTtyDataRead(&FirCicIsFir, UNSIGNED_READ);
        HwInterfaceGpReg0(FirCicIsFir);
        ReyaxTtyMessageSend("GP Reg 0 ('0'-Normal Demod Path / '1'-"
          "Save Raw ADC/DAC samples): ");
        ReyaxTtyDataRead(&SampleSave, UNSIGNED_READ);
        if (SampleSave)
        {
          ReyaxTtyMessageSend("Save Raw ADC samples: "
            "('0'-Off / '1'-On): ");
          ReyaxTtyDataRead(&AdcSampleSave, UNSIGNED_READ);
          HwInterfaceGpReg1(AdcSampleSave);
          ReyaxTtyMessageSend("Save Raw DAC samples: "
            "('0'-Off / '1'-On): ");
          ReyaxTtyDataRead(&DacSampleSave, UNSIGNED_READ);
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
            ReyaxTtyMessageSend("Save samples at interpolator output: "
              "('0'-No / '1'-Yes): ");
            ReyaxTtyDataRead(&FirSampleSave, UNSIGNED_READ);
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
        ReyaxTtyMessageSend("Invalid selection");
    }

    sprintf(FileName, "files/OfdmInfo%d.txt", 1);
    OfdmInfoFile = fopen(FileName,"w");
    if (OfdmInfoFile == NULL)
    {
      ReyaxTtyMessageSend("Failed to write to OfdmInfoFile");
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
      ReyaxTtyMessageSend("ERROR: Continue OFDM Radio Test? "
        "('0'-No / '1'-Yes): ");
      ReyaxTtyDataRead(&DebugSelection, INT_READ);
      if (!(DebugSelection == 1))
      {
        ReyaxTtyMessageSend("Exiting ... ");
        break;
      }
      ReturnStatus.Status = RETURN_STATUS_SUCCESS;
    }

  } while (Selection);

  // Cleanup
  ReyaxTtyMessageSend("%d", ScanfRet);
  ReyaxTtyMessageSend("%d", TxOff);
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
