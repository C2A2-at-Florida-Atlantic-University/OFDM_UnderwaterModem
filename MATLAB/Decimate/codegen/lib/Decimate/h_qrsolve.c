/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_qrsolve.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_qrsolve.h"
#include "h_Decimate_emxutil.h"
#include "h_Decimate_types.h"
#include "h_xzgeqp3.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Function Declarations */
static void LSQFromQR(const emxArray_real_T *A, const double tau_data[],
                      const int jpvt_data[], double B_data[], int rankA,
                      double Y_data[], int *Y_size);

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *A
 *                const double tau_data[]
 *                const int jpvt_data[]
 *                double B_data[]
 *                int rankA
 *                double Y_data[]
 *                int *Y_size
 * Return Type  : void
 */
static void LSQFromQR(const emxArray_real_T *A, const double tau_data[],
                      const int jpvt_data[], double B_data[], int rankA,
                      double Y_data[], int *Y_size)
{
  const double *A_data;
  int b_i;
  int i;
  int j;
  int loop_ub;
  A_data = A->data;
  *Y_size = A->size[1];
  loop_ub = A->size[1];
  if (loop_ub - 1 >= 0) {
    memset(&Y_data[0], 0, (unsigned int)loop_ub * sizeof(double));
  }
  i = A->size[1];
  for (j = 0; j < i; j++) {
    if (tau_data[j] != 0.0) {
      double wj;
      wj = B_data[j];
      loop_ub = j + 2;
      for (b_i = loop_ub; b_i < 514; b_i++) {
        wj += A_data[(b_i + 513 * j) - 1] * B_data[b_i - 1];
      }
      wj *= tau_data[j];
      if (wj != 0.0) {
        B_data[j] -= wj;
        for (b_i = loop_ub; b_i < 514; b_i++) {
          B_data[b_i - 1] -= A_data[(b_i + 513 * j) - 1] * wj;
        }
      }
    }
  }
  i = (unsigned short)rankA;
  for (b_i = 0; b_i < i; b_i++) {
    Y_data[jpvt_data[b_i] - 1] = B_data[b_i];
  }
  for (j = rankA; j >= 1; j--) {
    i = jpvt_data[j - 1];
    loop_ub = 513 * (j - 1);
    Y_data[i - 1] /= A_data[(j + loop_ub) - 1];
    i = (unsigned short)(j - 1);
    for (b_i = 0; b_i < i; b_i++) {
      Y_data[jpvt_data[b_i] - 1] -=
          Y_data[jpvt_data[j - 1] - 1] * A_data[b_i + loop_ub];
    }
  }
}

/*
 * Arguments    : const emxArray_real_T *A
 *                const double B_data[]
 *                double Y_data[]
 *                int *Y_size
 * Return Type  : void
 */
void qrsolve(const emxArray_real_T *A, const double B_data[], double Y_data[],
             int *Y_size)
{
  emxArray_real_T *b_A;
  double b_B_data[513];
  double tau_data[512];
  const double *A_data;
  double *b_A_data;
  int jpvt_data[512];
  int n;
  int rankA;
  A_data = A->data;
  h_emxInit_real_T(&b_A);
  n = b_A->size[0] * b_A->size[1];
  b_A->size[0] = 513;
  b_A->size[1] = A->size[1];
  h_emxEnsureCapacity_real_T(b_A, n);
  b_A_data = b_A->data;
  rankA = 513 * A->size[1];
  for (n = 0; n < rankA; n++) {
    b_A_data[n] = A_data[n];
  }
  n = A->size[1] - 1;
  rankA = A->size[1];
  if (rankA - 1 >= 0) {
    memset(&tau_data[0], 0, (unsigned int)rankA * sizeof(double));
  }
  if (A->size[1] == 0) {
    for (rankA = 0; rankA <= n; rankA++) {
      jpvt_data[rankA] = rankA + 1;
    }
  } else {
    rankA = A->size[1];
    memset(&jpvt_data[0], 0, (unsigned int)rankA * sizeof(int));
    for (rankA = 0; rankA <= n; rankA++) {
      jpvt_data[rankA] = rankA + 1;
    }
    qrpf(b_A, A->size[1], tau_data, jpvt_data);
    b_A_data = b_A->data;
  }
  rankA = 0;
  if (b_A->size[1] > 0) {
    double tol;
    tol = 1.1390888232654106E-12 * fabs(b_A_data[0]);
    while ((rankA < b_A->size[1]) &&
           (!(fabs(b_A_data[rankA + 513 * rankA]) <= tol))) {
      rankA++;
    }
  }
  memcpy(&b_B_data[0], &B_data[0], 513U * sizeof(double));
  LSQFromQR(b_A, tau_data, jpvt_data, b_B_data, rankA, Y_data, Y_size);
  h_emxFree_real_T(&b_A);
}

/*
 * File trailer for h_qrsolve.c
 *
 * [EOF]
 */
