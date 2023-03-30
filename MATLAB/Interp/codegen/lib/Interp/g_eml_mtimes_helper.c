/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_eml_mtimes_helper.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 29-Mar-2023 23:32:49
 */

/* Include Files */
#include "g_eml_mtimes_helper.h"
#include "g_Interp_emxutil.h"
#include "g_Interp_types.h"

/* Function Definitions */
/*
 * Arguments    : g_emxArray_real_T *in1
 *                const g_emxArray_real_T *in2
 *                const double in3[20]
 *                const short in4_data[]
 *                const int in4_size[2]
 *                short in5
 * Return Type  : void
 */
void binary_expand_op(g_emxArray_real_T *in1, const g_emxArray_real_T *in2,
                      const double in3[20], const short in4_data[],
                      const int in4_size[2], short in5)
{
  g_emxArray_real_T *in4;
  g_emxArray_real_T *r;
  const double *in2_data;
  double *b_in4_data;
  double *in1_data;
  int aux_0_1;
  int aux_1_1;
  int i;
  int i1;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in2_data = in2->data;
  g_emxInit_real_T(&in4, 2);
  i = in4->size[0] * in4->size[1];
  in4->size[0] = 1;
  in4->size[1] = in4_size[1];
  g_emxEnsureCapacity_real_T(in4, i);
  b_in4_data = in4->data;
  loop_ub = in4_size[1];
  for (i = 0; i < loop_ub; i++) {
    b_in4_data[i] = (double)in4_data[i] / (double)in5;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 20;
  in1->size[1] = in4->size[1];
  g_emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  loop_ub = in4->size[1];
  for (i = 0; i < loop_ub; i++) {
    for (i1 = 0; i1 < 20; i1++) {
      in1_data[i1 + 20 * i] = in3[i1] * b_in4_data[i];
    }
  }
  g_emxFree_real_T(&in4);
  g_emxInit_real_T(&r, 2);
  i = r->size[0] * r->size[1];
  r->size[0] = 20;
  if (in1->size[1] == 1) {
    r->size[1] = in2->size[1];
  } else {
    r->size[1] = in1->size[1];
  }
  g_emxEnsureCapacity_real_T(r, i);
  b_in4_data = r->data;
  stride_0_1 = (in2->size[1] != 1);
  stride_1_1 = (in1->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  if (in1->size[1] == 1) {
    loop_ub = in2->size[1];
  } else {
    loop_ub = in1->size[1];
  }
  for (i = 0; i < loop_ub; i++) {
    for (i1 = 0; i1 < 20; i1++) {
      b_in4_data[i1 + 20 * i] =
          3.1415926535897931 *
          ((in2_data[i1 + 20 * aux_0_1] + 2.2204460492503131E-16) +
           in1_data[i1 + 20 * aux_1_1]);
    }
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = 20;
  in1->size[1] = r->size[1];
  g_emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  loop_ub = r->size[1];
  for (i = 0; i < loop_ub; i++) {
    for (i1 = 0; i1 < 20; i1++) {
      stride_0_1 = i1 + 20 * i;
      in1_data[stride_0_1] = b_in4_data[stride_0_1];
    }
  }
  g_emxFree_real_T(&r);
}

/*
 * File trailer for g_eml_mtimes_helper.c
 *
 * [EOF]
 */
