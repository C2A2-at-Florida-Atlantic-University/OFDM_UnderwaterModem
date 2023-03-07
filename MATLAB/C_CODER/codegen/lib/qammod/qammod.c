/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: QamMod.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 12:23:52
 */

/* Include Files */
#include "QamMod.h"
#include "getConstellation.h"
#include "log2.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Declarations */
static real_T rt_roundd_snf(real_T u);

/* Function Definitions */
/*
 * Arguments    : real_T u
 * Return Type  : real_T
 */
static real_T rt_roundd_snf(real_T u)
{
  real_T y;
  if (fabs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = ceil(u - 0.5);
    }
  } else {
    y = u;
  }
  return y;
}

/*
 * Arguments    : int8_T x
 *                int8_T M
 * Return Type  : creal_T
 */
creal_T QamMod(int8_T x, int8_T M)
{
  creal_T tmp_data[127];
  real_T d;
  int32_T binMapping_data[127];
  int32_T tmp_size[2];
  int32_T b_i;
  int32_T binMapping_tmp_size_idx_1;
  int32_T i;
  int32_T nBitsBy2;
  int32_T nBitsI;
  int8_T binMapping_tmp_data[127];
  d = rt_roundd_snf(b_log2(M));
  if (d < 2.147483648E+9) {
    if (d >= -2.147483648E+9) {
      nBitsBy2 = (int32_T)d;
    } else {
      nBitsBy2 = MIN_int32_T;
    }
  } else if (d >= 2.147483648E+9) {
    nBitsBy2 = MAX_int32_T;
  } else {
    nBitsBy2 = 0;
  }
  if (M - 1 < 0) {
    binMapping_tmp_size_idx_1 = 0;
  } else {
    binMapping_tmp_size_idx_1 = M;
    i = M - 1;
    for (b_i = 0; b_i <= i; b_i++) {
      binMapping_tmp_data[b_i] = (int8_T)b_i;
    }
  }
  for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
    binMapping_data[b_i] = binMapping_tmp_data[b_i];
  }
  if ((nBitsBy2 & 1) != 0) {
    int32_T symbolI_data[127];
    int32_T symbolQ_data[127];
    int32_T varargin_1;
    if (nBitsBy2 > 2147483646) {
      i = MAX_int32_T;
    } else {
      i = nBitsBy2 + 1;
    }
    nBitsI = i >> 1;
    if (nBitsBy2 < -2147483647) {
      i = MIN_int32_T;
    } else {
      i = nBitsBy2 - 1;
    }
    nBitsBy2 = i >> 1;
    for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
      varargin_1 = binMapping_data[b_i];
      if (-nBitsBy2 >= 0) {
        if (-nBitsBy2 <= 31) {
          symbolI_data[b_i] = varargin_1 << -nBitsBy2;
        } else {
          symbolI_data[b_i] = 0;
        }
      } else if (-nBitsBy2 >= -31) {
        symbolI_data[b_i] = varargin_1 >> nBitsBy2;
      } else {
        symbolI_data[b_i] = 0;
      }
    }
    if (-nBitsI >= 0) {
      if (-nBitsI <= 31) {
        i = (M - 1) << -nBitsI;
      } else {
        i = 0;
      }
    } else if (-nBitsI >= -31) {
      i = (M - 1) >> nBitsI;
    } else if (M - 1 < 0) {
      i = -1;
    } else {
      i = 0;
    }
    for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
      symbolQ_data[b_i] = binMapping_data[b_i] & i;
    }
    for (i = 1; i < nBitsI; i += i) {
      for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
        varargin_1 = symbolI_data[b_i];
        symbolI_data[b_i] = varargin_1 ^ varargin_1 >> (uint8_T) - (real_T)-i;
      }
    }
    for (i = 1; i < nBitsBy2; i += i) {
      for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
        varargin_1 = symbolQ_data[b_i];
        symbolQ_data[b_i] = varargin_1 ^ varargin_1 >> (uint8_T) - (real_T)-i;
      }
    }
    nBitsI = binMapping_tmp_size_idx_1;
    for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
      varargin_1 = symbolI_data[b_i];
      if (nBitsBy2 >= 0) {
        if (nBitsBy2 <= 31) {
          binMapping_data[b_i] = varargin_1 << nBitsBy2;
        } else {
          binMapping_data[b_i] = 0;
        }
      } else if (nBitsBy2 >= -31) {
        binMapping_data[b_i] = varargin_1 >> -nBitsBy2;
      } else if (varargin_1 < 0) {
        binMapping_data[b_i] = -1;
      } else {
        binMapping_data[b_i] = 0;
      }
    }
    for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
      nBitsBy2 = binMapping_data[b_i];
      i = symbolQ_data[b_i];
      if ((nBitsBy2 < 0) && (i < MIN_int32_T - nBitsBy2)) {
        i = MIN_int32_T;
      } else if ((nBitsBy2 > 0) && (i > MAX_int32_T - nBitsBy2)) {
        i = MAX_int32_T;
      } else {
        i += nBitsBy2;
      }
      binMapping_data[b_i] = i;
    }
  } else {
    int32_T symbolI_data[127];
    int32_T symbolQ_data[127];
    int32_T varargin_1;
    nBitsBy2 >>= 1;
    for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
      varargin_1 = binMapping_data[b_i];
      if (-nBitsBy2 >= 0) {
        if (-nBitsBy2 <= 31) {
          symbolI_data[b_i] = varargin_1 << -nBitsBy2;
        } else {
          symbolI_data[b_i] = 0;
        }
      } else if (-nBitsBy2 >= -31) {
        symbolI_data[b_i] = varargin_1 >> nBitsBy2;
      } else {
        symbolI_data[b_i] = 0;
      }
    }
    if (-nBitsBy2 >= 0) {
      if (-nBitsBy2 <= 31) {
        i = (M - 1) << -nBitsBy2;
      } else {
        i = 0;
      }
    } else if (-nBitsBy2 >= -31) {
      i = (M - 1) >> nBitsBy2;
    } else if (M - 1 < 0) {
      i = -1;
    } else {
      i = 0;
    }
    for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
      symbolQ_data[b_i] = binMapping_data[b_i] & i;
    }
    for (i = 1; i < nBitsBy2; i += i) {
      for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
        varargin_1 = symbolI_data[b_i];
        symbolI_data[b_i] = varargin_1 ^ varargin_1 >> (uint8_T) - (real_T)-i;
      }
      for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
        varargin_1 = symbolQ_data[b_i];
        symbolQ_data[b_i] = varargin_1 ^ varargin_1 >> (uint8_T) - (real_T)-i;
      }
    }
    nBitsI = binMapping_tmp_size_idx_1;
    for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
      varargin_1 = symbolI_data[b_i];
      if (nBitsBy2 >= 0) {
        if (nBitsBy2 <= 31) {
          binMapping_data[b_i] = varargin_1 << nBitsBy2;
        } else {
          binMapping_data[b_i] = 0;
        }
      } else if (nBitsBy2 >= -31) {
        binMapping_data[b_i] = varargin_1 >> -nBitsBy2;
      } else if (varargin_1 < 0) {
        binMapping_data[b_i] = -1;
      } else {
        binMapping_data[b_i] = 0;
      }
    }
    for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
      nBitsBy2 = binMapping_data[b_i];
      i = symbolQ_data[b_i];
      if ((nBitsBy2 < 0) && (i < MIN_int32_T - nBitsBy2)) {
        i = MIN_int32_T;
      } else if ((nBitsBy2 > 0) && (i > MAX_int32_T - nBitsBy2)) {
        i = MAX_int32_T;
      } else {
        i += nBitsBy2;
      }
      binMapping_data[b_i] = i;
    }
  }
  for (b_i = 0; b_i < nBitsI; b_i++) {
    i = binMapping_data[b_i];
    if (i > 127) {
      i = 127;
    } else if (i < -128) {
      i = -128;
    }
    binMapping_tmp_data[b_i] = (int8_T)i;
  }
  b_i = x + 1;
  if (x + 1 > 127) {
    b_i = 127;
  }
  b_i = binMapping_tmp_data[b_i - 1] + 1;
  if (b_i > 127) {
    b_i = 127;
  }
  getConstellation(M, tmp_data, tmp_size);
  return tmp_data[b_i - 1];
}

/*
 * File trailer for QamMod.c
 *
 * [EOF]
 */
