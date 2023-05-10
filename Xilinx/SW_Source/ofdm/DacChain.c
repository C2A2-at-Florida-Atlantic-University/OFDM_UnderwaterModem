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
#include "g_Interp.h"

//#define SAMPLE_DEBUG

static Dac_Parameters_Type DacParams;
static int16_t *DucOutData = NULL; // Buffer going to DAC
bool Loopback = false;
bool LoopbackSync = false;

void DacChainSetLoopback(unsigned Loop)
{
  if (Loop == 1)
  {
    Loopback = true;
    HwInterfaceDucDdcLoopback(true);
  }
  else
  {
    Loopback = false;
    HwInterfaceDucDdcLoopback(false);
  }
}

void DacChainSetLoopbackSync(unsigned Loop)
{
  if (Loop == 1)
  {
    LoopbackSync = true;
  }
  else
  {
    LoopbackSync = false;
  }
}

ReturnStatusType DacChainSetDacParams(unsigned BandWidth, unsigned Fc,
  bool Configure)
{
  ReturnStatusType ReturnStatus;
  Hw_Parameters_Type HwParams;
  double BitWidth = 4294967295.0;

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

  HwParams.DacInterpolation = DAC_SAMPLE_RATE_KHZ/BandWidth;
  if (Loopback || LoopbackSync)
  {
    HwParams.AdcDecimation = DAC_SAMPLE_RATE_KHZ/BandWidth;
  }
  else
  {
    HwParams.AdcDecimation = ADC_SAMPLE_RATE_KHZ/BandWidth;
  }
  HwParams.FcDds = (unsigned)((double)Fc*1000*
    (BitWidth/(double)FpgaClkRate));
  HwParams.FcDdsAdc=(unsigned)((double)Fc*1000*
    (BitWidth/(double)AdcClkRate));

#ifndef NO_DEVMEM
  if (Configure)
  {
    HwInterfaceConfigureSignalParams(HwParams.DacInterpolation,
      HwParams.AdcDecimation, HwParams.FcDds, HwParams.FcDdsAdc);
  }
#endif

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

Dac_Parameters_Type DacChainGetDacParams(void)
{
  return DacParams;
}

#ifdef DAC
ReturnStatusType DacChainUpConversion(bool DebugMode, unsigned FileNumber,
  unsigned Nfft, unsigned CpLen, unsigned Bandwidth, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  char FileName[32];
  FILE *DucFile = NULL;
  creal_T *DucBufferPtr = NULL;
  creal_T *DucInData = NULL; // Buffer going to IQ mixer
  creal_T DucIQMix;
  creal_T *DucTmpOut = NULL; // Buffer part of out emxArray struct
  g_emxArray_creal_T *DucInStruct = NULL;
  g_emxArray_creal_T *DucOutStruct = NULL;
  int SizeInt[2];
  int SizeInt1[2];
  double t = 0;

  DucBufferPtr = TxModulateGetTxBuffer();

  DucInData = (creal_T *)
    malloc((CpLen+Nfft)*OfdmSymbols*sizeof(creal_T));
  if (DucInData == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DacChainUpConversion: Could not malloc DucInData\n");
    return ReturnStatus;
  }
  memset(DucInData, 0, (CpLen+Nfft)*OfdmSymbols*sizeof(creal_T));

  DucOutData = (int16_t *)
    malloc((CpLen+Nfft)*OfdmSymbols*DacParams.Interp*
    DacParams.Interp*sizeof(creal_T));
  if (DucOutData == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DacChainUpConversion: Could not malloc DucOutData\n");
    return ReturnStatus;
  }
  memset(DucOutData, 0, (CpLen+Nfft)*OfdmSymbols*DacParams.Interp*
    DacParams.Interp*sizeof(creal_T));

  DucTmpOut = (creal_T *)
    malloc((CpLen+Nfft)*DacParams.Interp*sizeof(creal_T));
  if (DucTmpOut == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DacChainUpConversion: Could not malloc DucTmpOut\n");
    return ReturnStatus;
  }
  memset(DucTmpOut, 0, (CpLen+Nfft)*DacParams.Interp*sizeof(creal_T));

  DucInStruct = (g_emxArray_creal_T *)malloc(sizeof(g_emxArray_creal_T));
  if (DucInStruct == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DacChainUpConversion: Could not malloc DucInStruct\n");
    return ReturnStatus;
  }
  memset(DucInStruct, 0, sizeof(g_emxArray_creal_T));

  DucOutStruct = (g_emxArray_creal_T *)malloc(sizeof(g_emxArray_creal_T));
  if (DucOutStruct == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DacChainUpConversion: Could not malloc DucOutStruct\n");
    return ReturnStatus;
  }

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

  for (unsigned i = 0; i < OfdmSymbols; i++)
  {
    for (unsigned j = 0; j < (Nfft+CpLen); j++)
    {
      DucInData[j].re = DucBufferPtr[j+(Nfft+CpLen)*i].re;
      DucInData[j].im = DucBufferPtr[j+(Nfft+CpLen)*i].im;
#ifdef SAMPLE_DEBUG
      if (j == 0)
      {
        printf("\tSymbol %d\n", i);
      }
      if (j < 4)
      {
        printf("\tDucInData[%d]: %lf+j%lf\n", j, DucInData[j].re,
          DucInData[j].im);
      }
      if (j > (Nfft+CpLen-5))
      {
        printf("\tDucInData[%d]: %lf+j%lf\n", j, DucInData[j].re,
          DucInData[j].im);
      }
#endif
    }
    ////////////////////////////////////////////////////////////
    printf("Nfft+CpLen = %d\n", (int)(Nfft+CpLen));
    SizeInt[1] = (int)(Nfft+CpLen);
    SizeInt[0] = 1;
    //DucInStruct->data = DucBufferPtr;
    DucInStruct->data = DucInData;
    DucInStruct->size = SizeInt;
    DucInStruct->allocatedSize = Nfft + CpLen;
    DucInStruct->numDimensions = 1;
    ////////////////////////////////////////////////////////////
    memset(DucOutStruct, 0, sizeof(g_emxArray_creal_T));
    memset(DucTmpOut, 0, (CpLen+Nfft)*DacParams.Interp*sizeof(creal_T));
    //SizeInt[1] = (int)((Nfft+CpLen)*DacParams.Interp);
    SizeInt1[1] = (int)((Nfft+CpLen));
    SizeInt1[0] = 1;
    DucOutStruct->data = DucTmpOut;
    DucOutStruct->size = SizeInt1;
    DucOutStruct->allocatedSize = (Nfft + CpLen)*DacParams.Interp;
    //DucOutStruct->allocatedSize = (Nfft + CpLen);
    DucOutStruct->numDimensions = 1;

    printf("About to %dx Interpolate %d Symbol\n", DacParams.Interp,i);
    Interp(DucInStruct, (short)DacParams.Interp, DucOutStruct);
    ////////////////////////////////////////////////////////////
    for (unsigned j = 0; j < (Nfft+CpLen)*DacParams.Interp; j++)
    {
      DucIQMix.re = DucTmpOut[j].re*cos(2*M_PI*(double)DacParams.Fc*t);
      DucIQMix.im = DucTmpOut[j].im*-1.0*
        sin(2*M_PI*(double)DacParams.Fc*t);
      DucOutData[j+(Nfft+CpLen)*DacParams.Interp*i] = (int16_t)
        (DucIQMix.re + DucIQMix.im);
      t = t + (1.0/(double)Bandwidth/(double)DacParams.Interp);
      if (DebugMode)
      {
        // Record DUC output
        //fprintf(DucFile, "%lf, %lf\n", DucTmpOut[j].re, DucTmpOut[j].im);
        // Record IQ Mixer output
        fprintf(DucFile, "%d\n", 
          DucOutData[j+(Nfft+CpLen)*DacParams.Interp*i]);
#ifdef SAMPLE_DEBUG
      if (j == 0)
      {
        printf("\tSymbol %d\n", i);
      }
      if (j < 4)
      {
        printf("\tDucOutData[%d]: %lf+j%lf\n", j, DucTmpOut[j].re,
          DucTmpOut[j].im);
      }
      if (j > (((Nfft+CpLen)*DacParams.Interp)-5))
      {
        printf("\tDucOutData[%d]: %lf+j%lf\n", j, DucTmpOut[j].re,
          DucTmpOut[j].im);
      }
#endif
      }
    }
  }

  if (DucFile != NULL)
  {
    fclose(DucFile);
    printf("DacChainUpConversion: Wrote to file %s\n", FileName);
  }

  free(DucInData);
  free(DucTmpOut);
  free(DucInStruct);
  free(DucOutStruct);
  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
#endif // ifdef DAC

int16_t *DacChainGetDMABuff(void)
{
  return DucOutData;
}

void DacChainClearDMABuff(void)
{
  free(DucOutData);
}
