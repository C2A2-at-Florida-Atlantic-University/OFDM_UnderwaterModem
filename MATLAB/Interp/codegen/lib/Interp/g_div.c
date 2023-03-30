/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_div.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 14:28:10
 */

/* Include Files */
#include "g_div.h"
#include "g_Interp_emxutil.h"
#include "g_Interp_types.h"

/* Function Definitions */
/*
 * Arguments    : g_emxArray_real_T *in1
 *                const g_emxArray_real_T *in2
 * Return Type  : void
 */
void rdivide(g_emxArray_real_T *in1, const g_emxArray_real_T *in2)
{
  g_emxArray_real_T *b_in1;
  const double *in2_data;
  double *b_in1_data;
  double *in1_data;
  int aux_0_1;
  int aux_1_1;
  int i;
  int i1;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in2_data = in2->data;
  in1_data = in1->data;
  g_emxInit_real_T(&b_in1, 2);
  i = b_in1->size[0] * b_in1->size[1];
  b_in1->size[0] = 20;
  if (in2->size[1] == 1) {
    b_in1->size[1] = in1->size[1];
  } else {
    b_in1->size[1] = in2->size[1];
  }
  g_emxEnsureCapacity_real_T(b_in1, i);
  b_in1_data = b_in1->data;
  stride_0_1 = (in1->size[1] != 1);
  stride_1_1 = (in2->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  if (in2->size[1] == 1) {
    loop_ub = in1->size[1];
  } else {
    loop_ub = in2->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    for (i1 = 0; i1 < 20; i1++) {
      b_in1_data[i1 + 20 * i] =
          in1_data[i1 + 20 * aux_0_1] / in2_data[i1 + 20 * aux_1_1];
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 20;
  in1->size[1] = b_in1->size[1];
  g_emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    for (i1 = 0; i1 < 20; i1++) {
      stride_0_1 = i1 + 20 * i;
      in1_data[stride_0_1] = b_in1_data[stride_0_1];
    }
  }
  g_emxFree_real_T(&b_in1);
}

/*
 * File trailer for g_div.c
 *
 * [EOF]
 */
