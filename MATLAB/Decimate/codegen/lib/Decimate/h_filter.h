/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_filter.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

#ifndef H_FILTER_H
#define H_FILTER_H

/* Include Files */
#include "h_Decimate_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void b_filter(const double b[1025], const emxArray_creal_T *x,
              const creal_T zi[1024], emxArray_creal_T *y, creal_T zf[1024]);

void c_filter(const double b[1025], const creal_T x_data[],
              const creal_T zi[1024], emxArray_creal_T *y);

void filter(const double b[1025], const creal_T x[1025], creal_T y[1025],
            creal_T zf[1024]);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for h_filter.h
 *
 * [EOF]
 */
