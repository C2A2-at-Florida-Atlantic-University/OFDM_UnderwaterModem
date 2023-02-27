////////////////////////////////////////////////////////////////
// Jared Hermans
//
// User space DMA control is performed by directly manipulating
// Control and status registers in the Xilinx AXI DMA engine
// instead of using Xilinx's provided driver. Completion interrupt
// is monitored in a parallel pthread.
//
// Message signal is received over UART and converted to binary
// to modulate EX: 00110101. FSK modulation
// is performed on each bit. Frequency F0 modulates bit 0 and
// frequency F1 modulates bit 1. Waveform samples for F0 and F1
// are calculated previously and are saved to a contiguously
// allocated buffer in DDR before modulation actually begins.
////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/mman.h>
#include <math.h>
#include <malloc.h>
#include <pthread.h>
#include <sys/time.h>
#include <termios.h>
#include <sys/stat.h>

#define DEBUG

#ifdef DEBUG
  #define DEBUG_PRINT(x) printf x
#else
  #define DEBUG_PRINT(x) do {} while (0)
#endif

#define BAUDRATE                      B115200
#define MODEMDEVICE                   "/dev/ttyPS1" // Message signal over UART

#define BUFFER_BASE                   0x1F000000  // Set to be CMA area in device tree
#define BUFFER2_OFFSET                0x00030D40
#define BUFFER3_OFFSET                0x00061A80
#define BUFFER_SPAN                   0x01000000  // Span of CMA area

#define AXI_DMA_BASE                  0x40400000  // From Vivado Address Manager of DMA IP
#define AXI_SPAN                      0x00010000  // Span of all IP addresses
#define DMA_STATUS_OFFSET             0x00000004  // From AXI DMA IP Product Guide
#define DMA_SOURCE_OFFSET             0x00000018
#define DMA_LENGTH_OFFSET             0x00000028

// AXI GPIO Register
#define AXI_GPIO3                     0x41220000

// DAC at 10 Msps. 100,000 samples = 10ms signal
// Interpolation in FPGA x10, so software can generate samples at 1 Msps.
// 1,000 samples = 1ms signal at 1,000,000sps
#define NUM_DAC_SAMPLES               10000   		// Fixed symbol length
#define NUM_FILTERS                   91
static __uint16_t symbol_length;        					// Variable symbol length
static double sampleRate              = 1e6;
static double f1                      = 130000.0;
static double f2                      = 135000.0;
static int hop_pattern[NUM_FILTERS];

#define WAIT {}
#define IOC_IRQ_MASK                  0x00001000  // IRQ_Irc bit of DMA status register

// AXI GPIO1 masks
#define DAC_CONTROL_MASK              0x000000F0
#define DAC_CONTROL_OFFSET            4

static void    *hps_mem_store;
static void    *AXI_DMA_virtual_base;
// AXI GPIO virtual addresses:
static void    *AXI_GPIO3_virtual_base;

static volatile __uint32_t *DMA_Control_ptr  = NULL;   // MM2S_DMACR => DMA Control Register
static volatile __uint32_t *DMA_Status_ptr   = NULL;   // MM2S_DMASR => DMA Status Register
static volatile __uint32_t *DMA_Source_ptr   = NULL;   // MM2S_SA    => DMA Source Address
static volatile __uint32_t *DMA_Length_ptr   = NULL;   // MM2S_LENGTH=> DMA Length of transfer Address

static volatile __uint32_t *hps_mem_addr     = NULL;   // Virtual address of location to save buffer to
static volatile __uint32_t *hps_mem_addr2    = NULL;   // Virtual address of location to save second buffer to
static volatile __uint32_t *hps_mem_addr3    = NULL;   // Virtual address of location to save third buffer to
static volatile __uint32_t *multi1           = NULL;   // ADC control, DAC control, coefficient select and timeout register

static int Initialize(void);                       // Initialize all virtual addresses used
static int Modem_Setup(void);                      // Initialize all modem settings
static void DMA_Init(int);                         // Initialize DMA MM2S
static void DMA_MM2S(void);                        // Start DMA transfer
static void Gen_Sin(__uint16_t*, __uint32_t, int, double);
//static void Gen_Chirp(__uint16_t*, __uint32_t, int, double);
static void Enable_DAC(void);
static void Disable_DAC(void);

static FILE *tx_ff;        // File to read transmission data from
static FILE *freq_file;    // File containing frequency hop information
static int Buffer_Sel;     // Selection between f0 and f1
static int fd;             // /dev/mem file
static int fm;             // /dev/ttyPS1 file
static __uint16_t Samples[2*NUM_DAC_SAMPLES];

// Recording time
static struct timeval t1, t2, t3, t4;
static double ElapsedTime;

// Serial line
static const int BIT_MASK[8] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01};
#define FALSE 0
#define TRUE 1
static volatile int STOP = FALSE;
static struct termios oldtio;

