//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <pthread.h>

#define BAUDRATE                      B115200
#define CONNECTING_ADDR               1
#define BUFFER_SIZE                   1024

int serial_setup();
int reyax_setup();
int tty_command_write(const char *command, int commandSize);
int tty_command_read();
int tty_data_write();
void *tty_data_read(void *arg);

char serialPortName[20];
int serialPort;
struct termios tty;
pthread_t read_thread;
int address                         = -1;
int networkID                       = -1;
int factory                         = -1;
int debug                           = 0;

int main(int argc, char *argv[])
{
  int retVal;
  int sizeNeeded;

  printf("\nUsage: ./reyax --address=<value> --networkID=<value> ");
  printf("--factory<'1'-factory settings> --debug=<'1'or'0'\n");

  for (int i = 1; i < argc; i++)
  {
    // Check for the --address option
    if (strncmp(argv[i], "--address=", 10) == 0)
      sscanf(argv[i] + 10, "%d", &address);
    else if (strncmp(argv[i], "--networkID=", 12) == 0)
    {
      char *value_str = argv[i]+12;
      networkID = atoi(value_str);
    }
    else if (strncmp(argv[i], "--factory=", 10) == 0)
      sscanf(argv[i] + 10, "%d", &factory);
    else if (strncmp(argv[i], "--debug=", 8) == 0)
    {
      sscanf(argv[i] + 8, "%d", &debug);
      if (debug == 1)
        printf("main(): Entering debug mode\n");
      else
      {
        printf("Error: --debug= option is only 0 or 1 (0 by default\n");
        return 1;
      }
    }
    else
    {
      int tmp = -1;
      tmp = atoi(argv[i]+10);
      printf("Error, did not read correctly: tmp = %d, i = %d\n", tmp, i);
      return 1;
    }
  }

  // Set up /dev/ttyPS1 serial port connecting to REYAX wireless device
  retVal = serial_setup();
  if (retVal)
    return 1;

  // Set up REYAX wireless device
  retVal = reyax_setup();
  if (retVal)
    return 1;

  // Initial message from Modem to connected wireless device
  const char *initMessage = "FAU-Modem Connecting ...";
  sizeNeeded = snprintf(NULL, 0, "AT+SEND=%d,%d,%s\r\n", CONNECTING_ADDR,
    strlen(initMessage), initMessage) + 1;
  char *initMessageCommand = (char *)malloc(sizeNeeded);
  snprintf(initMessageCommand, sizeNeeded, "AT+SEND=%d,%d,%s\r\n",
    CONNECTING_ADDR, strlen(initMessage), initMessage);
  printf("main(): Sending Hello message 1 to connected device\n");
  retVal = tty_command_write(initMessageCommand, 
    strlen(initMessageCommand));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  printf("main(): Sending Hello message 2 to connected device\n");
  retVal = tty_command_write(initMessageCommand, 
    strlen(initMessageCommand));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  free(initMessageCommand);

  printf("main(): Connecting Address: %d\n", CONNECTING_ADDR);
  printf("\n\n");
  retVal = pthread_create(&read_thread, NULL, tty_data_read,
    (void *)debug);
  if (retVal)
  {
    printf("main(): Failed to create thread, %d\n", retVal);
    close(serialPort);
    return 1;
  }

  if (debug)
    retVal = tty_data_write();

  pthread_join(read_thread, NULL);
  close(serialPort);
  return 0;
}

