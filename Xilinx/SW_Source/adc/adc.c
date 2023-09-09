//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include "ReturnStatus.h"
#include "FpgaInterface.h"
#include "HwInterface.h"

#define DEBUG

int main()
{

  ReturnStatusType ReturnStatus;
  unsigned Selection;
  unsigned AdcStatus;
  unsigned ScanfRet; // To get rid of warnings
  int RxGain;

  printf("\n----- ADC TEST APPLICATION -----\n\n");

  ReturnStatus = FpgaInterfaceSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    return 1;
  }

  printf("\nADC Status ('0'-OFF / '1'-ON): ");
  ScanfRet = scanf("%d", &Selection);
  if (!Selection)
  {
    printf("\nTurning off ADC ...\n\n");
    HwInterfaceDisableAdc();
    return 0;
  }

  printf("\nEnter RX gain in dB: ");
  ScanfRet = scanf("%d", &RxGain);

  ReturnStatus = HwInterfaceGpioSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    return 1;
  }

  ReturnStatus = HwInterfaceSpiSetup();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
    return 1;
  }
  
  ReturnStatus = HwInterfaceSetVga(RxGain);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    printf("%s", ReturnStatus.ErrString);
  }

  printf("\nTurning on ADC ...\n");
  HwInterfaceEnableAdc();

  AdcStatus = HwInterfaceReturnAdcStatus();
  printf("\nADC Status: 0x%X\n\n", AdcStatus);

  printf("%d\n", ScanfRet);

  return 0;
}
