/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_Decimate_mex.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

#ifndef _CODER_DECIMATE_MEX_H
#define _CODER_DECIMATE_MEX_H

/* Include Files */
#include "emlrt.h"
#include "mex.h"
#include "tmwtypes.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
MEXFUNCTION_LINKAGE void mexFunction(int32_T nlhs, mxArray *plhs[],
                                     int32_T nrhs, const mxArray *prhs[]);

emlrtCTX mexFunctionCreateRootTLS(void);

void unsafe_Decimate_mexFunction(int32_T nlhs, mxArray *plhs[1], int32_T nrhs,
                                 const mxArray *prhs[2]);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_Decimate_mex.h
 *
 * [EOF]
 */
