/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_xzgeqp3.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_xzgeqp3.h"
#include "h_Decimate_types.h"
#include "h_xnrm2.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Function Declarations */
static int div_nde_s32_floor(int numerator);

static double rt_hypotd_snf(double u0, double u1);

/* Function Definitions */
/*
 * Arguments    : int numerator
 * Return Type  : int
 */
static int div_nde_s32_floor(int numerator)
{
  int i;
  if ((numerator < 0) && (numerator % 513 != 0)) {
    i = -1;
  } else {
    i = 0;
  }
  return numerator / 513 + i;
}

/*
 * Arguments    : double u0
 *                double u1
 * Return Type  : double
 */
static double rt_hypotd_snf(double u0, double u1)
{
  double a;
  double b;
  double y;
  a = fabs(u0);
  b = fabs(u1);
  if (a < b) {
    a /= b;
    y = b * sqrt(a * a + 1.0);
  } else if (a > b) {
    b /= a;
    y = a * sqrt(b * b + 1.0);
  } else if (rtIsNaN(b)) {
    y = rtNaN;
  } else {
    y = a * 1.4142135623730951;
  }
  return y;
}

/*
 * Arguments    : emxArray_real_T *A
 *                int n
 *                double tau_data[]
 *                int jpvt_data[]
 * Return Type  : void
 */
