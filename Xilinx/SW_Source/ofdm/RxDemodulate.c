//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include "ReturnStatus.h"
#include "TxModulate.h"
#include "QamDemod.h"

#define DEBUG

unsigned *TxBufferPtrLoop = NULL;
//unsigned *RxBufferPtr = NULL;

ReturnStatusType RxDemodulateBufferData(bool Loopback, 
  unsigned FileNumber, unsigned ModOrder, unsigned Nfft, 
  unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  float DemodData;

  printf("Hello\n");
  if (Loopback)
  {
    TxBufferPtrLoop = TxModulateGetTxBuffer();
    if (TxBufferPtrLoop == NULL)
    {
      perror("RxDemodulateBufferData");
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      sprintf(ReturnStatus.ErrString,
        "RxDemodulateBufferData: No Data on TX Buffer\n");
      return ReturnStatus;
    }
  }

  printf("Hello\n");
  DemodData = QamDemod((float)12.0, (float)16.0);
  printf("Hello\n");
  printf("DemodData = %d\n", (int)DemodData);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
