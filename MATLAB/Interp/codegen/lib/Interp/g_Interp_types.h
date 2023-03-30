/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_Interp_types.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 14:28:10
 */

#ifndef G_INTERP_TYPES_H
#define G_INTERP_TYPES_H

/* Include Files */
#include "rtwtypes.h"

/* Type Definitions */
#ifndef typedef_g_emxArray_creal_T
#define typedef_g_emxArray_creal_T
typedef struct {
  creal_T *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  bool canFreeData;
} g_emxArray_creal_T;
#endif /* typedef_g_emxArray_creal_T */

#ifndef struct_g_emxArray_real_T
#define struct_g_emxArray_real_T
struct g_emxArray_real_T {
  double *data;
  int *size;
  int allocatedSize;
  int numDimensions;
  bool canFreeData;
};
#endif /* struct_g_emxArray_real_T */
#ifndef typedef_g_emxArray_real_T
#define typedef_g_emxArray_real_T
typedef struct g_emxArray_real_T g_emxArray_real_T;
#endif /* typedef_g_emxArray_real_T */

#endif
/*
 * File trailer for g_Interp_types.h
 *
 * [EOF]
 */
