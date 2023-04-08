/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_div.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_div.h"
#include "h_Decimate_data.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Function Definitions */
/*
 * Arguments    : creal_T in1_data[]
 *                int in1_size[2]
 *                const creal_T in2_data[]
 *                const int in2_size[2]
 * Return Type  : void
 */
void rdivide(creal_T in1_data[], int in1_size[2], const creal_T in2_data[],
             const int in2_size[2])
{
  creal_T b_in1_data[2065];
  int i;
  int in1_size_idx_1;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (in2_size[1] == 1) {
    in1_size_idx_1 = in1_size[1];
  } else {
    in1_size_idx_1 = in2_size[1];
  }
  stride_0_1 = (in1_size[1] != 1);
  stride_1_1 = (in2_size[1] != 1);
  if (in2_size[1] == 1) {
    loop_ub = in1_size[1];
  } else {
    loop_ub = in2_size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    double ai;
    double ar;
    double bi;
    double br;
    int ar_tmp;
    ar_tmp = i * stride_0_1;
    ar = in1_data[ar_tmp].re;
    ai = in1_data[ar_tmp].im;
    ar_tmp = i * stride_1_1;
    br = in2_data[ar_tmp].re;
    bi = in2_data[ar_tmp].im;
    if (bi == 0.0) {
      if (ai == 0.0) {
        b_in1_data[i].re = ar / br;
        b_in1_data[i].im = 0.0;
      } else if (ar == 0.0) {
        b_in1_data[i].re = 0.0;
        b_in1_data[i].im = ai / br;
      } else {
        b_in1_data[i].re = ar / br;
        b_in1_data[i].im = ai / br;
      }
    } else if (br == 0.0) {
      if (ar == 0.0) {
        b_in1_data[i].re = ai / bi;
        b_in1_data[i].im = 0.0;
      } else if (ai == 0.0) {
        b_in1_data[i].re = 0.0;
        b_in1_data[i].im = -(ar / bi);
      } else {
        b_in1_data[i].re = ai / bi;
        b_in1_data[i].im = -(ar / bi);
      }
    } else {
      double bim;
      double brm;
      brm = fabs(br);
      bim = fabs(bi);
      if (brm > bim) {
        double s;
        s = bi / br;
        bim = br + s * bi;
        b_in1_data[i].re = (ar + s * ai) / bim;
        b_in1_data[i].im = (ai - s * ar) / bim;
      } else if (bim == brm) {
        double s;
        if (br > 0.0) {
          s = 0.5;
        } else {
          s = -0.5;
        }
        if (bi > 0.0) {
          bim = 0.5;
        } else {
          bim = -0.5;
        }
        b_in1_data[i].re = (ar * s + ai * bim) / brm;
        b_in1_data[i].im = (ai * s - ar * bim) / brm;
      } else {
        double s;
        s = br / bi;
        bim = bi + s * br;
        b_in1_data[i].re = (s * ar + ai) / bim;
        b_in1_data[i].im = (s * ai - ar) / bim;
      }
    }
  }
  in1_size[0] = 1;
  in1_size[1] = in1_size_idx_1;
  if (in1_size_idx_1 - 1 >= 0) {
    memcpy(&in1_data[0], &b_in1_data[0],
           (unsigned int)in1_size_idx_1 * sizeof(creal_T));
  }
}

/*
 * File trailer for h_div.c
 *
 * [EOF]
 */
