/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: log2.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 10:54:48
 */

/* Include Files */
#include "log2.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : double x
 * Return Type  : double
 */
double b_log2(double x)
{
  double f;
  int eint;
  if (x == 0.0) {
    f = rtMinusInf;
  } else if (x < 0.0) {
    f = rtNaN;
  } else {
    double t;
    t = frexp(x, &eint);
    if (t == 0.5) {
      f = (double)eint - 1.0;
    } else if ((eint == 1) && (t < 0.75)) {
      f = log(2.0 * t) / 0.69314718055994529;
    } else {
      f = log(t) / 0.69314718055994529 + (double)eint;
    }
  }
  return f;
}

/*
 * File trailer for log2.c
 *
 * [EOF]
 */
