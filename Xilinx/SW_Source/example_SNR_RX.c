///////////////////////////////////////////////////////////////////////////////////////////
// Jared Hermans
//
// B-FSK, FH-FSK and Chirp-FSK
//
// Make sure driver for Cadence SPI hard IP is enabled as well as
// user space spi driver "spidev". Editing device tree is necessary.
// When successful device "/dev/spidevB.C" will show up.
//
// ADC connected to FPGA IO at 40Msps. A decimator IP in FPGA decimated by 40 down to 1Msps.
// This 1Msps stream of digital samples is then split. One stream goes to DMA engine to 
// be saved to DDR to be saved to SD card and analyzed later in MATLAB. The second stream
// follows a full demodulation sequence where the processing system (PS) reads the 
// demodulated bits from BRAM on FPGA. 
//
// The PS aranges the recovered bits into byte packets and sends each byte over UART1.
//
// Ideally, many of the functions handled by this user-space code should be handled by 
// a custom kernel module.
//
// There are 2 FIR Filters in FPGA with the capability of re-loading their coefficients.
// There is a reload DMA and a config DMA which allows the PS to re-load the coefficients
// of either FIR via AXIS Control register muxing. The coefficients are reloaded as 
// integers and are stored in file "FIR_Compilter_coefficients". The frequency hop pattern
// is also stored in a file.
///////////////////////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/mman.h>
#include <malloc.h>
#include <pthread.h>
#include <sys/time.h>
#include <termios.h>
#include <sys/stat.h>
#include <getopt.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>
#include <linux/gpio.h>
#include <stdarg.h>

#define BAUDRATE                      B115200
#define MODEMDEVICE                   "/dev/ttyPS1" // Message signal over UART

//#define AXI_SPAN                    0x00010000  // 64k address span
#define DMA_SPAN                      0x00000080  // 128 address span (AXI_DMA)
#define AXI_SPAN                      0x00000010  // 16 address span (AXI_GPIO)
#define AXI_BRAM_BASE                 0x42000000
#define BRAM_SPAN                     0x00003000  // Address span of 8k

#define BUFFER_BASE                   0x1F000000  // Set to be CMA area in device tree
//#define BUFFER_SPAN                   0x01000000  // Span of entire CMA area
#define BUFFER_SPAN                   0x000F0000  // Set span smaller than entire CMA area to save memory

#define RELOAD_BUFFER_BASE            0x1FF00000  // CMA area for coefficient re-loading
#define RELOAD_BUFFER_SPAN            0x000F0000  // Arround 516 words sent per filter

#define AXI_DMA_BASE                  0x40400000  // From Vivado Address Manager of DMA IP
#define DMA_STATUS_OFFSET             0x00000004
#define DMA_SOURCE_OFFSET             0x00000018
#define DMA_LENGTH_OFFSET             0x00000028
#define DMAS_CONTROL_OFFSET           0x00000030  // Control stream to memmory mapped DMA
#define DMAS_STATUS_OFFSET            0x00000034  // View status of S2MM
#define DMAS_DEST_OFFSET              0x00000048  // Write Destination address (DDR) for S2MM
#define DMAS_LENGTH_OFFSET            0x00000058  // Write number of bytes to write to destination address

#define AXI_RELOAD_BASE               0x40420000  // AXI DMA Reload to filter0 from address manager
#define AXI_RELOAD_BASE1              0x40410000  // AXI DMA Reload to filter1

// AXI GPIO Register
#define AXI_GPIO1                     0x41200000  // (symbol_length), (threshold at offset 0x8)
#define AXI_GPIO2                     0x41210000  // (BRAM_Address), (passthrough at offset 0x8)
#define AXI_GPIO3                     0x41220000  // (ADC_ctrl, DAC_ctrl, coeff, timeout, override), (ADC status at offset 0x8)

#define WAIT {}
#define IOC_IRQ_MASK                  0x00001000  // IRQ_Irc bit of DMA status register
#define DMA_BYTES                     160000       // Number of bytes for DMA to transfer

// AXI GPIO3 masks
#define ADC_CONTROL_MASK              0x0000000F
#define DAC_CONTROL_MASK              0x000000F0
#define DAC_CONTROL_OFFSET            4
#define COEFF_SELECT_MASK             0x00000F00
#define COEFF_SELECT_OFFSET           8
#define TIMEOUT_MASK                  0x0000F000
#define TIMEOUT_OFFSET                12
#define OVERRIDE_MASK                 0x000F0000  // Bit decision override threshold
#define OVERRIDE_OFFSET               16

// Number of filters in coefficient reload file
#define NUM_FILTERS                   91
#define NUM_COEFF                     516
static __int16_t                     reload_buffer[NUM_FILTERS*NUM_COEFF];

static void    *hps_mem_store;
static void    *reload_ddr_virtual_base;
static void    *AXI_BRAM_virtual_base;
static void    *AXI_DMA_virtual_base;
static void    *AXI_DMA_reload_virtual_base;
static void    *AXI_DMA_reload_1_virtual_base;
// AXI GPIO virtual addresses:
static void    *AXI_GPIO1_virtual_base;
static void    *AXI_GPIO2_virtual_base;
static void    *AXI_GPIO3_virtual_base;

static volatile __uint32_t *hps_mem_addr     = NULL;   // Virtual address of location to save buffer to
static volatile __uint32_t *reload_dma       = NULL;
static volatile __uint32_t *BRAM             = NULL;   // Virtual address of dual port BRAM in PL
// AXI DMA Data (For saving raw samples to SD)
static volatile __uint32_t *DMAS_Control_ptr = NULL;   // S2MM_DMACR => DMA Stream to MM Control Register
static volatile __uint32_t *DMAS_Status_ptr  = NULL;   // S2MM_DMASR => DMA Stream to MM Status Register
static volatile __uint32_t *DMAS_Dest_ptr    = NULL;   // S2MM_DA    => DMA Stream to MM Destination Address
static volatile __uint32_t *DMAS_Length_ptr  = NULL;   // S2MM_LENGTH=> DMA Stream to MM length of transfer addr
// AXI DMA Reload Channel
static volatile __uint32_t *DMA_ctr_reload   = NULL;
static volatile __uint32_t *DMA_stat_reload  = NULL;
static volatile __uint32_t *DMA_src_reload   = NULL;
static volatile __uint32_t *DMA_len_reload   = NULL;
// AXI DMA Reload 1 Channel
static volatile __uint32_t *DMA_ctr_reload_1 = NULL;
static volatile __uint32_t *DMA_stat_reload_1= NULL;
static volatile __uint32_t *DMA_src_reload_1 = NULL;
static volatile __uint32_t *DMA_len_reload_1 = NULL;

