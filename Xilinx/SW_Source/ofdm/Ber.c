//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>
#include "ReturnStatus.h"
#include "Ber.h"
#include "log2.h"
#include "TransmitChain.h"

#define DEBUG
#define SAMPLE_DEBUG
//#define EXTRA_DEBUG

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
  unsigned OfdmSymbols, Calculated_Ofdm_Parameters *OfdmCalcParams)
{
  ReturnStatusType ReturnStatus;
  char tx, rx;
  unsigned TxSymbol, RxSymbol;
  double CharBer;
  double SymbolBer = 0;
  double SymbolSer = 0;
  double TotalBer = 0, TotalSer = 0;
  unsigned IndexLoop;
  unsigned SymbolLoop;
  unsigned SymbolCount = 0;
  unsigned NumSymbols = 0;
  unsigned i;
  unsigned fscanfRet = 0;

  ReturnStatus = BerOpenFiles(Ber, FileNumber);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    return ReturnStatus;
  }

  printf("Number of OFDM Symbols: %d\n", OfdmSymbols);
  printf("Number of Data Carriers: %d\n", OfdmCalcParams->NumDataCarriers);
  printf("Modulation Order: %d\n", ModOrder);
  if (Ber)
  {
    SymbolLoop = OfdmCalcParams->NumDataCarriers*
      (unsigned)b_log2(ModOrder)/8;
    IndexLoop = OfdmSymbols*SymbolLoop;
    printf("IndexLoop = %d, SymbolLoop = %d\n",IndexLoop,SymbolLoop);
  }
  else // Symbol error rate
  {
    SymbolLoop = OfdmCalcParams->NumDataCarriers;
    IndexLoop = OfdmSymbols*SymbolLoop;
    printf("IndexLoop = %d, SymbolLoop = %d\n",IndexLoop,SymbolLoop);
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
    if (Ber) // Bit Error Rate
    {
      tx = fgetc(TxModFile);
      rx = fgetc(RxDemodFile);
      CharBer = BerCharCalculation(tx, rx);
#ifdef EXTRA_DEBUG
      if (CharBer != 0x00)
      {
        printf("Ber: Bit Error Index %d\n", IndexLoop);
      }
#endif
      TotalBer = TotalBer + CharBer;
      if (SymbolCount == SymbolLoop)
      {
        SymbolBer = SymbolBer / ((double)(SymbolLoop+1));
        printf("Ber: OFDM SYMBOL %d BIT ERROR RATE = %lf\n", NumSymbols,
          SymbolBer);
        SymbolBer = 0;
        SymbolCount = 0;
        NumSymbols++;
      }
      else
      {
        SymbolCount++;
        SymbolBer = SymbolBer + CharBer;
      }
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
      if (SymbolCount == SymbolLoop) // For Symbol SER
      {
        SymbolSer = SymbolSer / ((double)(SymbolLoop+1));
        printf("Ber: OFDM SYMBOL %d SYMBOL ERROR RATE = %lf\n", 
          NumSymbols, SymbolSer);
        SymbolSer = 0;
        SymbolCount = 0;
        NumSymbols++;
        if (TxSymbol != RxSymbol)
        {
          SymbolSer++; // For Symbol SER
        }
      }
      else
      {
        SymbolCount++;
        if (TxSymbol != RxSymbol)
        {
          SymbolSer++; // For Symbol SER
#ifdef EXTRA_DEBUG
          printf("Ber: Symbol Error Index %d\n", IndexLoop);
#endif
        }
      }
      if (TxSymbol != RxSymbol)
      {
        TotalSer++; // For packet SER
      }
    }
  }

  if (Ber)
  {
    SymbolBer = SymbolBer / ((double)(SymbolLoop+1));
    printf("Ber: OFDM SYMBOL %d BIT ERROR RATE = %lf\n", NumSymbols,
      SymbolBer);
  }
  else // Symbol error rate
  {
    SymbolSer = SymbolSer / ((double)(SymbolLoop+1));
    printf("Ber: OFDM SYMBOL %d SYMBOL ERROR RATE = %lf\n", 
      NumSymbols, SymbolSer);
  }
 
  if (Ber)
  {
    TotalBer = TotalBer / ((double)(i+1));
    printf("Ber: Looped for %d bits\n", i*8);
    printf("Ber: PACKET BIT ERROR RATE: %lf\n", TotalBer);
  }
  else
  {
    TotalSer = TotalSer / ((double)(i+1));
    printf("Ber: Looped for %d symbols\n", i);
    printf("Ber: PACKET SYMBOL ERROR RATE: %lf\n", TotalSer);
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
