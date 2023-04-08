/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_islinphase.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_islinphase.h"
#include "h_Decimate_rtwutil.h"
#include "h_find.h"
#include "h_minOrMax.h"
#include "h_poly2rc.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Function Declarations */
static void d_binary_expand_op(double in1_data[], int in1_size[2],
                               const double in2_data[], const int in2_size[2],
                               int in3, int in4, int in5);

static bool determineiflinphase(const double b_data[], const int b_size[2]);

static void e_binary_expand_op(double in1_data[], int in1_size[2],
                               const double in2_data[], const int in2_size[2],
                               int in3, int in4, int in5);

/* Function Definitions */
/*
 * Arguments    : double in1_data[]
 *                int in1_size[2]
 *                const double in2_data[]
 *                const int in2_size[2]
 *                int in3
 *                int in4
 *                int in5
 * Return Type  : void
 */
static void d_binary_expand_op(double in1_data[], int in1_size[2],
                               const double in2_data[], const int in2_size[2],
                               int in3, int in4, int in5)
{
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in1_size[0] = 1;
  if (div_s32(in5 - in3, in4) + 1 == 1) {
    in1_size[1] = in2_size[1];
  } else {
    in1_size[1] = div_s32(in5 - in3, in4) + 1;
  }
  stride_0_1 = (in2_size[1] != 1);
  stride_1_1 = (div_s32(in5 - in3, in4) + 1 != 1);
  if (div_s32(in5 - in3, in4) + 1 == 1) {
    loop_ub = in2_size[1];
  } else {
    loop_ub = div_s32(in5 - in3, in4) + 1;
  }
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] =
        in2_data[i * stride_0_1] + in2_data[in3 + in4 * (i * stride_1_1)];
  }
}

/*
 * Arguments    : const double b_data[]
 *                const int b_size[2]
 * Return Type  : bool
 */