int main(int argc, char **argv)
{
  int packet_sleep, packet_length, k = 0, z = 0, y = 0, toggle = 0, num_hops, m = 0;
  double delay;
  char ch;
  char buf[255];
  int res;
 
  double gain, symbol;
  if (argc != 8) {
 	  printf("\nError wrong arguments ... type:\n");
 	  printf("\t./SNR_TX <gain(0.0 - 0.1)>  <symbol_length(0.25||0.3125||0.4||0.5||1||2||5||10)>  <freq_file> ...\n");
    printf("\t<sleep_between_bits(ms)>  <packet_length(bytes)>  <sleep_between_packets(ms)>  <transmit_file>\n");
   	printf("\nEX:\t./SNR_TX 0.5 0.5 freq_file1.txt 5 8 15 TX_file1.txt\n\n");
    printf("Note: sleep_between_packets is silence between every packet. sleep_between_bits and sleep_between_packets must be a multiple of symbol_length\n\n");
    printf("freq_pair 3 is up-chirp and down-chirp\n\n");
    return 1;
   }

  if (Initialize())  // Initialize all peripherals
    return 1;

  packet_sleep = atoi(argv[6]);
  packet_length = atoi(argv[5]);
  //delay = atoi(argv[4]);
  delay = strtod(argv[4], NULL);
  gain = strtod(argv[1], NULL);
  symbol = strtod(argv[2], NULL);

  tx_ff = fopen(argv[7], "r");
  if (tx_ff == NULL) {
    printf("Could not open file %s\n", argv[7]);
    return 1;
  }

  if (packet_sleep < delay) {
    printf("Error: <sleep_between_packets> variable must be integer multiple of symbol_length and larger than <sleep_between_bits>\n");
    return 1;
  }

  freq_file = fopen(argv[3], "r");
  if (freq_file == NULL) {
    printf("Could not open file %s\n", argv[3]);
    return 1;
  }

  printf("Frequency hop pattern:\n");
  while (fscanf(freq_file,"%d",&hop_pattern[z]) == 1) {
    if (z % 2 == 0) {
      if (((y)%8==0) || y == 0) {
        printf("\nByte %d Hop Pattern:\n", m);
        m++;
      }
      printf("f0 bit%d = %d\t",y,hop_pattern[z]);
    }
    else {
      printf("f1 bit%d = %d\n",y,hop_pattern[z]);
      if (!((y+1)%8==0))
        y++;
      else
        y = 0;
    }
    z++;
  }
  num_hops = z;
  y = 0;
  
  if (!feof(freq_file))
    printf("Error reaching end of file\n");

  printf("\nGain set to %lf\nSymbol length set to %lfms\n", gain, symbol);
  printf("Guard band set to %f\n\n",delay); 

  if (symbol == 0.25)
    symbol_length = 40;
  else if (symbol == 0.3125)
    symbol_length = 32;
  else if (symbol == 0.4)
    symbol_length = 25;
  else if (symbol == 0.5)
    symbol_length = 20;
  else if (symbol == 1.0)
    symbol_length = 10;
  else if (symbol == 2.0)
    symbol_length = 5;
  else if (symbol == 5.0)
    symbol_length = 2;
  else if (symbol == 10.0)
    symbol_length = 1;
  else {
    printf("Error ... unsupported symbol_length, symbol = %lf ...\n", symbol);
    return 1;
  }
  
  printf("NUM_DAC_SAMPLES / symbol_length = %u\n", NUM_DAC_SAMPLES / symbol_length);
  printf("sizeof(Samples) = %d, sizeof(Samples) / symbol_length = %d\n", sizeof(Samples), sizeof(Samples) / symbol_length);
  
  // Enable Power amp and DAC
  Enable_DAC();
  DMA_Init(1);

  // Assign first bit hop frequencies
  f1 = hop_pattern[0];
  f2 = hop_pattern[1];

  // Generate Samples and record time taken
  gettimeofday(&t1, NULL);
  Gen_Sin(Samples, (sizeof(Samples) / symbol_length / 2), 0, gain);
  gettimeofday(&t2, NULL);
  ElapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0; // sec to us
  ElapsedTime += (t2.tv_usec - t1.tv_usec);
  printf("\nGen_Sin took %.0f uSec for %lfms signal\n", ElapsedTime, symbol);

  // Save Samples to allocated buffer area and record time taken
  gettimeofday(&t1, NULL);
  memcpy((void *) hps_mem_addr, (const void *) &Samples, (sizeof(Samples) / symbol_length / 2));
  gettimeofday(&t2, NULL);
  ElapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0; // sec to us
  ElapsedTime += (t2.tv_usec - t1.tv_usec);
  printf("memcoy took %0.f uSec for %lfms signal\n", ElapsedTime, symbol);
  
  // Kick off DMA loop with samples all at zero
  //Gen_Sin(Samples, (sizeof(Samples) / symbol_length), 0, 0);
  for (int k = 0; k < NUM_DAC_SAMPLES; k++) {
    Samples[k] = (__uint16_t) 8191;
  }
  memcpy((void *) hps_mem_addr3, (const void *) &Samples, (sizeof(Samples) / symbol_length));
  *DMA_Source_ptr = BUFFER_BASE + BUFFER3_OFFSET;
  //DMA_MM2S();
  *DMA_Length_ptr = 2;
  ch = fgetc(tx_ff);

  gettimeofday(&t3, NULL);

  while (1) {
    
    res = read(fm, buf, 255); // Read data from serial line
    buf[res] = 0;
    for (int i = 0; i < res; i++)
    {

    DEBUG_PRINT(("Sending character: %c\n", buf[i]));

    for (int j = 0; j < 8; j++) // Modulate each data bit of serial line
    {
      Buffer_Sel = ((buf[i] & BIT_MASK[j]) >> (7 - j)); // Determine if bit is a zero or 1

      gettimeofday(&t1, NULL);
      f1 = hop_pattern[y];
      f2 = hop_pattern[y+1];
      if (y >= num_hops - 2) // Reset hopping
        y = 0;
      else 
        y = y + 2;
      
      Gen_Sin(Samples, (sizeof(Samples) / symbol_length / 2), Buffer_Sel, gain);

      // Toggle between two buffers: While one buffer is being emptied by the DMA, fill the second buffer
      if (toggle == 0) {
        memcpy((void *) hps_mem_addr, (const void *) &Samples, (sizeof(Samples) / symbol_length / 2));
        *DMA_Source_ptr = BUFFER_BASE;
        toggle = 1;
      }
      else if (toggle == 1) {
        memcpy((void *) hps_mem_addr2, (const void *) &Samples, (sizeof(Samples) / symbol_length / 2));
        *DMA_Source_ptr = BUFFER_BASE + BUFFER2_OFFSET;
        toggle = 0;
      }
      else {
        printf("Modulation Error\n");
        return 1;
      }
      gettimeofday(&t2, NULL);
      ElapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0; // sec to us
      ElapsedTime += (t2.tv_usec - t1.tv_usec);

      // DMA stuff
      if (delay != 0) {
        usleep(1000 * (delay + symbol - (ElapsedTime/1000)) - 70); // Delay in between bits
      }

      while((*DMA_Status_ptr & IOC_IRQ_MASK) == 0)  // Wait for interrupt bit to go high
      {
        WAIT; // Wait while pending DMA transaction
      }
      *DMA_Status_ptr  = IOC_IRQ_MASK;              // Clear interrupt bit by writing 1 to it
      gettimeofday(&t4, NULL);
      ElapsedTime = (t4.tv_sec - t3.tv_sec) * 1000000.0; // sec to us
      ElapsedTime += (t4.tv_usec - t3.tv_usec);
      //printf("\tTime = %.0f msec\n", ElapsedTime/1000);
      DMA_MM2S();  // Start DMA transfer
    }
      
    if (k  == (packet_length - 1)) {
      k = 0;
      usleep(1000 * (packet_sleep - delay));
    }
    else {
      k = k + 1;
    }
  }
    
    //ch = fgetc(tx_ff);

  }

  // Cleanup
  printf("\nCleanup\n");
  DMA_Init(0); // Stop DMA engine
  tcsetattr(fd, TCSANOW, &oldtio);   // Go back to old UART settings on UART1 after program finishes
  sleep(1); // Sleep just in case any pending transactions to DAC
  Disable_DAC();
  close(fd);
  close(fm);

  return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////
void DMA_Init(int start)
{
  *DMA_Control_ptr = start;                     // Assert start bit high for DMA transfer
}
void DMA_MM2S(void)
{
  // As soon as length register is written to the DMA transfer starts
  //*DMA_Length_ptr = sizeof(Samples); // Set length in bytes for DMA transfer
  *DMA_Length_ptr = sizeof(Samples) / symbol_length / 2;
}

///////////////////////////////////////////////////////////////////////////////////////////
// gain = 8,191 => pk-pk output is 62.5V
// gain = 7,000 => pk-pk output is 53V
// gain = 6,000 => pk-pk output is 47V
// gain = 5,000 => pk-pk output is 39V
// gain = 4,000 => pk-pk output is 31V
// gain = 3,000 => pk-pk output is 24V
// gain = 2,000 => pk-pk output is 16V
// gain = 1,000 => pk-pk output is 8.5V
// gain = 500   => pk-pk output is 4.8V
void Gen_Sin(__uint16_t *Buffer, __uint32_t n, int sel, double gain)
{
  //printf("Inside Gen_Sin function\n");
  int i;
  double dt = 1.0 / sampleRate;
  double w1 = 2.0 * M_PI * f1;
  double w2 = 2.0 * M_PI * f2;
  double t;
  double s;
  double w;
  
  if (gain > 1.0)
    gain = 1.0;

  if (sel == 0)           // Selection between freq1 and freq2
    w = w1;
  else if (sel == 1)
    w = w2;
  else {
    printf("Error\n");
  }
  
  for (i = 0; i < n; i++)
  {
    t = dt * (double)i;
    s = cos((w * t));
    //Buffer[i] = (__uint32_t)((8192.0 * s) + 8191.0);
    Buffer[i] = (__uint16_t)(((8191.0 + 1.0) * s * gain) + 8191.0);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////
/*void Gen_Chirp(__uint16_t *Buffer, __uint32_t n, int sel, double gain)
{
  //printf("Inside Gen_Chirp function\n");
  int i;
  double dt = 1.0 / sampleRate;
  double w1 = 2.0 * M_PI * f1;
  double w2 = 2.0 * M_PI * f2;
  double t;
  double s;
  double T = n / 2 / sampleRate; // Pulse length
  //double W;

  if (gain > 1.0)
    gain = 1.0;

  if (sel == 0) // Up-chirp
    NULL;
  else if (sel == 1) { // Down-chirp
    w1 = 2.0 * M_PI * f2;
    w2 = 2.0 * M_PI * f1;
  }

  for (i = 0; i < n; i++) {
    t = dt * (double)i;
    s = cos((w1*t) + (((w2 - w1) * t * t) / (2 * T)));
    //W = (sin((M_PI * t) / T)) * (sin((M_PI * t) / T));
    Buffer[i] = (__uint16_t)(((8191.0 + 1.0) * s * gain) + 8191.0);
  }
}*/

///////////////////////////////////////////////////////////////////////////////////////////
void Enable_DAC(void) // Also enable Power Amp
{
  //*DAC_Control = 0x00000003;
  *multi1 = (*multi1 & ~DAC_CONTROL_MASK) | (0x3 << DAC_CONTROL_OFFSET);

}
void Disable_DAC(void) // Also disable Power Amp
{
  //*DAC_Control = 0x00000000;
  *multi1 = (*multi1 & ~DAC_CONTROL_MASK) | (0 << DAC_CONTROL_OFFSET);
}

///////////////////////////////////////////////////////////////////////////////////////////
int Modem_Setup(void)
{
  struct termios newtio;

  // Open modem device for reading and writing, not controlling tty to not
  // get killed if line sendsd CTRL-C.
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
  //newtio.c_lflag = ICANON;

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

int Initialize(void)
{
  printf("\nCustom Transmit Command, version 1.1\n\n");

  // Open /dev/mem
  if ((fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1)
  {
    printf("ERROR: Could not open \"/dev/mem\"...\n");
    return 1;
  }

  // DMA Virtual Addresses
  AXI_DMA_virtual_base = mmap(NULL, AXI_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, AXI_DMA_BASE);
  if (AXI_DMA_virtual_base == MAP_FAILED)
  {
    printf("ERROR mmap1() failed ...\n");
    return 1;
  }
  DMA_Control_ptr     = (__uint32_t *)(AXI_DMA_virtual_base);
  DMA_Status_ptr      = (__uint32_t *)(AXI_DMA_virtual_base + DMA_STATUS_OFFSET);
  DMA_Source_ptr      = (__uint32_t *)(AXI_DMA_virtual_base + DMA_SOURCE_OFFSET);
  DMA_Length_ptr      = (__uint32_t *)(AXI_DMA_virtual_base + DMA_LENGTH_OFFSET);

  // AXI GPIO3
  AXI_GPIO3_virtual_base = mmap(NULL, AXI_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, AXI_GPIO3);
  if (AXI_GPIO3_virtual_base == MAP_FAILED)
  {
    printf("ERROR mmap() failed ...\n");
    return 1;
  }
  multi1 = (__uint32_t *)(AXI_GPIO3_virtual_base);

  // DDR virtual addresses
  hps_mem_store = mmap(NULL, BUFFER_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, BUFFER_BASE);
  if (hps_mem_store == MAP_FAILED)
  {
    printf("ERROR: mmap3() failed ...\n");
    return 1;
  }
  hps_mem_addr = (__uint32_t *)(hps_mem_store); // Location to store samples for buffer1
  hps_mem_addr2 = (__uint32_t *)(hps_mem_store + BUFFER2_OFFSET); // Location to store samples for buffer2
  hps_mem_addr3 = (__uint32_t *)(hps_mem_store + BUFFER3_OFFSET); // Location to store samples for buffer3

  if (Modem_Setup())
      return 1;

  return 0;
}
