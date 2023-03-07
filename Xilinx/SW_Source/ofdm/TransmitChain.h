//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef TRANSMIT_CHAIN_H_INCLUDED
#define TRANSMIT_CHAIN_H_INCLUDED

#include <stdbool.h>

#define PILOT_DENSITY 1/4 
#define MAX_NFFT 4096

#define DEFAULT_NFFT 1024
#define DEFAULT_BANDWIDTH 250 // in kHz
#define DEFAULT_CP_LEN 0 // in Samples
#define DEFAULT_MOD_ORDER 2 // BPSK

#define DEFAULT_SYMBOL_GUARD_PERIOD 1 // in ms
#define DEFAULT_FRAME_GUARD_PERIOD 5 // in ms
#define DEFAULT_SYMBOlS_PER_FRAME 10

typedef struct {
  unsigned Nfft;
  unsigned BandWidth;
  unsigned CpLen;
  unsigned ModOrder;
} Ofdm_Parameters_Type;

typedef struct {
  unsigned SymbolGuardPeriod;
  unsigned FrameGuardPeriod;
  unsigned OfdmSymbolsPerFrame;
} Ofdm_Timing_Type;

typedef struct {
  unsigned Samples;
  unsigned FpgaClkSamples;
  double Time;
} Time_Samples_Type;

typedef struct {
  double Scs;
  Time_Samples_Type Symbol;
  Time_Samples_Type SymbolGuard;
  Time_Samples_Type FrameGuard;
  double SymbolDataRate;
  double FrameDataRate;
  unsigned NfftScaled;
} Calculated_Ofdm_Parameters;

extern void TransmitChainCalcParams(Ofdm_Parameters_Type
  *OfdmParams, Ofdm_Timing_Type *OfdmTiming);
extern Calculated_Ofdm_Parameters TransmitChainGetParams(void);
extern ReturnStatusType TransmitChainEnableDl(bool Continuous,
  Ofdm_Parameters_Type *OfdmParams, Ofdm_Timing_Type *OfdmTiming);
extern ReturnStatusType TransmitChainParamCheck(Ofdm_Parameters_Type
  *OfdmParams);

#endif