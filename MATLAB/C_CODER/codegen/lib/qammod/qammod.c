/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: qammod.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 10:54:48
 */

/* Include Files */
#include "qammod.h"
#include "getConstellation.h"
#include "log2.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Declarations */
static double rt_roundd_snf(double u);

/* Function Definitions */
/*
 * Arguments    : double u
 * Return Type  : double
 */
static double rt_roundd_snf(double u)
{
  double y;
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
 * QAMMOD Quadrature amplitude modulation
 *
 *    Y = QAMMOD(X,M) outputs the complex envelope of the modulation of the
 *    message signal X using quadrature amplitude modulation. M is the
 *    alphabet size and must be an integer power of two. The message signal X
 *    must consist of integers between 0 and M-1. X can be a scalar, a
 *    vector, a matrix or an array with 3 dimensions.
 *
 *    Y = QAMMOD(X,M,SYMBOL_ORDER) specifies how the function maps an integer
 *    or group of log2(M) input bits to the corresponding symbol. If
 *    SYMBOL_ORDER is set to 'gray', then the function uses a Gray-coded
 *    ordering. If SYMBOL_ORDER is set to 'bin', then the function uses a
 *    natural binary-coded ordering. If SYMBOL_ORDER is an integer-valued
 *    vector with M elements, the function uses the ordering specified by
 *    this vector. This vector must have unique elements in the range [0,
 *    M-1]. The first element of this vector corresponds to the top-leftmost
 *    point of the constellation, with subsequent elements running down
 *    column-wise, from left to right. The last element corresponds to the
 *    bottom-rightmost point. The default value is 'gray'.
 *
 *    Y = QAMMOD(X,M,...,Name,Value) specifies additional name-value pair
 *    arguments described below:
 *
 *    'InputType'          One of the strings: 'integer', or 'bit'. 'integer'
 *                         indicates that the message signal is integer
 *                         valued between 0 and M-1. 'bit' indicates that the
 *                         message signal is binary (0 or 1). In this case,
 *                         the number of rows (dimension 1) must be an
 *                         integer multiple of log2(M). A group of log2(M)
 *                         bits are mapped onto a symbol, with the first bit
 *                         representing the MSB and the last bit representing
 *                         the LSB. The default value is 'integer'.
 *
 *    'UnitAveragePower'   A logical scalar value. If true, the QAM
 *                         constellation is scaled to average power of 1. If
 *                         false, the QAM constellation with minimum distance
 *                         of 2 between constellation points is used. The
 *                         default value is false.
 *
 *    'OutputDataType'     Output fixed-point type as a signed, unscaled
 *                         numerictype object in MATLAB simulation, and as a
 *                         signed, scaled numerictype object during C code or
 *                         MEX generation. When this argument is not
 *                         specified, if the input datatype is double or
 *                         built-in integers, the output datatype is double;
 *                         if the input datatype is single, the output
 *                         datatype is single. When the input is fixed-point,
 *                         this parameter must be specified.
 *
 *    'PlotConstellation'  A logical scalar value. If true, the QAM
 *                         constellation is plotted. The default value is
 *                         false.
 *
 *  Example 1:
 *     % 32-QAM modulation. Default: Integer input, Gray coding, minimum
 *     % distance of 2 between constellation points
 *     x = (0:31)';
 *     y = qammod(x, 32);
 *
 *  Example 2:
 *     % 16-QAM modulation, with LTE specific symbol mapping and
 *     % constellation % scaled to average power of 1. Default: Integer input
 *     x = randi([0, 15], 20, 4, 2);
 *     lteSymMap = [11 10 14 15 9 8 12 13 1 0 4 5 3 2 6 7];
 *     y = qammod(x, 16, lteSymMap, 'UnitAveragePower', true);
 *
 *  Example 3:
 *     % 64-QAM modulation with binary mapping, bit input and signed
 *     % fixed-point output data type with 16 bits of word length and 10
 *     % bits of fraction length. Default: minimum distance of 2 between
 *     % constellation points
 *     x = randi([0, 1], 10*log2(64), 3);
 *     y = qammod(x, 64, 'bin', 'InputType', 'bit', ...
 *                'OutputDataType', numerictype(1,16,10));
 *
 *  Example 4:
 *     % Visualize the constellation for 16-QAM modulation, with gray
 *     % mapping, bit input and constellation scaled to average power of 1.
 *     x = randi([0, 1], log2(16), 1);
 *     y = qammod(x, 16, 'InputType', 'bit', 'UnitAveragePower', true, ...
 *                'PlotConstellation', true);
 *
 *    See also QAMDEMOD, PSKMOD, APSKMOD, DVBSAPSKMOD, MIL188QAMMOD.
 *
 * Arguments    : signed char x
 *                signed char M
 * Return Type  : creal_T
 */
creal_T qammod(signed char x, signed char M)
{
  creal_T tmp_data[127];
  double d;
  int binMapping_data[127];
  int tmp_size[2];
  int b_i;
  int binMapping_tmp_size_idx_1;
  int i;
  int nBitsBy2;
  int nBitsI;
  signed char binMapping_tmp_data[127];
  /*     Copyright 1996-2022 The MathWorks, Inc. */
  /*  qammod(x, M) */
  /*  not used */
  /*  float or built-in integer input */
  d = rt_roundd_snf(b_log2(M));
  if (d < 2.147483648E+9) {
    if (d >= -2.147483648E+9) {
      nBitsBy2 = (int)d;
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
      binMapping_tmp_data[b_i] = (signed char)b_i;
    }
  }
  for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
    binMapping_data[b_i] = binMapping_tmp_data[b_i];
  }
  if ((nBitsBy2 & 1) != 0) {
    int symbolI_data[127];
    int symbolQ_data[127];
    int varargin_1;
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
        symbolI_data[b_i] =
            varargin_1 ^ varargin_1 >> (unsigned char)-(double)-i;
      }
    }
    for (i = 1; i < nBitsBy2; i += i) {
      for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
        varargin_1 = symbolQ_data[b_i];
        symbolQ_data[b_i] =
            varargin_1 ^ varargin_1 >> (unsigned char)-(double)-i;
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
    int symbolI_data[127];
    int symbolQ_data[127];
    int varargin_1;
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
        symbolI_data[b_i] =
            varargin_1 ^ varargin_1 >> (unsigned char)-(double)-i;
      }
      for (b_i = 0; b_i < binMapping_tmp_size_idx_1; b_i++) {
        varargin_1 = symbolQ_data[b_i];
        symbolQ_data[b_i] =
            varargin_1 ^ varargin_1 >> (unsigned char)-(double)-i;
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
    binMapping_tmp_data[b_i] = (signed char)i;
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
 * File trailer for qammod.c
 *
 * [EOF]
 */
