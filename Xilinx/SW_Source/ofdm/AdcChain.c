//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include "TransmitChain.h"
#include "TxModulate.h"
#include "DacChain.h"

ReturnStatusType AdcChainDownConversion(bool DebugMode, unsigned 
  FileNumber, unsigned Nfft, unsigned CpLen, unsigned BandWidth,
  unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  char FileName[32];
  FILE *DdcFile = NULL;

  if (DebugMode)
  {
    sprintf(FileName, "files/RxDdc%d.txt", FileNumber);
    DdcFile = fopen(FileName, "w");
    if (DdcFile == NULL)
    {
      perror("AdcChainDownConversion");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "AdcChainDownConversion: Failed to open file %s\n", FileName);
      return ReturnStatus;
    }
  }

  // Get rid of warning
  printf("Nfft %d, CpLen %d, BandWidth %d, OfdmSymbols %d\n", Nfft, CpLen,
    BandWidth, OfdmSymbols);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
