/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_lusolve.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_lusolve.h"
#include "h_Decimate_emxutil.h"
#include "h_Decimate_types.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *A
 *                double B_data[]
 * Return Type  : void
 */
void lusolve(const emxArray_real_T *A, double B_data[])
{
  emxArray_real_T *b_A;
  const double *A_data;
  double smax;
  double *b_A_data;
  int a;
  int b_k;
  int i;
  int jA;
  int jp1j;
  int k;
  int yk;
  short ipiv_data[513];
  A_data = A->data;
  h_emxInit_real_T(&b_A);
  i = b_A->size[0] * b_A->size[1];
  b_A->size[0] = 513;
  b_A->size[1] = 513;
  h_emxEnsureCapacity_real_T(b_A, i);
  b_A_data = b_A->data;
  for (i = 0; i < 263169; i++) {
    b_A_data[i] = A_data[i];
  }
  ipiv_data[0] = 1;
  yk = 1;
  for (k = 0; k < 512; k++) {
    int b_tmp;
    int mmj_tmp;
    short i1;
    yk++;
    ipiv_data[k + 1] = (short)yk;
    mmj_tmp = 511 - k;
    b_tmp = k * 514;
    jp1j = b_tmp + 2;
    jA = 513 - k;
    a = 0;
    smax = fabs(b_A_data[b_tmp]);
    for (b_k = 2; b_k <= jA; b_k++) {
      double s;
      s = fabs(b_A_data[(b_tmp + b_k) - 1]);
      if (s > smax) {
        a = b_k - 1;
        smax = s;
      }
    }
    if (b_A_data[b_tmp + a] != 0.0) {
      if (a != 0) {
        jA = k + a;
        ipiv_data[k] = (short)(jA + 1);
        for (b_k = 0; b_k < 513; b_k++) {
          a = k + b_k * 513;
          smax = b_A_data[a];
          i = jA + b_k * 513;
          b_A_data[a] = b_A_data[i];
          b_A_data[i] = smax;
        }
      }
      i = (b_tmp - k) + 513;
      for (a = jp1j; a <= i; a++) {
        b_A_data[a - 1] /= b_A_data[b_tmp];
      }
    }
    jA = b_tmp;
    for (jp1j = 0; jp1j <= mmj_tmp; jp1j++) {
      smax = b_A_data[(b_tmp + jp1j * 513) + 513];
      if (smax != 0.0) {
        i = jA + 515;
        a = (jA - k) + 1026;
        for (b_k = i; b_k <= a; b_k++) {
          b_A_data[b_k - 1] += b_A_data[((b_tmp + b_k) - jA) - 514] * -smax;
        }
      }
      jA += 513;
    }
    i1 = ipiv_data[k];
    if (i1 != k + 1) {
      smax = B_data[k];
      B_data[k] = B_data[i1 - 1];
      B_data[i1 - 1] = smax;
    }
  }
  for (k = 0; k < 513; k++) {
    jA = 513 * k;
    if (B_data[k] != 0.0) {
      i = k + 2;
      for (a = i; a < 514; a++) {
        B_data[a - 1] -= B_data[k] * b_A_data[(a + jA) - 1];
      }
    }
  }
  for (k = 512; k >= 0; k--) {
    jA = 513 * k;
    smax = B_data[k];
    if (smax != 0.0) {
      smax /= b_A_data[k + jA];
      B_data[k] = smax;
      for (a = 0; a < k; a++) {
        B_data[a] -= B_data[k] * b_A_data[a + jA];
      }
    }
  }
  h_emxFree_real_T(&b_A);
}

/*
 * File trailer for h_lusolve.c
 *
 * [EOF]
 */
