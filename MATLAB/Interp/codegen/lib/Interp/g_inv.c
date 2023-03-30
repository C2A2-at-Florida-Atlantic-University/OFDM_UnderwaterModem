/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_inv.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 14:28:10
 */

/* Include Files */
#include "g_inv.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : const double x[100]
 *                double y[100]
 * Return Type  : void
 */
void inv(const double x[100], double y[100])
{
  double b_x[100];
  double smax;
  int b_i;
  int i;
  int j;
  int jA;
  int jp1j;
  int k;
  int kAcol;
  int x_tmp;
  signed char ipiv[10];
  signed char p[10];
  for (i = 0; i < 100; i++) {
    y[i] = 0.0;
    b_x[i] = x[i];
  }
  for (i = 0; i < 10; i++) {
    ipiv[i] = (signed char)(i + 1);
  }
  for (j = 0; j < 9; j++) {
    int b_tmp;
    int mmj_tmp;
    mmj_tmp = 8 - j;
    b_tmp = j * 11;
    jp1j = b_tmp + 2;
    jA = 10 - j;
    kAcol = 0;
    smax = fabs(b_x[b_tmp]);
    for (k = 2; k <= jA; k++) {
      double s;
      s = fabs(b_x[(b_tmp + k) - 1]);
      if (s > smax) {
        kAcol = k - 1;
        smax = s;
      }
    }
    if (b_x[b_tmp + kAcol] != 0.0) {
      if (kAcol != 0) {
        jA = j + kAcol;
        ipiv[j] = (signed char)(jA + 1);
        for (k = 0; k < 10; k++) {
          kAcol = j + k * 10;
          smax = b_x[kAcol];
          x_tmp = jA + k * 10;
          b_x[kAcol] = b_x[x_tmp];
          b_x[x_tmp] = smax;
        }
      }
      i = (b_tmp - j) + 10;
      for (b_i = jp1j; b_i <= i; b_i++) {
        b_x[b_i - 1] /= b_x[b_tmp];
      }
    }
    jA = b_tmp;
    for (kAcol = 0; kAcol <= mmj_tmp; kAcol++) {
      smax = b_x[(b_tmp + kAcol * 10) + 10];
      if (smax != 0.0) {
        i = jA + 12;
        jp1j = (jA - j) + 20;
        for (x_tmp = i; x_tmp <= jp1j; x_tmp++) {
          b_x[x_tmp - 1] += b_x[((b_tmp + x_tmp) - jA) - 11] * -smax;
        }
      }
      jA += 10;
    }
  }
  for (i = 0; i < 10; i++) {
    p[i] = (signed char)(i + 1);
  }
  for (k = 0; k < 9; k++) {
    signed char i1;
    i1 = ipiv[k];
    if (i1 > k + 1) {
      jA = p[i1 - 1];
      p[i1 - 1] = p[k];
      p[k] = (signed char)jA;
    }
  }
  for (k = 0; k < 10; k++) {
    x_tmp = 10 * (p[k] - 1);
    y[k + x_tmp] = 1.0;
    for (j = k + 1; j < 11; j++) {
      i = (j + x_tmp) - 1;
      if (y[i] != 0.0) {
        jp1j = j + 1;
        for (b_i = jp1j; b_i < 11; b_i++) {
          jA = (b_i + x_tmp) - 1;
          y[jA] -= y[i] * b_x[(b_i + 10 * (j - 1)) - 1];
        }
      }
    }
  }
  for (j = 0; j < 10; j++) {
    jA = 10 * j;
    for (k = 9; k >= 0; k--) {
      kAcol = 10 * k;
      i = k + jA;
      smax = y[i];
      if (smax != 0.0) {
        y[i] = smax / b_x[k + kAcol];
        for (b_i = 0; b_i < k; b_i++) {
          x_tmp = b_i + jA;
          y[x_tmp] -= y[i] * b_x[b_i + kAcol];
        }
      }
    }
  }
}

/*
 * File trailer for g_inv.c
 *
 * [EOF]
 */
