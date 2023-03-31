/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_Interp_emxAPI.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 20:42:58
 */

#ifndef G_INTERP_EMXAPI_H
#define G_INTERP_EMXAPI_H

/* Include Files */
#include "g_Interp_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern g_emxArray_creal_T *g_emxCreateND_creal_T(int numDimensions,
                                                 const int *size);

extern g_emxArray_creal_T *
g_emxCreateWrapperND_creal_T(creal_T *data, int numDimensions, const int *size);

extern g_emxArray_creal_T *g_emxCreateWrapper_creal_T(creal_T *data, int rows,
                                                      int cols);

extern g_emxArray_creal_T *g_emxCreate_creal_T(int rows, int cols);

extern void g_emxDestroyArray_creal_T(g_emxArray_creal_T *emxArray);

extern void g_emxInitArray_creal_T(g_emxArray_creal_T **pEmxArray,
                                   int numDimensions);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for g_Interp_emxAPI.h
 *
 * [EOF]
 */
