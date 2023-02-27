//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef HW_INTERFACE_H_INCLUDED
#define HW_INTERFACE_H_INCLUDED

#define FpgaClkRate 100000000 // 100MHz

// On 0 to 1 transition of IFFT_CONFIG_START_REG a configuration packet 
// will be sent to the FFT IP core with the values in the SEL_IFFT_FFT_REG,
// CP_LEN_REG, and NFFT_REG
#define IFFT_CONFIG_START_REG 0x40010100
#define IFFT_CONFIG_START_REG_MASK 0x10000
#define IFFT_CONFIG_START_REG_OFFSET 16

// Select IFFT or FFT
#define SEL_IFFT_FFT_REG 0x40010100
#define SEL_IFFT_FFT_REG_MASK 0x1
#define SEL_IFFT_FFT_REG_OFSET 0

// Cyclic Prefix length in samples
#define CP_LEN_REG 0x40010004
#define CP_LEN_REG_MASK 0xFFFF
#define CP_LEN_REG_OFFSET 0

// ceil(log2(nfft))
#define NFFT_SCALED_REG 0x40010004
#define NFFT_SCALED_REG_MASK 0xFFF0000
#define NFFT_SCALED_REG_OFFSET 16

// Actual nfft value
#define NFFT_REG 0x40010000
#define NFFT_REG_MASK 0xF8000000
#define NFFT_REG_OFFSET 27

// Perform conjugate at output of IFFT
#define NEGATIVE_FREQ_REG 0x40010100
#define NEGATIVE_FREQ_REG_MASK 0x2
#define NEGATIVE_FREQ_REG_OFFSET 1

// OFDM symbol playback from memory
#define PLAYBACK_EN_REG 0x40010100
#define PLAYBACK_EN_REG_MASK 0x200
#define PLAYBACK_EN_REG_OFFSET 9

// Select if symbol playback is continuous or 1 frame
#define PLAYBACK_CONTINUOUS_REG 0x40010100
#define PLAYBACK_CONTINUOUS_REG_MASK 0x4
#define PLAYBACK_CONTINUOUS_REG_OFFSET 2

// Number of OFDM symbols in a frame
// Number of OFDM symbols when symbol playback is enabled
#define OFDM_SYMBOLS_REG 0x40010004
#define OFDM_SYMBOLS_REG_MASK 0xF0000000
#define OFDM_SYMBOLS_REG_OFFSET 28

// Number of 100MHz clock cycles per sample
#define FS_CYCLES_REG 0x40010000
#define FS_CYCLES_REG_MASK 0x07FFFFFF
#define FS_CYCLES_REG_OFFSET 0

// Number of 100MHz clock cycles in symbol guard period
#define SYMBOL_GUARD_PERIOD_REG 0
#define SYMBOL_GUARD_PERIOD_REG_MASK 0

// Enable/Disable Downlink. Reset to 0 after every frame
#define DL_EN_REG 0x40010100
#define DL_EN_REG_MASK 0x100
#define DL_EN_REG_OFFSET 8

extern unsigned HwInterfaceCalcNfftScaling(unsigned Nfft);
extern void HwInterfaceConfigFftCore(Ofdm_Parameters_Type *OfdmParams,
  Calculated_Ofdm_Parameters *OfdmCalcParams, Ofdm_Timing_Type
  *OfdmTiming);
extern void HwInterfaceConfigSymbPlayback(Ofdm_Parameters_Type
  *OfdmParams, Ofdm_Timing_Type *OfdmTiming);
extern void HwInterfaceConfigTxChain(Ofdm_Parameters_Type
  *OfdmParams, Calculated_Ofdm_Parameters *OfdmCalcParams, 
  Ofdm_Timing_Type *OfdmTiming);

#endif
