/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: getConstellation.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 10:54:48
 */

/* Include Files */
#include "getConstellation.h"
#include "log2.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Function Declarations */
static double rt_powd_snf(double u0, double u1);

/* Function Definitions */
/*
 * Arguments    : double u0
 *                double u1
 * Return Type  : double
 */
static double rt_powd_snf(double u0, double u1)
{
  double y;
  if (rtIsNaN(u0) || rtIsNaN(u1)) {
    y = rtNaN;
  } else {
    double d;
    double d1;
    d = fabs(u0);
    d1 = fabs(u1);
    if (rtIsInf(u1)) {
      if (d == 1.0) {
        y = 1.0;
      } else if (d > 1.0) {
        if (u1 > 0.0) {
          y = rtInf;
        } else {
          y = 0.0;
        }
      } else if (u1 > 0.0) {
        y = 0.0;
      } else {
        y = rtInf;
      }
    } else if (d1 == 0.0) {
      y = 1.0;
    } else if (d1 == 1.0) {
      if (u1 > 0.0) {
        y = u0;
      } else {
        y = 1.0 / u0;
      }
    } else if (u1 == 2.0) {
      y = u0 * u0;
    } else if ((u1 == 0.5) && (u0 >= 0.0)) {
      y = sqrt(u0);
    } else if ((u0 < 0.0) && (u1 > floor(u1))) {
      y = rtNaN;
    } else {
      y = pow(u0, u1);
    }
  }
  return y;
}

/*
 * Arguments    : double M
 *                creal_T const_data[]
 *                int const_size[2]
 * Return Type  : void
 */