static volatile __uint32_t *ADC_Status       = NULL;   // Virtual address of ADC Status GPIO in PL
static volatile __uint32_t *multi1           = NULL;   // ADC control, DAC control, coefficient select, timeout and override reg
static volatile __uint32_t *Bit_Decision     = NULL;   // Virtual address of FPGA BRAM address
static volatile __uint32_t *symbol_length    = NULL;   // Virtual address of symbol length in clock cycles
static volatile __uint32_t *threshold        = NULL;   // Virtual address of threshold level to start decoding
static volatile __uint32_t *passthrough      = NULL;   // Virtual address of passthrough reg (asserted to 1 by FPGA when threshold met)

static FILE *tx_ff;        // File to compare received message to
static FILE *ff;           // Samples.txt file to save samples to measure SNR
static FILE *reload;       // reload txt file
static FILE *freq_file;    // File to read frequency hopping pattern from
static int fd;             // /dev/mem file
static int fm;             // /dev/ttyPS1 file
static int fs;             // /dev/spidev1 file
static int fg;             // /sys/class/gpio/* file

static int Initialize(void);                           // Initialize all virtual addresses used
static int Uninitialize(void);                         // Free all virtual addresses
static int Modem_Setup(void);                          // Initialize all modem settings
static int SPI_Setup(void);                            // Initialize all SPI settings
static int GPIO_Setup(void);                           // Initialize GPIO
static void Set_VGA_HI_LO(int);                        // Set VGA Hi/Lo
static double bit_error_rate(const char tx, const char rx);
static void Enable_ADC(void);
static void Disable_ADC(void);
static void *DMA_Samples(void *);                      // Pthread function
static void DMAS_Init(int);                            // Initialize DMA S2MM
static void DMA_Init(int);                             // Initialize DMA (config + reload) MM2S
static int DMAS_S2MM(int, int);                        // Receive buffer from DMA
static void *Set_VGA_Gain_thread(void *);              // Write to DAC to control VGA gain using SPI
static void DEBUG_PRINT(char *, ...);                  // Function to print debug messages
static int reload_dma_init(void);                      // Initialize buffer of all reload coefficients
static int reload_dma_transfer(int,int);               // Send fir coefficients to fir0

// FH-FSK
static int hop_pattern[NUM_FILTERS];

// PThread
static pthread_t p1, p2;

// Serial line
static const int BIT_MASK[8] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01};
static struct termios oldtio;

// Recording time
static struct timeval t1, t2, t3, t4;
static double ElapsedTime, ElapsedTime1, ElapsedTime2, ElapsedTime3;

// Debug
static int debug = 0;
static int noise = 0; // Save Raw samples on noise

