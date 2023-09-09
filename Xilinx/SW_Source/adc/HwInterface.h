//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef HW_INTERFACE_H_INCLUDED
#define HW_INTERFACE_H_INCLUDED

#include <stdbool.h>
#include "ReturnStatus.h"

#define GPIO_0_BASE_ADDR 0x41210000
#define GPIO_1_BASE_ADDR 0x41220000

#define ADC_CONTROL_OFFSET 0x0
#define ADC_CONTROL_MASK_OFFSET 0
#define ADC_CONTROL_MASK 0xFFFFFFFF
#define ADC_ENABLE 0x1
#define ADC_DISABLE 0x0

#define ADC_STATUS_OFFSET 0x0
#define ADC_STATUS_MASK 0xFFFFFFFF

ReturnStatusType HwInterfaceSpiSetup(void);
ReturnStatusType HwInterfaceSetVga(int gain);
void HwInterfaceSetVgaHiLo(unsigned value);
ReturnStatusType HwInterfaceGpioSetup(void);
void HwInterfaceSetVgaHiLo(unsigned value);
void HwInterfaceEnableAdc(void);
void HwInterfaceDisableAdc(void);
unsigned HwInterfaceReturnAdcStatus(void);
#endif
