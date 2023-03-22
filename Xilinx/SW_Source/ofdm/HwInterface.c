//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <unistd.h>
#include "ReturnStatus.h"
#include "TxModulate.h"
#include "TransmitChain.h"
#include "HwInterface.h"
#include "FpgaInterface.h"

//#define DEBUG

// Start TX Transmission (will still wait for DMA data)
void HwInterfaceStartTx(void)
{
  unsigned RegValue;

  RegValue = 1 << DL_EN_REG_OFFSET;
  RegValue &= DL_EN_REG_MASK;
#ifdef DEBUG
  printf("HwInterfaceStartTx: Tx Chain configured and waiting\n");
#endif
  FpgaInterfaceWrite(DL_EN_REG, RegValue, DL_EN_REG_MASK);
}

// Stop TX Transmission 
void HwInterfaceStopTx(void)
{
  unsigned RegValue;

  RegValue = 0 << DL_EN_REG_OFFSET;
  RegValue &= DL_EN_REG_MASK;
#ifdef DEBUG
  printf("HwInterfaceStopTx: Tx Chain stopped\n");
#endif
  FpgaInterfaceWrite(DL_EN_REG, RegValue, DL_EN_REG_MASK);
}

// Configure config_fft register
void HwInterfaceConfigFftCore(void)
{
  unsigned RegValue;

  RegValue = 1 << CONFIG_FFT_CORE_OFFSET;
  RegValue &= CONFIG_FFT_CORE_MASK;
#ifdef DEBUG
  printf("HwInterfaceConfigFftCore: Rising edge on FFT config\n");
#endif
  FpgaInterfaceWrite(CONFIG_FFT_CORE_REG, RegValue, CONFIG_FFT_CORE_MASK);
  usleep(1000); // Give some time for core to configure

  RegValue = 0 << CONFIG_FFT_CORE_OFFSET;
  RegValue &= CONFIG_FFT_CORE_MASK;
#ifdef DEBUG
  printf("HwInterfaceConfigFftCore: Falling edge on FFT config\n");
#endif
  FpgaInterfaceWrite(CONFIG_FFT_CORE_REG, RegValue, CONFIG_FFT_CORE_MASK);
}

// Configure fs_cycles, nfft, cp_len, nfft symbols, inv,
// negative_freq, continuous, playback registers
void HwInterfaceConfigTxChain(Ofdm_Parameters_Type *OfdmParams,
  Calculated_Ofdm_Parameters *OfdmCalcParams, Ofdm_Timing_Type 
  *OfdmTiming)
{
  unsigned RegValue, mask, tmp;

  // Configure fs_cycles + nfft on same register:
  RegValue = OfdmCalcParams->Symbol.FpgaClkSamples <<
    FS_CYCLES_REG_OFFSET;
  RegValue &= FS_CYCLES_REG_MASK;
  tmp = OfdmCalcParams->NfftScaled; // Scaled NFFT
  RegValue |= ((tmp << NFFT_REG_OFFSET) & NFFT_REG_MASK);
  mask = NFFT_REG_MASK | FS_CYCLES_REG_MASK;
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring fs_cycles + nfft reg\n");
#endif
  FpgaInterfaceWrite(FS_CYCLES_REG, RegValue, mask);

  // Configure CP_LEN, NFFT_SCALED and OFDM_SYMBOLS
  RegValue = OfdmParams->CpLen << CP_LEN_REG_OFFSET;
  RegValue &= CP_LEN_REG_MASK;
  RegValue |= ((OfdmParams->Nfft << NFFT_SCALED_REG_OFFSET) &
    NFFT_SCALED_REG_MASK);
  RegValue |= ((OfdmTiming->OfdmSymbolsPerFrame << 
    OFDM_SYMBOLS_REG_OFFSET) & OFDM_SYMBOLS_REG_MASK);
  mask = CP_LEN_REG_MASK | NFFT_SCALED_REG_MASK | OFDM_SYMBOLS_REG_MASK;
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring cp_len, nfft_sc, ");
  printf(" and symbols reg\n");
#endif
  FpgaInterfaceWrite(CP_LEN_REG, RegValue, mask);

  // Configure IFFT/FFT control
  RegValue = 1 << SEL_IFFT_FFT_REG_OFFSET;
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring IFFT/FFT select reg\n");
#endif
  FpgaInterfaceWrite(SEL_IFFT_FFT_REG, RegValue, SEL_IFFT_FFT_REG_MASK);

  // Enable/Disable conjugate at output of IFFT
  RegValue = IFFT_CONJUGATE << NEGATIVE_FREQ_REG_OFFSET;
  RegValue &= (NEGATIVE_FREQ_REG_MASK);
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring IFFT conjugate reg\n");
#endif
  FpgaInterfaceWrite(NEGATIVE_FREQ_REG, RegValue, NEGATIVE_FREQ_REG_MASK);

  // Configure Non-Continuous Transmission
  RegValue = 0 << PLAYBACK_CONTINUOUS_REG_OFFSET;
  RegValue &= (PLAYBACK_CONTINUOUS_REG_MASK);
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring continuous reg\n");
#endif
  FpgaInterfaceWrite(PLAYBACK_CONTINUOUS_REG, RegValue, 
    PLAYBACK_CONTINUOUS_REG_MASK);

  // Configure Non Playback mode
  RegValue = 0 << PLAYBACK_EN_REG_OFFSET;
  RegValue &= (PLAYBACK_EN_REG_MASK);
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring in normal mode reg\n");
#endif
  FpgaInterfaceWrite(PLAYBACK_EN_REG, RegValue, PLAYBACK_EN_REG_MASK);
}
