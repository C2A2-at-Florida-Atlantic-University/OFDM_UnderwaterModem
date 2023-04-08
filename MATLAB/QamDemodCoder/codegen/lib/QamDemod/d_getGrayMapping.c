/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: d_getGrayMapping.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 15-Mar-2023 18:38:51
 */

/* Include Files */
#include "d_getGrayMapping.h"
#include "d_QamDemod_emxutil.h"
#include "d_QamDemod_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : emxArray_int32_T *in1
 *                const emxArray_int32_T *in2
 * Return Type  : void
 */
void plus(emxArray_int32_T *in1, const emxArray_int32_T *in2)
{
  emxArray_int32_T *b_in1;
  const int *in2_data;
  int i;
  int loop_ub;
  int stride_0_0;
  int stride_1_0;
  int *b_in1_data;
  int *in1_data;
  in2_data = in2->data;
  in1_data = in1->data;
  emxInit_int32_T(&b_in1);
  i = b_in1->size[0];
  if (in2->size[0] == 1) {
    b_in1->size[0] = in1->size[0];
  } else {
    b_in1->size[0] = in2->size[0];
  }
  emxEnsureCapacity_int32_T(b_in1, i);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_1_0 = (in2->size[0] != 1);
  if (in2->size[0] == 1) {
    loop_ub = in1->size[0];
  } else {
    loop_ub = in2->size[0];
  }
  for (i = 0; i < loop_ub; i++) {
    int q0;
    int q1;
    q0 = in1_data[i * stride_0_0];
    q1 = in2_data[i * stride_1_0];
    if ((q0 < 0) && (q1 < MIN_int32_T - q0)) {
      q0 = MIN_int32_T;
    } else if ((q0 > 0) && (q1 > MAX_int32_T - q0)) {
      q0 = MAX_int32_T;
    } else {
      q0 += q1;
    }
    b_in1_data[i] = q0;
  }
  i = in1->size[0];
  in1->size[0] = b_in1->size[0];
  emxEnsureCapacity_int32_T(in1, i);
  in1_data = in1->data;
  loop_ub = b_in1->size[0];
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] = b_in1_data[i];
  }
  emxFree_int32_T(&b_in1);
}

/*
 * File trailer for d_getGrayMapping.c
 *
 * [EOF]
 */
