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
#include "TxModulate.h"
#include "TransmitChain.h"
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

void HwInterfaceResetPL(bool Reset)
{
  if (Reset)
  {
    printf("HwInterfaceResetPL: Putting PL in Reset ... \n");
    FpgaInterfaceWrite(GPIO_2_BASE_ADDR+AUX_RESETN_OFFSET,
      0<<AUX_RESETN_MASK_OFFSET, AUX_RESETN_MASK, GlobalMute);
  }
  else
  {
    printf("HwInterfaceResetPL: Taking PL out of Reset ... \n");
    FpgaInterfaceWrite(GPIO_2_BASE_ADDR+AUX_RESETN_OFFSET,
      1<<AUX_RESETN_MASK_OFFSET, AUX_RESETN_MASK, GlobalMute);
  }
}

void HwInterfaceDucDdcLoopback(bool Select)
{
  unsigned RegValue = Select << DUC_DDC_LOOPBACK_MASK_OFFSET;
  if (Select)
  {
    if (!GlobalMute)
      printf("HwInterfaceDucDdcLoopback: Configuring DUC, DDC Loop\n");
    FpgaInterfaceWrite(GPIO_3_BASE_ADDR+DUC_DDC_LOOPBACK_OFFSET,
      RegValue, DUC_DDC_LOOPBACK_MASK, GlobalMute);
  }
  else
  {
    if (!GlobalMute)
      printf("HwInterfaceDucDdcLoopback: Configuring DUC, DDC Loop\n");
    FpgaInterfaceWrite(GPIO_3_BASE_ADDR+DUC_DDC_LOOPBACK_OFFSET,
      RegValue, DUC_DDC_LOOPBACK_MASK, GlobalMute);
  }
}

void HwInterfaceSetDmaTlastGen(bool DucDdcLoopSel, unsigned Samples)
{
  if (DucDdcLoopSel == 0) // Program zero, tlast is passthrough
  {
    if (!GlobalMute)
      printf("HwinterfaceSetDmaTlastGen: Clearing DMA Tlast Gen\n");
    FpgaInterfaceWrite32(GPIO_3_BASE_ADDR+DMA_TLAST_GEN_OFFSET, 0,
      GlobalMute);
  }
  else // Program sample to generate tlast pulse on
  {
#ifdef DEBUG
    printf("HwInterfaceSetDmaTlastGen: Program tlast to be on "
      "%dth sample\n", Samples);
#endif
    if (!GlobalMute)
      printf("HwinterfaceSetDmaTlastGen: Configuring DMA Tlast Gen\n");
    FpgaInterfaceWrite32(GPIO_3_BASE_ADDR+DMA_TLAST_GEN_OFFSET,
      Samples-1, GlobalMute);
  }
}

void HwInterfaceEnableDac(void)
{
  unsigned RegValue;
  FpgaInterfaceRead32(GPIO_0_BASE_ADDR+ADC_CONTROL_OFFSET, &RegValue,
    true);
  RegValue = (RegValue & ADC_CONTROL_MASK) >> ADC_CONTROL_MASK_OFFSET;
  if (RegValue != 0)
  {
    printf("HwInterfaceEnableDac: ERROR: ADC Enabled, not turning on "
      " DAC\n");
    printf("HwInterfaceEnableDac: Disabling DAC/PA\n");
    HwInterfaceDisableDac();
  }
  else
  {
    RegValue = ENABLE_DAC_PWR_AMP << DAC_CONTROL_MASK_OFFSET;
    if (!GlobalMute)
      printf("HwInterfaceEnableDac: Enabling DAC and PA\n");
    FpgaInterfaceWrite(GPIO_0_BASE_ADDR+DAC_CONTROL_OFFSET, RegValue, 
      DAC_CONTROL_MASK, GlobalMute);
  }
}

void HwInterfaceDisableDac(void)
{
  unsigned RegValue;
  RegValue = DISABLE_DAC_PWR_AMP << DAC_CONTROL_MASK_OFFSET;
  if (!GlobalMute)
    printf("HwInterfaceDisableDac: Disabling DAC and PA\n");
  FpgaInterfaceWrite(GPIO_0_BASE_ADDR+DAC_CONTROL_OFFSET, RegValue,
    DAC_CONTROL_MASK, GlobalMute);
}