int serial_setup()
{
  snprintf(serialPortName, sizeof(serialPortName), "/dev/ttyPS1");
  serialPort = open(serialPortName, O_RDWR | O_NOCTTY, O_SYNC);
  if (serialPort < 0)
  {
    perror("serial_setup(): Error opening serial port\n");
    return 1;
  }

  memset(&tty, 0, sizeof(tty));
  if (tcgetattr(serialPort, &tty) !=0 )
  {
    perror("serial_setup(): Error getting termios attributes\n");
    close(serialPort);
    return 1;
  }

  // BAUDRATE : Set bps rate, Can also use cfsetispeed and cfsetospeed.
  // CRTSCTS  : Output hardware flow control
  // CS8      : 8n1 (8 bit, no parity, 1 stopbit)
  // CLOCAL   : local connection, no modem control
  // CREAD    : enable receiving characters
  tty.c_cflag = BAUDRATE | CRTSCTS | CS8 | CLOCAL | CREAD;

  // IGNPAR   : Ignore bytes with parity errors
  // ICRNL    : map CR to NL
  tty.c_iflag = IGNPAR | ICRNL;

  tty.c_oflag = 0;         // Raw output

  // ICANON   : Enable canonical input, disable all echo functionality
  //            and don't sent signals to calling program
  //tty.c_lflag = ICANON;
  tty.c_lflag = 0;

  // Initialize all control characters. Default values in /usr/include/termios.h
  tty.c_cc[VINTR]    = 0;     /* Ctrl-c */
  tty.c_cc[VQUIT]    = 0;     /* Ctrl-\ */
  tty.c_cc[VERASE]   = 0;     /* del */
  tty.c_cc[VKILL]    = 0;     /* @ */
  tty.c_cc[VEOF]     = 4;     /* Ctrl-d */
  tty.c_cc[VTIME]    = 0;     /* inter-character timer unused */
  tty.c_cc[VMIN]     = 1;     /* blocking read until 1 character arrives */
  tty.c_cc[VSWTC]    = 0;     /* '\0' */
  tty.c_cc[VSTART]   = 0;     /* Ctrl-q */
  tty.c_cc[VSTOP]    = 0;     /* Ctrl-s */
  tty.c_cc[VSUSP]    = 0;     /* Ctrl-z */
  tty.c_cc[VEOL]     = 0;     /* '\0' */
  tty.c_cc[VREPRINT] = 0;     /* Ctrl-r */
  tty.c_cc[VDISCARD] = 0;     /* Ctrl-u */
  tty.c_cc[VWERASE]  = 0;     /* Ctrl-w */
  tty.c_cc[VLNEXT]   = 0;     /* Ctrl-v */
  tty.c_cc[VEOL2]    = 0;     /* '\0' */


/*
  cfsetospeed(&tty, B115200);
  cfsetispeed(&tty, B115200);

  tty.c_cflag |= (CLOCAL | CREAD);
  tty.c_cflag &= ~CSIZE;
  tty.c_cflag |= CS8;
  tty.c_cflag &= ~PARENB;
  tty.c_cflag &= ~CSTOPB;
  tty.c_cflag &= ~CRTSCTS;

  tty.c_iflag &= ~(IXON | IXOFF | IXANY);
  tty.c_iflag &= ~(ICRNL | INLCR);

  tty.c_oflag &= ~OPOST;

  tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);

  tty.c_cc[VMIN] = 0;
  tty.c_cc[VTIME] = 10;
*/
/*
  tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;// 8-bit chars
  tty.c_iflag &= ~IGNBRK;                    // disable break processing
  tty.c_lflag = 0;                           // no sig chars, no echo,
                                             // no canonical processing
  tty.c_oflag = 0;                           // no remapping, no delays
  tty.c_cc[VMIN]  = 0;                       // read doesn't block
  tty.c_cc[VTIME] = 5;                       // 0.5 seconds read timeout

  tty.c_iflag &= ~(IXON | IXOFF | IXANY);    // shut off xon/xoff ctrl

  tty.c_cflag |= (CLOCAL | CREAD);           // ignore modem controls,
                                             // enable reading
  tty.c_cflag &= ~(PARENB | PARODD);         // shut off parity
  tty.c_cflag &= ~CSTOPB;
  tty.c_cflag &= ~CRTSCTS;
*/

  tcflush(serialPort, TCIFLUSH);
  if (tcsetattr(serialPort, TCSANOW, &tty) != 0) {
      perror("Error setting termios attributes");
      close(serialPort);
      return 1;
  }
  return 0;
}