static bool determineiflinphase(const double b_data[], const int b_size[2])
{
  static const char cv1[128] = {
      '\x00', '\x01', '\x02', '\x03', '\x04', '\x05', '\x06', '\x07', '\x08',
      '\x09', '\x0a', '\x0b', '\x0c', '\x0d', '\x0e', '\x0f', '\x10', '\x11',
      '\x12', '\x13', '\x14', '\x15', '\x16', '\x17', '\x18', '\x19', '\x1a',
      '\x1b', '\x1c', '\x1d', '\x1e', '\x1f', ' ',    '!',    '\"',   '#',
      '$',    '%',    '&',    '\'',   '(',    ')',    '*',    '+',    ',',
      '-',    '.',    '/',    '0',    '1',    '2',    '3',    '4',    '5',
      '6',    '7',    '8',    '9',    ':',    ';',    '<',    '=',    '>',
      '?',    '@',    'a',    'b',    'c',    'd',    'e',    'f',    'g',
      'h',    'i',    'j',    'k',    'l',    'm',    'n',    'o',    'p',
      'q',    'r',    's',    't',    'u',    'v',    'w',    'x',    'y',
      'z',    '[',    '\\',   ']',    '^',    '_',    '`',    'a',    'b',
      'c',    'd',    'e',    'f',    'g',    'h',    'i',    'j',    'k',
      'l',    'm',    'n',    'o',    'p',    'q',    'r',    's',    't',
      'u',    'v',    'w',    'x',    'y',    'z',    '{',    '|',    '}',
      '~',    '\x7f'};
  static const char cv3[13] = {'a', 'n', 't', 'i', 's', 'y', 'm',
                               'm', 'e', 't', 'r', 'i', 'c'};
  static const char cv[9] = {'s', 'y', 'm', 'm', 'e', 't', 'r', 'i', 'c'};
  static const char cv2[4] = {'n', 'o', 'n', 'e'};
  double x_data[1026];
  double bIn_data[1025];
  int bIn_size[2];
  int varargin_1_size[2];
  int x_size[2];
  int i;
  int idx;
  int ii_data;
  int k;
  bool islinphaseflag;
  if (b_size[1] == 1) {
    islinphaseflag = true;
  } else {
    double varargin_1_data[1026];
    int loop_ub;
    char symstr_data[13];
    bool b_bool;
    i = b_size[1];
    varargin_1_size[0] = 1;
    varargin_1_size[1] = b_size[1];
    for (k = 0; k < i; k++) {
      varargin_1_data[k] = fabs(b_data[k]);
    }
    if (maximum(varargin_1_data, varargin_1_size) == 0.0) {
      bIn_size[0] = 1;
      bIn_size[1] = 1;
      bIn_data[0] = 0.0;
    } else {
      int ii_size[2];
      int startidx_data;
      short stopidx_data;
      bool exitg1;
      bIn_size[0] = 1;
      bIn_size[1] = b_size[1];
      loop_ub = b_size[1];
      if (loop_ub - 1 >= 0) {
        memcpy(&bIn_data[0], &b_data[0],
               (unsigned int)loop_ub * sizeof(double));
      }
      eml_find(bIn_data, bIn_size, (int *)&ii_data, ii_size);
      loop_ub = ii_size[1];
      for (i = 0; i < loop_ub; i++) {
        startidx_data = ii_data;
      }
      k = b_size[1];
      idx = 0;
      ii_size[1] = 1;
      exitg1 = false;
      while ((!exitg1) && (k > 0)) {
        if (b_data[k - 1] != 0.0) {
          idx = 1;
          ii_data = k;
          exitg1 = true;
        } else {
          k--;
        }
      }
      if (idx == 0) {
        ii_size[1] = 0;
      }
      loop_ub = ii_size[1];
      for (i = 0; i < loop_ub; i++) {
        stopidx_data = (short)ii_data;
      }
      if (startidx_data > stopidx_data) {
        i = 0;
        k = 0;
      } else {
        i = startidx_data - 1;
        k = stopidx_data;
      }
      bIn_size[0] = 1;
      loop_ub = k - i;
      bIn_size[1] = loop_ub;
      for (k = 0; k < loop_ub; k++) {
        bIn_data[k] = b_data[i + k];
      }
    }
    if (bIn_size[1] < 1) {
      i = 0;
      k = 1;
      idx = -1;
    } else {
      i = bIn_size[1] - 1;
      k = -1;
      idx = 0;
    }
    if (bIn_size[1] == div_s32(idx - i, k) + 1) {
      x_size[0] = 1;
      x_size[1] = bIn_size[1];
      loop_ub = bIn_size[1];
      for (idx = 0; idx < loop_ub; idx++) {
        x_data[idx] = bIn_data[idx] - bIn_data[i + k * idx];
      }
    } else {
      e_binary_expand_op(x_data, x_size, bIn_data, bIn_size, i, k, idx);
    }
    i = x_size[1];
    varargin_1_size[0] = 1;
    varargin_1_size[1] = x_size[1];
    for (k = 0; k < i; k++) {
      varargin_1_data[k] = fabs(x_data[k]);
    }
    if (maximum(varargin_1_data, varargin_1_size) <= 0.0) {
      k = 9;
      for (i = 0; i < 9; i++) {
        symstr_data[i] = cv[i];
      }
    } else {
      if (bIn_size[1] < 1) {
        i = 0;
        k = 1;
        idx = -1;
      } else {
        i = bIn_size[1] - 1;
        k = -1;
        idx = 0;
      }
      if (bIn_size[1] == div_s32(idx - i, k) + 1) {
        x_size[1] = bIn_size[1];
        loop_ub = bIn_size[1];
        for (idx = 0; idx < loop_ub; idx++) {
          x_data[idx] = bIn_data[idx] + bIn_data[i + k * idx];
        }
      } else {
        d_binary_expand_op(x_data, x_size, bIn_data, bIn_size, i, k, idx);
      }
      i = x_size[1];
      varargin_1_size[0] = 1;
      varargin_1_size[1] = x_size[1];
      for (k = 0; k < i; k++) {
        varargin_1_data[k] = fabs(x_data[k]);
      }
      if (maximum(varargin_1_data, varargin_1_size) <= 0.0) {
        k = 13;
        for (i = 0; i < 13; i++) {
          symstr_data[i] = cv3[i];
        }
      } else {
        k = 4;
        symstr_data[0] = 'n';
        symstr_data[1] = 'o';
        symstr_data[2] = 'n';
        symstr_data[3] = 'e';
      }
    }
    b_bool = false;
    if (k == 4) {
      k = 0;
      int exitg2;
      do {
        exitg2 = 0;
        if (k < 4) {
          if (cv1[(int)symstr_data[k]] != cv1[(int)cv2[k]]) {
            exitg2 = 1;
          } else {
            k++;
          }
        } else {
          b_bool = true;
          exitg2 = 1;
        }
      } while (exitg2 == 0);
    }
    islinphaseflag = !b_bool;
  }
  return islinphaseflag;
}

