/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: d_getSquareConstellation.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 15-Mar-2023 18:38:51
 */

/* Include Files */
#include "d_getSquareConstellation.h"
#include "d_QamDemod_emxutil.h"
#include "d_QamDemod_types.h"
#include "d_log2.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"
#include <math.h>

/* Function Declarations */
static float rt_powf_snf(float u0, float u1);

/* Function Definitions */
/*
 * Arguments    : float u0
 *                float u1
 * Return Type  : float
 */
static float rt_powf_snf(float u0, float u1)
{
  float y;
  if (rtIsNaNF(u0) || rtIsNaNF(u1)) {
    y = rtNaNF;
  } else {
    float f;
    float f1;
    f = fabsf(u0);
    f1 = fabsf(u1);
    if (rtIsInfF(u1)) {
      if (f == 1.0F) {
        y = 1.0F;
      } else if (f > 1.0F) {
        if (u1 > 0.0F) {
          y = rtInfF;
        } else {
          y = 0.0F;
        }
      } else if (u1 > 0.0F) {
        y = 0.0F;
      } else {
        y = rtInfF;
      }
    } else if (f1 == 0.0F) {
      y = 1.0F;
    } else if (f1 == 1.0F) {
      if (u1 > 0.0F) {
        y = u0;
      } else {
        y = 1.0F / u0;
      }
    } else if (u1 == 2.0F) {
      y = u0 * u0;
    } else if ((u1 == 0.5F) && (u0 >= 0.0F)) {
      y = sqrtf(u0);
    } else if ((u0 < 0.0F) && (u1 > floorf(u1))) {
      y = rtNaNF;
    } else {
      y = powf(u0, u1);
    }
  }
  return y;
}

/*
 * Arguments    : float M
 *                emxArray_creal32_T *constellation
 * Return Type  : void
 */
