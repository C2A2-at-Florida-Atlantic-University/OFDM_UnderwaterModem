/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_grpdelay.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_grpdelay.h"
#include "h_Decimate_data.h"
#include "h_Decimate_rtwutil.h"
#include "h_div.h"
#include "h_fft.h"
#include "h_find.h"
#include "h_islinphase.h"
#include "h_minOrMax.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Function Declarations */
static void b_binary_expand_op(double in1[8], const creal_T in2_data[], int in3,
                               int in4, const int in5_size[2]);

/* Function Definitions */
/*
 * Arguments    : double in1[8]
 *                const creal_T in2_data[]
 *                int in3
 *                int in4
 *                const int in5_size[2]
 * Return Type  : void
 */
static void b_binary_expand_op(double in1[8], const creal_T in2_data[], int in3,
                               int in4, const int in5_size[2])
{
  int i;
  int stride_0_0;
  stride_0_0 = (div_s32(in4 - 1, in3) + 1 != 1);
  for (i = 0; i < 8; i++) {
    in1[i] = in2_data[in3 * (i * stride_0_0)].re - ((double)in5_size[1] - 1.0);
  }
}

/*
 * Arguments    : const double b[1025]
 *                double gd_out[8]
 * Return Type  : void
 */
void grpdelay(const double b[1025], double gd_out[8])
{
  static creal_T den_data[2065];
  static creal_T gd1_data[2065];
  static creal_T tmp_data[2064];
  static double b_cr_data[2065];
  static double c_data[2050];
  static const signed char iv[1025] = {
      1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  double cr_data[2050];
  double a_data[1025];
  double b_data[1025];
  double G;
  int a_size[2];
  int b_size[2];
  int cr_size[2];
  int den_size[2];
  int gd1_size[2];
  int tmp_size[2];
  int varargin_1_size[2];
  int b_ii_data;
  int c_tmp;
  int idx;
  int k;
  int n;
  int nApnB;
  int nB;
  short ii_data;
  bool exitg1;
  idx = 0;
  nB = 1025;
  exitg1 = false;
  while ((!exitg1) && (nB > 0)) {
    if (b[nB - 1] != 0.0) {
      idx = 1;
      ii_data = (short)nB;
      exitg1 = true;
    } else {
      nB--;
    }
  }
  if (idx == 0) {
    n = 1;
  } else {
    n = ii_data;
  }
  a_size[0] = 1;
  a_size[1] = n;
  b_size[0] = 1;
  b_size[1] = n;
  for (k = 0; k < n; k++) {
    a_data[k] = iv[k];
    b_data[k] = b[k];
  }
  idx = n - 1;
  nB = n - 1;
  nApnB = (n + n) - 1;
  memset(&c_data[0], 0, (unsigned int)nApnB * sizeof(double));
  for (k = 0; k <= nB; k++) {
    for (b_ii_data = 0; b_ii_data <= idx; b_ii_data++) {
      c_tmp = k + b_ii_data;
      c_data[c_tmp] += a_data[(n - k) - 1] * b[b_ii_data];
    }
  }
  cr_size[0] = 1;
  cr_size[1] = nApnB;
  for (k = 0; k < nApnB; k++) {
    cr_data[k] = c_data[k] * (double)k;
  }
  if (nApnB <= 16) {
    tmp_size[0] = 1;
    tmp_size[1] = 16;
    memcpy(&b_cr_data[0], &cr_data[0], (unsigned int)nApnB * sizeof(double));
    idx = 16 - nApnB;
    if (idx - 1 >= 0) {
      memset(&b_cr_data[nApnB], 0,
             (unsigned int)((idx + nApnB) - nApnB) * sizeof(double));
    }
    fft(b_cr_data, tmp_size, gd1_data, gd1_size);
    tmp_size[0] = 1;
    tmp_size[1] = 16;
    memcpy(&b_cr_data[0], &c_data[0], (unsigned int)nApnB * sizeof(double));
    if (idx - 1 >= 0) {
      memset(&b_cr_data[nApnB], 0,
             (unsigned int)((idx + nApnB) - nApnB) * sizeof(double));
    }
    fft(b_cr_data, tmp_size, den_data, den_size);
    if (gd1_size[1] == den_size[1]) {
      c_tmp = gd1_size[1] - 1;
      for (k = 0; k <= c_tmp; k++) {
        double ai;
        double ar;
        double bi;
        double br;
        double re;
        ar = gd1_data[k].re;
        ai = gd1_data[k].im;
        br = den_data[k].re;
        bi = den_data[k].im;
        if (bi == 0.0) {
          if (ai == 0.0) {
            re = ar / br;
            G = 0.0;
          } else if (ar == 0.0) {
            re = 0.0;
            G = ai / br;
          } else {
            re = ar / br;
            G = ai / br;
          }
        } else if (br == 0.0) {
          if (ar == 0.0) {
            re = ai / bi;
            G = 0.0;
          } else if (ai == 0.0) {
            re = 0.0;
            G = -(ar / bi);
          } else {
            re = ai / bi;
            G = -(ar / bi);
          }
        } else {
          double brm;
          brm = fabs(br);
          G = fabs(bi);
          if (brm > G) {
            double s;
            s = bi / br;
            G = br + s * bi;
            re = (ar + s * ai) / G;
            G = (ai - s * ar) / G;
          } else if (G == brm) {
            double s;
            if (br > 0.0) {
              s = 0.5;
            } else {
              s = -0.5;
            }
            if (bi > 0.0) {
              G = 0.5;
            } else {
              G = -0.5;
            }
            re = (ar * s + ai * G) / brm;
            G = (ai * s - ar * G) / brm;
          } else {
            double s;
            s = br / bi;
            G = bi + s * br;
            re = (s * ar + ai) / G;
            G = (s * ai - ar) / G;
          }
        }
        gd1_data[k].re = re;
        gd1_data[k].im = G;
      }
    } else {
      rdivide(gd1_data, gd1_size, den_data, den_size);
    }
    for (k = 0; k < 8; k++) {
      gd_out[k] = gd1_data[k].re - ((double)n - 1.0);
    }
  } else {
    idx = (int)ceil((double)nApnB / 16.0) << 1;
    nB = idx << 3;
    b_fft(cr_data, cr_size, nB, tmp_data, tmp_size);
    gd1_size[0] = 1;
    gd1_size[1] = tmp_size[1];
    c_tmp = tmp_size[1];
    if (c_tmp - 1 >= 0) {
      memcpy(&gd1_data[0], &tmp_data[0], (unsigned int)c_tmp * sizeof(creal_T));
    }
    cr_size[0] = 1;
    cr_size[1] = nApnB;
    memcpy(&cr_data[0], &c_data[0], (unsigned int)nApnB * sizeof(double));
    b_fft(cr_data, cr_size, nB, tmp_data, tmp_size);
    den_size[0] = 1;
    den_size[1] = tmp_size[1];
    c_tmp = tmp_size[1];
    if (c_tmp - 1 >= 0) {
      memcpy(&den_data[0], &tmp_data[0], (unsigned int)c_tmp * sizeof(creal_T));
    }
    if (gd1_size[1] == tmp_size[1]) {
      c_tmp = gd1_size[1] - 1;
      for (k = 0; k <= c_tmp; k++) {
        double ai;
        double ar;
        double bi;
        double br;
        double re;
        ar = gd1_data[k].re;
        ai = gd1_data[k].im;
        br = den_data[k].re;
        bi = den_data[k].im;
        if (bi == 0.0) {
          if (ai == 0.0) {
            re = ar / br;
            G = 0.0;
          } else if (ar == 0.0) {
            re = 0.0;
            G = ai / br;
          } else {
            re = ar / br;
            G = ai / br;
          }
        } else if (br == 0.0) {
          if (ar == 0.0) {
            re = ai / bi;
            G = 0.0;
          } else if (ai == 0.0) {
            re = 0.0;
            G = -(ar / bi);
          } else {
            re = ai / bi;
            G = -(ar / bi);
          }
        } else {
          double brm;
          brm = fabs(br);
          G = fabs(bi);
          if (brm > G) {
            double s;
            s = bi / br;
            G = br + s * bi;
            re = (ar + s * ai) / G;
            G = (ai - s * ar) / G;
          } else if (G == brm) {
            double s;
            if (br > 0.0) {
              s = 0.5;
            } else {
              s = -0.5;
            }
            if (bi > 0.0) {
              G = 0.5;
            } else {
              G = -0.5;
            }
            re = (ar * s + ai * G) / brm;
            G = (ai * s - ar * G) / brm;
          } else {
            double s;
            s = br / bi;
            G = bi + s * br;
            re = (s * ar + ai) / G;
            G = (s * ai - ar) / G;
          }
        }
        gd1_data[k].re = re;
        gd1_data[k].im = G;
      }
    } else {
      rdivide(gd1_data, gd1_size, den_data, den_size);
    }
    if (div_s32(nB - 1, idx) + 1 == 8) {
      for (k = 0; k < 8; k++) {
        gd_out[k] = gd1_data[idx * k].re - ((double)n - 1.0);
      }
    } else {
      b_binary_expand_op(gd_out, gd1_data, idx, nB, a_size);
    }
  }
  if (islinphase(b_data, b_size, a_data, a_size)) {
    double varargin_1_data[1026];
    int startidx_size_idx_1;
    eml_find(b_data, b_size, (int *)&b_ii_data, tmp_size);
    startidx_size_idx_1 = tmp_size[1];
    c_tmp = tmp_size[1];
    for (k = 0; k < c_tmp; k++) {
      nApnB = b_ii_data;
    }
    nB = n;
    idx = 0;
    tmp_size[1] = 1;
    exitg1 = false;
    while ((!exitg1) && (nB > 0)) {
      if (b[nB - 1] != 0.0) {
        idx = 1;
        b_ii_data = nB;
        exitg1 = true;
      } else {
        nB--;
      }
    }
    if (idx == 0) {
      tmp_size[1] = 0;
    }
    c_tmp = tmp_size[1];
    for (k = 0; k < c_tmp; k++) {
      ii_data = (short)b_ii_data;
    }
    varargin_1_size[0] = 1;
    varargin_1_size[1] = n;
    for (k = 0; k < n; k++) {
      varargin_1_data[k] = fabs(b[k]);
    }
    if (maximum(varargin_1_data, varargin_1_size) == 0.0) {
      ii_data = 1;
    } else {
      if (nApnB > ii_data) {
        k = 1;
        idx = 0;
      } else {
        k = nApnB;
        idx = ii_data;
      }
      ii_data = (short)((idx - k) + 1);
    }
    if (startidx_size_idx_1 == 0) {
      idx = 0;
    } else {
      idx = (int)fmax((double)nApnB - 1.0, 0.0);
    }
    G = (double)idx + ((double)ii_data - 1.0) / 2.0;
    for (idx = 0; idx < 8; idx++) {
      gd_out[idx] = G;
    }
  }
}

/*
 * File trailer for h_grpdelay.c
 *
 * [EOF]
 */
