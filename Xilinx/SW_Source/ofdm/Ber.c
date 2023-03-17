//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "ReturnStatus.h"
#include "Ber.h"
#include "log2.h"
#include "TransmitChain.h"

#define DEBUG
#define SAMPLE_DEBUG

static FILE *TxModFile;
static FILE *RxDemodFile;

static const int BIT_MASK[8] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04,
  0x02, 0x01};

double BerCharCalculation(const char tx, const char rx)
{
  int err = 0;
  for (int i = 0; i < 8; i++)
  {
    if ((tx & BIT_MASK[i]) != (rx & BIT_MASK[i])) 
    {
      err++;
    }
  }
  return ((double) err) / 8;
}

ReturnStatusType Ber(bool Ber, unsigned FileNumber, unsigned ModOrder,
  unsigned Nfft, unsigned OfdmSymbols)
{
  ReturnStatusType ReturnStatus;
  char tx, rx;
  unsigned TxSymbol, RxSymbol;
  double CharBer;
  double SymbolBer;
  double TotalBer = 0, TotalSer = 0;
  unsigned IndexLoop;
  unsigned i;
  unsigned fscanfRet;

  ReturnStatus = BerOpenFiles(Ber, FileNumber);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    return ReturnStatus;
  }

  if (Ber)
  {
    IndexLoop = OfdmSymbols*Nfft*((unsigned)b_log2(ModOrder))
      *DATA_DENSITY/8;
  }
  else // Symbol error rate
  {
    IndexLoop = OfdmSymbols*Nfft*DATA_DENSITY;
    // Throw away header information
    fscanfRet = fscanf(TxModFile, "%d\n", &TxSymbol);
    fscanfRet = fscanf(TxModFile, "%d\n", &TxSymbol);
    fscanfRet = fscanf(TxModFile, "%d\n", &TxSymbol);
    fscanfRet = fscanf(RxDemodFile, "%d\n", &RxSymbol);
    fscanfRet = fscanf(RxDemodFile, "%d\n", &RxSymbol);
    fscanfRet = fscanf(RxDemodFile, "%d\n", &RxSymbol);
  }

#ifdef DEBUG
  if (Ber)
  {
    printf("Ber: Example: BerCharCalculation(0x55,0x55) = %lf\n",
      BerCharCalculation((char) 0x55, (char) 0x55));
    printf("Ber: Example: BerCharCalculation(0x54,0x55) = %lf\n",
      BerCharCalculation((char) 0x54, (char) 0x55));
    printf("Ber: Example: BerCharCalculation(0x55,0xAA) = %lf\n",
      BerCharCalculation((char) 0x55, (char) 0xAA));
  }
#endif
  
  for (i = 0; i < IndexLoop; i++)
  {
    if (Ber)
    {
      tx = fgetc(TxModFile);
      rx = fgetc(RxDemodFile);
      CharBer = BerCharCalculation(tx, rx);
      TotalBer = TotalBer + CharBer;
      TotalBer = TotalBer / ((double)(i+1));
    }
    else // Symbol error Rate
    {
      fscanfRet = fscanf(TxModFile,"%d\n", &TxSymbol);
      fscanfRet = fscanf(RxDemodFile,"%d\n", &RxSymbol);
#ifdef SAMPLE_DEBUG
      if (i < 12)
      {
        printf("Ber: TxSymbol = %d, RxSymbol = %d\n", TxSymbol, RxSymbol);
      }
#endif
      if (TxSymbol != RxSymbol)
      {
        TotalSer++;
        TotalSer = TotalSer / ((double)(i+1));
      }
    }
  }
 
  if (Ber)
  {
    printf("Ber: Looped for %d bits\n", i*8);
    printf("Ber: Packet Bit Error Rate: %lf\n", TotalBer);
  }
  else
  {
    printf("Ber: Looped for %d symbols\n", i);
    printf("Ber: Packet Symbol Error Rate: %lf\n", TotalSer);
    printf("%d\n", fscanfRet);
  }

  fclose(TxModFile);
  fclose(RxDemodFile);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType BerOpenFiles(bool Ber, unsigned FileNumber)
{
  ReturnStatusType ReturnStatus;
  char TxFileName[32];
  char RxFileName[32];
  char Message[32];

  if (Ber)
  {
    sprintf(TxFileName, "files/TxModMessage%d.txt", FileNumber);
    sprintf(RxFileName, "files/RxDemodMessage%d.txt", FileNumber);
    sprintf(Message, "Bit");
  }
  else // SER (Symbol Error Rate)
  {
    sprintf(TxFileName, "files/TxModData%d.txt", FileNumber);
    sprintf(RxFileName, "files/RxDemodData%d.txt", FileNumber);
    sprintf(Message, "Symbol");
  }
  
  TxModFile = fopen(TxFileName, "r");
  if (TxModFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "BerOpenFiles: Failed top open %s\n", TxFileName);
    perror("BerOpenFiles");
    return ReturnStatus;
  }

  RxDemodFile = fopen(RxFileName, "r");
  if (RxDemodFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "BerOpenFiles: Failed top open %s\n", RxFileName);
    perror("BerOpenFiles");
    return ReturnStatus;
  }

  
  printf("BerOpenFiles: Get %s Error Rate between %s and %s\n",
    Message, TxFileName, RxFileName);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
