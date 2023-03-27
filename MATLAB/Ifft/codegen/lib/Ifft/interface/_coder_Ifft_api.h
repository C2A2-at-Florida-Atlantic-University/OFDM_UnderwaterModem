/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_Ifft_api.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 27-Mar-2023 17:38:08
 */

#ifndef _CODER_IFFT_API_H
#define _CODER_IFFT_API_H

/* Include Files */
#include "emlrt.h"
#include "tmwtypes.h"
#include <string.h>

/* Type Definitions */
#ifndef typedef_emxArray_creal_T
#define typedef_emxArray_creal_T
typedef struct {
  creal_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
} emxArray_creal_T;
#endif /* typedef_emxArray_creal_T */

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void Ifft(cint16_T x_data[], int32_T x_size[1], uint16_T nfft,
          emxArray_creal_T *y);

void Ifft_api(const mxArray *const prhs[2], const mxArray **plhs);

void Ifft_atexit(void);

void Ifft_initialize(void);

void Ifft_terminate(void);

void Ifft_xil_shutdown(void);

void Ifft_xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_Ifft_api.h
 *
 * [EOF]
 */
