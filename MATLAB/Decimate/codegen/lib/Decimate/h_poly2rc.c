/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_poly2rc.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_poly2rc.h"
#include "h_Decimate_rtwutil.h"
#include "rt_nonfinite.h"
#include <string.h>

/* Function Definitions */
/*
 * Arguments    : double in1_data[]
 *                int in4
 *                int in6
 *                int in7
 *                int in8
 *                int in9
 *                int in10
 *                double in11
 * Return Type  : void
 */
void c_binary_expand_op(double in1_data[], int in4, int in6, int in7, int in8,
                        int in9, int in10, double in11)
{
  double b_in1_data[1026];
  double in1;
  int i;
  int in1_size;
  int loop_ub;
  int stride_0_0;
  int stride_1_0;
  in1 = in1_data[in7];
  if (div_s32(in10 - in8, in9) + 1 == 1) {
    in1_size = in6 + 1;
  } else {
    in1_size = div_s32(in10 - in8, in9) + 1;
  }
  stride_0_0 = (in6 + 1 != 1);
  stride_1_0 = (div_s32(in10 - in8, in9) + 1 != 1);
  if (div_s32(in10 - in8, in9) + 1 == 1) {
    loop_ub = in6 + 1;
  } else {
    loop_ub = div_s32(in10 - in8, in9) + 1;
  }
  for (i = 0; i < loop_ub; i++) {
    b_in1_data[i] =
        (in1_data[(short)(in4 - 1) + i * stride_0_0] -
         in1 * in1_data[((short)(in4 - 1) + in8) + in9 * (i * stride_1_0)]) /
        (1.0 - in11);
  }
  in1_data[0] = 1.0;
  if (in1_size - 1 >= 0) {
    memcpy(&in1_data[1], &b_in1_data[0],
           (unsigned int)in1_size * sizeof(double));
  }
}

/*
 * File trailer for h_poly2rc.c
 *
 * [EOF]
 */
