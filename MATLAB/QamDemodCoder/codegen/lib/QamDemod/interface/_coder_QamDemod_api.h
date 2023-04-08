/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_QamDemod_api.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 15-Mar-2023 18:38:51
 */

#ifndef _CODER_QAMDEMOD_API_H
#define _CODER_QAMDEMOD_API_H

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
real32_T QamDemod(creal32_T x, real32_T M);

void QamDemod_api(const mxArray *const prhs[2], const mxArray **plhs);

void QamDemod_atexit(void);

void QamDemod_initialize(void);

void QamDemod_terminate(void);

void QamDemod_xil_shutdown(void);

void QamDemod_xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_QamDemod_api.h
 *
 * [EOF]
 */
