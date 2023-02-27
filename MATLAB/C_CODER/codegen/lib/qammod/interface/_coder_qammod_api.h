/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_qammod_api.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 10:54:48
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
creal_T qammod(int8_T x, int8_T M);

void qammod_api(const mxArray *const prhs[2], const mxArray **plhs);

void qammod_atexit(void);

void qammod_initialize(void);

void qammod_terminate(void);

void qammod_xil_shutdown(void);

void qammod_xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_qammod_api.h
 *
 * [EOF]
 */
