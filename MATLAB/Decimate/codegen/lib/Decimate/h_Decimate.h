/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_Decimate.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

#ifndef H_DECIMATE_H
#define H_DECIMATE_H

/* Include Files */
#include "h_Decimate_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void Decimate(const emxArray_creal_T *x, double Factor,
                     emxArray_creal_T *y);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for h_Decimate.h
 *
 * [EOF]
 */
