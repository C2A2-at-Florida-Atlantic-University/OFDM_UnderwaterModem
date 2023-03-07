/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: log2.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 12:23:52
 */

/* Include Files */
#include "log2.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : real_T x
 * Return Type  : real_T
 */
real_T b_log2(real_T x)
{
  real_T f;
  int32_T eint;
  if (x == 0.0) {
    f = rtMinusInf;
  } else if (x < 0.0) {
    f = rtNaN;
  } else {
    real_T t;
    t = frexp(x, &eint);
    if (t == 0.5) {
      f = (real_T)eint - 1.0;
    } else if ((eint == 1) && (t < 0.75)) {
      f = log(2.0 * t) / 0.69314718055994529;
    } else {
      f = log(t) / 0.69314718055994529 + (real_T)eint;
    }
  }
  return f;
}

/*
 * File trailer for log2.c
 *
 * [EOF]
 */
