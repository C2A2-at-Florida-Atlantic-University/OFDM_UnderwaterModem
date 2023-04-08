/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_FFTImplementationCallback.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

#ifndef H_FFTIMPLEMENTATIONCALLBACK_H
#define H_FFTIMPLEMENTATIONCALLBACK_H

/* Include Files */
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
void c_FFTImplementationCallback_dob(const double x_data[], int x_size,
                                     int n2blue, int nfft,
                                     const double costab_data[],
                                     const int costab_size[2],
                                     const double sintab_data[],
                                     const double sintabinv_data[],
                                     creal_T y_data[], int *y_size);

void c_FFTImplementationCallback_gen(int nRows, bool useRadix2,
                                     double costab_data[], int costab_size[2],
                                     double sintab_data[], int sintab_size[2],
                                     double sintabinv_data[],
                                     int sintabinv_size[2]);

void c_FFTImplementationCallback_get(int nfft, bool useRadix2, int *n2blue,
                                     int *nRows);

void c_FFTImplementationCallback_r2b(const double x_data[], int x_size,
                                     int n1_unsigned,
                                     const double costab_data[],
                                     const int costab_size[2],
                                     const double sintab_data[],
                                     creal_T y_data[], int *y_size);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for h_FFTImplementationCallback.h
 *
 * [EOF]
 */
