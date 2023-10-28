//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef HW_INTERFACE_H_INCLUDED
#define HW_INTERFACE_H_INCLUDED

#include <stdbool.h>
#include "ReturnStatus.h"

#define RELOAD_COEF_MAX 4103

// PS to PL control and status registers
#define DMA_BASE_ADDR 0x40000000 // Same as DMA_CONTROL_REGISTER
#define DMA_RELOAD_BASE_ADDR 0x40001000
#define DMA_STATUS_OFFSET 0x4
#define DMA_SOURCE_OFFSET 0x18
#define DMA_LENGTH_OFFSET 0x28

// PL to PS control and status registers
#define DMAS_CONTROL_OFFSET 0x30
#define DMAS_STATUS_OFFSET 0x34
#define DMAS_DEST_OFFSET 0x48
#define DMAS_LENGTH_OFFSET 0x58

#define DMA_RESET 0x4
#define DMA_IOC_IRQ_MASK 0x00001000
#define DMA_CLEAR 0x00000000

#define DMA_BUFFER_WIDTH_VAL 26 // Configured in DMA GUI

#define FpgaClkRate 100000000 // 100MHz
#define AdcClkRate 40000000 // 40MHz
// MAX input voltage of ~0.3V before distortion using 10 dB RX gain
#define DEFAULT_RX_GAIN_DB 32 // in dB
#define DEFAULT_SYNCHRONIZER_OFFSET -20

#define GPIO_0_BASE_ADDR 0x40010000
#define GPIO_1_BASE_ADDR 0x40010200
#define GPIO_2_BASE_ADDR 0x40010400
#define GPIO_3_BASE_ADDR 0x40010600
#define GPIO_4_BASE_ADDR 0x40010800
#define GPIO_5_BASE_ADDR 0x40010A00

#define FC_SCALED_OFFSET 0x0
#define FC_SCALED_MASK 0xFFFFFFFF

#define DECIMATE_RADIO_OFFSET 0x8
#define DECIMATE_RADIO_MASK 0x0000FFFF

#define DAC_CONTROL_OFFSET 0x8
#define DAC_CONTROL_MASK_OFFSET 16
#define DAC_CONTROL_MASK 0x000F0000
#define ENABLE_DAC_PWR_AMP 0x3
#define DISABLE_DAC_PWR_AMP 0x0

#define ADC_CONTROL_OFFSET 0x8
#define ADC_CONTROL_MASK_OFFSET 20
#define ADC_CONTROL_MASK 0x00F00000
#define ADC_CLEAR_OTR 0x4
#define ADC_CLEAR_OVERRUN 0x2
#define ADC_ENABLE 0x1
#define ADC_DISABLE 0x0

#define ADC_STATUS_OFFSET 0x8
#define ADC_STATUS_MASK 0xFFFFFFFF

#define DUC_INTERP_RATIO_OFFSET 0x0
#define DUC_INTERP_RATIO_MASK 0x0000FFFF

#define DMA_LOOPBACK_OFFSET 0x0
#define DMA_LOOPBACK_MASK_OFFSET 16
#define DMA_LOOPBACK_MASK 0x00010000

#define OFDM_SYMBOLS_OFFSET 0x0
#define OFDM_SYMBOLS_MASK_OFFSET 17
#define OFDM_SYMBOLS_MASK 0x001E0000

#define SYNC_THRESHOLD_OFFSET 0x0
#define SYNC_THRESHOLD_MASK 0xFFFFFFFF

#define NFFT_OFFSET 0x8
#define NFFT_MASK 0x00003FFF

#define CP_LEN_OFFSET 0x8
#define CP_LEN_MASK_OFFSET 14
#define CP_LEN_MASK 0x03FFC000

#define SYNC_LOOPBACK_OFFSET 0x8
#define SYNC_LOOPBACK_MASK_OFFSET 26
#define SYNC_LOOPBACK_MASK 0x04000000

#define SYNC_OFFSET_OFFSET 0x0
#define SYNC_OFFSET_MASK_OFFSET 21
#define SYNC_OFFSET_MASK 0xFFE00000

#define DMA_TLAST_GEN_OFFSET 0x0
#define DMA_TLAST_GEN_MASK 0xFFFFFFFF

#define DUC_DDC_LOOPBACK_OFFSET 0x8
#define DUC_DDC_LOOPBACK_MASK_OFFSET 3
#define DUC_DDC_LOOPBACK_MASK 0x8

#define SYNC_ENABLE_OFFSET 0x8
#define SYNC_ENABLE_MASK_OFFSET 27
#define SYNC_ENABLE_MASK 0x08000000