void HwInterfaceEnableAdc(void)
{
  unsigned RegValue;
  FpgaInterfaceRead32(GPIO_0_BASE_ADDR+DAC_CONTROL_OFFSET, &RegValue,
    true);
  RegValue = (RegValue & DAC_CONTROL_MASK) >> DAC_CONTROL_MASK_OFFSET;
  if (RegValue != 0)
  {
    printf("HwInterfaceEnableAdc: ERROR: DAC/PA Enabled, not turning "
      "on ADC\n");
    printf("HwInterfaceEnableAdc: Disabling ADC\n");
    HwInterfaceDisableAdc();
  }
  else
  {
    RegValue = (ADC_ENABLE+ADC_CLEAR_OVERRUN+ADC_CLEAR_OTR) << 
      ADC_CONTROL_MASK_OFFSET;
    printf("HwInterfaceEnableAdc: Enabling ADC\n");
    FpgaInterfaceWrite(GPIO_0_BASE_ADDR+ADC_CONTROL_OFFSET, RegValue,
      ADC_CONTROL_MASK, GlobalMute);
  }
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

void HwInterfaceDmaLoopback(unsigned Enable)
{
  unsigned RegValue = Enable;
  RegValue = RegValue << DMA_LOOPBACK_MASK_OFFSET;
  if (!GlobalMute)
    printf("HwInterfaceDmaLoopback: Setting DMA Loop %d\n", Enable);
  FpgaInterfaceWrite(GPIO_1_BASE_ADDR+DMA_LOOPBACK_OFFSET, RegValue,
    DMA_LOOPBACK_MASK, GlobalMute);
}

void HwInterfaceSyncLoopback(unsigned Enable)
{
  unsigned RegValue = Enable;
  RegValue = RegValue << SYNC_LOOPBACK_MASK_OFFSET;
  if (!GlobalMute)
    printf("HwInterfaceSyncLoopback: Setting Sync Loop %d\n", Enable);
  FpgaInterfaceWrite(GPIO_2_BASE_ADDR+SYNC_LOOPBACK_OFFSET,
    RegValue, SYNC_LOOPBACK_MASK, GlobalMute);
}

void HwInterfaceConfigureSignalParams(unsigned Interpolation,
  unsigned Decimation, unsigned FcScaledDac, unsigned FcScaledAdc)
{
  unsigned RegValue = Interpolation;
  if (!GlobalMute)
    printf("HwinterfaceConfigureSignalParams: Setting Interp Factor\n");
  FpgaInterfaceWrite(GPIO_1_BASE_ADDR+DUC_INTERP_RATIO_OFFSET,
    RegValue, DUC_INTERP_RATIO_MASK, GlobalMute);
  RegValue = Decimation;
  if (!GlobalMute)
    printf("HwinterfaceConfigureSignalParams: Setting Decim Factor\n");
  FpgaInterfaceWrite(GPIO_0_BASE_ADDR+DECIMATE_RADIO_OFFSET,
    RegValue, DECIMATE_RADIO_MASK, GlobalMute);
  RegValue = FcScaledDac;
  if (!GlobalMute)
    printf("HwinterfaceConfigureSignalParams: Setting DAC FC\n");
  FpgaInterfaceWrite32(GPIO_0_BASE_ADDR+FC_SCALED_OFFSET,
    RegValue, GlobalMute);
  if (!GlobalMute)
    printf("HwinterfaceConfigureSignalParams: Setting ADC FC\n");
  // ADC DDS requires specific value
  RegValue = FcScaledAdc;
  FpgaInterfaceWrite32(GPIO_4_BASE_ADDR+ADC_FC_SCALED_OFFSET,
    RegValue, GlobalMute);
    //26843546, GlobalMute);
}

ReturnStatusType HwInterfaceConfigureSynchronizer(unsigned Nfft, 
  unsigned CpLen, unsigned OfdmSymbols, unsigned Threshold, 
  int SyncOffset)
{
  ReturnStatusType ReturnStatus;
  unsigned RegValue;
  if (!GlobalMute)
    printf("HwInterfaceConfigureSynchronizer: Config Nfft\n");
  FpgaInterfaceWrite(GPIO_2_BASE_ADDR+NFFT_OFFSET, Nfft-1, NFFT_MASK,
    GlobalMute);
  RegValue = (CpLen-1) << CP_LEN_MASK_OFFSET;
  if (!GlobalMute)
    printf("HwInterfaceConfigureSynchronizer: Config CP Length\n");
  FpgaInterfaceWrite(GPIO_2_BASE_ADDR+CP_LEN_OFFSET, RegValue,
    CP_LEN_MASK, GlobalMute);
  RegValue = (OfdmSymbols-1) << OFDM_SYMBOLS_MASK_OFFSET;
  if (!GlobalMute)
    printf("HwInterfaceConfigureSynchronizer: Config OFDM Symbols\n");
  FpgaInterfaceWrite(GPIO_1_BASE_ADDR+OFDM_SYMBOLS_OFFSET, RegValue,
    OFDM_SYMBOLS_MASK, GlobalMute);
  if (!GlobalMute)
    printf("HwInterfaceConfigureSynchronizer: Config Threshold\n");
  FpgaInterfaceWrite32(GPIO_2_BASE_ADDR+SYNC_THRESHOLD_OFFSET,
    Threshold, GlobalMute);
  if (SyncOffset < -1024 || SyncOffset > 1024)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "HwInterfaceConfigureSynchronizer: ERR: Offset too large/small\n");
    return ReturnStatus;
  }
  if (!GlobalMute)
    printf("HwInterfaceConfigureSynchronizer: Config Sync Offset\n");
  FpgaInterfaceWrite(GPIO_1_BASE_ADDR+SYNC_OFFSET_OFFSET,
    SyncOffset<<SYNC_OFFSET_MASK_OFFSET, SYNC_OFFSET_MASK, GlobalMute);
  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void HwInterfaceSynchronizerStatus(bool Enable)
{
  if (!GlobalMute)
    printf("HwInterfaceSynchronizerStatus: Set Sync Status %d\n", Enable);
  if (Enable)
  {
    FpgaInterfaceWrite(GPIO_2_BASE_ADDR+SYNC_ENABLE_OFFSET,
      1<<SYNC_ENABLE_MASK_OFFSET, SYNC_ENABLE_MASK, GlobalMute);
  }
  else
  {
    FpgaInterfaceWrite(GPIO_2_BASE_ADDR+SYNC_ENABLE_OFFSET,
      0<<SYNC_ENABLE_MASK_OFFSET, SYNC_ENABLE_MASK, GlobalMute);
  }
}

