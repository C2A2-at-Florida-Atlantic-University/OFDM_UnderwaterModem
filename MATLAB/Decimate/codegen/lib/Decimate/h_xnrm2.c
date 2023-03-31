/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_xnrm2.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_xnrm2.h"
#include "h_Decimate_types.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : int n
 *                const emxArray_real_T *x
 *                int ix0
 * Return Type  : double
 */
double xnrm2(int n, const emxArray_real_T *x, int ix0)
{
  const double *x_data;
  double y;
  int k;
  x_data = x->data;
  y = 0.0;
  if (n == 1) {
    y = fabs(x_data[ix0 - 1]);
  } else {
    double scale;
    int kend;
    scale = 3.3121686421112381E-170;
    kend = (ix0 + n) - 1;
    for (k = ix0; k <= kend; k++) {
      double absxk;
      absxk = fabs(x_data[k - 1]);
      if (absxk > scale) {
        double t;
        t = scale / absxk;
        y = y * t * t + 1.0;
        scale = absxk;
      } else {
        double t;
        t = absxk / scale;
        y += t * t;
      }
    }
    y = scale * sqrt(y);
  }
  return y;
}

/*
 * File trailer for h_xnrm2.c
 *
 * [EOF]
 */
