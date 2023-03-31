/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_Decimate_emxutil.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

#ifndef H_DECIMATE_EMXUTIL_H
#define H_DECIMATE_EMXUTIL_H

/* Include Files */
#include "h_Decimate_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void h_emxEnsureCapacity_creal_T(emxArray_creal_T *emxArray,
                                        int oldNumel);

extern void h_emxEnsureCapacity_real_T(emxArray_real_T *emxArray, int oldNumel);

extern void h_emxFree_creal_T(emxArray_creal_T **pEmxArray);

extern void h_emxFree_real_T(emxArray_real_T **pEmxArray);

extern void h_emxInit_creal_T(emxArray_creal_T **pEmxArray, int numDimensions);

extern void h_emxInit_real_T(emxArray_real_T **pEmxArray);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for h_Decimate_emxutil.h
 *
 * [EOF]
 */
