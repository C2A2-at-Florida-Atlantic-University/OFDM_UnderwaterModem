//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef TRANSMIT_CHAIN_H_INCLUDED
#define TRANSMIT_CHAIN_H_INCLUDED

#define PILOT_DENSITY 1/4 

#define DEFAULT_NFFT 1024
#define DEFAULT_BANDWIDTH 250 // in kHz
#define DEFAULT_CP_LEN 0 // in Samples
#define DEFAULT_MOD_ORDER 4 // QPSK

#define DEFAULT_SYMBOL_GUARD_PERIOD 1 // in ms
#define DEFAULT_FRAME_GUARD_PERIOD 5 // in ms

typedef struct {
  unsigned Nfft;
  unsigned BandWidth;
  unsigned CpLen;
  unsigned ModOrder;
} Ofdm_Parameters_Type;

typedef struct {
  unsigned SymbolGuardPeriod;
  unsigned FrameGuardPeriod;
} Ofdm_Timing_Type;

typedef struct {
  unsigned Samples;
  double Time;
} Time_Samples_Type;

typedef struct {
  double Scs;
  Time_Samples_Type Symbol;
  double SymbolDataRate;
  double FrameDataRate;
} Calculated_Ofdm_Parameters;

extern void TransmitChainCalcParams(Ofdm_Parameters_Type
  *OfdmParams, Ofdm_Timing_Type *OfdmTiming);

#endif
