//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <unistd.h>
#include "DirectDma.h"
#include "DacChain.h"
#include "rtwtypes.h"

ReturnStatusType DirectDmaPsToPl(unsigned Bytes)
{
  ReturnStatusType ReturnStatus;


#ifndef NO_DEVMEM
  int16_t *DucBufferPtr;
  DucBufferPtr = DacChainGetDMABuff();

#else // Get rid of warnings
  printf("%d Bytes\n", Bytes);
#endif

  DacChainClearDMABuff();

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