void qrpf(emxArray_real_T *A, int n, double tau_data[], int jpvt_data[])
{
  double vn1_data[512];
  double vn2_data[512];
  double work_data[512];
  double absxk;
  double scale;
  double smax;
  double t;
  double *A_data;
  int b_i;
  int i;
  int iy;
  int j;
  int kend;
  int lastv;
  int nmi;
  int temp_tmp;
  A_data = A->data;
  kend = A->size[1];
  if (kend - 1 >= 0) {
    memset(&work_data[0], 0, (unsigned int)kend * sizeof(double));
  }
  kend = A->size[1];
  if (kend - 1 >= 0) {
    memset(&vn1_data[0], 0, (unsigned int)kend * sizeof(double));
  }
  kend = A->size[1];
  if (kend - 1 >= 0) {
    memset(&vn2_data[0], 0, (unsigned int)kend * sizeof(double));
  }
  i = (unsigned short)n;
  for (j = 0; j < i; j++) {
    iy = j * 513;
    smax = 0.0;
    scale = 3.3121686421112381E-170;
    kend = iy + 513;
    for (lastv = iy + 1; lastv <= kend; lastv++) {
      absxk = fabs(A_data[lastv - 1]);
      if (absxk > scale) {
        t = scale / absxk;
        smax = smax * t * t + 1.0;
        scale = absxk;
      } else {
        t = absxk / scale;
        smax += t * t;
      }
    }
    absxk = scale * sqrt(smax);
    vn1_data[j] = absxk;
    vn2_data[j] = absxk;
  }
  for (b_i = 0; b_i < i; b_i++) {
    int i1;
    int ii;
    int ip1;
    int pvt;
    ip1 = b_i + 2;
    ii = b_i * 513 + b_i;
    nmi = n - b_i;
    if (nmi < 1) {
      kend = -1;
    } else {
      kend = 0;
      if (nmi > 1) {
        smax = fabs(vn1_data[b_i]);
        for (lastv = 2; lastv <= nmi; lastv++) {
          scale = fabs(vn1_data[(b_i + lastv) - 1]);
          if (scale > smax) {
            kend = lastv - 1;
            smax = scale;
          }
        }
      }
    }
    pvt = b_i + kend;
    if (pvt + 1 != b_i + 1) {
      kend = pvt * 513;
      iy = b_i * 513;
      for (lastv = 0; lastv < 513; lastv++) {
        temp_tmp = kend + lastv;
        smax = A_data[temp_tmp];
        i1 = iy + lastv;
        A_data[temp_tmp] = A_data[i1];
        A_data[i1] = smax;
      }
      kend = jpvt_data[pvt];
      jpvt_data[pvt] = jpvt_data[b_i];
      jpvt_data[b_i] = kend;
      vn1_data[pvt] = vn1_data[b_i];
      vn2_data[pvt] = vn2_data[b_i];
    }
    t = A_data[ii];
    iy = ii + 2;
    tau_data[b_i] = 0.0;
    smax = xnrm2(512 - b_i, A, ii + 2);
    if (smax != 0.0) {
      scale = rt_hypotd_snf(A_data[ii], smax);
      if (A_data[ii] >= 0.0) {
        scale = -scale;
      }
      if (fabs(scale) < 1.0020841800044864E-292) {
        kend = 0;
        i1 = (ii - b_i) + 513;
        do {
          kend++;
          for (lastv = iy; lastv <= i1; lastv++) {
            A_data[lastv - 1] *= 9.9792015476736E+291;
          }
          scale *= 9.9792015476736E+291;
          t *= 9.9792015476736E+291;
        } while ((fabs(scale) < 1.0020841800044864E-292) && (kend < 20));
        scale = rt_hypotd_snf(t, xnrm2(512 - b_i, A, ii + 2));
        if (t >= 0.0) {
          scale = -scale;
        }
        tau_data[b_i] = (scale - t) / scale;
        smax = 1.0 / (t - scale);
        for (lastv = iy; lastv <= i1; lastv++) {
          A_data[lastv - 1] *= smax;
        }
        for (lastv = 0; lastv < kend; lastv++) {
          scale *= 1.0020841800044864E-292;
        }
        t = scale;
      } else {
        tau_data[b_i] = (scale - A_data[ii]) / scale;
        smax = 1.0 / (A_data[ii] - scale);
        i1 = (ii - b_i) + 513;
        for (lastv = iy; lastv <= i1; lastv++) {
          A_data[lastv - 1] *= smax;
        }
        t = scale;
      }
    }
    A_data[ii] = t;
    if (b_i + 1 < n) {
      t = A_data[ii];
      A_data[ii] = 1.0;
      temp_tmp = ii + 514;
      if (tau_data[b_i] != 0.0) {
        bool exitg2;
        lastv = 513 - b_i;
        kend = (ii - b_i) + 512;
        while ((lastv > 0) && (A_data[kend] == 0.0)) {
          lastv--;
          kend--;
        }
        pvt = nmi - 2;
        exitg2 = false;
        while ((!exitg2) && (pvt + 1 > 0)) {
          int exitg1;
          kend = (ii + pvt * 513) + 513;
          nmi = kend;
          do {
            exitg1 = 0;
            if (nmi + 1 <= kend + lastv) {
              if (A_data[nmi] != 0.0) {
                exitg1 = 1;
              } else {
                nmi++;
              }
            } else {
              pvt--;
              exitg1 = 2;
            }
          } while (exitg1 == 0);
          if (exitg1 == 1) {
            exitg2 = true;
          }
        }
      } else {
        lastv = 0;
        pvt = -1;
      }
      if (lastv > 0) {
        if (pvt + 1 != 0) {
          if (pvt >= 0) {
            memset(&work_data[0], 0, (unsigned int)(pvt + 1) * sizeof(double));
          }
          i1 = (ii + 513 * pvt) + 514;
          for (j = temp_tmp; j <= i1; j += 513) {
            smax = 0.0;
            iy = (j + lastv) - 1;
            for (nmi = j; nmi <= iy; nmi++) {
              smax += A_data[nmi - 1] * A_data[(ii + nmi) - j];
            }
            kend = div_nde_s32_floor((j - ii) - 514);
            work_data[kend] += smax;
          }
        }
        if (!(-tau_data[b_i] == 0.0)) {
          kend = ii;
          for (j = 0; j <= pvt; j++) {
            absxk = work_data[j];
            if (absxk != 0.0) {
              smax = absxk * -tau_data[b_i];
              i1 = kend + 514;
              iy = lastv + kend;
              for (temp_tmp = i1; temp_tmp <= iy + 513; temp_tmp++) {
                A_data[temp_tmp - 1] +=
                    A_data[((ii + temp_tmp) - kend) - 514] * smax;
              }
            }
            kend += 513;
          }
        }
      }
      A_data[ii] = t;
    }
    for (j = ip1; j <= n; j++) {
      kend = b_i + (j - 1) * 513;
      absxk = vn1_data[j - 1];
      if (absxk != 0.0) {
        smax = fabs(A_data[kend]) / absxk;
        smax = 1.0 - smax * smax;
        if (smax < 0.0) {
          smax = 0.0;
        }
        scale = absxk / vn2_data[j - 1];
        scale = smax * (scale * scale);
        if (scale <= 1.4901161193847656E-8) {
          absxk = xnrm2(512 - b_i, A, kend + 2);
          vn1_data[j - 1] = absxk;
          vn2_data[j - 1] = absxk;
        } else {
          vn1_data[j - 1] = absxk * sqrt(smax);
        }
      }
    }
  }
}

/*
 * File trailer for h_xzgeqp3.c
 *
 * [EOF]
 */
