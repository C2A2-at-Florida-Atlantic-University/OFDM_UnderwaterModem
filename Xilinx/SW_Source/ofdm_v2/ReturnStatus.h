//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#ifndef RETURN_STATUS_H_INCLUDED
#define RETURN_STATUS_H_INCLUDED

#include "ReturnStatus.h"

#define RETURN_STATUS_FAIL 1
#define RETURN_STATUS_SUCCESS 0

typedef struct {
  int Status;
  char ErrString[256];
} ReturnStatusType;

#endif
