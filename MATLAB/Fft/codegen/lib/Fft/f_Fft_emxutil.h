/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: f_Fft_emxutil.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 27-Mar-2023 19:38:11
 */

#ifndef F_FFT_EMXUTIL_H
#define F_FFT_EMXUTIL_H

/* Include Files */
#include "f_Fft_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void f_emxEnsureCapacity_creal_T(emxArray_creal_T *emxArray,
                                        int oldNumel);

extern void f_emxEnsureCapacity_real_T(emxArray_real_T *emxArray, int oldNumel);

extern void f_emxFree_creal_T(emxArray_creal_T **pEmxArray);

extern void f_emxFree_real_T(emxArray_real_T **pEmxArray);

extern void f_emxInit_creal_T(emxArray_creal_T **pEmxArray, int numDimensions);

extern void f_emxInit_real_T(emxArray_real_T **pEmxArray);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for f_Fft_emxutil.h
 *
 * [EOF]
 */
