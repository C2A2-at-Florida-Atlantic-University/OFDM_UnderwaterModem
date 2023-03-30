/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_Interp_api.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 14:28:10
 */

#ifndef _CODER_INTERP_API_H
#define _CODER_INTERP_API_H

/* Include Files */
#include "emlrt.h"
#include "tmwtypes.h"
#include <string.h>

/* Type Definitions */
#ifndef typedef_g_emxArray_creal_T
#define typedef_g_emxArray_creal_T
typedef struct {
  creal_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
} g_emxArray_creal_T;
#endif /* typedef_g_emxArray_creal_T */

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void Interp(g_emxArray_creal_T *x, int16_T factor, g_emxArray_creal_T *y);

void Interp_api(const mxArray *const prhs[2], const mxArray **plhs);

void Interp_atexit(void);

void Interp_initialize(void);

void Interp_terminate(void);

void Interp_xil_shutdown(void);

void Interp_xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_Interp_api.h
 *
 * [EOF]
 */
