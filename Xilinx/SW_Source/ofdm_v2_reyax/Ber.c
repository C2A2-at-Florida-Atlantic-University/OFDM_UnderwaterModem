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
#include "Reyax.h"

//#define DEBUG
//#define SAMPLE_DEBUG
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

ReturnStatusType Ber(bool Ber, unsigned ModOrder, unsigned OfdmSymbols,
  Calculated_Ofdm_Parameters *OfdmCalcParams)
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

  ReturnStatus = BerOpenFiles(Ber, ModOrder);
  if (ReturnStatus.Status == RETURN_STATUS_FAIL)
  {
    return ReturnStatus;
  }

  if (Ber)
  {
    SymbolLoop = OfdmCalcParams->NumDataCarriers*
      (unsigned)b_log2(ModOrder)/8;
    IndexLoop = OfdmSymbols*SymbolLoop;
  }
  else // Symbol error rate
  {
    SymbolLoop = OfdmCalcParams->NumDataCarriers;
    IndexLoop = OfdmSymbols*SymbolLoop;
    // Throw away header information
    //fscanfRet = fscanf(TxModFile, "%d\n", &TxSymbol);
    //fscanfRet = fscanf(TxModFile, "%d\n", &TxSymbol);
    //fscanfRet = fscanf(TxModFile, "%d\n", &TxSymbol);
    fscanfRet = fscanf(RxDemodFile, "%d\n", &RxSymbol);
    fscanfRet = fscanf(RxDemodFile, "%d\n", &RxSymbol);
    fscanfRet = fscanf(RxDemodFile, "%d\n", &RxSymbol);
  }

#ifdef DEBUG
  if (Ber)
  {
    ReyaxTtyMessageSend("Ber: Example: BerCharCalculation(0x55,0x55) = "
      "%lf", BerCharCalculation((char) 0x55, (char) 0x55));
    ReyaxTtyMessageSend("Ber: Example: BerCharCalculation(0x54,0x55) = "
      "%lf", BerCharCalculation((char) 0x54, (char) 0x55));
    ReyaxTtyMessageSend("Ber: Example: BerCharCalculation(0x55,0xAA) = "
      "%lf", BerCharCalculation((char) 0x55, (char) 0xAA));
  }
#endif

  ReyaxTtyMessageSend(" ");
  
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
        ReyaxTtyMessageSend("Ber: Bit Error Index %d", IndexLoop);
      }
#endif
      TotalBer = TotalBer + CharBer;
      if (SymbolCount == SymbolLoop)
      {
        SymbolBer = SymbolBer / ((double)(SymbolLoop+1));
        ReyaxTtyMessageSend("Ber: OFDM SYMBOL %d BIT ERROR RATE = %lf",
          NumSymbols, SymbolBer);
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
        ReyaxTtyMessageSend("Ber: TxSymbol = %d, RxSymbol = %d", 
          TxSymbol, RxSymbol);
      }
#endif
      if (SymbolCount == SymbolLoop) // For Symbol SER
      {
        SymbolSer = SymbolSer / ((double)(SymbolLoop+1));
        ReyaxTtyMessageSend("Ber: OFDM SYMBOL %2d SYMBOL ERROR RATE = "
          "%lf", NumSymbols, SymbolSer);
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
          ReyaxTtyMessageSend("Ber: Symbol Error Index %d", IndexLoop);
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
    ReyaxTtyMessageSend("Ber: OFDM SYMBOL %d BIT ERROR RATE = %lf", 
      NumSymbols, SymbolBer);
  }
  else // Symbol error rate
  {
    SymbolSer = SymbolSer / ((double)(SymbolLoop+1));
    ReyaxTtyMessageSend("Ber: OFDM SYMBOL %2d SYMBOL ERROR RATE = %lf", 
      NumSymbols, SymbolSer);
  }

  ReyaxTtyMessageSend(" ");
 
  if (Ber)
  {
    TotalBer = TotalBer / ((double)(i+1));
    ReyaxTtyMessageSend("Ber: Looped for %d bits", i*8);
    ReyaxTtyMessageSend("Ber: PACKET BIT ERROR RATE: %lf", TotalBer);
    ReyaxTtyMessageSend(" ");
  }
  else
  {
    TotalSer = TotalSer / ((double)(i+1));
    ReyaxTtyMessageSend("Ber: Looped for %d symbols", i);
    ReyaxTtyMessageSend("Ber: PACKET SYMBOL ERROR RATE: %lf", TotalSer);
    ReyaxTtyMessageSend(" ");
    ReyaxTtyMessageSend("%d", fscanfRet);
  }


  fclose(TxModFile);
  fclose(RxDemodFile);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType BerOpenFiles(bool Ber, unsigned
  ModOrder)
{
  ReturnStatusType ReturnStatus;
  char TxFileName[32];
  char RxFileName[32];
  char Message[32];

  if (Ber)
  {
    sprintf(TxFileName, "files/TxModMessage%d.txt", ModOrder);
    sprintf(RxFileName, "files/RxDemodMessage%d.txt", ModOrder);
    sprintf(Message, "Bit");
  }
  else // SER (Symbol Error Rate)
  {
    sprintf(TxFileName, "files/TxModData%d.txt", ModOrder);
    sprintf(RxFileName, "files/RxDemodData%d.txt", ModOrder);
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
  ReyaxTtyMessageSend("BerOpenFiles: Opened file %s", TxFileName);

  RxDemodFile = fopen(RxFileName, "r");
  if (RxDemodFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "BerOpenFiles: Failed top open %s\n", RxFileName);
    perror("BerOpenFiles");
    return ReturnStatus;
  }
  ReyaxTtyMessageSend("BerOpenfiles: Opened file %s", RxFileName);
  
  ReyaxTtyMessageSend("BerOpenFiles: Get %s Error Rate between %s and %s",
    Message, TxFileName, RxFileName);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}
