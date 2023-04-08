/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_filter.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_filter.h"
#include "h_Decimate_emxutil.h"
#include "h_Decimate_types.h"
#include "rt_nonfinite.h"
#include <string.h>

/* Function Definitions */
/*
 * Arguments    : const double b[1025]
 *                const emxArray_creal_T *x
 *                const creal_T zi[1024]
 *                emxArray_creal_T *y
 *                creal_T zf[1024]
 * Return Type  : void
 */
void b_filter(const double b[1025], const emxArray_creal_T *x,
              const creal_T zi[1024], emxArray_creal_T *y, creal_T zf[1024])
{
  emxArray_creal_T *b_b;
  emxArray_creal_T *b_y1;
  const creal_T *x_data;
  creal_T *y1_data;
  creal_T *y_data;
  double d;
  int i;
  int j;
  int k;
  int naxpy;
  int niccp;
  int nx;
  x_data = x->data;
  h_emxInit_creal_T(&b_b, 1);
  i = b_b->size[0];
  b_b->size[0] = x->size[1];
  h_emxEnsureCapacity_creal_T(b_b, i);
  y_data = b_b->data;
  niccp = x->size[1];
  for (i = 0; i < niccp; i++) {
    y_data[i] = x_data[i];
  }
  h_emxInit_creal_T(&b_y1, 1);
  i = b_y1->size[0];
  b_y1->size[0] = b_b->size[0];
  h_emxEnsureCapacity_creal_T(b_y1, i);
  y1_data = b_y1->data;
  nx = b_b->size[0];
  memset(&zf[0], 0, 1024U * sizeof(creal_T));
  if (b_b->size[0] < 1024) {
    niccp = b_b->size[0] - 1;
  } else {
    niccp = 1023;
  }
  for (k = 0; k <= niccp; k++) {
    y1_data[k] = zi[k];
  }
  i = niccp + 2;
  for (k = i; k <= nx; k++) {
    y1_data[k - 1].re = 0.0;
    y1_data[k - 1].im = 0.0;
  }
  if (b_b->size[0] >= 2050) {
    for (k = 0; k < 1025; k++) {
      niccp = k + 1;
      d = b[k];
      for (j = niccp; j <= nx; j++) {
        i = (j - k) - 1;
        y1_data[j - 1].re += d * y_data[i].re;
        y1_data[j - 1].im += d * y_data[i].im;
      }
    }
  } else {
    if (b_b->size[0] > 1025) {
      niccp = b_b->size[0] - 1026;
    } else {
      niccp = -1;
    }
    for (k = 0; k <= niccp; k++) {
      for (j = 0; j < 1025; j++) {
        i = k + j;
        d = b[j];
        y1_data[i].re += y_data[k].re * d;
        y1_data[i].im += y_data[k].im * d;
      }
    }
    naxpy = b_b->size[0] - niccp;
    i = niccp + 2;
    for (k = i; k <= nx; k++) {
      for (j = 0; j <= naxpy - 2; j++) {
        niccp = (k + j) - 1;
        d = b[j];
        y1_data[niccp].re += y_data[k - 1].re * d;
        y1_data[niccp].im += y_data[k - 1].im * d;
      }
      naxpy--;
    }
  }
  if (b_b->size[0] < 1024) {
    i = 1023 - b_b->size[0];
    for (k = 0; k <= i; k++) {
      zf[k] = zi[k + nx];
    }
  }
  if (b_b->size[0] >= 1025) {
    niccp = b_b->size[0] - 1024;
  } else {
    niccp = 0;
  }
  i = b_b->size[0] - 1;
  for (k = niccp; k <= i; k++) {
    int boffset_tmp;
    boffset_tmp = nx - k;
    naxpy = 1024 - boffset_tmp;
    for (j = 0; j <= naxpy; j++) {
      d = b[boffset_tmp + j];
      zf[j].re += y_data[k].re * d;
      zf[j].im += y_data[k].im * d;
    }
  }
  h_emxFree_creal_T(&b_b);
  i = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = b_y1->size[0];
  h_emxEnsureCapacity_creal_T(y, i);
  y_data = y->data;
  niccp = b_y1->size[0];
  for (i = 0; i < niccp; i++) {
    y_data[i] = y1_data[i];
  }
  h_emxFree_creal_T(&b_y1);
}

/*
 * Arguments    : const double b[1025]
 *                const creal_T x_data[]
 *                const creal_T zi[1024]
 *                emxArray_creal_T *y
 * Return Type  : void
 */
void c_filter(const double b[1025], const creal_T x_data[],
              const creal_T zi[1024], emxArray_creal_T *y)
{
  emxArray_creal_T *b_b;
  emxArray_creal_T *b_y1;
  creal_T *y1_data;
  creal_T *y_data;
  int i;
  int j;
  int k;
  h_emxInit_creal_T(&b_b, 1);
  i = b_b->size[0];
  b_b->size[0] = 2050;
  h_emxEnsureCapacity_creal_T(b_b, i);
  y_data = b_b->data;
  for (i = 0; i < 2050; i++) {
    y_data[i] = x_data[i];
  }
  h_emxInit_creal_T(&b_y1, 1);
  i = b_y1->size[0];
  b_y1->size[0] = 2050;
  h_emxEnsureCapacity_creal_T(b_y1, i);
  y1_data = b_y1->data;
  for (k = 0; k < 1024; k++) {
    y1_data[k] = zi[k];
  }
  for (k = 0; k < 1026; k++) {
    y1_data[k + 1024].re = 0.0;
    y1_data[k + 1024].im = 0.0;
  }
  for (k = 0; k < 1025; k++) {
    double d;
    int b_k;
    b_k = k + 1;
    d = b[k];
    for (j = b_k; j < 2051; j++) {
      i = (j - k) - 1;
      y1_data[j - 1].re += d * y_data[i].re;
      y1_data[j - 1].im += d * y_data[i].im;
    }
  }
  h_emxFree_creal_T(&b_b);
  i = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = 2050;
  h_emxEnsureCapacity_creal_T(y, i);
  y_data = y->data;
  for (i = 0; i < 2050; i++) {
    y_data[i] = y1_data[i];
  }
  h_emxFree_creal_T(&b_y1);
}

/*
 * Arguments    : const double b[1025]
 *                const creal_T x[1025]
 *                creal_T y[1025]
 *                creal_T zf[1024]
 * Return Type  : void
 */
void filter(const double b[1025], const creal_T x[1025], creal_T y[1025],
            creal_T zf[1024])
{
  double d;
  int j;
  int k;
  int naxpy;
  memset(&zf[0], 0, 1024U * sizeof(creal_T));
  memset(&y[0], 0, 1025U * sizeof(creal_T));
  naxpy = 1024;
  for (k = 0; k < 1025; k++) {
    for (j = 0; j <= naxpy; j++) {
      int i;
      i = k + j;
      d = b[j];
      y[i].re += x[k].re * d;
      y[i].im += x[k].im * d;
    }
    naxpy--;
  }
  for (k = 0; k < 1024; k++) {
    for (j = 0; j <= k; j++) {
      d = b[(j - k) + 1024];
      zf[j].re += x[k + 1].re * d;
      zf[j].im += x[k + 1].im * d;
    }
  }
}

/*
 * File trailer for h_filter.c
 *
 * [EOF]
 */
