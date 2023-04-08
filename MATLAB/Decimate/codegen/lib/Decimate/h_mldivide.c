/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_mldivide.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_mldivide.h"
#include "h_Decimate_types.h"
#include "h_lusolve.h"
#include "h_qrsolve.h"
#include "rt_nonfinite.h"
#include <string.h>

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *A
 *                const double B_data[]
 *                double Y_data[]
 *                int *Y_size
 * Return Type  : void
 */
void mldivide(const emxArray_real_T *A, const double B_data[], double Y_data[],
              int *Y_size)
{
  if (A->size[1] == 0) {
    *Y_size = 0;
  } else if (A->size[1] == 513) {
    *Y_size = 513;
    memcpy(&Y_data[0], &B_data[0], 513U * sizeof(double));
    lusolve(A, Y_data);
  } else {
    qrsolve(A, B_data, Y_data, Y_size);
  }
}

/*
 * File trailer for h_mldivide.c
 *
 * [EOF]
 */