int main(int argc, char **argv)
{
  double symbol_ber = 0, total_ber = 0, symbol, tmp, delay;
  int j = 0, i, k = 0, packet_length, gain, timeout_val, packet_sleep, added_gain;
  int z = 0, y = 0, num_hops, init = 0, m = 0;
  char ch = 0, tx_ch;
  __uint32_t BRAM_addr = 0, thresh;

  if (argc != 15) {                  // Check if number of arguments are correct and print usage if wrong
    printf("\nError wrong arguments ... type:\n");
  
    printf("\t./SNR_RX <gain(-4dB - 55dB)>  <symbol_length(0.5||1||2||5||10)>  <freq_file>  ...\n\t");
    printf("<set_timeout>  <set_threshold(hex)>  <sleep_between_bits(ms)>  <packet_length(bytes)>  ...\n\t");
    printf("<transmit_file>  <save_samples(y/n)>  <save_samples_on_trigger(y/n)>  ...\n\t");
    printf("<sleep_between_packets(ms)>  <debug_messages(0/1)>  <save_samples_on_noise(0/1)> ...\n\t");
    printf("<extra_gain_on_first_symbol>\n");
  
    printf("\nEX:\t./SNR_RX 32 1 freq_file1.txt 5 240000 15 1000 TX_file1.txt y n 30 1 0 10\n\n");
    printf("Note: sleep_between_bits must be a multiple of symbol_length\n\n");
    printf("Warning: if sleep_between_bits is less than 13ms or so, the time taken to ...\n\t");
    printf("print out debug messages will effect the receiver timing\n\n");
    return 1;
  }

  if (Initialize())                 // Initialize all mmaped virtual memmory addresses and peripherals
    return 1;

  for (i = 0; i < DMA_BYTES/4; i++) {     // Clear any remaining data in CMA area
    *(hps_mem_addr + i) = 0x00000000;
  }

  gain = atoi(argv[1]);
  symbol = strtod(argv[2], NULL);
  timeout_val = atoi(argv[4]);
  thresh = strtol(argv[5], NULL, 16);
  //delay = atoi(argv[6]);
  delay = strtod(argv[6], NULL);
  packet_length = atoi(argv[7]);
  packet_sleep = atoi(argv[11]);
  debug = atoi(argv[12]);
  noise = atoi(argv[13]);
  added_gain = atoi(argv[14]);

  tx_ff = fopen(argv[8], "r");
  if (tx_ff == NULL) {
    printf("Could not open file %s\n", argv[8]);
    return 1;
  }

  // Set RX gain higher than specified. Later, after the first bit has been detected, set the RX
  // gain to the value specified. This is because the receiver must have a clear start bit in
  // order to demodulate a packet. The function to set the gain is a thread because it is called
  // in the demodulation routine which needs strict timing.
  if (gain < 10) {
    printf("RX Gain values less than 10 not implemented yet. Error\n");
    return 1;
  }
  Set_VGA_HI_LO(1); // Function affects mmaped ports - still have to debug
  pthread_create(&p2, NULL, Set_VGA_Gain_thread, (void *) (gain + added_gain));

  printf("Symbol length set to %lfms\n", symbol);
  printf("Guard band set to %fms\n", delay);

  printf("\nPacket length set to %d bytes\n\n", packet_length);

  // FIR coefficient selection: FIR IP in FPGA can reload different coefficients
  freq_file = fopen(argv[3], "r");
  if (freq_file == NULL) {
    printf("Could not open file %s\n", argv[3]);
    return 1;
  }

  printf("\nFrequency hop pattern:\n");
  while (fscanf(freq_file,"%d",&hop_pattern[z]) == 1) {
    if (z % 2 == 0) {
      if (((y)%8==0) || y == 0) {
        printf("\nByte %d Hop Pattern:\n", m);
        m++;
      }
      printf("f0 bit%d = %-10d",y,hop_pattern[z]);
    }
    else {
      printf("f1 bit%d = %d\n",y,hop_pattern[z]);
      if (!((y+1)%8==0))
        y++;
      else
        y = 0;
    }
    z++;
    //if (z%16 == 0)
  }
  
  num_hops = z;
  printf("\nnum_hops = %d\n",num_hops);
  y = 0;

  if (!feof(freq_file))
    printf("Error reaching end of file\n");
  
  printf("\nADC_Status = 0x%X\n", *ADC_Status);
 
  // Set Symbol length: if every symbol is encoded in 1ms, the symbol length
  // should be set to 1ms * 100MHz (bus clock freq) = 100,000 = 0x186A0
  *symbol_length = 0x000186A0 * symbol;

  // Set timeout: the timeout variable in the custom threshold IP stops decoding
  // of the received signal timeout clock cycles after the received signal drops
  // below the threshold value (unless the PS issues a manual override)
  *multi1 = (*multi1 & ~TIMEOUT_MASK) | (timeout_val << TIMEOUT_OFFSET);

  // Set threshold: In simulation a good value to set the threshold is 68118688 = 0x040F68A0
  *threshold = thresh;
    //*threshold = 0x040F68A0;
    //*threshold = 0x050F68A0;
    //*threshold = 0x09000000;
  
  printf("Receiver threshold set to 0x%X\n", *threshold);
  printf("timeout = %d\n", (*multi1 & TIMEOUT_MASK) >> TIMEOUT_OFFSET);
  printf("RX Gain = %d\n", (int) gain);

  *multi1 = (*multi1 & ~OVERRIDE_MASK) | (0x00 << OVERRIDE_OFFSET); // Set threshold override to zero

  // Enable ADC
  Enable_ADC();
  printf("After Enable_ADC, ADC_Status = 0x%X\n", *ADC_Status);

  DMA_Init(1); // Enable reload DMA

  // Load initial coefficient values:
  // Re-load filter 0
  if (reload_dma_init()) {
    printf("reload_dma_init() failed\n");
    return 1;
  }
  gettimeofday(&t1, NULL);
  reload_dma_transfer(hop_pattern[0],hop_pattern[1]);
  gettimeofday(&t2, NULL);
  ElapsedTime1 = (t2.tv_sec - t1.tv_sec) * 1000000.0; // sec to us
  ElapsedTime2 += (t2.tv_usec - t1.tv_usec);
  
  printf("It took %.0f us to reload + config both filters\n", ElapsedTime3 + ElapsedTime2);

  BRAM_addr = *Bit_Decision;

  if (*argv[9] == 'y' || noise == 1) {
    DMAS_Init(1);
    // Start pthread to save samples to SD card
    pthread_create(&p1, NULL, DMA_Samples, NULL);
    pthread_join(p1, NULL);
  
    *multi1 = (*multi1 & ~OVERRIDE_MASK) | (0x00 << OVERRIDE_OFFSET); // Set threshold override to zero
    DMAS_Init(0);

    Uninitialize();

    return 0;
  }
  else
    DMAS_Init(1);

  printf("\nStarting Main loop ...\n\n");
  if (num_hops > 2)
    y = 2;
  else
    y = 0;

  // MAIN LOOP - Demodulate untill entire message has been received
  tx_ch = fgetc(tx_ff);
  while (1) {

    pthread_join(p2, NULL);
    
    if (feof(tx_ff)) {
      DEBUG_PRINT("End of file\n");
      break;
    }
    
    gettimeofday(&t1, NULL);
    // If begining of packet (marked by k = 0), wait for signal to pass threshold
    if (k == 0 && i == 0) {
      while (*passthrough == 0) {
        WAIT;
      }
      *multi1 = (*multi1 & ~OVERRIDE_MASK) | (0x01 << OVERRIDE_OFFSET);
      DEBUG_PRINT("Begining of new packet - setting override\n");
    }

    while(BRAM_addr == *Bit_Decision){ // New value saved by FPGA when BRAM Addr changes
      if (init == 0) {
        DEBUG_PRINT("\nWaiting for new bit\n");
        init = 1;
      }
    }
    init = 0;
    
    // Bit 0 has a value 1 and Bit 1 has a value 2
    if (*(BRAM + (*Bit_Decision)/4) == 1) {
      DEBUG_PRINT("Decoded bit: 0  ");
    }
    else if (*(BRAM + *Bit_Decision/4) == 2) {
      DEBUG_PRINT("Decoded bit: 1  ");
      ch = ch + BIT_MASK[i];
    }
    else if (*(BRAM + *Bit_Decision/4) == 0)
      printf("f0_Counter and f1_Counter equal: Decoded bit: 0\n");
    else
      printf("Error Decoding bit\n");

    // Determine how much time it took to decode the bit from the previous decoded bit
    gettimeofday(&t2, NULL);
    ElapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0; // sec to us
    ElapsedTime += (t2.tv_usec - t1.tv_usec);
    DEBUG_PRINT("Decoded bit took %.0f us  ", ElapsedTime);
    DEBUG_PRINT("f0=%d, f1=%d  ",hop_pattern[y],hop_pattern[y+1]);
   
    if (1) {
    //if (delay != 0) { // Sleep between bits the same length specified at the transmitter
      *multi1 = (*multi1 & ~OVERRIDE_MASK) | (0x00 << OVERRIDE_OFFSET);
      
      gettimeofday(&t1, NULL);
      // Re-load filter 0 and 1
      reload_dma_transfer(hop_pattern[y],hop_pattern[y+1]); // Set Filter Coefficients
      DEBUG_PRINT("y=%d  ",y);
      // Create index for hop pattern
      if (y >= num_hops - 2) // Reset Hopping
        y = 0;
      else
        y = y + 2;
      
      gettimeofday(&t2, NULL);
      ElapsedTime3 = (t2.tv_sec - t1.tv_sec) * 1000000.0; // sec to us
      ElapsedTime3 += (t2.tv_usec - t1.tv_usec);
      
      tmp = (((double) delay)*1000.0) - (ElapsedTime3);
      DEBUG_PRINT("Re-Config Time = %f  ", ElapsedTime3);
      DEBUG_PRINT("Sleeping for %f ms  ", tmp/1000.0);
      if (tmp > 0)
        usleep(tmp);
      
      //usleep((1000 * delay) - ElapsedTime3);
      *multi1 = (*multi1 & ~OVERRIDE_MASK) | (0x01 << OVERRIDE_OFFSET);
    }
    
    if (k == 3 && i == 0 && *argv[10] == 'y') // Start collecting samples on a trigger
      pthread_create(&p1, NULL, DMA_Samples, NULL);

    if (ElapsedTime > 1060.0 * (symbol + 1)) { // Allow some headroom by multiplying by 1060 instead of 1000
      if (k != 0) { // If in the middle of a burst packet transfer - keep going
        i = i + 1;
      }
      else {
        // Decoded bit took longer than specified - start of new packet
        DEBUG_PRINT("Started new packet  ");
        i = 1;
        if (*(BRAM + *Bit_Decision/4) == 2) {
          ch = BIT_MASK[i];
        }
        else
          ch = 0;
      }
    }
    else {
      // Continue packet
      i = i + 1;
    }

    DEBUG_PRINT("*Bit_Decision = 0x%X  ", *Bit_Decision);
    DEBUG_PRINT("i = %d  ", i);
    //BRAM_addr = *Bit_Decision;
  
    if (i == 8) // Decoded byte - print byte to UART terminal
    {
      if (k == 0) { // Set RX gain to correct value after first byte of packet received
        pthread_create(&p2, NULL, Set_VGA_Gain_thread, (void *) gain);
      }
      DEBUG_PRINT("\nDecoded character: %c  ", ch);
      DEBUG_PRINT("Correct character: %c  ", tx_ch);
      symbol_ber = bit_error_rate(tx_ch, ch);
      total_ber = total_ber + symbol_ber;
      //printf("symbol_ber = %lf\n", symbol_ber);
      DEBUG_PRINT("total_ber = %lf  ", total_ber / ((double) (j + 1)));
      write(fm, &ch, 1);// Write to serial line
      j++;
      ch = 0;
      i = 0;
      k++;
      DEBUG_PRINT("ADC_Status = 0x%X  ", *ADC_Status);
      tx_ch = fgetc(tx_ff);
    }
   
    DEBUG_PRINT("Bytes transmitted: %d  ", j);
    //DEBUG_PRINT("Bytes left: %d\t", strlen(buff) - j - 1);
    // Only the first received bit must surpass the threshold. After the threshold
    // has been surpassed, the threshold condition will be overridden untill
    // an entire packet has been received. This forces the receiver to always make a 
    // bit decision.
    if (k == packet_length) {
      printf("End of packet total BER = %lf\n", total_ber / ((double) (j + 1)));
      DEBUG_PRINT("\thop_pattern[%d] = %d, hop_pattern[%d] = %d\n",y,hop_pattern[y],y+1,hop_pattern[y+1]);
      k = 0;
      *multi1 = (*multi1 & ~OVERRIDE_MASK) | (0x00 << OVERRIDE_OFFSET);  // Set threshold override to zero
      DEBUG_PRINT("Removing overriding and sleeping, k = %d\n\n\n", k);
      usleep(1000 * (packet_sleep - delay - 1));  // Sleep for specified time in between packets
      pthread_join(p2, NULL); // Previous pthread should have finished
      // Set to high gain again to accurately detect starting bit of packet
      pthread_create(&p2, NULL, Set_VGA_Gain_thread, (void *) (gain + added_gain));
    }
    else {
      *multi1 = (*multi1 & ~OVERRIDE_MASK) | (0x1 << OVERRIDE_OFFSET); // Set threshold override to one
      DEBUG_PRINT("Override, k = %d\n", k);
    }

    BRAM_addr = *Bit_Decision;

  }

  pthread_join(p2, NULL);
  *multi1 = (*multi1 & ~OVERRIDE_MASK) | (0x00 << OVERRIDE_OFFSET); // Set threshold override to zero
  printf("\nTotal Bytes transmitted: %d\n", j);
  printf("\nTotal Bit Error Rate = %lf\n\n", total_ber / ((double) (j + 1)));
  if (*argv[9] == 'y')
    pthread_join(p1, NULL);
  printf("End, ADC_Status = 0x%X, DMA Status = 0x%X\n", *ADC_Status, *DMAS_Status_ptr);
  //Disable_ADC();
  DMAS_Init(0);

  if (Uninitialize())
    return 1;

  return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
void *DMA_Samples(void *arg)
{
  DMAS_Init(1);
  int bytes1 = 0, bytes2 = 0;
  printf("<pthread>Inside function, *passthrough = %d\n", *passthrough);
  printf("<pthread>*multi1 = 0x%X\n", *multi1);
  while (*passthrough == 0) {
    WAIT;
  }
  printf("<pthread>Starting to save samples ...\n");
  //for (int i = 0; ; i++) {
    //printf("<pthread>Before DMAS_S2MM(bytes)\n");
    //bytes1 = DMAS_S2MM(1200000,0);
    bytes1 = DMAS_S2MM(DMA_BYTES,0);
    //bytes2 = DMAS_S2MM(1000,1);
    printf("<pthread>bytes1 = %d, bytes2 = %d\n", bytes1, bytes2);
    // Save samples to SD card
    for (int j = 0; j < (bytes1 / 4); j++)
    {
      fprintf(ff, "%d\n", *(hps_mem_addr + j));
      //fprintf(ff, "%p: 0x%X = %d\n", (hps_mem_addr + j), *(hps_mem_addr + j), *(hps_mem_addr + j));
      if (j < 25) {
        printf("%p: 0x%X = %d\n", (hps_mem_addr + j), *(hps_mem_addr + j), *(hps_mem_addr + j));
      }
    }
    printf("\n\n");
    /*for (int j = 0; j < (bytes2 / 4); j++)
    {
      fprintf(ff, "%d\n", *(hps_mem_addr2 + j));
      //fprintf(ff, "%p: 0x%X = %d\n", (hps_mem_addr + j), *(hps_mem_addr + j), *(hps_mem_addr + j));
      if (j < 25) {
        printf("%p: 0x%X = %d\n", (hps_mem_addr2 + j), *(hps_mem_addr2 + j), *(hps_mem_addr2 + j));
      }
    }*/
  //}
  printf("<pthread>Done\n");
  return NULL;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
void DMAS_Init(int start)
{
  *DMAS_Control_ptr = 0x00000004;         // Reset DMA S2MM
  //*DMAS_Control_ptr = start;              // Assert start bit high for DMA transfer
  *DMAS_Control_ptr = 0x00001000 + start;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
void DMA_Init(int start) // Start reload + config DMA MM2S
{
  *DMA_ctr_reload = 0x00000004; // Reset DMA S2MM
  *DMA_ctr_reload = start;
  *DMA_ctr_reload_1 = 0x00000004;
  *DMA_ctr_reload_1 = start;
  printf("\nReload 0 DMA Status: 0x%X\n", *DMA_stat_reload);
  printf("Reload 1 DMA Status: 0x%X\n\n", *DMA_stat_reload_1);
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
int DMAS_S2MM(int bytes, int buffer_sel)
{
  int i = 0;
  __uint32_t Dest;
  if (buffer_sel == 0) {
    Dest = BUFFER_BASE;
  }
  else if (buffer_sel == 1) {
    //Dest = BUFFER_BASE + BUFFER2_OFFSET;
    Dest = BUFFER_BASE;
  }
  else return 0;

  // printf statements will cause DMA to miss samples
  while (i < bytes)
  {
    gettimeofday(&t3, NULL);
    *DMAS_Dest_ptr = Dest + i;      // Update DMA S2MM address

    // As soon as length register is written to the DMA transfer starts
    *DMAS_Length_ptr=bytes; // Length in bytes must be greater than packet size on DMA Stream
    
    //while (((*DMAS_Status_ptr & IOC_IRQ_MASK) == 0) && ((*DMAS_Status_ptr & DMA_INT_ERR) == 0)) // Wait for interrupt bit to go high
    while ((*DMAS_Status_ptr & IOC_IRQ_MASK) == 0) 
    {
      // Check if DMA transfer gets stuck
      gettimeofday(&t4, NULL);
      ElapsedTime2 = (t4.tv_sec - t3.tv_sec) * 1000000.0; // sec to us
      ElapsedTime2 = (t4.tv_usec - t3.tv_usec);
      if (ElapsedTime2 > ((double) bytes)) {
        printf("\n<pthread_func>ERROR: DMA S2MM Timeout, DMA Status = 0x%X\n\n", *DMAS_Status_ptr);
        return i;
      }
    }
    // There is a DMA interrupt upon AXI TLAST regardless of whether or not DMAS_Length register
    // has reached zero. As a result, we have to keep restarting the DMA transfer untill 
    // we receive the correct number of bytes we want
    i = i + *DMAS_Length_ptr;
    //printf("DMA Status = 0x%X, *DMAS_Length_ptr = 0x%X = %d, i = %d\n", *DMAS_Status_ptr, *DMAS_Length_ptr, *DMAS_Length_ptr, i);
    *DMAS_Status_ptr = IOC_IRQ_MASK;             // Clear interrupt bit by writing 1 to it
  }
  return i;   // Return actual number of bytes transfered - will be more than input bytes due to packet size
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
int reload_dma_init(void) {
  reload = fopen("single_file_reorder.txt", "r");
  if (reload == NULL) {
    printf("Could not open file\n");
    return 1;
  }

  for (int i = 0; i < (NUM_FILTERS*NUM_COEFF); i++) {
    if (!fscanf(reload,"%hd",&reload_buffer[i])) {
      printf("End of file error, i = %d\n", i);
      return 1;
    }
  }
  //for (int i = 0; i < 516; i++) {
  //  printf("%d\n", reload_buffer[i]);
  //}
  //printf("sizeof(reload_buffer) = %d\n",sizeof(reload_buffer));
  memcpy((void *) reload_dma, (const void *) &reload_buffer, sizeof(reload_buffer));
  fclose(reload);
  return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
int reload_dma_transfer(int freq0, int freq1) {
  int i0 = (freq0 - 80000)/1000;
  int i1 = (freq1 - 80000)/1000;
  *DMA_src_reload = RELOAD_BUFFER_BASE + (NUM_COEFF/2)*4*i0; // set physical address of data
  *DMA_src_reload_1 = RELOAD_BUFFER_BASE + (NUM_COEFF/2)*4*i1;
  *DMA_len_reload = 1032;
  *DMA_len_reload_1 = 1032;
  while (((*DMA_stat_reload & IOC_IRQ_MASK) == 0) && ((*DMA_stat_reload_1 & IOC_IRQ_MASK) == 0)) {
    WAIT; // Pending DMA Transaction
  }
  *DMA_stat_reload = IOC_IRQ_MASK;
  *DMA_stat_reload_1 = IOC_IRQ_MASK;
  return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
void DEBUG_PRINT(char *x, ...) {
  if (debug != 1)
    return;
  va_list args;
  va_start(args, x);
  vprintf(x, args);
  va_end(args);
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
// Calculates bit error rate between two bytes
double bit_error_rate(const char tx, const char rx)
{
  int err = 0;
  for (int i = 0; i < 8; i++) {
    if ((tx & BIT_MASK[i]) != (rx & BIT_MASK[i])) {
      err ++;
    }
  }
  return ((double) err) / 8;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
// HI/LO setting on VGA
void Set_VGA_HI_LO(int value)
{
  if (value == 0)
    write(fg, "0", 2); // Drive GPIO low
  else if (value == 1) {
/*
    printf("\n\nBefore write\n");
    printf("ADC_Status = 0x%X\n", *ADC_Status);
    printf("Receiver threshold set to 0x%X\n", *threshold);
    printf("timeout = %d\n", (*multi1 & TIMEOUT_MASK) >> TIMEOUT_OFFSET);
    printf("coeff = %d\n", (*multi1 & COEFF_SELECT_MASK) >> COEFF_SELECT_OFFSET);
    printf("ADC_Control = 0x%X\n", (*multi1 & ADC_CONTROL_MASK));
*/
    write(fg, "1", 2); // Drive GPIO high NOTE: Function affects mmaped GPIO on AXI - still have to debug
/*
    printf("\n\nAfter write\n");
    printf("ADC_Status = 0x%X\n", *ADC_Status);
    printf("Receiver threshold set to 0x%X\n", *threshold);
    printf("timeout = %d\n", (*multi1 & TIMEOUT_MASK) >> TIMEOUT_OFFSET);
    printf("coeff = %d\n", (*multi1 & COEFF_SELECT_MASK) >> COEFF_SELECT_OFFSET);
    printf("ADC_Control = 0x%X\n", (*multi1 & ADC_CONTROL_MASK));
*/
  }
  else
    printf("Invalid GPIO value\n");
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//////// Set VGA Gain //////////
// VGA Gain controlled by single analog voltage with range 40mV to 1V.
// Chip select (SS1 on MIO26 pin A15)
// Analog voltage created using 12-bit serial DAC using SPI.
// VGA Hi/Lo Gain range select on PS MIO20 A17
// https://www.kernel.org/doc/html/latest/admin-guide/gpio/sysfs.html
void *Set_VGA_Gain_thread(void *gain)
{
  int ret;
  __uint16_t data;

  if ((int) gain > 55.5)
    gain = (void *) 55;

  if ((int) gain < 10.0)
    gain = (void *) 10;
  //if ((int) gian < -4.5)
    //gain = -4.0;

  DEBUG_PRINT("Setting gain to %d\n", (int) gain);
  
  if ((int) gain < 10) // Use LO setting on VGA
  {
    //Set_VGA_HI_LO(0);
    data = (__uint16_t)((((int) gain + 6.5)/50.0)/0.001);
  }
  else           // Use HI setting on VGA
  {
    //Set_VGA_HI_LO(1);
    data = (__uint16_t)((((int) gain - 5.5)/50.0)/0.001);
  }

  //returnVal = data;
  // Write to VGA DAC via SPI
  data = ((data << 8) & 0xFF00)|((data >> 8) & 0x00FF); //swap bytes for correct order to DAC

  struct spi_ioc_transfer tr = {
    .tx_buf = (unsigned long) &data,
    .len = 2,
    .speed_hz = 1250000,
    .bits_per_word = 8,
  };

  ret = ioctl(fs, SPI_IOC_MESSAGE(1), &tr);
  if (ret < 1)
    perror("Can't send SPI data\n");

  //return returnVal;
  return NULL;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
void Enable_ADC(void)
{
  // Bit 0 = Stream Enable, Bit 1 = Clear Over Run, Bit 2 = Clear OTR, Bit 3 = Test mode
  *multi1 = (*multi1 & ~ADC_CONTROL_MASK) | 0x7; // Normal operation + clear OTR
  *multi1 = (*multi1 & ~ADC_CONTROL_MASK) | 0x3; // Normal operation
  //*multi1 = (*multi1 & ~ADC_CONTROL_MASK) | 0x9; // IP generates test waveform
}
void Disable_ADC(void)
{
  *multi1 = (*multi1 & ~ADC_CONTROL_MASK) | 0x0;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
// Set up UART parameters
int Modem_Setup(void)
{
  struct termios newtio;

  // Open modem device for reading and writing, not controlling tty to not
  // get killed if line sends CTRL-C.
  fm = open(MODEMDEVICE, O_RDWR | O_NOCTTY);
  if (fm < 0) {
    perror(MODEMDEVICE);
    return 1;
  }

  tcgetattr(fd, &oldtio);         // Save current serial port settings
  bzero(&newtio, sizeof(newtio)); // Clear struct for new port settings

  // BAUDRATE : Set bps rate, Can also use cfsetispeed and cfsetospeed.
  // CRTSCTS  : Output hardware flow control
  // CS8      : 8n1 (8 bit, no parity, 1 stopbit)
  // CLOCAL   : local connection, no modem control
  // CREAD    : enable receiving characters
  newtio.c_cflag = BAUDRATE | CRTSCTS | CS8 | CLOCAL | CREAD;

  // IGNPAR   : Ignore bytes with parity errors
  // ICRNL    : map CR to NL
  newtio.c_iflag = IGNPAR | ICRNL;

  newtio.c_oflag = 0;         // Raw output

  // ICANON   : Enable canonical input, disable all echo functionality
  //            and don't sent signals to calling program
  newtio.c_lflag = ICANON;

  // Initialize all control characters. Default values in /usr/include/termios.h
  newtio.c_cc[VINTR]    = 0;     /* Ctrl-c */
  newtio.c_cc[VQUIT]    = 0;     /* Ctrl-\ */
  newtio.c_cc[VERASE]   = 0;     /* del */
  newtio.c_cc[VKILL]    = 0;     /* @ */
  newtio.c_cc[VEOF]     = 4;     /* Ctrl-d */
  newtio.c_cc[VTIME]    = 0;     /* inter-character timer unused */
  newtio.c_cc[VMIN]     = 1;     /* blocking read until 1 character arrives */
  newtio.c_cc[VSWTC]    = 0;     /* '\0' */
  newtio.c_cc[VSTART]   = 0;     /* Ctrl-q */
  newtio.c_cc[VSTOP]    = 0;     /* Ctrl-s */
  newtio.c_cc[VSUSP]    = 0;     /* Ctrl-z */
  newtio.c_cc[VEOL]     = 0;     /* '\0' */
  newtio.c_cc[VREPRINT] = 0;     /* Ctrl-r */
  newtio.c_cc[VDISCARD] = 0;     /* Ctrl-u */
  newtio.c_cc[VWERASE]  = 0;     /* Ctrl-w */
  newtio.c_cc[VLNEXT]   = 0;     /* Ctrl-v */
  newtio.c_cc[VEOL2]    = 0;     /* '\0' */

  // Now clean the modem line and activate the settings for the port
  tcflush(fm, TCIFLUSH);
  tcsetattr(fm, TCSANOW, &newtio);

  return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
int SPI_Setup(void)
{
  __uint8_t bits = 8;
  __uint32_t mode;
  __uint32_t speed = 1250000;

  if ((fs = open("/dev/spidev0.1", O_RDWR)) == -1)
  {
    printf("ERROR: Could not open \"dev/spidev0.1\"...\n");
    return 1;
  }
  //possible modes: mode |= SPI_LOOP; mode |= SPI_CPHA; mode |= SPI_CPOL; mode |= SPI_LSB_FIRST; mode |= SPI_CS_HIGH; mode |= SPI_3WIRE; mode |= SPI_NO_CS; mode |= SPI_READY;
  //multiple possibilities using |
  mode = SPI_CPHA;
  if (ioctl(fs, SPI_IOC_WR_MODE32, &mode) == -1)   {
    perror("can't set spi mode");
    return 1;
  }

  /*if (ioctl(fs, SPI_IOC_RD_MODE, &mode) == -1)
  {
    perror("SPI rd_mode");
    return 1;
  }
  if (ioctl(fs, SPI_IOC_RD_LSB_FIRST, &lsb) == -1)
  {
    perror("SPI rd_lsb_fist");
    return 1;
  }*/
  // bits per word
  //if (ioctl(fs, SPI_IOC_WR_BITS_PER_WORD, (__u8[1]){8}) == -1)
  if (ioctl(fs, SPI_IOC_WR_BITS_PER_WORD, &bits) < 0)
  {
    perror("can't set bits per word");
    return 1;
  }
  /*if (ioctl(fs, SPI_IOC_RD_BITS_PER_WORD, &bits) == -1)
  {
    perror("SPI bits_per_word");
    return 1;
  }*/
  if (ioctl(fs, SPI_IOC_WR_MAX_SPEED_HZ, &speed) == -1)
  {
    perror("can't set max speed hz");
    return 1;
  }
  /*if (ioctl(fs, SPI_IOC_RD_MAX_SPEED_HZ, &speed) == -1)
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

  return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
// In device tree, there are gpio device entries: Zynq_GPIO (for MIO), ADC_Control,
// DAC_Control, and ADC_Status, etc. You can use /dev/gpiochip0 to control MIO20.
// We could have used /dev/gpiochip* to control the GPIO PL
// peripherals ADC_Control, etc but we used a different method of mmaping directly to the
// addresses. The way we will control the GPIO MIO20 is via SysFs interface as it is
// easy and requires very little setup.
int GPIO_Setup(void)
{
  // Export MIO20 pin
  fg = open("/sys/class/gpio/export", O_WRONLY);
  if (fg == -1)
  {
    printf("ERROR: Could not open\"/sys/class/gpio/export\"...\n");
    return 1;
  }
  // MIO20 = GPIO20 + 866 = 886; because /sys/class/gpio/gpiochip866 - may be different on your board
  write(fg, "886", 4);
  close(fg);
  // Set MIO20 pin to be an output
  fg = open("/sys/class/gpio/gpio886/direction", O_WRONLY);
  if (fg == -1)
  {
    printf("ERROR: Could not open\"/sys/class/gpio/gpio886/direction\"...\n");
    return 1;
  }
  write(fg, "out", 4);
  close(fg);
  // Set fg to value on MIO20
  fg = open("/sys/class/gpio/gpio886/value", O_WRONLY);
  if (fg == -1)
  {
    printf("ERROR: Could not open\"/sys/class/gpio/gpio886/value\"...\n");
    return 1;
  }
  return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
// Initialize all memmory mapped peripherals
int Initialize(void)
{
  printf("\nCustom Receiver SNR Command, version 2.1\n\n");

  ff = fopen("Samples.txt", "w");     // Open text file to write samples to

  // Open /dev/mem
  if ((fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1)
  {
    printf("ERROR: Could not open \"/dev/mem\"...\n");
    return 1;
  }

  // DDR virtual addresses
  hps_mem_store = mmap(NULL, BUFFER_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, BUFFER_BASE);
  if (hps_mem_store == MAP_FAILED)
  {
    printf("ERROR: mmap3() failed ...\n");
    return 1;
  }
  hps_mem_addr = (__uint32_t *)(hps_mem_store);

  // Reload virtual addresses
  reload_ddr_virtual_base = mmap(NULL, RELOAD_BUFFER_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, RELOAD_BUFFER_BASE);
  if (reload_ddr_virtual_base == MAP_FAILED)
  {
    printf("ERROR: reload_ddr failed ...\n");
    return 1;
  }
  reload_dma = (__uint32_t *)(reload_ddr_virtual_base);

  // DMA Data Virtual Addresses
  AXI_DMA_virtual_base = mmap(NULL, DMA_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, AXI_DMA_BASE);
  if (AXI_DMA_virtual_base == MAP_FAILED)
  {
    printf("ERROR mmap10() failed ...\n");
    return 1;
  }
  DMAS_Control_ptr    = (__uint32_t *)(AXI_DMA_virtual_base + DMAS_CONTROL_OFFSET);
  DMAS_Status_ptr     = (__uint32_t *)(AXI_DMA_virtual_base + DMAS_STATUS_OFFSET);
  DMAS_Dest_ptr       = (__uint32_t *)(AXI_DMA_virtual_base + DMAS_DEST_OFFSET);
  DMAS_Length_ptr     = (__uint32_t *)(AXI_DMA_virtual_base + DMAS_LENGTH_OFFSET);

  // DMA Reload Virtual Addresses
  AXI_DMA_reload_virtual_base = mmap(NULL, DMA_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, AXI_RELOAD_BASE);
  if (AXI_DMA_reload_virtual_base == MAP_FAILED)
  {
    printf("ERROR mmap DMA_Reload failed ...\n");
    return 1;
  }
  DMA_ctr_reload      = (__uint32_t *)(AXI_DMA_reload_virtual_base);
  DMA_stat_reload     = (__uint32_t *)(AXI_DMA_reload_virtual_base + DMA_STATUS_OFFSET);
  DMA_src_reload      = (__uint32_t *)(AXI_DMA_reload_virtual_base + DMA_SOURCE_OFFSET);
  DMA_len_reload      = (__uint32_t *)(AXI_DMA_reload_virtual_base + DMA_LENGTH_OFFSET);

  // DMA Reload Virtual Addresses
  AXI_DMA_reload_1_virtual_base = mmap(NULL, DMA_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, AXI_RELOAD_BASE1);
  if (AXI_DMA_reload_1_virtual_base == MAP_FAILED)
  {
    printf("ERROR mmap DMA_Reload failed ...\n");
    return 1;
  }
  DMA_ctr_reload_1      = (__uint32_t *)(AXI_DMA_reload_1_virtual_base);
  DMA_stat_reload_1     = (__uint32_t *)(AXI_DMA_reload_1_virtual_base + DMA_STATUS_OFFSET);
  DMA_src_reload_1      = (__uint32_t *)(AXI_DMA_reload_1_virtual_base + DMA_SOURCE_OFFSET);
  DMA_len_reload_1      = (__uint32_t *)(AXI_DMA_reload_1_virtual_base + DMA_LENGTH_OFFSET);

  // AXI GPIO1
  AXI_GPIO1_virtual_base = mmap(NULL, AXI_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, AXI_GPIO1);
  if (AXI_GPIO1_virtual_base == MAP_FAILED)
  {
    printf("EROR mmap() failed ...\n");
    return 1;
  }
  symbol_length = (__uint32_t *)(AXI_GPIO1_virtual_base);
  threshold = (__uint32_t *)(AXI_GPIO1_virtual_base + 8);

  // AXI GPIO2
  AXI_GPIO2_virtual_base = mmap(NULL, AXI_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, AXI_GPIO2);
  if (AXI_GPIO2_virtual_base == MAP_FAILED)
  {
    printf("ERROR mmap() failed ...\n");
    return 1;
  }
  Bit_Decision = (__uint32_t *)(AXI_GPIO2_virtual_base);
  passthrough = (__uint32_t *)(AXI_GPIO2_virtual_base + 8);

  // AXI GPIO3
  AXI_GPIO3_virtual_base = mmap(NULL, AXI_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, AXI_GPIO3);
  if (AXI_GPIO3_virtual_base == MAP_FAILED)
  {
    printf("ERROR mmap() failed ...\n");
    return 1;
  }
  multi1 = (__uint32_t *)(AXI_GPIO3_virtual_base);
  ADC_Status = (__uint32_t *)(AXI_GPIO3_virtual_base + 8);

  // BRAM
  AXI_BRAM_virtual_base = mmap(NULL, BRAM_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, AXI_BRAM_BASE);
  if (AXI_BRAM_virtual_base == MAP_FAILED)
  {
    printf("ERROR: mmap9() failed ...\n");
    return 1;
  }
  BRAM = (__uint32_t *)(AXI_BRAM_virtual_base);

  if (Modem_Setup())
    return 1;

  if (SPI_Setup())
    return 1;

  if (GPIO_Setup())
    return 1;

  return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
int Uninitialize(void)
{
  if (munmap(hps_mem_store, BUFFER_SPAN)) {
    perror("Could not munmap hps_mem_store\n");
    return 1;
  } 

  if (munmap(reload_ddr_virtual_base, RELOAD_BUFFER_SPAN)) {
    perror("Could not munmap reload_ddr_virtual_base\n");
    return 1;
  }

  if (munmap(AXI_BRAM_virtual_base, BRAM_SPAN)) {
    perror("Could not munmap AXI_BRAM_virtual_base\n");
    return 1;
  }

  if (munmap(AXI_DMA_virtual_base, DMA_SPAN)) {
    perror("Coult not munmap AXI_DMA_virtual_base\n");
    return 1;
  }

  if (munmap(AXI_DMA_reload_virtual_base, DMA_SPAN)) {
    perror("Could not munmap AXI_DMA_reload_virtual_base\n");
    return 1;
  }

  if (munmap(AXI_DMA_reload_1_virtual_base, DMA_SPAN)) {
    perror("Could not munmap AXI_DMA_reload_virtual_base\n");
    return 1;
  }

  if (munmap(AXI_GPIO1_virtual_base, AXI_SPAN)) {
    perror("Could not munmap AXI_GPIO1_virtual_base\n");
    return 1;
  }

  if (munmap(AXI_GPIO2_virtual_base, AXI_SPAN)) {
    perror("Could not munmap AXI_GPIO2_virtual_base\n");
    return 1;
  }

  if (munmap(AXI_GPIO3_virtual_base, AXI_SPAN)) {
    perror("Could not munmap AXI_GPIO3_virtual_base\n");
    return 1;
  }
  
  close(fd);
  close(fm);
  close(fs);
  close(fg);

  printf("De-allocating complete\n");
  
  return 0;
}
