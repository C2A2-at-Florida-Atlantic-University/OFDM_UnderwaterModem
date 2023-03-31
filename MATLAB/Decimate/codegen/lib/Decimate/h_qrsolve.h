/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_qrsolve.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

#ifndef H_QRSOLVE_H
#define H_QRSOLVE_H

/* Include Files */
#include "h_Decimate_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void qrsolve(const emxArray_real_T *A, const double B_data[], double Y_data[],
             int *Y_size);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for h_qrsolve.h
 *
 * [EOF]
 */
