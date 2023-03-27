/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: d_QamDemod.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 15-Mar-2023 18:38:51
 */

/* Include Files */
#include "d_QamDemod.h"
#include "d_QamDemod_emxutil.h"
#include "d_QamDemod_types.h"
#include "d_getGrayMapping.h"
#include "d_getSquareConstellation.h"
#include "d_log2.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Declarations */
static float rt_hypotf_snf(float u0, float u1);

/* Function Definitions */
/*
 * Arguments    : float u0
 *                float u1
 * Return Type  : float
 */
static float rt_hypotf_snf(float u0, float u1)
{
  float a;
  float b;
  float y;
  a = fabsf(u0);
  b = fabsf(u1);
  if (a < b) {
    a /= b;
    y = b * sqrtf(a * a + 1.0F);
  } else if (a > b) {
    b /= a;
    y = a * sqrtf(b * b + 1.0F);
  } else if (rtIsNaNF(b)) {
    y = rtNaNF;
  } else {
    y = a * 1.41421354F;
  }
  return y;
}

/*
 * Arguments    : const creal32_T x
 *                float M
 * Return Type  : float
 */
float QamDemod(const creal32_T x, float M)
{
  emxArray_creal32_T *b_const;
  emxArray_int32_T *binMapping;
  emxArray_int32_T *symbolI;
  emxArray_int32_T *symbolQ;
  emxArray_real32_T *mapping;
  emxArray_real32_T *varargin_1;
  creal32_T *const_data;
  float f;
  float sqrtM;
  float x_tmp;
  float y;
  float *mapping_data;
  float *varargin_1_data;
  int i;
  int k;
  int loop_ub;
  int nBitsBy2;
  int nx;
  int *binMapping_data;
  int *symbolI_data;
  int *symbolQ_data;
  if ((!(M == 0.0F)) && (!(M < 0.0F)) && ((!rtIsInf(M)) && (!rtIsNaN(M)))) {
    frexp(M, &nx);
  }
  x_tmp = d_b_log2(M);
  if (rtIsNaNF(x_tmp) || rtIsInfF(x_tmp)) {
    sqrtM = rtNaNF;
  } else if (x_tmp == 0.0F) {
    sqrtM = 0.0F;
  } else {
    sqrtM = fmodf(x_tmp, 2.0F);
    if (sqrtM == 0.0F) {
      sqrtM = 0.0F;
    } else if (x_tmp < 0.0F) {
      sqrtM += 2.0F;
    }
  }
  emxInit_real32_T(&varargin_1, 2);
  varargin_1_data = varargin_1->data;
  if (sqrtM != 0.0F) {
    emxInit_creal32_T(&b_const);
    getSquareConstellation(M, b_const);
    i = b_const->size[0] * b_const->size[1];
    b_const->size[0] = 1;
    emxEnsureCapacity_creal32_T(b_const, i);
    const_data = b_const->data;
    loop_ub = b_const->size[1] - 1;
    for (i = 0; i <= loop_ub; i++) {
      const_data[i].re = x.re - const_data[i].re;
      const_data[i].im = x.im - const_data[i].im;
    }
    nx = b_const->size[1];
    i = varargin_1->size[0] * varargin_1->size[1];
    varargin_1->size[0] = 1;
    varargin_1->size[1] = b_const->size[1];
    emxEnsureCapacity_real32_T(varargin_1, i);
    varargin_1_data = varargin_1->data;
    for (k = 0; k < nx; k++) {
      varargin_1_data[k] = rt_hypotf_snf(const_data[k].re, const_data[k].im);
    }
    emxFree_creal32_T(&b_const);
    nx = varargin_1->size[1];
    if (varargin_1->size[1] <= 2) {
      if (varargin_1->size[1] == 1) {
        nBitsBy2 = 1;
      } else if ((varargin_1_data[0] >
                  varargin_1_data[varargin_1->size[1] - 1]) ||
                 (rtIsNaNF(varargin_1_data[0]) &&
                  (!rtIsNaNF(varargin_1_data[varargin_1->size[1] - 1])))) {
        nBitsBy2 = varargin_1->size[1];
      } else {
        nBitsBy2 = 1;
      }
    } else {
      if (!rtIsNaNF(varargin_1_data[0])) {
        nBitsBy2 = 1;
      } else {
        boolean_T exitg1;
        nBitsBy2 = 0;
        k = 2;
        exitg1 = false;
        while ((!exitg1) && (k <= nx)) {
          if (!rtIsNaNF(varargin_1_data[k - 1])) {
            nBitsBy2 = k;
            exitg1 = true;
          } else {
            k++;
          }
        }
      }
      if (nBitsBy2 == 0) {
        nBitsBy2 = 1;
      } else {
        sqrtM = varargin_1_data[nBitsBy2 - 1];
        i = nBitsBy2 + 1;
        for (k = i; k <= nx; k++) {
          f = varargin_1_data[k - 1];
          if (sqrtM > f) {
            sqrtM = f;
            nBitsBy2 = k;
          }
        }
      }
    }
    sqrtM = (float)((double)nBitsBy2 - 1.0);
  } else {
    float iIdx;
    sqrtM = sqrtf(M);
    iIdx = roundf((x.re + (sqrtM - 1.0F)) / 2.0F);
    if (iIdx < 0.0F) {
      iIdx = 0.0F;
    }
    f = iIdx;
    nx = 0;
    if (iIdx > sqrtM - 1.0F) {
      nx = 1;
    }
    for (i = 0; i < nx; i++) {
      f = sqrtM - 1.0F;
    }
    iIdx = roundf((x.im + (sqrtM - 1.0F)) / 2.0F);
    if (iIdx < 0.0F) {
      iIdx = 0.0F;
    }
    nx = 0;
    if (iIdx > sqrtM - 1.0F) {
      nx = 1;
    }
    for (i = 0; i < nx; i++) {
      iIdx = sqrtM - 1.0F;
    }
    sqrtM = ((sqrtM - iIdx) - 1.0F) + sqrtM * f;
  }
  f = roundf(x_tmp);
  if (f < 2.14748365E+9F) {
    if (f >= -2.14748365E+9F) {
      nBitsBy2 = (int)f;
    } else {
      nBitsBy2 = MIN_int32_T;
    }
  } else if (f >= 2.14748365E+9F) {
    nBitsBy2 = MAX_int32_T;
  } else {
    nBitsBy2 = 0;
  }
  if (rtIsNaNF(M - 1.0F)) {
    i = varargin_1->size[0] * varargin_1->size[1];
    varargin_1->size[0] = 1;
    varargin_1->size[1] = 1;
    emxEnsureCapacity_real32_T(varargin_1, i);
    varargin_1_data = varargin_1->data;
    varargin_1_data[0] = rtNaNF;
  } else if (M - 1.0F < 0.0F) {
    varargin_1->size[0] = 1;
    varargin_1->size[1] = 0;
  } else {
    i = varargin_1->size[0] * varargin_1->size[1];
    varargin_1->size[0] = 1;
    varargin_1->size[1] = (int)(M - 1.0F) + 1;
    emxEnsureCapacity_real32_T(varargin_1, i);
    varargin_1_data = varargin_1->data;
    loop_ub = (int)(M - 1.0F);
    for (i = 0; i <= loop_ub; i++) {
      varargin_1_data[i] = (float)i;
    }
  }
  emxInit_int32_T(&binMapping);
  i = binMapping->size[0];
  binMapping->size[0] = varargin_1->size[1];
  emxEnsureCapacity_int32_T(binMapping, i);
  binMapping_data = binMapping->data;
  loop_ub = varargin_1->size[1];
  for (i = 0; i < loop_ub; i++) {
    f = varargin_1_data[i];
    if (f < 2.14748365E+9F) {
      nx = (int)f;
    } else if (f >= 2.14748365E+9F) {
      nx = MAX_int32_T;
    } else {
      nx = 0;
    }
    binMapping_data[i] = nx;
  }
  emxInit_real32_T(&mapping, 1);
  i = mapping->size[0];
  mapping->size[0] = (int)M;
  emxEnsureCapacity_real32_T(mapping, i);
  mapping_data = mapping->data;
  loop_ub = (int)M;
  for (i = 0; i < loop_ub; i++) {
    mapping_data[i] = 0.0F;
  }
  f = roundf(M);
  if (f < 2.14748365E+9F) {
    if (f >= -2.14748365E+9F) {
      i = (int)f;
    } else {
      i = MIN_int32_T;
    }
  } else if (f >= 2.14748365E+9F) {
    i = MAX_int32_T;
  } else {
    i = 0;
  }
  emxInit_int32_T(&symbolI);
  emxInit_int32_T(&symbolQ);
  if ((nBitsBy2 & 1) != 0) {
    int b_varargin_1;
    int nBitsI;
    if (nBitsBy2 > 2147483646) {
      nx = MAX_int32_T;
    } else {
      nx = nBitsBy2 + 1;
    }
    nBitsI = nx >> 1;
    if (nBitsBy2 < -2147483647) {
      nx = MIN_int32_T;
    } else {
      nx = nBitsBy2 - 1;
    }
    nBitsBy2 = nx >> 1;
    nx = symbolI->size[0];
    symbolI->size[0] = binMapping->size[0];
    emxEnsureCapacity_int32_T(symbolI, nx);
    symbolI_data = symbolI->data;
    loop_ub = binMapping->size[0];
    for (nx = 0; nx < loop_ub; nx++) {
      b_varargin_1 = binMapping_data[nx];
      if (-nBitsBy2 >= 0) {
        if (-nBitsBy2 <= 31) {
          symbolI_data[nx] = b_varargin_1 << -nBitsBy2;
        } else {
          symbolI_data[nx] = 0;
        }
      } else if (-nBitsBy2 >= -31) {
        symbolI_data[nx] = b_varargin_1 >> nBitsBy2;
      } else if (b_varargin_1 < 0) {
        symbolI_data[nx] = -1;
      } else {
        symbolI_data[nx] = 0;
      }
    }
    if (-nBitsI >= 0) {
      if (-nBitsI <= 31) {
        nx = (i - 1) << -nBitsI;
      } else {
        nx = 0;
      }
    } else if (-nBitsI >= -31) {
      nx = (i - 1) >> nBitsI;
    } else if (i - 1 < 0) {
      nx = -1;
    } else {
      nx = 0;
    }
    i = symbolQ->size[0];
    symbolQ->size[0] = binMapping->size[0];
    emxEnsureCapacity_int32_T(symbolQ, i);
    symbolQ_data = symbolQ->data;
    loop_ub = binMapping->size[0];
    for (i = 0; i < loop_ub; i++) {
      b_varargin_1 = binMapping_data[i];
      symbolQ_data[i] = b_varargin_1 & nx;
    }
    for (nx = 1; nx < nBitsI; nx += nx) {
      loop_ub = symbolI->size[0];
      for (i = 0; i < loop_ub; i++) {
        b_varargin_1 = symbolI_data[i];
        k = symbolI_data[i];
        if (-nx >= -31) {
          b_varargin_1 >>= (unsigned char)-(double)-nx;
        } else if (b_varargin_1 < 0) {
          b_varargin_1 = -1;
        } else {
          b_varargin_1 = 0;
        }
        symbolI_data[i] = k ^ b_varargin_1;
      }
    }
    for (nx = 1; nx < nBitsBy2; nx += nx) {
      loop_ub = symbolQ->size[0];
      for (i = 0; i < loop_ub; i++) {
        b_varargin_1 = symbolQ_data[i];
        k = symbolQ_data[i];
        if (-nx >= -31) {
          b_varargin_1 >>= (unsigned char)-(double)-nx;
        } else if (b_varargin_1 < 0) {
          b_varargin_1 = -1;
        } else {
          b_varargin_1 = 0;
        }
        symbolQ_data[i] = k ^ b_varargin_1;
      }
    }
    i = binMapping->size[0];
    binMapping->size[0] = symbolI->size[0];
    emxEnsureCapacity_int32_T(binMapping, i);
    binMapping_data = binMapping->data;
    loop_ub = symbolI->size[0];
    for (i = 0; i < loop_ub; i++) {
      b_varargin_1 = symbolI_data[i];
      if (nBitsBy2 >= 0) {
        if (nBitsBy2 <= 31) {
          binMapping_data[i] = b_varargin_1 << nBitsBy2;
        } else {
          binMapping_data[i] = 0;
        }
      } else if (nBitsBy2 >= -31) {
        binMapping_data[i] = b_varargin_1 >> -nBitsBy2;
      } else if (b_varargin_1 < 0) {
        binMapping_data[i] = -1;
      } else {
        binMapping_data[i] = 0;
      }
    }
    if (binMapping->size[0] == symbolQ->size[0]) {
      loop_ub = binMapping->size[0];
      for (i = 0; i < loop_ub; i++) {
        nBitsBy2 = binMapping_data[i];
        nx = symbolQ_data[i];
        if ((nBitsBy2 < 0) && (nx < MIN_int32_T - nBitsBy2)) {
          nx = MIN_int32_T;
        } else if ((nBitsBy2 > 0) && (nx > MAX_int32_T - nBitsBy2)) {
          nx = MAX_int32_T;
        } else {
          nx += nBitsBy2;
        }
        binMapping_data[i] = nx;
      }
    } else {
      plus(binMapping, symbolQ);
      binMapping_data = binMapping->data;
    }
  } else {
    int b_varargin_1;
    nBitsBy2 >>= 1;
    nx = symbolI->size[0];
    symbolI->size[0] = binMapping->size[0];
    emxEnsureCapacity_int32_T(symbolI, nx);
    symbolI_data = symbolI->data;
    loop_ub = binMapping->size[0];
    for (nx = 0; nx < loop_ub; nx++) {
      b_varargin_1 = binMapping_data[nx];
      if (-nBitsBy2 >= 0) {
        if (-nBitsBy2 <= 31) {
          symbolI_data[nx] = b_varargin_1 << -nBitsBy2;
        } else {
          symbolI_data[nx] = 0;
        }
      } else if (-nBitsBy2 >= -31) {
        symbolI_data[nx] = b_varargin_1 >> nBitsBy2;
      } else if (b_varargin_1 < 0) {
        symbolI_data[nx] = -1;
      } else {
        symbolI_data[nx] = 0;
      }
    }
    if (-nBitsBy2 >= 0) {
      if (-nBitsBy2 <= 31) {
        nx = (i - 1) << -nBitsBy2;
      } else {
        nx = 0;
      }
    } else if (-nBitsBy2 >= -31) {
      nx = (i - 1) >> nBitsBy2;
    } else if (i - 1 < 0) {
      nx = -1;
    } else {
      nx = 0;
    }
    i = symbolQ->size[0];
    symbolQ->size[0] = binMapping->size[0];
    emxEnsureCapacity_int32_T(symbolQ, i);
    symbolQ_data = symbolQ->data;
    loop_ub = binMapping->size[0];
    for (i = 0; i < loop_ub; i++) {
      b_varargin_1 = binMapping_data[i];
      symbolQ_data[i] = b_varargin_1 & nx;
    }
    for (nx = 1; nx < nBitsBy2; nx += nx) {
      loop_ub = symbolI->size[0];
      for (i = 0; i < loop_ub; i++) {
        b_varargin_1 = symbolI_data[i];
        k = symbolI_data[i];
        if (-nx >= -31) {
          b_varargin_1 >>= (unsigned char)-(double)-nx;
        } else if (b_varargin_1 < 0) {
          b_varargin_1 = -1;
        } else {
          b_varargin_1 = 0;
        }
        symbolI_data[i] = k ^ b_varargin_1;
      }
      loop_ub = symbolQ->size[0];
      for (i = 0; i < loop_ub; i++) {
        b_varargin_1 = symbolQ_data[i];
        k = symbolQ_data[i];
        if (-nx >= -31) {
          b_varargin_1 >>= (unsigned char)-(double)-nx;
        } else if (b_varargin_1 < 0) {
          b_varargin_1 = -1;
        } else {
          b_varargin_1 = 0;
        }
        symbolQ_data[i] = k ^ b_varargin_1;
      }
    }
    i = binMapping->size[0];
    binMapping->size[0] = symbolI->size[0];
    emxEnsureCapacity_int32_T(binMapping, i);
    binMapping_data = binMapping->data;
    loop_ub = symbolI->size[0];
    for (i = 0; i < loop_ub; i++) {
      b_varargin_1 = symbolI_data[i];
      if (nBitsBy2 >= 0) {
        if (nBitsBy2 <= 31) {
          binMapping_data[i] = b_varargin_1 << nBitsBy2;
        } else {
          binMapping_data[i] = 0;
        }
      } else if (nBitsBy2 >= -31) {
        binMapping_data[i] = b_varargin_1 >> -nBitsBy2;
      } else if (b_varargin_1 < 0) {
        binMapping_data[i] = -1;
      } else {
        binMapping_data[i] = 0;
      }
    }
    if (binMapping->size[0] == symbolQ->size[0]) {
      loop_ub = binMapping->size[0];
      for (i = 0; i < loop_ub; i++) {
        nBitsBy2 = binMapping_data[i];
        nx = symbolQ_data[i];
        if ((nBitsBy2 < 0) && (nx < MIN_int32_T - nBitsBy2)) {
          nx = MIN_int32_T;
        } else if ((nBitsBy2 > 0) && (nx > MAX_int32_T - nBitsBy2)) {
          nx = MAX_int32_T;
        } else {
          nx += nBitsBy2;
        }
        binMapping_data[i] = nx;
      }
    } else {
      plus(binMapping, symbolQ);
      binMapping_data = binMapping->data;
    }
  }
  emxFree_int32_T(&symbolQ);
  emxFree_int32_T(&symbolI);
  loop_ub = binMapping->size[0];
  for (i = 0; i < loop_ub; i++) {
    binMapping_data[i] = (int)((float)binMapping_data[i] + 1.0F);
  }
  loop_ub = binMapping->size[0];
  for (i = 0; i < loop_ub; i++) {
    mapping_data[binMapping_data[i] - 1] = varargin_1_data[i];
  }
  emxFree_int32_T(&binMapping);
  emxFree_real32_T(&varargin_1);
  y = mapping_data[(int)(sqrtM + 1.0F) - 1];
  emxFree_real32_T(&mapping);
  /* y =
   * qamdemod(x,M,'SymbolOrder','grey','UnitAveragePower',0,'OutputType','integer','NoiseVariance',1,'PlotConstellation',0);
   */
  return y;
}

/*
 * File trailer for d_QamDemod.c
 *
 * [EOF]
 */
