//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//
// Make sure driver for Cadence SPI hard IP is enabled as well as
// user space spi driver "spidev". Editing device tree is necessary.
// When successful device "/dev/spidevB.C" will show up.
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/spi/spidev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include "ReturnStatus.h"
#include "HwInterface.h"
#include "FpgaInterface.h"
#include "ReturnStatus.h"

#define DEBUG

static int SpiFile;  // /dev/spidev1 file
static int GpioFile; // /sys/class/gpio/* file
static bool GlobalMute;

void HwInterfaceSetGlobalMute(bool GlobalMuteSelect)
{
  GlobalMute = GlobalMuteSelect;
}

void HwInterfaceEnableAdc(void)
{
  unsigned RegValue;
  RegValue = (ADC_ENABLE) << ADC_CONTROL_MASK_OFFSET;
  printf("HwInterfaceEnableAdc: Enabling ADC\n");
  FpgaInterfaceWrite(GPIO_0_BASE_ADDR+ADC_CONTROL_OFFSET, RegValue,
    ADC_CONTROL_MASK, GlobalMute);
}

void HwInterfaceDisableAdc(void)
{
  unsigned RegValue;
  RegValue = ADC_DISABLE << ADC_CONTROL_MASK_OFFSET;
  if (!GlobalMute)
    printf("HwInterfaceDisableAdc: Disabling ADC\n");
  FpgaInterfaceWrite(GPIO_0_BASE_ADDR+ADC_CONTROL_OFFSET, RegValue,
    ADC_CONTROL_MASK, GlobalMute);
}

unsigned HwInterfaceReturnAdcStatus(void)
{
  unsigned RegValue;
  if (!GlobalMute)
  FpgaInterfaceRead32(GPIO_1_BASE_ADDR+ADC_STATUS_OFFSET, &RegValue,
    GlobalMute);
  return RegValue;
}