//////////////////////////////////////////////////////////////////////////
int reyax_setup()
{
  int retVal;
  int sizeNeeded;
  const char *command1 = "AT\r\n";
  const char *command2 = "AT+RESET\r\n";
  const char *command3 = "AT+IPR=115200\r\n";
  const char *command4 = "AT+IPR?\r\n";
  const char *command5 = "AT+BAND?\r\n";
  const char *command6 = "AT+PARAMETER?\r\n";
  const char *command8 = "AT+ADDRESS?\r\n";
  const char *command10= "AT+NETWORKID?\r\n";
  const char *command11= "AT+CRFOP?\r\n";
  const char *command12= "AT+FACTORY\r\n";

  printf("\nreyax_setup(): Checking AT Commands\n");
  retVal = tty_command_write(command1, strlen(command1));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  if (factory != -1)
  {
    printf("reyax_setup(); Setting Factory Settings\n");
    retVal = tty_command_write(command12, strlen(command12));
    if (retVal) return retVal;
    retVal = tty_command_read();
    if (retVal) return retVal;
    return 1;
  }
  printf("reyax_setup(): Reseting REYAX Device\n");
  retVal = tty_command_write(command2, strlen(command2));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  printf("reyax_setup(): Setting Baud Rate\n");
  retVal = tty_command_write(command3, strlen(command3));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  printf("reyax_setup(): Reading Baud Rate\n");
  retVal = tty_command_write(command4, strlen(command4));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  printf("reyax_setup(): Reading RF Frequency\n");
  retVal = tty_command_write(command5, strlen(command5));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  printf("reyax_setup(): Reading RF Parameters\n");
  retVal = tty_command_write(command6, strlen(command6));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  if (address != -1)
  {
    printf("reyax_setup(): Setting Address to %d\n", address);
    sizeNeeded = snprintf(NULL, 0, "AT+ADDRESS=%d\r\n", address) + 1;
    char *command7 = (char *)malloc(sizeNeeded);
    snprintf(command7, sizeNeeded, "AT+ADDRESS=%d\r\n", address);
    retVal = tty_command_write(command7, strlen(command7));
    if (retVal) return retVal;
    retVal = tty_command_read();
    if (retVal) return retVal;
    free(command7);
  }
  printf("reyax_setup(): Reading Address\n");
  retVal = tty_command_write(command8, strlen(command8));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  if (networkID != -1)
  {
    printf("reyax_setup(): Setting Network ID to %d\n", networkID);
    sizeNeeded = snprintf(NULL, 0, "AT+NETWORKID=%d\r\n", networkID) + 1;
    char *command9 = (char *)malloc(sizeNeeded);
    snprintf(command9, sizeNeeded, "AT+NETWORKID=%d\r\n", networkID);
    retVal = tty_command_write(command9, strlen(command9));
    if (retVal) return retVal;
    retVal = tty_command_read();
    if (retVal) return retVal;
    free(command9);
  }
  printf("reyax_setup(): Reading Network ID\n");
  retVal = tty_command_write(command10, strlen(command10));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;
  printf("reyax_setup(): Reading Output Power\n");
  retVal = tty_command_write(command11, strlen(command11));
  if (retVal) return retVal;
  retVal = tty_command_read();
  if (retVal) return retVal;

  return 0;
}

//////////////////////////////////////////////////////////////////////////
int tty_command_write(const char *command, int commandSize)
{
  int writeStatus;
  writeStatus = write(serialPort, command, commandSize);
  if (writeStatus < 0)
  {
    printf("tty_command_write(): Error writting %s to serial port",
      command);
    close(serialPort);
    return 1;
  }

  return 0;
}
//////////////////////////////////////////////////////////////////////////
int tty_command_read()
{
  int readStatus;
  char response[200];
  while (1)
  {
    readStatus = read(serialPort, response, sizeof(response)-1);
    if (readStatus < 0)
    {
      perror("tty_command_read(): Error reading from serial port\n");
      close(serialPort);
      return 1;
    } 
    else if (readStatus > 0)
    {
      response[readStatus] = '\0'; // Null-terminate the string
      if (debug)
      {
        printf("tty_command_read(): REYAX device command status: %s", 
          response);
      }
      else
      {
        response[readStatus-1] = '\0';
        printf("\t%s", response);
      }
      break;
    }
    //usleep(1000);
  }
  return 0;
}

