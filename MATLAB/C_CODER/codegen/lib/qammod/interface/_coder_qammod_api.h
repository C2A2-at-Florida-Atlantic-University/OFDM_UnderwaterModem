/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_QamMod_api.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 12:23:52
 */

#ifndef _CODER_QAMMOD_API_H
#define _CODER_QAMMOD_API_H

/* Include Files */
#include "emlrt.h"
#include "tmwtypes.h"
#include <string.h>

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
creal_T QamModXilWrapper(int8_T x, int8_T M);

void QamMod_api(const mxArray *const prhs[2], const mxArray **plhs);

void QamMod_atexit(void);

void QamMod_initialize(void);

void QamMod_terminate(void);

void QamMod_xil_shutdown(void);

void QamMod_xil_terminate(void);

void xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_QamMod_api.h
 *
 * [EOF]
 */
