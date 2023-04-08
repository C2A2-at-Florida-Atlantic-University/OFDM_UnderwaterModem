/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_fft.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_fft.h"
#include "h_FFTImplementationCallback.h"
#include "rt_nonfinite.h"
#include <string.h>

/* Function Definitions */
/*
 * Arguments    : const double x_data[]
 *                const int x_size[2]
 *                double varargin_1
 *                creal_T y_data[]
 *                int y_size[2]
 * Return Type  : void
 */
void b_fft(const double x_data[], const int x_size[2], double varargin_1,
           creal_T y_data[], int y_size[2])
{
  static creal_T b_y_data[2065];
  static creal_T yCol_data[2065];
  static double costab_data[4131];
  static double sintab_data[4131];
  static double sintabinv_data[4131];
  int N2blue;
  int nRows;
  if ((x_size[1] == 0) || ((int)varargin_1 == 0)) {
    nRows = (int)varargin_1;
    N2blue = (int)varargin_1;
    if (N2blue - 1 >= 0) {
      memset(&b_y_data[0], 0, (unsigned int)N2blue * sizeof(creal_T));
    }
  } else {
    int costab_size[2];
    int sintab_size[2];
    int sintabinv_size[2];
    bool useRadix2;
    useRadix2 = (((int)varargin_1 > 0) &&
                 (((int)varargin_1 & ((int)varargin_1 - 1)) == 0));
    c_FFTImplementationCallback_get((int)varargin_1, useRadix2, &N2blue,
                                    &nRows);
    c_FFTImplementationCallback_gen(nRows, useRadix2, costab_data, costab_size,
                                    sintab_data, sintab_size, sintabinv_data,
                                    sintabinv_size);
    if (useRadix2) {
      c_FFTImplementationCallback_r2b(x_data, x_size[1], (int)varargin_1,
                                      costab_data, costab_size, sintab_data,
                                      yCol_data, &nRows);
    } else {
      c_FFTImplementationCallback_dob(
          x_data, x_size[1], N2blue, (int)varargin_1, costab_data, costab_size,
          sintab_data, sintabinv_data, yCol_data, &nRows);
    }
    nRows = (int)varargin_1;
    N2blue = (int)varargin_1;
    if (N2blue - 1 >= 0) {
      memcpy(&b_y_data[0], &yCol_data[0],
             (unsigned int)N2blue * sizeof(creal_T));
    }
  }
  y_size[0] = 1;
  y_size[1] = nRows;
  if (nRows - 1 >= 0) {
    memcpy(&y_data[0], &b_y_data[0], (unsigned int)nRows * sizeof(creal_T));
  }
}

/*
 * Arguments    : const double x_data[]
 *                const int x_size[2]
 *                creal_T y_data[]
 *                int y_size[2]
 * Return Type  : void
 */
void fft(const double x_data[], const int x_size[2], creal_T y_data[],
         int y_size[2])
{
  static creal_T yCol_data[2065];
  static double costab_data[4131];
  static double sintab_data[4131];
  static double sintabinv_data[4131];
  int N2blue;
  int nRows;
  if (x_size[1] == 0) {
    y_size[0] = 1;
    y_size[1] = 0;
  } else {
    int costab_size[2];
    int sintab_size[2];
    int sintabinv_size[2];
    bool useRadix2;
    useRadix2 = ((x_size[1] & (x_size[1] - 1)) == 0);
    c_FFTImplementationCallback_get(x_size[1], useRadix2, &N2blue, &nRows);
    c_FFTImplementationCallback_gen(nRows, useRadix2, costab_data, costab_size,
                                    sintab_data, sintab_size, sintabinv_data,
                                    sintabinv_size);
    if (useRadix2) {
      c_FFTImplementationCallback_r2b(x_data, x_size[1], x_size[1], costab_data,
                                      costab_size, sintab_data, yCol_data,
                                      &nRows);
    } else {
      c_FFTImplementationCallback_dob(x_data, x_size[1], N2blue, x_size[1],
                                      costab_data, costab_size, sintab_data,
                                      sintabinv_data, yCol_data, &nRows);
    }
    y_size[0] = 1;
    y_size[1] = x_size[1];
    nRows = x_size[1];
    memcpy(&y_data[0], &yCol_data[0], (unsigned int)nRows * sizeof(creal_T));
  }
}

/*
 * File trailer for h_fft.c
 *
 * [EOF]
 */