//#define RX_SHIFT_ATTEN_OFFSET 0x8
//#define RX_SHIFT_ATTEN_MASK_OFFSET

#define AUX_RESETN_OFFSET 0x8
#define AUX_RESETN_MASK_OFFSET 28
#define AUX_RESETN_MASK 0x10000000

#define ADC_FC_SCALED_OFFSET 0x0
#define ADC_FC_SCALED_MASK_OFFSET 0
#define ADC_FC_SCALED_MASK 0xFFFFFFFF

#define FIR_1_RELOAD_OFFSET 0x8
#define FIR_1_RELOAD_MASK_OFFSET 29
#define FIR_1_RELOAD_MASK 0x20000000

#define SINE_TONE_OFFSET 0x8

#define SYMBOL_GUARD_OFFSET 0x0

// On 0 to 1 transition of IFFT_CONFIG_START_REG a configuration packet 
// will be sent to the FFT IP core with the values in the SEL_IFFT_FFT_REG,
// CP_LEN_REG, and NFFT_REG
#define IFFT_CONFIG_START_REG 0x40010100
#define IFFT_CONFIG_START_REG_MASK 0x10000
#define IFFT_CONFIG_START_REG_OFFSET 16

// Select IFFT (1) or FFT (0)
#define SEL_IFFT_FFT_REG 0x40010100
#define SEL_IFFT_FFT_REG_MASK 0x1
#define SEL_IFFT_FFT_REG_OFFSET 0

// Cyclic Prefix length in samples
#define CP_LEN_REG 0x40010004
#define CP_LEN_REG_MASK 0xFFFF
#define CP_LEN_REG_OFFSET 0

// Actual nfft value
#define NFFT_SCALED_REG 0x40010004
#define NFFT_SCALED_REG_MASK 0xFFF0000
#define NFFT_SCALED_REG_OFFSET 16

// ceil(log2(nfft))
#define NFFT_REG 0x40010000
#define NFFT_REG_MASK 0xF8000000
#define NFFT_REG_OFFSET 27

// Perform conjugate at output of IFFT
#define NEGATIVE_FREQ_REG 0x40010100
#define NEGATIVE_FREQ_REG_MASK 0x2
#define NEGATIVE_FREQ_REG_OFFSET 1

// Configure FFT core with rising edge
#define CONFIG_FFT_CORE_REG 0x40010100
#define CONFIG_FFT_CORE_MASK 0x10000
#define CONFIG_FFT_CORE_OFFSET 16

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

extern void HwInterfaceStartTx(void);
extern void HwInterfaceStopTx(void);
extern void HwInterfaceConfigFftCore(void);
extern void HwInterfaceConfigTxChain(Ofdm_Parameters_Type *OfdmParams,
  Calculated_Ofdm_Parameters *OfdmCalcParams, Ofdm_Timing_Type
  *OfdmTiming);
extern void HwInterfaceConfigSymbPlayback(Ofdm_Parameters_Type
  *OfdmParams, Ofdm_Timing_Type *OfdmTiming);
ReturnStatusType HwInterfaceSpiSetup(void);
ReturnStatusType HwInterfaceSetVga(int gain);
void HwInterfaceSetVgaHiLo(unsigned value);
ReturnStatusType HwInterfaceGpioSetup(void);
void HwInterfaceSetVgaHiLo(unsigned value);
void HwInterfaceEnableDac(void);
void HwInterfaceDisableDac(void);
void HwInterfaceEnableAdc(void);
void HwInterfaceDisableAdc(void);
unsigned HwInterfaceReturnAdcStatus(void);
void HwInterfaceDmaLoopback(unsigned Enable);
void HwInterfaceSyncLoopback(unsigned Enable);
void HwInterfaceSetGlobalMute(bool GlobalMuteSelect);
ReturnStatusType  HwInterfaceConfigureSynchronizer(unsigned nfft,
  unsigned CpLen, unsigned OfdmSymbols, unsigned Threshold,
  int SyncOffset);
void HwInterfaceConfigureSignalParams(unsigned Interpolation,
  unsigned Decimation, unsigned FcScaledDac, unsigned FcScaledAdc);
void HwInterfaceSetDmaTlastGen(bool DucDdcLoopSel, unsigned Samples);
void HwInterfaceDucDdcLoopback(bool Select);
void HwInterfaceSynchronizerStatus(bool Enable);
void HwInterfaceResetPL(bool Reset);
ReturnStatusType HwInterfaceLoadZcSequence(unsigned Nfft, unsigned
  IqSelect, double Bw;);
void HwInterfaceSineToneSet(unsigned CwIqScale);
void HwInterfaceSetGuardPeriod(unsigned FpgaClkSamples);

#endif
