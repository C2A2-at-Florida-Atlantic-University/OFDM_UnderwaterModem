/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_fft.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

#ifndef H_FFT_H
#define H_FFT_H

/* Include Files */
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void b_fft(const double x_data[], const int x_size[2], double varargin_1,
           creal_T y_data[], int y_size[2]);

void fft(const double x_data[], const int x_size[2], creal_T y_data[],
         int y_size[2]);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for h_fft.h
 *
 * [EOF]
 */
