//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "TransmitChain.h"
#include "TxModulate.h"
#include "DacChain.h"
#include "g_Interp.h"

#define SAMPLE_DEBUG

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

ReturnStatusType DacChainUpConversion(bool DebugMode, unsigned FileNumber,
  unsigned Nfft, unsigned CpLen, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  char FileName[32];
  FILE *DucFile = NULL;
  creal_T *DucBufferPtr = NULL;
  creal_T *DucInData = NULL; // Buffer going to IQ mixer
  creal_T *DucOutData = NULL; // Buffer going to IQ mixer
  creal_T *DucTmpOut = NULL; // Buffer part of out emxArray struct
  g_emxArray_creal_T *DucInStruct = NULL;
  g_emxArray_creal_T *DucOutStruct = NULL;
  int SizeInt[2];

  DucBufferPtr = TxModulateGetTxBuffer();

  DucInData = (creal_T *)
    malloc((CpLen+Nfft)*OfdmSymbols*16);
  if (DucInData == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DacChainUpConversion: Could not malloc DucInData\n");
    return ReturnStatus;
  }
  memset(DucInData, 0, (CpLen+Nfft)*OfdmSymbols*16);

  DucOutData = (creal_T *)
    malloc((CpLen+Nfft)*OfdmSymbols*DacParams.Interp*
    DacParams.Interp*16);
  if (DucOutData == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DacChainUpConversion: Could not malloc DucOutData\n");
    return ReturnStatus;
  }
  memset(DucOutData, 0, (CpLen+Nfft)*OfdmSymbols*DacParams.Interp*
    DacParams.Interp*16);

  DucTmpOut = (creal_T *)
    malloc((CpLen+Nfft)*DacParams.Interp*16);
  if (DucTmpOut == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "DacChainUpConversion: Could not malloc DucTmpOut\n");
    return ReturnStatus;
  }
  memset(DucTmpOut, 0, (CpLen+Nfft)*DacParams.Interp*16);

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
    SizeInt[1] = (int)(Nfft+CpLen);
    SizeInt[0] = 0;
    //DucInStruct->data = DucBufferPtr;
    DucInStruct->data = DucInData;
    DucInStruct->size = SizeInt;
    DucInStruct->allocatedSize = Nfft + CpLen;
    DucInStruct->numDimensions = 1;
    ////////////////////////////////////////////////////////////
    memset(DucOutStruct, 0, sizeof(g_emxArray_creal_T));
    memset(DucTmpOut, 0, (CpLen+Nfft)*DacParams.Interp*16);
    //SizeInt[1] = (int)((Nfft+CpLen)*DacParams.Interp);
    SizeInt[1] = (int)((Nfft+CpLen));
    SizeInt[0] = 1;
    DucOutStruct->data = DucTmpOut;
    DucOutStruct->size = SizeInt;
    DucOutStruct->allocatedSize = (Nfft + CpLen)*DacParams.Interp;
    //DucOutStruct->allocatedSize = (Nfft + CpLen);
    DucOutStruct->numDimensions = 1;
    Interp(DucInStruct, (short)DacParams.Interp, DucOutStruct);
    ////////////////////////////////////////////////////////////
    for (unsigned j = 0; j < (Nfft+CpLen)*DacParams.Interp; j++)
    {
      if (DebugMode)
      {
        fprintf(DucFile, "%lf, %lf\n", DucTmpOut[j].re, DucTmpOut[j].im);
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
    printf("Interpolated %d Symbols\n", i+1);
  }

  if (DucFile != NULL)
  {
    fclose(DucFile);
    printf("DacChainUpConversion: Wrote to file %s\n", FileName);
  }

  free(DucInData);
  free(DucOutData);
  free(DucTmpOut);
  free(DucInStruct);
  free(DucOutStruct);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