/*
 * Arguments    : double in1_data[]
 *                int in1_size[2]
 *                const double in2_data[]
 *                const int in2_size[2]
 *                int in3
 *                int in4
 *                int in5
 * Return Type  : void
 */
static void e_binary_expand_op(double in1_data[], int in1_size[2],
                               const double in2_data[], const int in2_size[2],
                               int in3, int in4, int in5)
{
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  in1_size[0] = 1;
  if (div_s32(in5 - in3, in4) + 1 == 1) {
    in1_size[1] = in2_size[1];
  } else {
    in1_size[1] = div_s32(in5 - in3, in4) + 1;
  }
  stride_0_1 = (in2_size[1] != 1);
  stride_1_1 = (div_s32(in5 - in3, in4) + 1 != 1);
  if (div_s32(in5 - in3, in4) + 1 == 1) {
    loop_ub = in2_size[1];
  } else {
    loop_ub = div_s32(in5 - in3, in4) + 1;
  }
  for (i = 0; i < loop_ub; i++) {
    in1_data[i] =
        in2_data[i * stride_0_1] - in2_data[in3 + in4 * (i * stride_1_1)];
  }
}

/*
 * Arguments    : const double b_data[]
 *                const int b_size[2]
 *                const double a_data[]
 *                const int a_size[2]
 * Return Type  : bool
 */
