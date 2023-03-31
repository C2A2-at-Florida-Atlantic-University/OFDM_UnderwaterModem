/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_Decimate.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_Decimate.h"
#include "h_Decimate_emxutil.h"
#include "h_Decimate_rtwutil.h"
#include "h_Decimate_types.h"
#include "h_filter.h"
#include "h_fir1.h"
#include "h_grpdelay.h"
#include "rt_nonfinite.h"
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
 * y=decimate(x,factor,1024,'fir');
 *
 * Arguments    : const emxArray_creal_T *x
 *                double Factor
 *                emxArray_creal_T *y
 * Return Type  : void
 */
void Decimate(const emxArray_creal_T *x, double Factor, emxArray_creal_T *y)
{
  static creal_T b_itemp_data[2050];
  static creal_T b_y[1025];
  static creal_T itemp[1025];
  static creal_T zf[1024];
  static creal_T zi[1024];
  emxArray_creal_T *b_itemp;
  emxArray_creal_T *odata;
  emxArray_real_T *list;
  const creal_T *x_data;
  creal_T *itemp_data;
  creal_T *odata_data;
  creal_T *y_data;
  double b[1025];
  double a;
  double cdiff;
  double ndbl;
  double *list_data;
  int i;
  int i1;
  int k;
  int loop_ub;
  int nm1d2;
  x_data = x->data;
  /*  FIR filter */
  fir1(1.0 / Factor, b);
  /*  prepend sequence with mirror image of first points so that transients */
  /*  can be eliminated. then do same thing at right end of data sequence. */
  ndbl = 2.0 * x_data[0].re;
  cdiff = 2.0 * x_data[0].im;
  for (i = 0; i < 1025; i++) {
    b_y[i].re = ndbl - x_data[1025 - i].re;
    b_y[i].im = cdiff - x_data[1025 - i].im;
  }
  filter(b, b_y, itemp, zi);
  h_emxInit_creal_T(&odata, 2);
  b_filter(b, x, zi, odata, zf);
  odata_data = odata->data;
  /*  row data */
  ndbl = 2.0 * x_data[x->size[1] - 1].re;
  cdiff = 2.0 * x_data[x->size[1] - 1].im;
  h_emxInit_creal_T(&b_itemp, 2);
  i = b_itemp->size[0] * b_itemp->size[1];
  b_itemp->size[0] = 1;
  b_itemp->size[1] = 2050;
  h_emxEnsureCapacity_creal_T(b_itemp, i);
  itemp_data = b_itemp->data;
  for (i = 0; i < 2050; i++) {
    itemp_data[i].re = ndbl - x_data[(x->size[1] - i) - 2].re;
    itemp_data[i].im = cdiff - x_data[(x->size[1] - i) - 2].im;
  }
  loop_ub = b_itemp->size[0] * b_itemp->size[1] - 1;
  for (i = 0; i <= loop_ub; i++) {
    b_itemp_data[i] = itemp_data[i];
  }
  double gd[8];
  c_filter(b, b_itemp_data, zf, b_itemp);
  itemp_data = b_itemp->data;
  /*  finally, select only every r'th point from the interior of the lowpass */
  /*  filtered sequence */
  grpdelay(b, gd);
  a = rt_roundd_snf(gd[0] + 1.25);
  h_emxInit_real_T(&list);
  list_data = list->data;
  if (rtIsNaN(a) || rtIsNaN(Factor)) {
    i = list->size[0] * list->size[1];
    list->size[0] = 1;
    list->size[1] = 1;
    h_emxEnsureCapacity_real_T(list, i);
    list_data = list->data;
    list_data[0] = rtNaN;
  } else if ((Factor == 0.0) || ((a < x->size[1]) && (Factor < 0.0)) ||
             ((x->size[1] < a) && (Factor > 0.0))) {
    list->size[0] = 1;
    list->size[1] = 0;
  } else if (rtIsInf(a) && (rtIsInf(Factor) || (a == x->size[1]))) {
    i = list->size[0] * list->size[1];
    list->size[0] = 1;
    list->size[1] = 1;
    h_emxEnsureCapacity_real_T(list, i);
    list_data = list->data;
    list_data[0] = rtNaN;
  } else if (rtIsInf(Factor)) {
    i = list->size[0] * list->size[1];
    list->size[0] = 1;
    list->size[1] = 1;
    h_emxEnsureCapacity_real_T(list, i);
    list_data = list->data;
    list_data[0] = a;
  } else if (floor(Factor) == Factor) {
    i = list->size[0] * list->size[1];
    list->size[0] = 1;
    list->size[1] = (int)(((double)x->size[1] - a) / Factor) + 1;
    h_emxEnsureCapacity_real_T(list, i);
    list_data = list->data;
    loop_ub = (int)(((double)x->size[1] - a) / Factor);
    for (i = 0; i <= loop_ub; i++) {
      list_data[i] = a + Factor * (double)i;
    }
  } else {
    double apnd;
    ndbl = floor(((double)x->size[1] - a) / Factor + 0.5);
    apnd = a + ndbl * Factor;
    if (Factor > 0.0) {
      cdiff = apnd - (double)x->size[1];
    } else {
      cdiff = (double)x->size[1] - apnd;
    }
    if (fabs(cdiff) < 4.4408920985006262E-16 * fmax(fabs(a), x->size[1])) {
      ndbl++;
      apnd = x->size[1];
    } else if (cdiff > 0.0) {
      apnd = a + (ndbl - 1.0) * Factor;
    } else {
      ndbl++;
    }
    if (ndbl >= 0.0) {
      loop_ub = (int)ndbl;
    } else {
      loop_ub = 0;
    }
    i = list->size[0] * list->size[1];
    list->size[0] = 1;
    list->size[1] = loop_ub;
    h_emxEnsureCapacity_real_T(list, i);
    list_data = list->data;
    if (loop_ub > 0) {
      list_data[0] = a;
      if (loop_ub > 1) {
        list_data[loop_ub - 1] = apnd;
        nm1d2 = (loop_ub - 1) / 2;
        for (k = 0; k <= nm1d2 - 2; k++) {
          cdiff = ((double)k + 1.0) * Factor;
          list_data[k + 1] = a + cdiff;
          list_data[(loop_ub - k) - 2] = apnd - cdiff;
        }
        if (nm1d2 << 1 == loop_ub - 1) {
          list_data[nm1d2] = (a + apnd) / 2.0;
        } else {
          cdiff = (double)nm1d2 * Factor;
          list_data[nm1d2] = a + cdiff;
          list_data[nm1d2 + 1] = apnd - cdiff;
        }
      }
    }
  }
  ndbl = Factor - (double)(x->size[1] - (int)list_data[list->size[1] - 1]);
  /*  row data */
  cdiff = (ndbl + (ceil((double)x->size[1] / Factor) - (double)list->size[1]) *
                      Factor) -
          1.0;
  if ((Factor == 0.0) || (((Factor > 0.0) && (ndbl > cdiff)) ||
                          ((Factor < 0.0) && (cdiff > ndbl)))) {
    i = 0;
    k = 1;
    i1 = -1;
  } else {
    i = (int)ndbl - 1;
    k = (int)Factor;
    i1 = (int)cdiff - 1;
  }
  nm1d2 = y->size[0] * y->size[1];
  y->size[0] = 1;
  loop_ub = div_s32(i1 - i, k);
  y->size[1] = (list->size[1] + loop_ub) + 1;
  h_emxEnsureCapacity_creal_T(y, nm1d2);
  y_data = y->data;
  nm1d2 = list->size[1];
  for (i1 = 0; i1 < nm1d2; i1++) {
    y_data[i1] = odata_data[(int)list_data[i1] - 1];
  }
  h_emxFree_creal_T(&odata);
  for (i1 = 0; i1 <= loop_ub; i1++) {
    y_data[i1 + list->size[1]] = itemp_data[i + k * i1];
  }
  h_emxFree_creal_T(&b_itemp);
  h_emxFree_real_T(&list);
}

/*
 * File trailer for h_Decimate.c
 *
 * [EOF]
 */
