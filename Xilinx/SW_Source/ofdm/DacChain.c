//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include "TransmitChain.h"
#include "DacChain.h"

static Dac_Parameters_Type DacParams;

ReturnStatusType DacChainSetDacParams(unsigned BandWidth, unsigned Fc)
{
  ReturnStatusType ReturnStatus;

  printf("DacChainSetDacParams: Valid Freq Range: %d kHz - %d kHz\n",
    CENTER_FREQUENCY_KHZ_MIN, CENTER_FREQUENCY_KHZ_MAX);

  if ((Fc - BandWidth/2) < CENTER_FREQUENCY_KHZ_MIN)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, 
      "DacChainSetDacParams: Failed to set Fc %d kHz for %d kHz BW "
      "signal\n", Fc, BandWidth);
    return ReturnStatus;
  }

  if ((Fc + BandWidth/2) > CENTER_FREQUENCY_KHZ_MAX)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString, 
      "DacChainSetDacParams: Failed to set Fc %d kHz for %d kHz BW "
      "signal\n", Fc, BandWidth);
    return ReturnStatus;
  }

  DacParams.BandWidth = BandWidth;
  DacParams.Fs = BandWidth; // Nyquist complex Fs = BW
  DacParams.Interp = DAC_SAMPLE_RATE_KHZ/BandWidth;
  DacParams.Fc = Fc;

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

Dac_Parameters_Type DacChainGetDacParams(void)
{
  return DacParams;
}

ReturnStatusType DacChainUpConversion(bool DebugMode, unsigned FileNumber)
{
  ReturnStatusType ReturnStatus;
  char FileName[32];
  FILE *DucFile = NULL;

  if (DebugMode)
  {
    sprintf(FileName, "files/TxDuc%d.txt", FileNumber);
    DucFile = fopen(FileName, "w");
    if (DucFile == NULL)
    {
      perror("DacChainUpConversion");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "DacChainUpConversion: Failed to open file %s\n", FileName);
      return ReturnStatus;
    }
    // Write header information 
    fprintf(DucFile, "%d,\n%d,\n", DacParams.Fc, DacParams.Interp);
  }

  if (DucFile != NULL)
  {
    fclose(DucFile);
    printf("DacChainUpConversion: Wrote to file %s\n", FileName);
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