void getConstellation(double M, creal_T const_data[], int const_size[2])
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
  double xPoints_data[11];
  double yPoints_data[11];
  double nbits;
  int i;
  int ibmat;
  int itilerow;
  int kd;
  nbits = b_log2(M);
  kd = (int)M;
  const_size[1] = (int)M;
  if (nbits == 1.0) {
    const_size[0] = 1;
    const_size[1] = (int)M;
    for (i = 0; i < kd; i++) {
      const_data[i].re = 2.0 * (double)i - 1.0;
      const_data[i].im = -0.0;
    }
  } else {
    double sqrtM;
    if (rtIsNaN(nbits) || rtIsInf(nbits)) {
      sqrtM = rtNaN;
    } else if (nbits == 0.0) {
      sqrtM = 0.0;
    } else {
      sqrtM = fmod(nbits, 2.0);
      if (sqrtM == 0.0) {
        sqrtM = 0.0;
      } else if (nbits < 0.0) {
        sqrtM += 2.0;
      }
    }
    if ((sqrtM != 0.0) && (nbits > 3.0)) {
      double mI;
      double mQ;
      double tmp2;
      double tmp3;
      double tmp4;
      double tmp5;
      mI = rt_powd_snf(2.0, (nbits + 1.0) / 2.0);
      mQ = rt_powd_snf(2.0, (nbits - 1.0) / 2.0);
      nbits = trunc((M - 1.0) / mI);
      tmp2 = 3.0 * mI / 4.0;
      tmp3 = mI / 2.0;
      tmp4 = mQ / 2.0;
      tmp5 = 2.0 * mQ;
      i = (int)((M - 1.0) + 1.0);
      if (i - 1 >= 0) {
        if (nbits < 2.147483648E+9) {
          if (nbits >= -2.147483648E+9) {
            itilerow = (int)nbits;
          } else {
            itilerow = MIN_int32_T;
          }
        } else if (nbits >= 2.147483648E+9) {
          itilerow = MAX_int32_T;
        } else {
          itilerow = 0;
        }
      }
      for (kd = 0; kd < i; kd++) {
        double apnd;
        nbits = 2.0 * trunc((double)kd / mQ) + (1.0 - mI);
        sqrtM = -(2.0 * (double)(kd & itilerow) + (1.0 - mQ));
        apnd = fabs(floor(nbits));
        if (apnd > tmp2) {
          double cdiff;
          int nm1d2;
          cdiff = fabs(floor(sqrtM));
          if (nbits < 0.0) {
            nm1d2 = -1;
          } else {
            nm1d2 = (nbits > 0.0);
          }
          if (sqrtM < 0.0) {
            ibmat = -1;
          } else {
            ibmat = (sqrtM > 0.0);
          }
          if (cdiff > tmp4) {
            nbits = (double)nm1d2 * (apnd - tmp3);
            sqrtM = (double)ibmat * (tmp5 - cdiff);
          } else {
            nbits = (double)nm1d2 * (mI - apnd);
            sqrtM = (double)ibmat * (mQ + cdiff);
          }
        }
        const_data[kd].re = nbits;
        const_data[kd].im = sqrtM;
      }
    } else if (nbits == 3.0) {
      const_size[1] = (int)M;
      for (i = 0; i < kd; i++) {
        const_data[i].re = icv[i].re;
        const_data[i].im = icv[i].im;
      }
    } else {
      double x_data[121];
      double y_data[121];
      double apnd;
      double cdiff;
      int b_n;
      int n;
      int nm1d2;
      sqrtM = rt_powd_snf(2.0, nbits / 2.0);
      if (rtIsNaN(-(sqrtM - 1.0)) || rtIsNaN(sqrtM - 1.0)) {
        n = 1;
        xPoints_data[0] = rtNaN;
      } else if (sqrtM - 1.0 < -(sqrtM - 1.0)) {
        n = 0;
      } else if ((rtIsInf(-(sqrtM - 1.0)) || rtIsInf(sqrtM - 1.0)) &&
                 (-(sqrtM - 1.0) == sqrtM - 1.0)) {
        n = 1;
        xPoints_data[0] = rtNaN;
      } else if (floor(-(sqrtM - 1.0)) == -(sqrtM - 1.0)) {
        kd = (int)(((sqrtM - 1.0) - (-(sqrtM - 1.0))) / 2.0);
        n = kd + 1;
        for (i = 0; i <= kd; i++) {
          xPoints_data[i] = -(sqrtM - 1.0) + 2.0 * (double)i;
        }
      } else {
        nbits = floor(((sqrtM - 1.0) - (-(sqrtM - 1.0))) / 2.0 + 0.5);
        apnd = -(sqrtM - 1.0) + nbits * 2.0;
        cdiff = apnd - (sqrtM - 1.0);
        if (fabs(cdiff) < 4.4408920985006262E-16 *
                              fmax(fabs(-(sqrtM - 1.0)), fabs(sqrtM - 1.0))) {
          nbits++;
          apnd = sqrtM - 1.0;
        } else if (cdiff > 0.0) {
          apnd = -(sqrtM - 1.0) + (nbits - 1.0) * 2.0;
        } else {
          nbits++;
        }
        if (nbits >= 0.0) {
          n = (int)nbits;
        } else {
          n = 0;
        }
        if (n > 0) {
          xPoints_data[0] = -(sqrtM - 1.0);
          if (n > 1) {
            xPoints_data[n - 1] = apnd;
            nm1d2 = (unsigned char)(n - 1) >> 1;
            for (ibmat = 0; ibmat <= nm1d2 - 2; ibmat++) {
              kd = (ibmat + 1) << 1;
              xPoints_data[ibmat + 1] = -(sqrtM - 1.0) + (double)kd;
              xPoints_data[(n - ibmat) - 2] = apnd - (double)kd;
            }
            i = nm1d2 << 1;
            if (i == n - 1) {
              xPoints_data[nm1d2] = (-(sqrtM - 1.0) + apnd) / 2.0;
            } else {
              xPoints_data[nm1d2] = -(sqrtM - 1.0) + (double)i;
              xPoints_data[nm1d2 + 1] = apnd - (double)i;
            }
          }
        }
      }
      if (rtIsNaN(sqrtM - 1.0) || rtIsNaN(-(sqrtM - 1.0))) {
        b_n = 1;
        yPoints_data[0] = rtNaN;
      } else if (sqrtM - 1.0 < -(sqrtM - 1.0)) {
        b_n = 0;
      } else if ((rtIsInf(sqrtM - 1.0) || rtIsInf(-(sqrtM - 1.0))) &&
                 (sqrtM - 1.0 == -(sqrtM - 1.0))) {
        b_n = 1;
        yPoints_data[0] = rtNaN;
      } else if (floor(sqrtM - 1.0) == sqrtM - 1.0) {
        kd = (int)((-(sqrtM - 1.0) - (sqrtM - 1.0)) / -2.0);
        b_n = kd + 1;
        for (i = 0; i <= kd; i++) {
          yPoints_data[i] = (sqrtM - 1.0) + -2.0 * (double)i;
        }
      } else {
        nbits = floor((-(sqrtM - 1.0) - (sqrtM - 1.0)) / -2.0 + 0.5);
        apnd = (sqrtM - 1.0) + nbits * -2.0;
        cdiff = -(sqrtM - 1.0) - apnd;
        if (fabs(cdiff) < 4.4408920985006262E-16 *
                              fmax(fabs(sqrtM - 1.0), fabs(-(sqrtM - 1.0)))) {
          nbits++;
          apnd = -(sqrtM - 1.0);
        } else if (cdiff > 0.0) {
          apnd = (sqrtM - 1.0) + (nbits - 1.0) * -2.0;
        } else {
          nbits++;
        }
        if (nbits >= 0.0) {
          b_n = (int)nbits;
        } else {
          b_n = 0;
        }
        if (b_n > 0) {
          yPoints_data[0] = sqrtM - 1.0;
          if (b_n > 1) {
            yPoints_data[b_n - 1] = apnd;
            nm1d2 = (unsigned char)(b_n - 1) >> 1;
            for (ibmat = 0; ibmat <= nm1d2 - 2; ibmat++) {
              kd = (ibmat + 1) * -2;
              yPoints_data[ibmat + 1] = (sqrtM - 1.0) + (double)kd;
              yPoints_data[(b_n - ibmat) - 2] = apnd - (double)kd;
            }
            if (nm1d2 << 1 == b_n - 1) {
              yPoints_data[nm1d2] = ((sqrtM - 1.0) + apnd) / 2.0;
            } else {
              kd = nm1d2 * -2;
              yPoints_data[nm1d2] = (sqrtM - 1.0) + (double)kd;
              yPoints_data[nm1d2 + 1] = apnd - (double)kd;
            }
          }
        }
      }
      nm1d2 = (int)sqrtM;
      for (kd = 0; kd < n; kd++) {
        ibmat = kd * (int)sqrtM;
        for (itilerow = 0; itilerow < nm1d2; itilerow++) {
          x_data[ibmat + itilerow] = xPoints_data[kd];
        }
      }
      if (b_n - 1 >= 0) {
        memcpy(&xPoints_data[0], &yPoints_data[0],
               (unsigned int)b_n * sizeof(double));
      }
      for (itilerow = 0; itilerow < nm1d2; itilerow++) {
        kd = itilerow * b_n;
        for (ibmat = 0; ibmat < b_n; ibmat++) {
          y_data[kd + ibmat] = xPoints_data[ibmat];
        }
      }
      kd = (int)sqrtM * n;
      const_size[1] = kd;
      for (i = 0; i < kd; i++) {
        const_data[i].re = x_data[i];
        const_data[i].im = y_data[i];
      }
    }
    const_size[0] = 1;
    kd = const_size[1] - 1;
    for (i = 0; i <= kd; i++) {
      sqrtM = const_data[i].re;
      nbits = const_data[i].im;
      const_data[i].re = sqrtM - nbits * 0.0;
      const_data[i].im = sqrtM * 0.0 + nbits;
    }
  }
}

/*
 * File trailer for getConstellation.c
 *
 * [EOF]
 */
