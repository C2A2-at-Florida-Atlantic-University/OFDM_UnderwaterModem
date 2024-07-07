//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef REYAX_H_INCLUDED
#define REYAX_H_INCLUDED

#include "ReturnStatus.h"
#include <stdarg.h>

#define BAUDRATE                      B115200
#define CONNECTING_ADDR               1
#define BUFFER_SIZE                   1024

#define UNSIGNED_READ                 0
#define UNSIGNED_HEX_READ             1
#define INT_READ                      2
#define DOUBLE_READ                   3

ReturnStatusType ReyaxSerialSetup();
ReturnStatusType ReyaxSetup(int address, int networkID);
void ReyaxInitMessage();
ReturnStatusType ReyaxTtyCommandWrite(const char *command, 
  int commandSize);
ReturnStatusType ReyaxTtyCommandRead();
ReturnStatusType ReyaxTtyDataWrite();
ReturnStatusType ReyaxTtyMessageSend(const char *Message, ...);
ReturnStatusType ReyaxTtyDataRead(void *val, unsigned Sel);
void *ReyaxTtyDataReadPThread(void *arg);

#endif
