/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: c_Ifft_emxAPI.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 27-Mar-2023 19:38:35
 */

#ifndef C_IFFT_EMXAPI_H
#define C_IFFT_EMXAPI_H

/* Include Files */
#include "c_Ifft_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern emxArray_creal_T *emxCreateND_creal_T(int numDimensions,
                                             const int *size);

extern emxArray_creal_T *
emxCreateWrapperND_creal_T(creal_T *data, int numDimensions, const int *size);

extern emxArray_creal_T *emxCreateWrapper_creal_T(creal_T *data, int rows,
                                                  int cols);

extern emxArray_creal_T *emxCreate_creal_T(int rows, int cols);

extern void emxDestroyArray_creal_T(emxArray_creal_T *emxArray);

extern void emxInitArray_creal_T(emxArray_creal_T **pEmxArray,
                                 int numDimensions);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for c_Ifft_emxAPI.h
 *
 * [EOF]
 */
