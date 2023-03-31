/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_firls.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_firls.h"
#include "h_Decimate_emxutil.h"
#include "h_Decimate_types.h"
#include "h_mldivide.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Function Declarations */
static void binary_expand_op(emxArray_real_T *in1, double in2,
                             const emxArray_real_T *in3,
                             const emxArray_real_T *in4, double in5,
                             const emxArray_real_T *in6,
                             const emxArray_real_T *in7);

static void initMatrices(const double m_data[], emxArray_real_T *I1,
                         emxArray_real_T *I2, emxArray_real_T *G);

/* Function Definitions */
/*
 * Arguments    : emxArray_real_T *in1
 *                double in2
 *                const emxArray_real_T *in3
 *                const emxArray_real_T *in4
 *                double in5
 *                const emxArray_real_T *in6
 *                const emxArray_real_T *in7
 * Return Type  : void
 */
static void binary_expand_op(emxArray_real_T *in1, double in2,
                             const emxArray_real_T *in3,
                             const emxArray_real_T *in4, double in5,
                             const emxArray_real_T *in6,
                             const emxArray_real_T *in7)
{
  emxArray_real_T *b_in1;
  const double *in3_data;
  const double *in4_data;
  const double *in6_data;
  const double *in7_data;
  double *b_in1_data;
  double *in1_data;
  int aux_0_1;
  int aux_1_1;
  int aux_2_1;
  int aux_3_1;
  int aux_4_1;
  int b_loop_ub;
  int i;
  int i1;
  int loop_ub;
  int stride_0_0;
  int stride_0_1;
  int stride_1_0;
  int stride_1_1;
  int stride_2_0;
  int stride_2_1;
  int stride_3_0;
  int stride_3_1;
  int stride_4_0;
  int stride_4_1;
  in7_data = in7->data;
  in6_data = in6->data;
  in4_data = in4->data;
  in3_data = in3->data;
  in1_data = in1->data;
  h_emxInit_real_T(&b_in1);
  i = b_in1->size[0] * b_in1->size[1];
  if (in7->size[0] == 1) {
    i1 = in6->size[0];
  } else {
    i1 = in7->size[0];
  }
  if (i1 == 1) {
    if (in4->size[0] == 1) {
      i1 = in3->size[0];
    } else {
      i1 = in4->size[0];
    }
  } else if (in7->size[0] == 1) {
    i1 = in6->size[0];
  } else {
    i1 = in7->size[0];
  }
  if (i1 == 1) {
    b_in1->size[0] = in1->size[0];
  } else {
    if (in7->size[0] == 1) {
      i1 = in6->size[0];
    } else {
      i1 = in7->size[0];
    }
    if (i1 == 1) {
      if (in4->size[0] == 1) {
        b_in1->size[0] = in3->size[0];
      } else {
        b_in1->size[0] = in4->size[0];
      }
    } else if (in7->size[0] == 1) {
      b_in1->size[0] = in6->size[0];
    } else {
      b_in1->size[0] = in7->size[0];
    }
  }
  if (in7->size[1] == 1) {
    i1 = in6->size[1];
  } else {
    i1 = in7->size[1];
  }
  if (i1 == 1) {
    if (in4->size[1] == 1) {
      i1 = in3->size[1];
    } else {
      i1 = in4->size[1];
    }
  } else if (in7->size[1] == 1) {
    i1 = in6->size[1];
  } else {
    i1 = in7->size[1];
  }
  if (i1 == 1) {
    b_in1->size[1] = in1->size[1];
  } else {
    if (in7->size[1] == 1) {
      i1 = in6->size[1];
    } else {
      i1 = in7->size[1];
    }
    if (i1 == 1) {
      if (in4->size[1] == 1) {
        b_in1->size[1] = in3->size[1];
      } else {
        b_in1->size[1] = in4->size[1];
      }
    } else if (in7->size[1] == 1) {
      b_in1->size[1] = in6->size[1];
    } else {
      b_in1->size[1] = in7->size[1];
    }
  }
  h_emxEnsureCapacity_real_T(b_in1, i);
  b_in1_data = b_in1->data;
  stride_0_0 = (in1->size[0] != 1);
  stride_0_1 = (in1->size[1] != 1);
  stride_1_0 = (in3->size[0] != 1);
  stride_1_1 = (in3->size[1] != 1);
  stride_2_0 = (in4->size[0] != 1);
  stride_2_1 = (in4->size[1] != 1);
  stride_3_0 = (in6->size[0] != 1);
  stride_3_1 = (in6->size[1] != 1);
  stride_4_0 = (in7->size[0] != 1);
  stride_4_1 = (in7->size[1] != 1);
  aux_0_1 = 0;
  aux_1_1 = 0;
  aux_2_1 = 0;
  aux_3_1 = 0;
  aux_4_1 = 0;
  if (in7->size[1] == 1) {
    i = in6->size[1];
  } else {
    i = in7->size[1];
  }
  if (i == 1) {
    if (in4->size[1] == 1) {
      i = in3->size[1];
    } else {
      i = in4->size[1];
    }
  } else if (in7->size[1] == 1) {
    i = in6->size[1];
  } else {
    i = in7->size[1];
  }
  if (i == 1) {
    loop_ub = in1->size[1];
  } else {
    if (in7->size[1] == 1) {
      i = in6->size[1];
    } else {
      i = in7->size[1];
    }
    if (i == 1) {
      if (in4->size[1] == 1) {
        loop_ub = in3->size[1];
      } else {
        loop_ub = in4->size[1];
      }
    } else if (in7->size[1] == 1) {
      loop_ub = in6->size[1];
    } else {
      loop_ub = in7->size[1];
    }
  }
  for (i = 0; i < loop_ub; i++) {
    int i2;
    int i3;
    int i4;
    i1 = in7->size[0];
    b_loop_ub = in6->size[0];
    i2 = in4->size[0];
    i3 = in3->size[0];
    if (i1 == 1) {
      i4 = b_loop_ub;
    } else {
      i4 = i1;
    }
    if (i4 == 1) {
      if (i2 == 1) {
        i4 = i3;
      } else {
        i4 = i2;
      }
    } else if (i1 == 1) {
      i4 = b_loop_ub;
    } else {
      i4 = i1;
    }
    if (i4 == 1) {
      b_loop_ub = in1->size[0];
    } else {
      if (i1 == 1) {
        i4 = b_loop_ub;
      } else {
        i4 = i1;
      }
      if (i4 == 1) {
        if (i2 == 1) {
          b_loop_ub = i3;
        } else {
          b_loop_ub = i2;
        }
      } else if (i1 != 1) {
        b_loop_ub = i1;
      }
    }
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      b_in1_data[i1 + b_in1->size[0] * i] =
          in1_data[i1 * stride_0_0 + in1->size[0] * aux_0_1] +
          (in2 * (in3_data[i1 * stride_1_0 + in3->size[0] * aux_1_1] +
                  in4_data[i1 * stride_2_0 + in4->size[0] * aux_2_1]) -
           in5 * (in6_data[i1 * stride_3_0 + in6->size[0] * aux_3_1] +
                  in7_data[i1 * stride_4_0 + in7->size[0] * aux_4_1]));
    }
    aux_4_1 += stride_4_1;
    aux_3_1 += stride_3_1;
    aux_2_1 += stride_2_1;
    aux_1_1 += stride_1_1;
    aux_0_1 += stride_0_1;
  }
  i = in1->size[0] * in1->size[1];
  in1->size[0] = b_in1->size[0];
  in1->size[1] = b_in1->size[1];
  h_emxEnsureCapacity_real_T(in1, i);
  in1_data = in1->data;
  loop_ub = b_in1->size[1];
  for (i = 0; i < loop_ub; i++) {
    b_loop_ub = b_in1->size[0];
    for (i1 = 0; i1 < b_loop_ub; i1++) {
      in1_data[i1 + in1->size[0] * i] = b_in1_data[i1 + b_in1->size[0] * i];
    }
  }
  h_emxFree_real_T(&b_in1);
}