void getSquareConstellation(float M, emxArray_creal32_T *constellation)
{
  static const cint8_T icv[8] = {{
                                     -3, /* re */
                                     1   /* im */
                                 },
                                 {
                                     -3, /* re */
                                     -1  /* im */
                                 },
                                 {
                                     -1, /* re */
                                     1   /* im */
                                 },
                                 {
                                     -1, /* re */
                                     -1  /* im */
                                 },
                                 {
                                     1, /* re */
                                     1  /* im */
                                 },
                                 {
                                     1, /* re */
                                     -1 /* im */
                                 },
                                 {
                                     3, /* re */
                                     1  /* im */
                                 },
                                 {
                                     3, /* re */
                                     -1 /* im */
                                 }};
  emxArray_real32_T *a;
  emxArray_real32_T *x;
  emxArray_real32_T *xPoints;
  emxArray_real32_T *y;
  emxArray_real32_T *yPoints;
  creal32_T *constellation_data;
  float nbits;
  float *a_data;
  float *xPoints_data;
  float *x_data;
  float *yPoints_data;
  int i;
  int ibmat;
  int itilerow;
  int k;
  int kd;
  int nm1d2;
  nbits = d_b_log2(M);
  i = constellation->size[0] * constellation->size[1];
  constellation->size[0] = 1;
  kd = (int)M;
  constellation->size[1] = (int)M;
  emxEnsureCapacity_creal32_T(constellation, i);
  constellation_data = constellation->data;
  if (nbits == 1.0F) {
    i = constellation->size[0] * constellation->size[1];
    constellation->size[0] = 1;
    constellation->size[1] = (int)M;
    emxEnsureCapacity_creal32_T(constellation, i);
    constellation_data = constellation->data;
    for (i = 0; i < kd; i++) {
      constellation_data[i].re = 2.0F * (float)i - 1.0F;
      constellation_data[i].im = -0.0F;
    }
  } else {
    float sqrtM;
    if (rtIsNaNF(nbits) || rtIsInfF(nbits)) {
      sqrtM = rtNaNF;
    } else if (nbits == 0.0F) {
      sqrtM = 0.0F;
    } else {
      sqrtM = fmodf(nbits, 2.0F);
      if (sqrtM == 0.0F) {
        sqrtM = 0.0F;
      } else if (nbits < 0.0F) {
        sqrtM += 2.0F;
      }
    }
    emxInit_real32_T(&xPoints, 2);
    xPoints_data = xPoints->data;
    emxInit_real32_T(&yPoints, 2);
    yPoints_data = yPoints->data;
    emxInit_real32_T(&x, 2);
    emxInit_real32_T(&y, 1);
    emxInit_real32_T(&a, 1);
    if ((sqrtM != 0.0F) && (nbits > 3.0F)) {
      float mI;
      float mQ;
      float tmp2;
      float tmp3;
      float tmp4;
      float tmp5;
      mI = rt_powf_snf(2.0F, (nbits + 1.0F) / 2.0F);
      mQ = rt_powf_snf(2.0F, (nbits - 1.0F) / 2.0F);
      sqrtM = truncf((M - 1.0F) / mI);
      tmp2 = 3.0F * mI / 4.0F;
      tmp3 = mI / 2.0F;
      tmp4 = mQ / 2.0F;
      tmp5 = 2.0F * mQ;
      i = (int)((M - 1.0F) + 1.0F);
      if (i - 1 >= 0) {
        if (sqrtM < 2.14748365E+9F) {
          if (sqrtM >= -2.14748365E+9F) {
            k = (int)sqrtM;
          } else {
            k = MIN_int32_T;
          }
        } else if (sqrtM >= 2.14748365E+9F) {
          k = MAX_int32_T;
        } else {
          k = 0;
        }
      }
      for (ibmat = 0; ibmat < i; ibmat++) {
        float iMag;
        sqrtM = 2.0F * truncf((float)ibmat / mQ) + (1.0F - mI);
        if (ibmat < 2.14748365E+9F) {
          kd = (int)(float)ibmat;
        } else {
          kd = MAX_int32_T;
        }
        nbits = -(2.0F * (float)(kd & k) + (1.0F - mQ));
        iMag = fabsf(floorf(sqrtM));
        if (iMag > tmp2) {
          float qMag;
          qMag = fabsf(floorf(nbits));
          if (sqrtM < 0.0F) {
            kd = -1;
          } else {
            kd = (sqrtM > 0.0F);
          }
          if (nbits < 0.0F) {
            nm1d2 = -1;
          } else {
            nm1d2 = (nbits > 0.0F);
          }
          if (qMag > tmp4) {
            sqrtM = (float)kd * (iMag - tmp3);
            nbits = (float)nm1d2 * (tmp5 - qMag);
          } else {
            sqrtM = (float)kd * (mI - iMag);
            nbits = (float)nm1d2 * (mQ + qMag);
          }
        }
        constellation_data[(int)((float)ibmat + 1.0F) - 1].re = sqrtM;
        constellation_data[(int)((float)ibmat + 1.0F) - 1].im = nbits;
      }
    } else if (nbits == 3.0F) {
      i = constellation->size[0] * constellation->size[1];
      constellation->size[0] = 1;
      constellation->size[1] = (int)M;
      emxEnsureCapacity_creal32_T(constellation, i);
      constellation_data = constellation->data;
      for (i = 0; i < kd; i++) {
        constellation_data[i].re = icv[i].re;
        constellation_data[i].im = icv[i].im;
      }
    } else {
      double apnd;
      double cdiff;
      double ndbl;
      sqrtM = rt_powf_snf(2.0F, nbits / 2.0F);
      if (rtIsNaNF(-(sqrtM - 1.0F)) || rtIsNaNF(sqrtM - 1.0F)) {
        i = xPoints->size[0] * xPoints->size[1];
        xPoints->size[0] = 1;
        xPoints->size[1] = 1;
        emxEnsureCapacity_real32_T(xPoints, i);
        xPoints_data = xPoints->data;
        xPoints_data[0] = rtNaNF;
      } else if (sqrtM - 1.0F < -(sqrtM - 1.0F)) {
        xPoints->size[0] = 1;
        xPoints->size[1] = 0;
      } else if ((rtIsInfF(-(sqrtM - 1.0F)) || rtIsInfF(sqrtM - 1.0F)) &&
                 (-(sqrtM - 1.0F) == sqrtM - 1.0F)) {
        i = xPoints->size[0] * xPoints->size[1];
        xPoints->size[0] = 1;
        xPoints->size[1] = 1;
        emxEnsureCapacity_real32_T(xPoints, i);
        xPoints_data = xPoints->data;
        xPoints_data[0] = rtNaNF;
      } else if (floorf(-(sqrtM - 1.0F)) == -(sqrtM - 1.0F)) {
        i = xPoints->size[0] * xPoints->size[1];
        xPoints->size[0] = 1;
        kd = (int)(((double)(sqrtM - 1.0F) - (-(sqrtM - 1.0F))) / 2.0);
        xPoints->size[1] = kd + 1;
        emxEnsureCapacity_real32_T(xPoints, i);
        xPoints_data = xPoints->data;
        for (i = 0; i <= kd; i++) {
          xPoints_data[i] = (float)(-(sqrtM - 1.0F) + 2.0 * (double)i);
        }
      } else {
        ndbl = floor(((double)(sqrtM - 1.0F) - (-(sqrtM - 1.0F))) / 2.0 + 0.5);
        apnd = -(sqrtM - 1.0F) + ndbl * 2.0;
        cdiff = apnd - (sqrtM - 1.0F);
        if (fabs(cdiff) < 2.384185791015625E-7 *
                              fmax(fabs(-(sqrtM - 1.0F)), fabs(sqrtM - 1.0F))) {
          ndbl++;
          nbits = sqrtM - 1.0F;
        } else if (cdiff > 0.0) {
          nbits = (float)(-(sqrtM - 1.0F) + (ndbl - 1.0) * 2.0);
        } else {
          ndbl++;
          nbits = (float)apnd;
        }
        if (ndbl >= 0.0) {
          ibmat = (int)ndbl;
        } else {
          ibmat = 0;
        }
        i = xPoints->size[0] * xPoints->size[1];
        xPoints->size[0] = 1;
        xPoints->size[1] = ibmat;
        emxEnsureCapacity_real32_T(xPoints, i);
        xPoints_data = xPoints->data;
        if (ibmat > 0) {
          xPoints_data[0] = -(sqrtM - 1.0F);
          if (ibmat > 1) {
            xPoints_data[ibmat - 1] = nbits;
            nm1d2 = (ibmat - 1) / 2;
            for (k = 0; k <= nm1d2 - 2; k++) {
              kd = (k + 1) << 1;
              xPoints_data[k + 1] = -(sqrtM - 1.0F) + (float)kd;
              xPoints_data[(ibmat - k) - 2] = nbits - (float)kd;
            }
            i = nm1d2 << 1;
            if (i == ibmat - 1) {
              xPoints_data[nm1d2] = (-(sqrtM - 1.0F) + nbits) / 2.0F;
            } else {
              xPoints_data[nm1d2] = -(sqrtM - 1.0F) + (float)i;
              xPoints_data[nm1d2 + 1] = nbits - (float)i;
            }
          }
        }
      }
      if (rtIsNaNF(sqrtM - 1.0F) || rtIsNaNF(-(sqrtM - 1.0F))) {
        i = yPoints->size[0] * yPoints->size[1];
        yPoints->size[0] = 1;
        yPoints->size[1] = 1;
        emxEnsureCapacity_real32_T(yPoints, i);
        yPoints_data = yPoints->data;
        yPoints_data[0] = rtNaNF;
      } else if (sqrtM - 1.0F < -(sqrtM - 1.0F)) {
        yPoints->size[0] = 1;
        yPoints->size[1] = 0;
      } else if ((rtIsInfF(sqrtM - 1.0F) || rtIsInfF(-(sqrtM - 1.0F))) &&
                 (sqrtM - 1.0F == -(sqrtM - 1.0F))) {
        i = yPoints->size[0] * yPoints->size[1];
        yPoints->size[0] = 1;
        yPoints->size[1] = 1;
        emxEnsureCapacity_real32_T(yPoints, i);
        yPoints_data = yPoints->data;
        yPoints_data[0] = rtNaNF;
      } else if (floorf(sqrtM - 1.0F) == sqrtM - 1.0F) {
        i = yPoints->size[0] * yPoints->size[1];
        yPoints->size[0] = 1;
        kd = (int)(((double)-(sqrtM - 1.0F) - (sqrtM - 1.0F)) / -2.0);
        yPoints->size[1] = kd + 1;
        emxEnsureCapacity_real32_T(yPoints, i);
        yPoints_data = yPoints->data;
        for (i = 0; i <= kd; i++) {
          yPoints_data[i] = (float)((sqrtM - 1.0F) + -2.0 * (double)i);
        }
      } else {
        ndbl = floor(((double)-(sqrtM - 1.0F) - (sqrtM - 1.0F)) / -2.0 + 0.5);
        apnd = (sqrtM - 1.0F) + ndbl * -2.0;
        cdiff = -(sqrtM - 1.0F) - apnd;
        if (fabs(cdiff) < 2.384185791015625E-7 *
                              fmax(fabs(sqrtM - 1.0F), fabs(-(sqrtM - 1.0F)))) {
          ndbl++;
          nbits = -(sqrtM - 1.0F);
        } else if (cdiff > 0.0) {
          nbits = (float)((sqrtM - 1.0F) + (ndbl - 1.0) * -2.0);
        } else {
          ndbl++;
          nbits = (float)apnd;
        }
        if (ndbl >= 0.0) {
          ibmat = (int)ndbl;
        } else {
          ibmat = 0;
        }
        i = yPoints->size[0] * yPoints->size[1];
        yPoints->size[0] = 1;
        yPoints->size[1] = ibmat;
        emxEnsureCapacity_real32_T(yPoints, i);
        yPoints_data = yPoints->data;
        if (ibmat > 0) {
          yPoints_data[0] = sqrtM - 1.0F;
          if (ibmat > 1) {
            yPoints_data[ibmat - 1] = nbits;
            nm1d2 = (ibmat - 1) / 2;
            for (k = 0; k <= nm1d2 - 2; k++) {
              kd = (k + 1) * -2;
              yPoints_data[k + 1] = (sqrtM - 1.0F) + (float)kd;
              yPoints_data[(ibmat - k) - 2] = nbits - (float)kd;
            }
            if (nm1d2 << 1 == ibmat - 1) {
              yPoints_data[nm1d2] = ((sqrtM - 1.0F) + nbits) / 2.0F;
            } else {
              kd = nm1d2 * -2;
              yPoints_data[nm1d2] = (sqrtM - 1.0F) + (float)kd;
              yPoints_data[nm1d2 + 1] = nbits - (float)kd;
            }
          }
        }
      }
      i = (int)sqrtM;
      k = x->size[0] * x->size[1];
      x->size[0] = (int)sqrtM;
      x->size[1] = xPoints->size[1];
      emxEnsureCapacity_real32_T(x, k);
      x_data = x->data;
      kd = xPoints->size[1];
      for (nm1d2 = 0; nm1d2 < kd; nm1d2++) {
        ibmat = nm1d2 * (int)sqrtM;
        for (itilerow = 0; itilerow < i; itilerow++) {
          x_data[ibmat + itilerow] = xPoints_data[nm1d2];
        }
      }
      k = a->size[0];
      a->size[0] = yPoints->size[1];
      emxEnsureCapacity_real32_T(a, k);
      a_data = a->data;
      kd = yPoints->size[1];
      for (k = 0; k < kd; k++) {
        a_data[k] = yPoints_data[k];
      }
      k = y->size[0];
      y->size[0] = a->size[0] * (int)sqrtM;
      emxEnsureCapacity_real32_T(y, k);
      xPoints_data = y->data;
      kd = a->size[0];
      for (itilerow = 0; itilerow < i; itilerow++) {
        nm1d2 = itilerow * kd;
        for (k = 0; k < kd; k++) {
          xPoints_data[nm1d2 + k] = a_data[k];
        }
      }
      kd = x->size[0] * x->size[1];
      i = constellation->size[0] * constellation->size[1];
      constellation->size[0] = 1;
      constellation->size[1] = kd;
      emxEnsureCapacity_creal32_T(constellation, i);
      constellation_data = constellation->data;
      for (i = 0; i < kd; i++) {
        constellation_data[i].re = x_data[i];
        constellation_data[i].im = xPoints_data[i];
      }
    }
    emxFree_real32_T(&a);
    emxFree_real32_T(&y);
    emxFree_real32_T(&x);
    emxFree_real32_T(&yPoints);
    emxFree_real32_T(&xPoints);
    i = constellation->size[0] * constellation->size[1];
    constellation->size[0] = 1;
    emxEnsureCapacity_creal32_T(constellation, i);
    constellation_data = constellation->data;
    kd = constellation->size[1] - 1;
    for (i = 0; i <= kd; i++) {
      sqrtM = constellation_data[i].re;
      nbits = constellation_data[i].im;
      constellation_data[i].re = sqrtM - nbits * 0.0F;
      constellation_data[i].im = sqrtM * 0.0F + nbits;
    }
  }
}

/*
 * File trailer for d_getSquareConstellation.c
 *
 * [EOF]
 */
