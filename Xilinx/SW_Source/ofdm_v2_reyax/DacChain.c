//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include "TransmitChain.h"
#include "TxModulate.h"
#include "HwInterface.h"
#include "FpgaInterface.h"
#include "DacChain.h"
#include "Reyax.h"

//#define SAMPLE_DEBUG

static Dac_Parameters_Type DacParams;
static int16_T *DucOutData = NULL; // Buffer going to DAC

ReturnStatusType DacChainSetDacParams(double BandWidth, unsigned Fc,
  bool Configure)
{
  ReturnStatusType ReturnStatus;
#ifndef NO_DEVMEM
  Hw_Parameters_Type HwParams;
  double BitWidth = 4294967295.0;
#endif

  /*
  ReyaxTtyMessageSend("Valid Freq Range: %d "
    "kHz - %d kHz", CENTER_FREQUENCY_KHZ_MIN, CENTER_FREQUENCY_KHZ_MAX);
  */

  if ((Fc - BandWidth/2.0) < (double)CENTER_FREQUENCY_KHZ_MIN)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, 
      "DacChainSetDacParams: Failed to set Fc %d kHz for %lf kHz BW "
      "signal\n", Fc, BandWidth);
    return ReturnStatus;
  }

  if ((Fc + BandWidth/2.0) > (double)CENTER_FREQUENCY_KHZ_MAX)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, 
      "DacChainSetDacParams: Failed to set Fc %d kHz for %lf kHz BW "
      "signal\n", Fc, BandWidth);
    return ReturnStatus;
  }

  DacParams.BandWidth = BandWidth;
  DacParams.Fs = BandWidth; // Nyquist complex Fs = BW
  DacParams.Interp = (unsigned)((double)DAC_SAMPLE_RATE_KHZ/
    BandWidth);
  DacParams.Fc = Fc;

#ifndef NO_DEVMEM
  HwParams.DacInterpolation = (unsigned)((double)DAC_SAMPLE_RATE_KHZ/
    BandWidth);
  HwParams.AdcDecimation = (unsigned)((double)ADC_SAMPLE_RATE_KHZ/
    BandWidth);
  HwParams.FcDds = (unsigned)((double)Fc*1000*
    (BitWidth/(double)FpgaClkRate));
  HwParams.FcDdsAdc=(unsigned)((double)Fc*1000*
    (BitWidth/(double)AdcClkRate));

  if (Configure)
  {
    HwInterfaceConfigureSignalParams(HwParams.DacInterpolation,
      HwParams.AdcDecimation, HwParams.FcDds, HwParams.FcDdsAdc);
  }
#endif

  // Get rid of warnings
  if (Configure)
    NULL;

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

Dac_Parameters_Type DacChainGetDacParams(void)
{
  return DacParams;
}

int16_T *DacChainGetDMABuff(void)
{
  return DucOutData;
}