/*
 * Arguments    : const double m_data[]
 *                emxArray_real_T *I1
 *                emxArray_real_T *I2
 *                emxArray_real_T *G
 * Return Type  : void
 */
static void initMatrices(const double m_data[], emxArray_real_T *I1,
                         emxArray_real_T *I2, emxArray_real_T *G)
{
  double *I1_data;
  double *I2_data;
  int i;
  int i1;
  i = I1->size[0] * I1->size[1];
  I1->size[0] = 513;
  I1->size[1] = 513;
  h_emxEnsureCapacity_real_T(I1, i);
  I1_data = I1->data;
  i = I2->size[0] * I2->size[1];
  I2->size[0] = 513;
  I2->size[1] = 513;
  h_emxEnsureCapacity_real_T(I2, i);
  I2_data = I2->data;
  for (i = 0; i < 513; i++) {
    for (i1 = 0; i1 < 513; i1++) {
      int i2;
      i2 = i1 + 513 * i;
      I1_data[i2] = m_data[i1] + m_data[i];
      I2_data[i2] = m_data[i1] - m_data[i];
    }
  }
  i = G->size[0] * G->size[1];
  G->size[0] = 513;
  G->size[1] = 513;
  h_emxEnsureCapacity_real_T(G, i);
  I1_data = G->data;
  for (i = 0; i < 263169; i++) {
    I1_data[i] = 0.0;
  }
}

