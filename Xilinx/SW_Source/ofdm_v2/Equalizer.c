//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include "Equalizer.h"
#include "rtwtypes.h"
#include "QamMod.h"

#define SAMPLE_DEBUG

static FILE *ChEstFile;
char FileName[32];
static FILE *PilotFile;
char FileName1[32];

ReturnStatusType EqualizerChFileOpen(void)
{
  ReturnStatusType ReturnStatus;

  sprintf(FileName, "files/ChannelEstimate%d.txt", 1);
  ChEstFile = fopen(FileName, "w");
  if (ChEstFile == NULL)
  {
    perror("EqualizerChFileOpen");
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "EqualizerChFileOpen: Failed to open %s\n", FileName);
    return ReturnStatus;
  }
  printf("EqualizerChFileOpen: Opened %s to Write CH Estimate\n",
    FileName);

  ReturnStatus.Status = RETURN_STATUS_FAIL;
  return ReturnStatus;
}

void EqualizerChFileClose(void)
{
  if (ChEstFile != NULL)
  {
    fclose(ChEstFile);
  }
  fclose(PilotFile);
}

ReturnStatusType EqualizerTxPilotOpen(unsigned ModOrder)
{
  ReturnStatusType ReturnStatus;

  sprintf(FileName1, "files/PilotDataM%d.txt", ModOrder);
  PilotFile = fopen(FileName1,"r");
  if (PilotFile == NULL)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    perror("EqualizerTxPilotOpen");
    sprintf(ReturnStatus.ErrString,
      "EqualizerTxPilotOpen: Failed to open %s\n", FileName1);
    return ReturnStatus;
  }
  printf("EqualizerTxPilotOpen: Opened Reference Pilot file %s\n",
    FileName1);

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

ReturnStatusType EqualizerChannelEstimate(bool DebugMode, unsigned
  ModOrder, creal32_T RxPilot, creal32_T *ChEst)
{
  ReturnStatusType ReturnStatus;
  creal32_T TxPilot;
  creal32_T H;
  creal_T tmp;
  unsigned PilotSymbol;

  if (fscanf(PilotFile, "%d\n", &PilotSymbol) != 1)
  {
    ReturnStatus.Status = RETURN_STATUS_FAIL;
    sprintf(ReturnStatus.ErrString,
      "EqualizerChannelEstimate: Error Reading Pilot Data\n");
    return ReturnStatus;
  }
  tmp = QamMod(PilotSymbol, ModOrder);
  TxPilot.re = (real_T)tmp.re;
  TxPilot.im = (real_T)tmp.im;
  if (DebugMode)
  {
    //fprintf(ChEstFile, "%d, %d\n", H.re, H.im);
    fprintf(ChEstFile, "%lf, %lf, %lf, %lf\n", TxPilot.re, TxPilot.im,
      RxPilot.re, RxPilot.im);
  }
  TxPilot.im = -TxPilot.im;
  RxPilot.im = -RxPilot.im;

  H.re = (RxPilot.re*TxPilot.re + RxPilot.im*TxPilot.im) /
         (TxPilot.re*TxPilot.re + TxPilot.im*TxPilot.im);
  H.im = (RxPilot.im*TxPilot.re - RxPilot.re*TxPilot.im) /
         (TxPilot.re*TxPilot.re + TxPilot.im*TxPilot.im);

  *ChEst = H;

  ReturnStatus.Status = RETURN_STATUS_SUCCESS;
  return ReturnStatus;
}

void EqualizerData(creal32_T ChEst, creal32_T Data,
  creal32_T *Result)
{
  creal32_T Res;

  ChEst.im = -ChEst.im;
  Res.re = (Data.re*ChEst.re + Data.im*ChEst.im) /
           (ChEst.re*ChEst.re + ChEst.im*ChEst.im);
  Res.im = (Data.im*ChEst.re - Data.re*ChEst.im) /
           (ChEst.re*ChEst.re + ChEst.im*ChEst.im);

  *Result = Res;
}