ReturnStatusType HwInterfaceSetVga(int gain)
{
  ReturnStatusType ReturnStatus;
  int ret;
  __uint16_t data;

  if ((int) gain > 55.5)
    gain = 55;

  if ((int) gain < -4.5)
    gain = -4.0;

  printf("HwInterfaceSetVga: Setting gain to %d\n", gain);
  
  if (gain < 10) // Use LO setting on VGA
  {
    HwInterfaceSetVgaHiLo(0);
    data = (__uint16_t)((((int) gain + 6.5)/50.0)/0.001);
  }
  else           // Use HI setting on VGA
  {
    HwInterfaceSetVgaHiLo(1);
    data = (__uint16_t)((((int) gain - 5.5)/50.0)/0.001);
  }

  // Write to VGA DAC via SPI
  //swap bytes for correct order to DAC
  data = ((data << 8) & 0xFF00)|((data >> 8) & 0x00FF); 

  struct spi_ioc_transfer tr = {
    .tx_buf = (unsigned long) &data,
    .len = 2,
    .speed_hz = 1250000,
    .bits_per_word = 8,
  };

  ret = ioctl(SpiFile, SPI_IOC_MESSAGE(1), &tr);
  if (ret < 1)
  {
    perror("Can't send SPI data\n");
    ReturnStatus.Status = RETURN_STATUS_SUCCESS;
    sprintf(ReturnStatus.ErrString,
      "HwINterfaceSetVga: Can't send SPI data\n");
    return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void HwInterfaceSetVgaHiLo(unsigned value)
{
  int RetVal = 0;

  if (value == 0)
  {
    RetVal = write(GpioFile, "0", 2); // Drive GPIO low
  }
  else if (value == 1)
  {
    RetVal = write(GpioFile, "1", 2); // Drive GPIO high
  }
  else
  {
    printf("HwInterfaceSetVgaHiLo: ERROR: Wrong GPIO setting\n");
  }

  if (RetVal == -1)
  {
    printf("HwINterfaceSetVgaHiLo: ERROR: issue with write()\n");
  }
}

// In the device tree, there are gpio device entries:
//  - Zynq_GPIO (for MIO)
//  - ADC_Control
//  - DAC_Control, etc
// You can use the /dev/gpiochip0 to control MIO20
//
// We could have used /dev/gpiochip* to control the PL GPIO registers
// which would require a different method of mmaping to the addresses.
// 
// The way we control the PS GPIO MIO20 via SysFs interface is easy
// and requires little setup
ReturnStatusType HwInterfaceGpioSetup(void)
{
  ReturnStatusType ReturnStatus;
  int RetVal;

  // unexport MIO20 pil
  GpioFile = open("/sys/class/gpio/unexport", O_WRONLY);
  if (GpioFile == -1)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "HwInterfaceGpioSetup: ERROR: Could not open "
      "\"/sys/class/gpio/unexport\"...\n");
    return ReturnStatus;
  }
  // If the pin is already exported, unexport it
  RetVal = write(GpioFile, "886", 4);
  if (RetVal == -1)
  {
    perror("HwInterfaceGpioSetup:");
    printf("HwInterfaceGpioSetup: WARNING: Could not unexport "
      "GPIO20\n");
  }
  close(GpioFile);

  // Export MIO20 pin
  GpioFile = open("/sys/class/gpio/export", O_WRONLY);
  if (GpioFile == -1)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "HwInterfaceGpioSetup: ERROR: Could not open "
      "\"/sys/class/gpio/export\"...\n");
    return ReturnStatus;;
  }

  // MIO20 = GPIO20 + 866 = 886; because /sys/class/gpio/gpiochip866
  // - may be different on your board
  RetVal = write(GpioFile, "886", 4);
  if (RetVal == -1)
  {
    perror("HwInterfaceGpioSetup:");
    printf("HwInterfaceGpioSetup: WARNING: Could not set GPIO20 "
    "through /sys/class/gpio/export\n");
  }
  close(GpioFile);
  // Set MIO20 pin to be an output
  GpioFile = open("/sys/class/gpio/gpio886/direction", O_WRONLY);
  if (GpioFile == -1)
  {
    perror("HwInterfaceGpioSetup");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "HwInterfaceGpioSetup: ERROR: Could not open "
      "\"/sys/class/gpio/gpio886/direction\"... RetVal = %d, "
      "GpioFile = %d\n", RetVal, GpioFile);
    return ReturnStatus;
  }

  RetVal = write(GpioFile, "out", 4);
  close(GpioFile);
  // Set GpioFile to value on MIO20
  GpioFile = open("/sys/class/gpio/gpio886/value", O_WRONLY);
  if (GpioFile == -1 || RetVal == -1)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    printf(ReturnStatus.ErrString, "ERROR: Could not open "
      "\"/sys/class/gpio/gpio886/value\"...\n");
    return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType HwInterfaceSpiSetup(void)
{
  ReturnStatusType ReturnStatus;
  __uint8_t bits = 8;
  __uint32_t mode;
  __uint32_t speed = 1250000;

  if ((SpiFile = open("/dev/spidev0.1", O_RDWR)) == -1)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
    "HwInterfaceSpiSetup: ERROR: Could not open \"dev/spidev0.1\"...\n");
    return ReturnStatus;
  }

  // Possible modes: mode |= SPI_LOOP; mode |= SPI_CPHA; mode 
  // |= SPI_CPOL; mode |= SPI_LSB_FIRST; mode |= SPI_CS_HIGH; 
  // mode |= SPI_3WIRE; mode |= SPI_NO_CS; mode |= SPI_READY;
  // multiple possibilities using |
  mode = SPI_CPHA;
  if (ioctl(SpiFile, SPI_IOC_WR_MODE32, &mode) == -1)   {
    perror("HwInterfaceSpiSetup");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "HwInterfaceSpiSetup: ERROR: Can't set SPI mode\n");
    return ReturnStatus;
  }

  /*if (ioctl(SpiFile, SPI_IOC_RD_MODE, &mode) == -1)
  {
    perror("SPI rd_mode");
    return 1;
  }

  if (ioctl(SpiFile, SPI_IOC_RD_LSB_FIRST, &lsb) == -1)
  {
    perror("SPI rd_lsb_fist");
    return 1;
  }*/

  // bits per word
  //if (ioctl(SpiFile, SPI_IOC_WR_BITS_PER_WORD, (__u8[1]){8}) == -1)
  if (ioctl(SpiFile, SPI_IOC_WR_BITS_PER_WORD, &bits) < 0)
  {
    perror("can't set bits per word");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "HwINterfaceSpiSetup: ERROR: Can't set bits per word\n");
    return ReturnStatus;
  }

  /*if (ioctl(SpiFile, SPI_IOC_RD_BITS_PER_WORD, &bits) == -1)
  {
    perror("SPI bits_per_word");
    return 1;
  }*/

  if (ioctl(SpiFile, SPI_IOC_WR_MAX_SPEED_HZ, &speed) == -1)
  {
    perror("can't set max speed hz");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "HwInterfaceSpiSetup: ERROR: Can't set max speed in Hz\n");
    return ReturnStatus;
  }

  /*if (ioctl(SpiFile, SPI_IOC_RD_MAX_SPEED_HZ, &speed) == -1)
    {
    perror("SPI max_speed_hz");
    return 1;
  }*/

//  //xfer[0].tx_buf = (unsigned long)buf;
//  xfer[0].len = 3; /* Length of  command to write*/
//  xfer[0].cs_change = 0; /* Keep CS activated */
//  xfer[0].delay_usecs = 0, //delay in us
//  xfer[0].speed_hz = 2500000, //speed
//  xfer[0].bits_per_word = 8, // bites per word 8
//
//  //xfer[1].rx_buf = (unsigned long) buf2;
//  xfer[1].len = 4; /* Length of Data to read */
//  xfer[1].cs_change = 0; /* Keep CS activated */
//  xfer[0].delay_usecs = 0;
//  xfer[0].speed_hz = 2500000;
//  xfer[0].bits_per_word = 8;

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