void HwInterfaceSineToneSet(unsigned CwIqScale)
{
  FpgaInterfaceWrite32(GPIO_4_BASE_ADDR+SINE_TONE_OFFSET,
    CwIqScale, GlobalMute);
}

ReturnStatusType HwInterfaceLoadZcSequence(unsigned Nfft, unsigned 
  IqSelect, unsigned Bw)
{
  ReturnStatusType ReturnStatus;
  char FileNamePath[64];
  FILE *ZcFile = NULL;
  FILE *ReloadOrderFile = NULL;
  unsigned DmaInterrupt;
  unsigned ReloadOrder;
  unsigned ReloadCoefLength;
  int16_T ReloadBufferUnOrdered[RELOAD_COEF_MAX];
  int16_T *ReloadBuffer = NULL;
  int16_T tmp;

  memset(ReloadBufferUnOrdered, 0, sizeof(ReloadBufferUnOrdered));

  ReloadBuffer = (int16_T *)FpgaInterfaceGetReloadBuffer();
  if (ReloadBuffer == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "HwInterfaceLoadZcSequence: Failed to open Reload Buffer\n");
    return ReturnStatus;
  }

  if (IqSelect)
  {
    sprintf(FileNamePath, "files/zc_fir_coef_%d_nfft_%d_ZC_13_root_q.txt",
      Nfft, Nfft/2);
  }
  else
  {
    sprintf(FileNamePath, "files/zc_fir_coef_%d_nfft_%d_ZC_13_root_i.txt",
      Nfft, Nfft/2);
  }

  ZcFile = fopen(FileNamePath, "r");
  if (ZcFile == NULL)
  {
    perror("HwInterfaceLoadZcSequence");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "HwInterfaceLoadZcSequence: Failed to open %s\n", FileNamePath);
    return ReturnStatus;
  }
  printf("HwInterfaceLoadZcSequence: Opened file %s\n", FileNamePath);

  sprintf(FileNamePath, "files/FIR_Sync_Reload_order_%d.txt", Bw);

  ReloadOrderFile = fopen(FileNamePath, "r");
  if (ReloadOrderFile == NULL)
  {
    perror("HwInterfaceLoadZcSequence");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "HwInterfaceLoadZcSequence: Failed to open %s\n", FileNamePath);
    return ReturnStatus;
  }
  printf("HwInterfaceLoadZcSequence: Opened file %s\n", FileNamePath);

  for (unsigned i = 0; i < Nfft; i++)
  {
    fscanf(ZcFile, "%hd", &tmp);
    ReloadBufferUnOrdered[i] = tmp;
  }

  fscanf(ReloadOrderFile, "%d\n", &ReloadCoefLength);
  memset(ReloadBuffer, 0, ReloadCoefLength*2);

  for (unsigned i = 0; i < ReloadCoefLength; i++)
  {
    fscanf(ReloadOrderFile, "%d\n", &ReloadOrder);
    ReloadBuffer[i] = ReloadBufferUnOrdered[ReloadOrder];
  }

  // Set DMA mux to go to either real or imaginary FIR filter
  FpgaInterfaceWrite(GPIO_2_BASE_ADDR+FIR_1_RELOAD_OFFSET,
    IqSelect<<FIR_1_RELOAD_MASK_OFFSET, FIR_1_RELOAD_MASK, GlobalMute);
  // Reset the DMA
  FpgaInterfaceWrite32(DMA_RELOAD_BASE_ADDR, DMA_RESET, GlobalMute);
  // Take DMA out of reset and enable IOC IRQ mask
  FpgaInterfaceWrite32(DMA_RELOAD_BASE_ADDR, DMA_IOC_IRQ_MASK+0x1,
    GlobalMute);
  // Configure read address of DMA
  FpgaInterfaceWrite32(DMA_RELOAD_BASE_ADDR+DMA_SOURCE_OFFSET,
    RELOAD_BUFFER_BASE, GlobalMute);
  // Configure length of transfer in bytes of DMA
  FpgaInterfaceWrite32(DMA_RELOAD_BASE_ADDR+DMA_LENGTH_OFFSET,
    ReloadCoefLength*2, GlobalMute);
  while (1) // Wait until done bit goes high
  {
    FpgaInterfaceRead32(DMA_RELOAD_BASE_ADDR+DMA_STATUS_OFFSET,
      &DmaInterrupt, true);
    if (!((DmaInterrupt & DMA_IOC_IRQ_MASK) == 0))
    {
      printf("HwInterfaceLoadZcSequence: Finished DMA Reload transaction "
        "%d\n", IqSelect);
      // Reset done bit when done
      FpgaInterfaceWrite(DMA_RELOAD_BASE_ADDR+DMA_STATUS_OFFSET,
        DMA_IOC_IRQ_MASK, DMA_IOC_IRQ_MASK, GlobalMute);
      break;
    }
  }

  // Put DMA back in reset
  FpgaInterfaceWrite32(DMA_RELOAD_BASE_ADDR, DMA_RESET, GlobalMute);
  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void HwInterfaceSetGuardPeriod(unsigned FpgaClkSamples)
{
  FpgaInterfaceWrite32(GPIO_5_BASE_ADDR+SYMBOL_GUARD_OFFSET,
    FpgaClkSamples, GlobalMute);
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

// Start TX Transmission (will still wait for DMA data)
void HwInterfaceStartTx(void)
{
  unsigned RegValue;

  RegValue = 1 << DL_EN_REG_OFFSET;
  RegValue &= DL_EN_REG_MASK;
#ifdef DEBUG
  printf("HwInterfaceStartTx: Tx Chain configured and waiting\n");
#endif
  FpgaInterfaceWrite(DL_EN_REG, RegValue, DL_EN_REG_MASK, GlobalMute);
}

// Stop TX Transmission 
void HwInterfaceStopTx(void)
{
  unsigned RegValue;

  RegValue = 0 << DL_EN_REG_OFFSET;
  RegValue &= DL_EN_REG_MASK;
#ifdef DEBUG
  printf("HwInterfaceStopTx: Tx Chain stopped\n");
#endif
  FpgaInterfaceWrite(DL_EN_REG, RegValue, DL_EN_REG_MASK, GlobalMute);
}

// Configure config_fft register
void HwInterfaceConfigFftCore(void)
{
  unsigned RegValue;

  RegValue = 1 << CONFIG_FFT_CORE_OFFSET;
  RegValue &= CONFIG_FFT_CORE_MASK;
#ifdef DEBUG
  printf("HwInterfaceConfigFftCore: Rising edge on FFT config\n");
#endif
  FpgaInterfaceWrite(CONFIG_FFT_CORE_REG, RegValue, CONFIG_FFT_CORE_MASK,
    GlobalMute);
  usleep(1000); // Give some time for core to configure

  RegValue = 0 << CONFIG_FFT_CORE_OFFSET;
  RegValue &= CONFIG_FFT_CORE_MASK;
#ifdef DEBUG
  printf("HwInterfaceConfigFftCore: Falling edge on FFT config\n");
#endif
  FpgaInterfaceWrite(CONFIG_FFT_CORE_REG, RegValue, CONFIG_FFT_CORE_MASK,
    GlobalMute);
}

// Configure SpiFile_cycles, nfft, cp_len, nfft symbols, inv,
// negative_freq, continuous, playback registers
void HwInterfaceConfigTxChain(Ofdm_Parameters_Type *OfdmParams,
  Calculated_Ofdm_Parameters *OfdmCalcParams, Ofdm_Timing_Type 
  *OfdmTiming)
{
  unsigned RegValue, mask, tmp;

  // Configure SpiFile_cycles + nfft on same register:
  RegValue = OfdmCalcParams->Symbol.FpgaClkSamples <<
    FS_CYCLES_REG_OFFSET;
  RegValue &= FS_CYCLES_REG_MASK;
  tmp = OfdmCalcParams->NfftScaled; // Scaled NFFT
  RegValue |= ((tmp << NFFT_REG_OFFSET) & NFFT_REG_MASK);
  mask = NFFT_REG_MASK | FS_CYCLES_REG_MASK;
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring SpiFile_cycles + nfft reg\n");
#endif
  FpgaInterfaceWrite(FS_CYCLES_REG, RegValue, mask, GlobalMute);

  // Configure CP_LEN, NFFT_SCALED and OFDM_SYMBOLS
  RegValue = OfdmParams->CpLen << CP_LEN_REG_OFFSET;
  RegValue &= CP_LEN_REG_MASK;
  RegValue |= ((OfdmParams->Nfft << NFFT_SCALED_REG_OFFSET) &
    NFFT_SCALED_REG_MASK);
  RegValue |= ((OfdmTiming->OfdmSymbolsPerFrame << 
    OFDM_SYMBOLS_REG_OFFSET) & OFDM_SYMBOLS_REG_MASK);
  mask = CP_LEN_REG_MASK | NFFT_SCALED_REG_MASK | OFDM_SYMBOLS_REG_MASK;
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring cp_len, nfft_sc, ");
  printf(" and symbols reg\n");
#endif
  FpgaInterfaceWrite(CP_LEN_REG, RegValue, mask, GlobalMute);

  // Configure IFFT/FFT control
  RegValue = 1 << SEL_IFFT_FFT_REG_OFFSET;
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring IFFT/FFT select reg\n");
#endif
  FpgaInterfaceWrite(SEL_IFFT_FFT_REG, RegValue, SEL_IFFT_FFT_REG_MASK, 
    GlobalMute);

  // Enable/Disable conjugate at output of IFFT
  RegValue = IFFT_CONJUGATE << NEGATIVE_FREQ_REG_OFFSET;
  RegValue &= (NEGATIVE_FREQ_REG_MASK);
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring IFFT conjugate reg\n");
#endif
  FpgaInterfaceWrite(NEGATIVE_FREQ_REG, RegValue, NEGATIVE_FREQ_REG_MASK,
    GlobalMute);

  // Configure Non-Continuous Transmission
  RegValue = 0 << PLAYBACK_CONTINUOUS_REG_OFFSET;
  RegValue &= (PLAYBACK_CONTINUOUS_REG_MASK);
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring continuous reg\n");
#endif
  FpgaInterfaceWrite(PLAYBACK_CONTINUOUS_REG, RegValue, 
    PLAYBACK_CONTINUOUS_REG_MASK, GlobalMute);

  // Configure Non Playback mode
  RegValue = 0 << PLAYBACK_EN_REG_OFFSET;
  RegValue &= (PLAYBACK_EN_REG_MASK);
#ifdef DEBUG
  printf("HwInterfaceConfigTxChain: Configuring in normal mode reg\n");
#endif
  FpgaInterfaceWrite(PLAYBACK_EN_REG, RegValue, PLAYBACK_EN_REG_MASK,
    GlobalMute);
}
