//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include "ReturnStatus.h"
#include "TransmitChain.h"
#include "HwInterface.h"
#include "FpgaInterface.h"

#define DEBUG

// Configure fs_cycles, nfft, cp_len, nfft symbols, inv,
// negative_freq, continuous, FFT_config_en registers
void HwInterfaceConfigFftCore(Ofdm_Parameters_Type *OfdmParams,
  Calculated_Ofdm_Parameters *OfdmCalcParams, Ofdm_Timing_Type 
  *OfdmTiming)
{
  unsigned RegValue, mask;

  // Configure fs_cycles + nfft on same register:
  RegValue = OfdmCalcParams->Symbol.FpgaClkSamples <<
    FS_CYCLES_REG_OFFSET;
  RegValue &= (~NFFT_REG_MASK);
  RegValue |= ((OfdmParams->Nfft << NFFT_REG_OFFSET) & NFFT_REG_MASK);
  mask = NFFT_REG_MASK & FS_CYCLES_REG_MASK;
#ifdef DEBUG
  printf("HwInterfaceConfigFftCore: Configure fs_cycles + nfft reg\n");
  printf("\tmask = 0x%X, val = 0x%X, reg = 0x%X\n", mask, RegValue,
    FS_CYCLES_REG);
#endif
  FpgaInterfaceWrite(FS_CYCLES_REG, RegValue, mask);

  // Configure CP_LEN, NFFT_SCALED and OFDM_SYMBOLS
  RegValue = OfdmParams->CpLen << CP_LEN_REG_OFFSET;
  RegValue &= (~NFFT_SCALED_REG_MASK);
  RegValue |= ((OfdmCalcParams->NfftScaled << NFFT_SCALED_REG_OFFSET) &
    NFFT_SCALED_REG_MASK);
  RegValue &= (~OFDM_SYMBOLS_REG_MASK);
  RegValue |= ((OfdmTiming->OfdmSymbolsPerFrame << 
    OFDM_SYMBOLS_REG_OFFSET) & OFDM_SYMBOLS_REG_MASK);
  mask = CP_LEN_REG_MASK & NFFT_SCALED_REG_MASK & OFDM_SYMBOLS_REG_MASK;
#ifdef DEBUG
  printf("HwInterfaceConfigFftCore: Configure cp_len, nfft_sc, symbols\n");
  printf("\tmask = 0x%X, val = 0x%X, reg = 0x%X\n", mask, RegValue,
    CP_LEN_REG);
#endif
  FpgaInterfaceWrite(CP_LEN_REG, RegValue, mask);

}
