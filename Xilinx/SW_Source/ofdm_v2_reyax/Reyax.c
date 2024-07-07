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
#include <stdarg.h>
#include "ReturnStatus.h"
#include "Reyax.h"

int serialPort;
struct termios tty;

ReturnStatusType ReyaxSerialSetup()
{
  ReturnStatusType ReturnStatus;
  char serialPortName[20];

  snprintf(serialPortName, sizeof(serialPortName), "/dev/ttyPS1");
  serialPort = open(serialPortName, O_RDWR | O_NOCTTY, O_SYNC);
  if (serialPort < 0)
  {
    perror("ReyaxSerialSetup(): Error opening serial port\n");
    sprintf(ReturnStatus.ErrString,
      "ReyaxSerialSetup(): Error opening serial port\n");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    return ReturnStatus;
  }

  memset(&tty, 0, sizeof(tty));
  if (tcgetattr(serialPort, &tty) !=0 )
  {
    perror("ReyaxSerialSetup(): Error getting termios attributes\n");
    close(serialPort);
    sprintf(ReturnStatus.ErrString,
      "ReyaxSerialSetup(): Error getting termios attributes\n");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    return ReturnStatus;
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

  // Initialize all control characters. Default values in 
  // /usr/include/termios.h
  tty.c_cc[VINTR]    = 0;     /* Ctrl-c */
  tty.c_cc[VQUIT]    = 0;     /* Ctrl-\ */
  tty.c_cc[VERASE]   = 0;     /* del */
  tty.c_cc[VKILL]    = 0;     /* @ */
  tty.c_cc[VEOF]     = 4;     /* Ctrl-d */
  tty.c_cc[VTIME]    = 0;     /* inter-character timer unused */
  tty.c_cc[VMIN]     = 1;     /* block read until 1 character arrives */
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

  tcflush(serialPort, TCIFLUSH);
  if (tcsetattr(serialPort, TCSANOW, &tty) != 0) {
      perror("Error setting termios attributes");
      sprintf(ReturnStatus.ErrString,
        "ReyaxSerialSetup(): Error setting termios attributes\n");
      close(serialPort);
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

//////////////////////////////////////////////////////////////////////////
void ReyaxInitMessage()
{
  ReyaxTtyMessageSend("FAU-Modem %d OFDM Connecting ...", 1);
}

//////////////////////////////////////////////////////////////////////////
ReturnStatusType ReyaxSetup(int address, int networkID)
{
  ReturnStatusType ReturnStatus;
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

  printf("\nReyaxSetup(): Checking AT Commands\n");
  ReturnStatus = ReyaxTtyCommandWrite(command1, strlen(command1));
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  printf("ReyaxSetup(): Reseting REYAX Device\n");
  ReturnStatus = ReyaxTtyCommandWrite(command2, strlen(command2));
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  printf("ReyaxSetup(): Setting Baud Rate\n");
  ReturnStatus = ReyaxTtyCommandWrite(command3, strlen(command3));
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  printf("ReyaxSetup(): Reading Baud Rate\n");
  ReturnStatus = ReyaxTtyCommandWrite(command4, strlen(command4));
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  printf("ReyaxSetup(): Reading RF Frequency\n");
  ReturnStatus = ReyaxTtyCommandWrite(command5, strlen(command5));
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  printf("ReyaxSetup(): Reading RF Parameters\n");
  ReturnStatus = ReyaxTtyCommandWrite(command6, strlen(command6));
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  if (address != -1)
  {
    printf("ReyaxSetup(): Setting Address to %d\n", address);
    sizeNeeded = snprintf(NULL, 0, "AT+ADDRESS=%d\r\n", address) + 1;
    char *command7 = (char *)malloc(sizeNeeded);
    snprintf(command7, sizeNeeded, "AT+ADDRESS=%d\r\n", address);
    ReturnStatus = ReyaxTtyCommandWrite(command7, strlen(command7));
    if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
    ReturnStatus = ReyaxTtyCommandRead();
    if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
    free(command7);
  }
  printf("ReyaxSetup(): Reading Address\n");
  ReturnStatus = ReyaxTtyCommandWrite(command8, strlen(command8));
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  if (networkID != -1)
  {
    printf("ReyaxSetup(): Setting Network ID to %d\n", networkID);
    sizeNeeded = snprintf(NULL, 0, "AT+NETWORKID=%d\r\n", networkID) + 1;
    char *command9 = (char *)malloc(sizeNeeded);
    snprintf(command9, sizeNeeded, "AT+NETWORKID=%d\r\n", networkID);
    ReturnStatus = ReyaxTtyCommandWrite(command9, strlen(command9));
    if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
    ReturnStatus = ReyaxTtyCommandRead();
    if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
    free(command9);
  }
  printf("ReyaxSetup(): Reading Network ID\n");
  ReturnStatus = ReyaxTtyCommandWrite(command10, strlen(command10));
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  printf("ReyaxSetup(): Reading Output Power\n");
  ReturnStatus = ReyaxTtyCommandWrite(command11, strlen(command11));
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

//////////////////////////////////////////////////////////////////////////
ReturnStatusType ReyaxTtyCommandWrite(const char *command, 
  int commandSize)
{
  ReturnStatusType ReturnStatus;
  int writeStatus;
  writeStatus = write(serialPort, command, commandSize);
  if (writeStatus < 0)
  {
    sprintf(ReturnStatus.ErrString,
      "ReyaxTtyCommandWrite(): Error writting %s to serial port",command);
    close(serialPort);
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    return ReturnStatus;
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
//////////////////////////////////////////////////////////////////////////
ReturnStatusType ReyaxTtyCommandRead()
{
  ReturnStatusType ReturnStatus;
  int readStatus;
  char response[200];
  while (1)
  {
    readStatus = read(serialPort, response, sizeof(response)-1);
    if (readStatus < 0)
    {
      perror("ReyaxTtyCommandRead(): Error reading from serial port\n");
      sprintf(ReturnStatus.ErrString,
        "ReyaxTtyCommandRead(): Error reading from serial port\n");
      close(serialPort);
      ReturnStatus.Status = RETURN_STATUS_FAIL;
      return ReturnStatus;
    } 
    else if (readStatus > 0)
    {
      response[readStatus] = '\0'; // Null-terminate the string
      response[readStatus-1] = '\0';
      printf("\t%s", response);
      break;
    }
    //usleep(1000);
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

//////////////////////////////////////////////////////////////////////////
ReturnStatusType ReyaxTtyDataWrite()
{
  ReturnStatusType ReturnStatus;
  char user_input[BUFFER_SIZE];
  char command[BUFFER_SIZE];
  size_t len;
  int writeStatus;

  printf("ReyaxTtyDataWrite(): Ready to Transmit ...\n");

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
        perror("ReyaxTtyDataWrite(): Error writting to serial port\n");
        sprintf(ReturnStatus.ErrString,
          " ReyaxTtyDataWrite(): Error writing to serial port\n");
        ReturnStatus.Status = RETURN_STATUS_FAIL;
        return ReturnStatus;
      }
    }
  }
  
  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

//////////////////////////////////////////////////////////////////////////
ReturnStatusType ReyaxTtyMessageSend(const char *Message, ...)
{
  ReturnStatusType ReturnStatus;
  va_list args;
  va_start(args, Message);
  char command[259]; // 240 + 19 for AT command
  char message[240];
  unsigned result;

  result = vsnprintf(message, sizeof(message), Message, args);
  va_end(args);

  if (result >= sizeof(message))
  {
    printf("ReyaxTtyMessageSend: Message is too long, Truncating ...\n");
    message[sizeof(message) - 1] = '\0';
  }

  snprintf(command, sizeof(command), "AT+SEND=%d,%d,%s\r\n",
    CONNECTING_ADDR, strlen(message), message);
  ReturnStatus = ReyaxTtyCommandWrite(command, strlen(command));
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;
  ReturnStatus = ReyaxTtyCommandRead();
  if (ReturnStatus.Status == RETURN_STATUS_FAIL) return ReturnStatus;

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
//////////////////////////////////////////////////////////////////////////
ReturnStatusType ReyaxTtyDataRead(void *val, unsigned Sel)
{
  ReturnStatusType ReturnStatus;
  char buffer[BUFFER_SIZE];
  int numBytes;
  char rx_addr[16], data_len[16], data[256], rssi[16], snr[16];

  memset(buffer, 0, BUFFER_SIZE);
  fflush(stdout);
  numBytes = read(serialPort, buffer, BUFFER_SIZE);
  if (numBytes > 0)
  {
    buffer[numBytes] = '\0';
    if (strncmp(buffer, "+RCV=", 5) == 0)
    {
      if (sscanf(buffer+5, "%15[^,],%15[^,],%255[^,],%15[^,],%15s",
        rx_addr, data_len, data, rssi, snr) == 5)
      {
        printf("%s        RSSI=%s, SNR=%s\n", data, rssi, snr);
        if (Sel == UNSIGNED_READ || Sel == INT_READ)
          *(unsigned *)val = atoi(data);
        else if (Sel == UNSIGNED_HEX_READ)
          *(unsigned *)val = strtol(data, NULL, 16);
        else if (Sel == DOUBLE_READ)
          *(double *)val = strtod(data, NULL);
        ReturnStatus.Status = RETURN_STATUS_SUCCESS;
        return ReturnStatus;
      }
      else
      {
        sprintf(ReturnStatus.ErrString,
          "ReyaxTtyDataRead(): Rx data is not in the expected format\n");
        ReturnStatus.Status = RETURN_STATUS_FAIL;
        return ReturnStatus;
      }
    }
  }

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

//////////////////////////////////////////////////////////////////////////
void *ReyaxTtyDataReadPThread(void *arg)
{
  ReturnStatusType ReturnStatus;
  int numBytes;
  int debugMode = (int)arg;
  char buffer[BUFFER_SIZE];
  char lineOutput[BUFFER_SIZE];
  char command[BUFFER_SIZE];
  char rx_addr[16], data_len[16], data[256], rssi[16], snr[16];
  size_t len;

  if (debugMode)
  {
    printf("*ReyaxTtyDataReadPThread(): Ready to Receive ");
    printf("(debug mode) ...\n");
  }
  else
  {
    printf("*ReyaxTtyDataReadPThread(): Ready to Transmit and Receive ");
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
            if (strncmp(data, "cd ", 3) == 0)
            {
              char *directory = data + 3;
              directory[strcspn(directory, "\n")] = 0;
              if (chdir(directory) != 0)
              {
                perror("*ReyaxTtyDataReadPThread(): chdir() failed");
              }
            }
            else
            {
              FILE *fp = popen(data, "r");
              if (fp == NULL) 
              {
                printf("*ReyaxTtyDataReadPThread(): Failed to run ");
                printf("command");
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
                ReturnStatus = ReyaxTtyCommandWrite(command, 
                  strlen(command));
                if (ReturnStatus.Status==RETURN_STATUS_FAIL) return NULL;
                ReturnStatus = ReyaxTtyCommandRead();
                if (ReturnStatus.Status==RETURN_STATUS_FAIL) return NULL;
              }
              pclose(fp);
            }
          }
        }
        else
        {
          printf("\t*ReyaxTtyDataReadPThread: Error: RX data is not ");
          printf("in the ");
          printf("expected format\n");
          return NULL;
        }
      }
      else if (strncmp(buffer, "+OK", 3) == 0)
        printf("%s", buffer);
      else
      {
        //printf("*ReyaxTtyDataReadPThread: Error: Expected: ");
        //printf("+RCV=, Actual: %s", 
        //  buffer);
      }
    }
  }
  printf("*ReyaxTtyDataReadPThread: Exiting thread\n");
  return NULL;
}
