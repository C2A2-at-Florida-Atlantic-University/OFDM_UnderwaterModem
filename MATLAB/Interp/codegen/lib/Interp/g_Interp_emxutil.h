/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_Interp_emxutil.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 20:42:58
 */

#ifndef G_INTERP_EMXUTIL_H
#define G_INTERP_EMXUTIL_H

/* Include Files */
#include "g_Interp_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void g_emxEnsureCapacity_creal_T(g_emxArray_creal_T *emxArray,
                                        int oldNumel);

extern void g_emxEnsureCapacity_real_T(g_emxArray_real_T *emxArray,
                                       int oldNumel);

extern void g_emxFree_creal_T(g_emxArray_creal_T **pEmxArray);

extern void g_emxFree_real_T(g_emxArray_real_T **pEmxArray);

extern void g_emxInit_creal_T(g_emxArray_creal_T **pEmxArray,
                              int numDimensions);

extern void g_emxInit_real_T(g_emxArray_real_T **pEmxArray, int numDimensions);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for g_Interp_emxutil.h
 *
 * [EOF]
 */