//////////////////////////////////////////////////////////////////////////
int tty_data_write()
{
  char user_input[BUFFER_SIZE];
  char command[BUFFER_SIZE];
  size_t len;
  int writeStatus;

  printf("tty_data_write(): Ready to Transmit ...\n");

  while (1)
  {
    if (fgets(user_input, sizeof(user_input), stdin) != NULL)
    {
      len = strlen(user_input);
      if (user_input[len-1] == '\n')
        user_input[len-1] = '\0';
      len = len-1;
      snprintf(command, sizeof(command), "AT+SEND=%d,%zu,%s\r\n",
        CONNECTING_ADDR, len, user_input);
      writeStatus = write(serialPort, command, strlen(command));
      if (writeStatus < 0)
      {
        perror("tty_data_write(): Error writting to serial port\n");
        return 1;
      }
    }
  }
  return 0;
}

//////////////////////////////////////////////////////////////////////////
void *tty_data_read(void *arg)
{
  int numBytes, retVal;
  int debugMode = (int)arg;
  char buffer[BUFFER_SIZE];
  char lineOutput[BUFFER_SIZE];
  char command[BUFFER_SIZE];
  char rx_addr[16], data_len[16], data[256], rssi[16], snr[16];
  size_t len;

  if (debugMode)
    printf("*tty_data_read(): Ready to Receive (debug mode) ...\n");
  else
  {
    printf("*tty_data_read(): Ready to Transmit and Receive ");
    printf("(non-debug mode) ...\n");
  }

  while (1)
  {
    memset(buffer, 0, BUFFER_SIZE);
    numBytes = read(serialPort, buffer, BUFFER_SIZE);
    if (numBytes > 0)
    {
      buffer[numBytes] = '\0';
      fflush(stdout);
      if (strncmp(buffer, "+RCV=", 5) == 0)
      {
        if (sscanf(buffer+5, "%15[^,],%15[^,],%255[^,],%15[^,],%15s",
          rx_addr, data_len, data, rssi, snr) == 5)
        {
          if (debugMode == 1) // debug value on arg
            printf("%s        RSSI=%s, SNR=%s\n", data, rssi, snr);
          else
          {
            printf("Running command: %s    RSSI=%s,SNR=%s\n", data, rssi,
              snr);
            FILE *fp = popen(data, "r");
            if (fp == NULL) 
            {
              perror("*tty_data_read(): Failed to run command");
              continue;
            }
            //fread(commandOutput, sizeof(char), BUFFER_SIZE, fp);
            while (fgets(lineOutput, sizeof(lineOutput), fp) != NULL)
            {
              len = strlen(lineOutput);
              if (lineOutput[len-1] == '\n')
                lineOutput[len-1] = '\0';
              else if (lineOutput[len-1] == '\r')
                lineOutput[len-1] = '\0';
              len = len-1;
              if (lineOutput[len-1] == '\r')
              {
                lineOutput[len-1] = '\0';
                len = len-1;
              }
              snprintf(command, sizeof(command), "AT+SEND=%d,%d,%s\r\n",
                CONNECTING_ADDR, len, lineOutput);
              printf("\t%s", lineOutput);
              retVal = tty_command_write(command, strlen(command));
              if (retVal) return NULL;
              retVal = tty_command_read();
              if (retVal) return NULL;
            }
            pclose(fp);
          }
        }
        else
        {
          printf("\t*tty_data_read: Error: RX data is not in the ");
          printf("expected format\n");
          return NULL;
        }
      }
      else if (strncmp(buffer, "+OK", 3) == 0)
        printf("%s", buffer);
      else
      {
        //printf("*tty_data_read: Error: Expected: +RCV=, Actual: %s", 
        //  buffer);
      }
//////////////////////////////////////////////////////////////////////////
    }
  }
  printf("*tty_data_read: Exiting thread\n");
  return NULL;
}
