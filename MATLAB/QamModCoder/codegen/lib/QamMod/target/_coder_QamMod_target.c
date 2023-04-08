/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_QamMod_target.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 12:23:52
 */

/* Include Files */
#include "_coder_QamMod_target.h"
#include "QamMod.h"
#include "QamMod_initialize.h"
#include "QamMod_terminate.h"
#include "rt_nonfinite.h"

/* Function Declarations */
static void b_xilTargetSerializer(const real_T *r);

static void xilTargetDeserializer(int8_T *r);

static void xilTargetSerializer(const creal_T *r);

/* Function Definitions */
/*
 * Arguments    : const real_T *r
 * Return Type  : void
 */
static void b_xilTargetSerializer(const real_T *r)
{
  xilWriteData((const MemUnit_T *)r, sizeof(real_T));
}

/*
 * Arguments    : int8_T *r
 * Return Type  : void
 */
static void xilTargetDeserializer(int8_T *r)
{
  xilReadData((MemUnit_T *)r, sizeof(int8_T));
}

/*
 * Arguments    : const creal_T *r
 * Return Type  : void
 */
static void xilTargetSerializer(const creal_T *r)
{
  b_xilTargetSerializer(&r->re);
  b_xilTargetSerializer(&r->im);
}

/*
 * Arguments    : uint32_T fcnId
 * Return Type  : void
 */
void XILTarget_initialize(uint32_T fcnId)
{
  /* Calling XIL API before invoke initialize function. */
  xilPreEntryPoint(fcnId);
  /* Invoke initialize function. */
  QamMod_initialize();
  /* Calling XIL API after invoke initialize function. */
  xilPostEntryPoint(fcnId);
}

/*
 * Arguments    : uint32_T fcnId
 * Return Type  : void
 */
void XILTarget_terminate(uint32_T fcnId)
{
  /* Calling XIL API before invoke terminate function. */
  xilPreEntryPoint(fcnId);
  /* Invoke terminate function. */
  QamMod_terminate();
  /* Calling XIL API after invoke terminate function. */
  xilPostTerminatePoint(fcnId);
}

/*
 * Arguments    : uint32_T fcnId
 * Return Type  : XIL_PROCESSDATA_ERROR_CODE
 */
XIL_PROCESSDATA_ERROR_CODE xilTarget_QamMod(uint32_T fcnId)
{
  creal_T y;
  int8_T M;
  int8_T x;
  /* Deserialize function input x argument. */
  xilTargetDeserializer(&x);
  /* Deserialize function input M argument. */
  xilTargetDeserializer(&M);
  /* Calling XIL API before invoke entry point. */
  xilPreEntryPoint(fcnId);
  /* Invoke target entry point. */
  y = QamMod(x, M);
  /* Calling XIL API after invoke entry point. */
  xilPostEntryPoint(fcnId);
  /* Serialize function output argument y. */
  xilTargetSerializer(&y);
  return XIL_PROCESSDATA_SUCCESS;
}

/*
 * File trailer for _coder_QamMod_target.c
 *
 * [EOF]
 */