bool islinphase(const double b_data[], const int b_size[2],
                const double a_data[], const int a_size[2])
{
  double a2_data[1025];
  double temp_a1_data[1025];
  double k_data[1024];
  double tmp_data[1024];
  int b_i;
  int c_i;
  int i;
  int i1;
  int idxNonZero;
  int k;
  int n;
  bool errLevdown_data[1024];
  bool exitg1;
  bool firflag;
  bool islinphaseflag;
  n = a_size[1];
  idxNonZero = 0;
  i = 0;
  exitg1 = false;
  while ((!exitg1) && (i <= n - 1)) {
    b_i = n - i;
    if (a_data[b_i - 1] != 0.0) {
      idxNonZero = b_i;
      exitg1 = true;
    } else {
      i++;
    }
  }
  if (idxNonZero > 1) {
    n = 0;
    c_i = a_size[1];
    for (k = 0; k < c_i; k++) {
      if (a_data[k] != 0.0) {
        n++;
      }
    }
    firflag = (n == 1);
  } else {
    firflag = true;
  }
  if (firflag) {
    islinphaseflag = determineiflinphase(b_data, b_size);
  } else {
    double a;
    int loop_ub;
    i = 0;
    while ((i < a_size[1]) && (a_data[(a_size[1] - i) - 1] == 0.0)) {
      i++;
    }
    c_i = a_size[1] - i;
    if (c_i < 1) {
      c_i = 0;
    }
    for (idxNonZero = 0; a_data[idxNonZero] == 0.0; idxNonZero++) {
    }
    if (idxNonZero + 1 > c_i) {
      idxNonZero = 0;
      c_i = 0;
    }
    a = a_data[idxNonZero];
    loop_ub = c_i - idxNonZero;
    for (c_i = 0; c_i < loop_ub; c_i++) {
      a2_data[c_i] = a_data[idxNonZero + c_i] / a;
    }
    if (loop_ub == 1) {
      firflag = true;
    } else if (loop_ub == 2) {
      firflag = (fabs(a2_data[1]) < 1.0);
    } else {
      firflag = true;
      a = fabs(a2_data[loop_ub - 1]);
      if (a >= 1.0) {
        firflag = false;
      } else {
        int k_size_idx_0;
        int k_size_idx_1;
        bool errFlag;
        errFlag = false;
        if (loop_ub <= 1) {
          k_size_idx_0 = 0;
          k_size_idx_1 = 0;
        } else {
          bool y;
          errFlag = (a2_data[0] == 0.0);
          a = a2_data[0];
          for (c_i = 0; c_i < loop_ub; c_i++) {
            temp_a1_data[c_i] = a2_data[c_i] / a;
          }
          idxNonZero = loop_ub - 1;
          k_size_idx_0 = loop_ub - 1;
          k_size_idx_1 = 1;
          memset(&k_data[0], 0, (unsigned int)idxNonZero * sizeof(double));
          k_data[loop_ub - 2] = temp_a1_data[loop_ub - 1];
          memcpy(&a2_data[0], &temp_a1_data[0],
                 (unsigned int)loop_ub * sizeof(double));
          memset(&errLevdown_data[0], 0,
                 (unsigned int)(loop_ub - 1) * sizeof(bool));
          for (k = 0; k <= loop_ub - 3; k++) {
            double absknxt2;
            int i2;
            int i3;
            b_i = (loop_ub - k) - 3;
            errLevdown_data[b_i] = false;
            c_i = loop_ub - k;
            if (c_i < 2) {
              n = 0;
              i1 = -1;
            } else {
              n = 1;
              i1 = c_i - 1;
            }
            if (a2_data[i1] == 1.0) {
              errLevdown_data[b_i] = true;
            }
            a = fabs(a2_data[i1]);
            absknxt2 = a * a;
            if (i1 - n < 1) {
              i = -1;
            } else {
              i = (i1 - n) - 1;
            }
            i2 = i1 - n;
            if (i2 < 1) {
              i2 = 0;
              i3 = 1;
              idxNonZero = -1;
            } else {
              i2--;
              i3 = -1;
              idxNonZero = 0;
            }
            if (i + 1 == div_s32(idxNonZero - i2, i3) + 1) {
              a = a2_data[i1];
              idxNonZero = i + 2;
              tmp_data[0] = 1.0;
              for (i1 = 0; i1 <= i; i1++) {
                tmp_data[i1 + 1] =
                    (a2_data[n + i1] - a * a2_data[(n + i2) + i3 * i1]) /
                    (1.0 - absknxt2);
              }
              if (idxNonZero - 1 >= 0) {
                memcpy(&a2_data[0], &tmp_data[0],
                       (unsigned int)idxNonZero * sizeof(double));
              }
            } else {
              c_binary_expand_op(a2_data, n + 1, i, i1, i2, i3, idxNonZero,
                                 absknxt2);
            }
            k_data[b_i] = a2_data[c_i - 2];
          }
          y = false;
          idxNonZero = 1;
          exitg1 = false;
          while ((!exitg1) && (idxNonZero <= loop_ub - 1)) {
            if (errLevdown_data[idxNonZero - 1]) {
              y = true;
              exitg1 = true;
            } else {
              idxNonZero++;
            }
          }
          errFlag = (y || errFlag);
        }
        if (errFlag) {
          firflag = false;
        } else {
          i = 0;
          exitg1 = false;
          while ((!exitg1) && (i <= k_size_idx_0 * k_size_idx_1 - 1)) {
            if (rtIsNaN(k_data[i]) || (fabs(k_data[i]) >= 1.0)) {
              firflag = false;
              exitg1 = true;
            } else {
              i++;
            }
          }
        }
      }
    }
    if (firflag) {
      islinphaseflag = false;
    } else {
      islinphaseflag = (determineiflinphase(b_data, b_size) &&
                        determineiflinphase(a_data, a_size));
    }
  }
  return islinphaseflag;
}

/*
 * File trailer for h_islinphase.c
 *
 * [EOF]
 */
