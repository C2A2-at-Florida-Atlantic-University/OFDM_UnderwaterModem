/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_filter.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 29-Mar-2023 23:32:49
 */

#ifndef G_FILTER_H
#define G_FILTER_H

/* Include Files */
#include "g_Interp_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void b_filter(const g_emxArray_real_T *b, const g_emxArray_creal_T *x,
              const g_emxArray_creal_T *zi, g_emxArray_creal_T *y,
              g_emxArray_creal_T *zf);

void c_filter(const g_emxArray_real_T *b, const g_emxArray_creal_T *x,
              const g_emxArray_creal_T *zi, g_emxArray_creal_T *y);

void filter(const g_emxArray_real_T *b, const g_emxArray_creal_T *x,
            g_emxArray_creal_T *y, g_emxArray_creal_T *zf);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for g_filter.h
 *
 * [EOF]
 */