/*
 * Arguments    : const double varargin_2[4]
 *                double h_data[]
 *                int h_size[2]
 * Return Type  : void
 */
void firls(const double varargin_2[4], double h_data[], int h_size[2])
{
  static const signed char A[4] = {1, 1, 0, 0};
  emxArray_real_T *G;
  emxArray_real_T *I1;
  emxArray_real_T *I2;
  emxArray_real_T *b_y_tmp;
  emxArray_real_T *r;
  emxArray_real_T *r1;
  emxArray_real_T *y_tmp;
  double b_data[513];
  double k_data[513];
  double *G_data;
  double *I1_data;
  double *I2_data;
  double *b_y_tmp_data;
  double *r2;
  double *r3;
  double *y_tmp_data;
  int i;
  int k;
  int s;
  h_emxInit_real_T(&I1);
  I1_data = I1->data;
  h_emxInit_real_T(&I2);
  I2_data = I2->data;
  h_emxInit_real_T(&G);
  G_data = G->data;
  h_emxInit_real_T(&r);
  h_emxInit_real_T(&r1);
  h_emxInit_real_T(&y_tmp);
  h_emxInit_real_T(&b_y_tmp);
  if ((!(varargin_2[0] > 1.0)) && (!(varargin_2[0] < 0.0))) {
    double max_freq[4];
    double b0;
    bool need_matrix;
    max_freq[0] = varargin_2[0] / 2.0;
    max_freq[1] = varargin_2[1] / 2.0;
    max_freq[2] = varargin_2[2] / 2.0;
    max_freq[3] = varargin_2[3] / 2.0;
    need_matrix = (max_freq[2] - max_freq[1] != 0.0);
    if (need_matrix) {
      for (i = 0; i < 513; i++) {
        k_data[i] = i;
      }
      initMatrices(k_data, I1, I2, G);
      G_data = G->data;
      I2_data = I2->data;
      I1_data = I1->data;
    } else {
      I1->size[0] = 0;
      I1->size[1] = 0;
      I2->size[0] = 0;
      I2->size[1] = 0;
      G->size[0] = 0;
      G->size[1] = 0;
    }
    b0 = 0.0;
    for (i = 0; i < 512; i++) {
      k_data[i] = (double)i + 1.0;
      b_data[i] = 0.0;
    }
    for (s = 0; s < 2; s++) {
      double a;
      double b1;
      double b1_tmp;
      double b_a;
      double d;
      double m_s;
      double m_s_tmp;
      double m_s_tmp_tmp;
      int b_s;
      signed char i1;
      b_s = s << 1;
      m_s_tmp_tmp = max_freq[b_s + 1];
      d = max_freq[b_s];
      m_s_tmp = m_s_tmp_tmp - d;
      i1 = A[b_s];
      m_s = (double)(A[b_s + 1] - i1) / m_s_tmp;
      b1_tmp = m_s * d;
      b1 = (double)i1 - b1_tmp;
      b0 += b1 * m_s_tmp + m_s / 2.0 * (m_s_tmp_tmp * m_s_tmp_tmp - d * d);
      a = m_s / 39.478417604357432;
      b_a = m_s_tmp_tmp * (m_s * m_s_tmp_tmp + b1);
      m_s_tmp = d * (b1_tmp + b1);
      for (k = 0; k < 512; k++) {
        i = (int)k_data[k];
        m_s = 6.2831853071795862 * (double)i;
        b1_tmp = b_data[k] +
                 a * (cos(m_s * m_s_tmp_tmp) - cos(m_s * d)) / (double)(i * i);
        m_s = 2.0 * (double)i;
        b1 = m_s * m_s_tmp_tmp;
        if (fabs(b1) < 1.0020841800044864E-292) {
          b1 = 1.0;
        } else {
          b1 *= 3.1415926535897931;
          b1 = sin(b1) / b1;
        }
        m_s *= d;
        if (fabs(m_s) < 1.0020841800044864E-292) {
          m_s = 1.0;
        } else {
          m_s *= 3.1415926535897931;
          m_s = sin(m_s) / m_s;
        }
        b1_tmp += b_a * b1 - m_s_tmp * m_s;
        b_data[k] = b1_tmp;
      }
      if (need_matrix) {
        int i2;
        int i3;
        int i4;
        i = y_tmp->size[0] * y_tmp->size[1];
        y_tmp->size[0] = I1->size[0];
        y_tmp->size[1] = I1->size[1];
        h_emxEnsureCapacity_real_T(y_tmp, i);
        y_tmp_data = y_tmp->data;
        k = I1->size[0] * I1->size[1];
        for (i = 0; i < k; i++) {
          y_tmp_data[i] = 2.0 * I1_data[i];
        }
        i = r->size[0] * r->size[1];
        r->size[0] = y_tmp->size[0];
        r->size[1] = y_tmp->size[1];
        h_emxEnsureCapacity_real_T(r, i);
        r2 = r->data;
        k = y_tmp->size[0] * y_tmp->size[1];
        for (i = 0; i < k; i++) {
          r2[i] = y_tmp_data[i] * m_s_tmp_tmp;
        }
        i = r->size[0] * r->size[1];
        for (k = 0; k < i; k++) {
          if (fabs(r2[k]) < 1.0020841800044864E-292) {
            r2[k] = 1.0;
          } else {
            r2[k] *= 3.1415926535897931;
            r2[k] = sin(r2[k]) / r2[k];
          }
        }
        i = b_y_tmp->size[0] * b_y_tmp->size[1];
        b_y_tmp->size[0] = I2->size[0];
        b_y_tmp->size[1] = I2->size[1];
        h_emxEnsureCapacity_real_T(b_y_tmp, i);
        b_y_tmp_data = b_y_tmp->data;
        k = I2->size[0] * I2->size[1];
        for (i = 0; i < k; i++) {
          b_y_tmp_data[i] = 2.0 * I2_data[i];
        }
        i = r1->size[0] * r1->size[1];
        r1->size[0] = b_y_tmp->size[0];
        r1->size[1] = b_y_tmp->size[1];
        h_emxEnsureCapacity_real_T(r1, i);
        r3 = r1->data;
        k = b_y_tmp->size[0] * b_y_tmp->size[1];
        for (i = 0; i < k; i++) {
          r3[i] = b_y_tmp_data[i] * m_s_tmp_tmp;
        }
        i = r1->size[0] * r1->size[1];
        for (k = 0; k < i; k++) {
          if (fabs(r3[k]) < 1.0020841800044864E-292) {
            r3[k] = 1.0;
          } else {
            r3[k] *= 3.1415926535897931;
            r3[k] = sin(r3[k]) / r3[k];
          }
        }
        k = y_tmp->size[0] * y_tmp->size[1];
        for (i = 0; i < k; i++) {
          y_tmp_data[i] *= max_freq[b_s];
        }
        i = y_tmp->size[0] * y_tmp->size[1];
        for (k = 0; k < i; k++) {
          if (fabs(y_tmp_data[k]) < 1.0020841800044864E-292) {
            y_tmp_data[k] = 1.0;
          } else {
            y_tmp_data[k] *= 3.1415926535897931;
            y_tmp_data[k] = sin(y_tmp_data[k]) / y_tmp_data[k];
          }
        }
        k = b_y_tmp->size[0] * b_y_tmp->size[1];
        for (i = 0; i < k; i++) {
          b_y_tmp_data[i] *= max_freq[b_s];
        }
        i = b_y_tmp->size[0] * b_y_tmp->size[1];
        for (k = 0; k < i; k++) {
          if (fabs(b_y_tmp_data[k]) < 1.0020841800044864E-292) {
            b_y_tmp_data[k] = 1.0;
          } else {
            b_y_tmp_data[k] *= 3.1415926535897931;
            b_y_tmp_data[k] = sin(b_y_tmp_data[k]) / b_y_tmp_data[k];
          }
        }
        a = 0.5 * m_s_tmp_tmp;
        b_a = 0.5 * max_freq[b_s];
        if (r->size[0] == 1) {
          i = r1->size[0];
        } else {
          i = r->size[0];
        }
        if (y_tmp->size[0] == 1) {
          b_s = b_y_tmp->size[0];
        } else {
          b_s = y_tmp->size[0];
        }
        if (r->size[1] == 1) {
          k = r1->size[1];
        } else {
          k = r->size[1];
        }
        if (y_tmp->size[1] == 1) {
          i2 = b_y_tmp->size[1];
        } else {
          i2 = y_tmp->size[1];
        }
        if (r->size[0] == 1) {
          i3 = r1->size[0];
        } else {
          i3 = r->size[0];
        }
        if (i3 == 1) {
          if (y_tmp->size[0] == 1) {
            i3 = b_y_tmp->size[0];
          } else {
            i3 = y_tmp->size[0];
          }
        } else if (r->size[0] == 1) {
          i3 = r1->size[0];
        } else {
          i3 = r->size[0];
        }
        if (r->size[1] == 1) {
          i4 = r1->size[1];
        } else {
          i4 = r->size[1];
        }
        if (i4 == 1) {
          if (y_tmp->size[1] == 1) {
            i4 = b_y_tmp->size[1];
          } else {
            i4 = y_tmp->size[1];
          }
        } else if (r->size[1] == 1) {
          i4 = r1->size[1];
        } else {
          i4 = r->size[1];
        }
        if ((r->size[0] == r1->size[0]) && (r->size[1] == r1->size[1]) &&
            (y_tmp->size[0] == b_y_tmp->size[0]) &&
            (y_tmp->size[1] == b_y_tmp->size[1]) && (i == b_s) && (k == i2) &&
            (G->size[0] == i3) && (G->size[1] == i4)) {
          k = G->size[0] * G->size[1];
          for (i = 0; i < k; i++) {
            G_data[i] +=
                a * (r2[i] + r3[i]) - b_a * (y_tmp_data[i] + b_y_tmp_data[i]);
          }
        } else {
          binary_expand_op(G, a, r, r1, b_a, y_tmp, b_y_tmp);
          G_data = G->data;
        }
      }
    }
    k_data[0] = b0;
    memcpy(&k_data[1], &b_data[0], 512U * sizeof(double));
    memcpy(&b_data[0], &k_data[0], 513U * sizeof(double));
    if (need_matrix) {
      mldivide(G, b_data, k_data, &k);
    } else {
      for (i = 0; i < 513; i++) {
        k_data[i] = 4.0 * b_data[i];
      }
      k_data[0] /= 2.0;
    }
    h_size[0] = 1;
    h_size[1] = 1025;
    h_data[512] = k_data[0];
    for (i = 0; i < 512; i++) {
      h_data[i] = k_data[512 - i] / 2.0;
      h_data[i + 513] = k_data[i + 1] / 2.0;
    }
  }
  h_emxFree_real_T(&b_y_tmp);
  h_emxFree_real_T(&y_tmp);
  h_emxFree_real_T(&r1);
  h_emxFree_real_T(&r);
  h_emxFree_real_T(&G);
  h_emxFree_real_T(&I2);
  h_emxFree_real_T(&I1);
}

/*
 * File trailer for h_firls.c
 *
 * [EOF]
 */
