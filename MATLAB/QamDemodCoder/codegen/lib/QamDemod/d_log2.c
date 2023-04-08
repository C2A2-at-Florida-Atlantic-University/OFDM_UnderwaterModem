/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: d_log2.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 15-Mar-2023 18:38:51
 */

/* Include Files */
#include "d_log2.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : float x
 * Return Type  : float
 */
float d_b_log2(float x)
{
  float f;
  int eint;
  if (x == 0.0F) {
    f = rtMinusInfF;
  } else if (x < 0.0F) {
    f = rtNaNF;
  } else if ((!rtIsInfF(x)) && (!rtIsNaNF(x))) {
    float t;
    t = frexpf(x, &eint);
    if (t == 0.5F) {
      f = (float)eint - 1.0F;
    } else if ((eint == 1) && (t < 0.75F)) {
      f = logf(2.0F * t) / 0.693147182F;
    } else {
      f = logf(t) / 0.693147182F + (float)eint;
    }
  } else {
    f = x;
  }
  return f;
}

/*
 * File trailer for d_log2.c
 *
 * [EOF]
 */
