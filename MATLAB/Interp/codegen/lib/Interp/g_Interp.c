/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_Interp.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 20:42:58
 */

/* Include Files */
#include "g_Interp.h"
#include "g_Interp_emxutil.h"
#include "g_Interp_types.h"
#include "g_div.h"
#include "g_eml_mtimes_helper.h"
#include "g_filter.h"
#include "g_inv.h"
#include <math.h>

/* Function Declarations */
static int div_s32(int numerator, int denominator);

/* Function Definitions */
/*
 * Arguments    : int numerator
 *                int denominator
 * Return Type  : int
 */
static int div_s32(int numerator, int denominator)
{
  int quotient;
  if (denominator == 0) {
    if (numerator >= 0) {
      quotient = MAX_int32_T;
    } else {
      quotient = MIN_int32_T;
    }
  } else {
    unsigned int tempAbsQuotient;
    unsigned int u;
    if (numerator < 0) {
      tempAbsQuotient = ~(unsigned int)numerator + 1U;
    } else {
      tempAbsQuotient = (unsigned int)numerator;
    }
    if (denominator < 0) {
      u = ~(unsigned int)denominator + 1U;
    } else {
      u = (unsigned int)denominator;
    }
    tempAbsQuotient /= u;
    if ((numerator < 0) != (denominator < 0)) {
      quotient = -(int)tempAbsQuotient;
    } else {
      quotient = (int)tempAbsQuotient;
    }
  }
  return quotient;
}

/*
 * Arguments    : const g_emxArray_creal_T *x
 *                short factor
 *                g_emxArray_creal_T *y
 * Return Type  : void
 */
void Interp(const g_emxArray_creal_T *x, short factor, g_emxArray_creal_T *y)
{
  static const double dv[100] = {1.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 -2.8271597168564584E-16,
                                 1.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 -6.6521405102504919E-17,
                                 -2.8271597168564584E-16,
                                 1.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 7.5390925782838923E-17,
                                 -2.8271597168564584E-16,
                                 1.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 7.5390925782838923E-17,
                                 2.1314218838975715E-32,
                                 -8.6989529749429508E-17,
                                 -2.8271597168564584E-16,
                                 1.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 6.1629758220391547E-33,
                                 -8.6989529749429508E-17,
                                 -2.459332942958736E-32,
                                 1.0280580788568945E-16,
                                 -2.8271597168564579E-16,
                                 1.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 -8.6989529749429508E-17,
                                 -1.8430353607548206E-32,
                                 1.0280580788568943E-16,
                                 2.2901868049291367E-32,
                                 1.5501250064709621E-32,
                                 -2.8271597168564584E-16,
                                 1.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 0.0,
                                 1.0280580788568943E-16,
                                 2.9064843871330521E-32,
                                 -7.750625032354801E-33,
                                 -1.8541138737789271E-48,
                                 8.9430288834863177E-33,
                                 -2.8271597168564584E-16,
                                 1.0,
                                 0.0,
                                 0.0,
                                 1.0280580788568943E-16,
                                 2.2901868049291367E-32,
                                 6.838786793254249E-33,
                                 6.1629758220391547E-33,
                                 -7.7506250323548078E-33,
                                 -1.4661821719313512E-48,
                                 1.5106004705525471E-32,
                                 -2.8271597168564584E-16,
                                 1.0,
                                 0.0,
                                 -6.1629758220391547E-33,
                                 -1.7423716980029416E-48,
                                 -4.0996981129481033E-49,
                                 1.5454001808265631E-65,
                                 6.1629758220391547E-33,
                                 6.1629758220391561E-33,
                                 1.206257329386652E-48,
                                 4.6503847224610843E-64,
                                 -2.8271597168564584E-16,
                                 0.99999999999999989};
  static const double dv1[100] = {0.99999999999999989,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  -2.047525350352584E-16,
                                  1.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  -1.1442031547882591E-17,
                                  -2.0475253503525835E-16,
                                  0.99999999999999989,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  7.7963436650387522E-17,
                                  -1.533543624332264E-16,
                                  -2.0475253503525842E-16,
                                  1.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  -1.5335436243322645E-16,
                                  7.7963436650387473E-17,
                                  9.026093099042014E-18,
                                  -2.0475253503525832E-16,
                                  0.99999999999999989,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  7.7963436650387535E-17,
                                  9.026093099042014E-18,
                                  7.7963436650387522E-17,
                                  -1.8076924453607693E-16,
                                  -2.0475253503525842E-16,
                                  1.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  9.026093099042E-18,
                                  7.7963436650387522E-17,
                                  -1.8076924453607696E-16,
                                  7.79634366503875E-17,
                                  -7.796343665038751E-17,
                                  -2.0475253503525835E-16,
                                  1.0,
                                  0.0,
                                  0.0,
                                  0.0,
                                  7.7963436650387522E-17,
                                  -1.8076924453607691E-16,
                                  7.79634366503875E-17,
                                  -7.7963436650387522E-17,
                                  7.7963436650387535E-17,
                                  -7.7963436650387522E-17,
                                  -2.0475253503525832E-16,
                                  1.0,
                                  0.0,
                                  0.0,
                                  -1.8076924453607698E-16,
                                  7.7963436650387485E-17,
                                  -7.796343665038751E-17,
                                  7.7963436650387535E-17,
                                  -7.7963436650387535E-17,
                                  7.7963436650387522E-17,
                                  -7.7963436650387535E-17,
                                  -2.0475253503525832E-16,
                                  1.0,
                                  0.0,
                                  7.7963436650387535E-17,
                                  -7.79634366503875E-17,
                                  7.796343665038751E-17,
                                  -7.796343665038751E-17,
                                  7.7963436650387535E-17,
                                  -7.7963436650387535E-17,
                                  7.7963436650387522E-17,
                                  -7.7963436650387535E-17,
                                  -2.0475253503525832E-16,
                                  1.0};
  g_emxArray_creal_T *b_od;
  g_emxArray_creal_T *c_od;
  g_emxArray_creal_T *d_od;
  g_emxArray_creal_T *g_y;
  g_emxArray_creal_T *od;
  g_emxArray_creal_T *zi;
  g_emxArray_real_T *b;
  g_emxArray_real_T *b_b;
  g_emxArray_real_T *b_h;
  g_emxArray_real_T *c_y;
  g_emxArray_real_T *e_y;
  g_emxArray_real_T *f_y;
  g_emxArray_real_T *h;
  g_emxArray_real_T *y_tmp;
  const creal_T *x_data;
  creal_T *b_y_data;
  creal_T *c_y_data;
  creal_T *od_data;
  double d[200];
  double d_y[200];
  double a[100];
  double am[100];
  double ap[100];
  double X[20];
  double b_y[20];
  double bkj;
  double y_im;
  double *b_data;
  double *h_data;
  double *y_tmp_data;
  int y_size[2];
  int aoffset;
  int b_i;
  int boffset;
  int coffset;
  int i;
  int i1;
  int j;
  int k;
  int nx;
  short y_data[32767];
  x_data = x->data;
  /* [~,coeff]=interp(x,factor,10,1); */
  /*  y=upsample(x,factor); */
  /*  y = filter(coeff,1,y); */
  /*  calculate AP and AM matrices for inversion */
  /*  Compute matrix inverses using Cholesky decomposition for more robustness
   */
  inv(dv, a);
  for (i = 0; i < 10; i++) {
    for (i1 = 0; i1 < 10; i1++) {
      bkj = 0.0;
      for (j = 0; j < 10; j++) {
        bkj += a[i + 10 * j] * a[i1 + 10 * j];
      }
      ap[i + 10 * i1] = bkj;
    }
  }
  inv(dv1, a);
  for (i = 0; i < 10; i++) {
    for (i1 = 0; i1 < 10; i1++) {
      bkj = 0.0;
      for (j = 0; j < 10; j++) {
        bkj += a[i + 10 * j] * a[i1 + 10 * j];
      }
      am[i + 10 * i1] = bkj;
    }
  }
  /*  now calculate D based on INV(AM) and INV(AP) */
  /* d = zeros(2*n,n,cName); */
  for (i = 0; i < 10; i++) {
    for (i1 = 0; i1 < 10; i1++) {
      j = i1 + 10 * i;
      bkj = ap[j];
      y_im = am[j];
      nx = (i1 << 1) + 20 * i;
      d[nx] = bkj + y_im;
      d[nx + 1] = bkj - y_im;
    }
  }
  /*  set up arrays to calculate interpolating filter B */
  if (factor - 1 < 0) {
    y_size[0] = 1;
    y_size[1] = 0;
  } else {
    y_size[0] = 1;
    y_size[1] = factor;
    b_i = factor - 1;
    for (i = 0; i <= b_i; i++) {
      y_data[i] = (short)i;
    }
  }
  /* y = zeros(2*n,1,cName); */
  for (i = 0; i < 10; i++) {
    nx = i << 1;
    b_y[nx] = 10.0 - (double)i;
    b_y[nx + 1] = 9.0 - (double)i;
  }
  for (b_i = 0; b_i < 20; b_i++) {
    X[b_i] = 1.0;
  }
  for (i = 0; i < 10; i++) {
    X[i << 1] = -1.0;
  }
  g_emxInit_real_T(&c_y, 2);
  i = c_y->size[0] * c_y->size[1];
  c_y->size[0] = 20;
  c_y->size[1] = factor;
  g_emxEnsureCapacity_real_T(c_y, i);
  b_data = c_y->data;
  b_i = factor;
  for (i = 0; i < b_i; i++) {
    for (i1 = 0; i1 < 20; i1++) {
      b_data[i1 + 20 * i] = b_y[i1];
    }
  }
  for (i = 0; i < 20; i++) {
    b_y[i] = (X[i] + b_y[i]) + 2.2204460492503131E-16;
    for (i1 = 0; i1 < 10; i1++) {
      d_y[i1 + 10 * i] = 0.5 * d[i + 20 * i1];
    }
  }
  g_emxInit_real_T(&y_tmp, 2);
  if (c_y->size[1] == y_size[1]) {
    g_emxInit_real_T(&e_y, 2);
    i = e_y->size[0] * e_y->size[1];
    e_y->size[0] = 1;
    e_y->size[1] = y_size[1];
    g_emxEnsureCapacity_real_T(e_y, i);
    y_tmp_data = e_y->data;
    b_i = y_size[1];
    for (i = 0; i < b_i; i++) {
      y_tmp_data[i] = (double)y_data[i] / (double)factor;
    }
    g_emxInit_real_T(&f_y, 2);
    i = f_y->size[0] * f_y->size[1];
    f_y->size[0] = 20;
    f_y->size[1] = e_y->size[1];
    g_emxEnsureCapacity_real_T(f_y, i);
    h_data = f_y->data;
    b_i = e_y->size[1];
    for (i = 0; i < b_i; i++) {
      for (i1 = 0; i1 < 20; i1++) {
        j = i1 + 20 * i;
        h_data[j] =
            (b_data[j] + 2.2204460492503131E-16) + X[i1] * y_tmp_data[i];
      }
    }
    g_emxFree_real_T(&e_y);
    i = y_tmp->size[0] * y_tmp->size[1];
    y_tmp->size[0] = 20;
    y_tmp->size[1] = f_y->size[1];
    g_emxEnsureCapacity_real_T(y_tmp, i);
    y_tmp_data = y_tmp->data;
    b_i = 20 * f_y->size[1];
    for (i = 0; i < b_i; i++) {
      y_tmp_data[i] = 3.1415926535897931 * h_data[i];
    }
    g_emxFree_real_T(&f_y);
  } else {
    binary_expand_op(y_tmp, c_y, X, y_data, y_size, factor);
    y_tmp_data = y_tmp->data;
  }
  i = c_y->size[0] * c_y->size[1];
  c_y->size[0] = 20;
  c_y->size[1] = y_tmp->size[1];
  g_emxEnsureCapacity_real_T(c_y, i);
  b_data = c_y->data;
  b_i = 20 * y_tmp->size[1];
  for (i = 0; i < b_i; i++) {
    b_data[i] = y_tmp_data[i];
  }
  nx = 20 * y_tmp->size[1];
  for (k = 0; k < nx; k++) {
    b_data[k] = sin(b_data[k]);
  }
  if (c_y->size[1] == y_tmp->size[1]) {
    b_i = 20 * c_y->size[1];
    i = c_y->size[0] * c_y->size[1];
    c_y->size[0] = 20;
    g_emxEnsureCapacity_real_T(c_y, i);
    b_data = c_y->data;
    for (i = 0; i < b_i; i++) {
      b_data[i] /= y_tmp_data[i];
    }
  } else {
    rdivide(c_y, y_tmp);
    b_data = c_y->data;
  }
  g_emxFree_real_T(&y_tmp);
  nx = c_y->size[1];
  g_emxInit_real_T(&h, 2);
  i = h->size[0] * h->size[1];
  h->size[0] = 10;
  h->size[1] = c_y->size[1];
  g_emxEnsureCapacity_real_T(h, i);
  h_data = h->data;
  for (j = 0; j < nx; j++) {
    coffset = j * 10;
    boffset = j * 20;
    for (b_i = 0; b_i < 10; b_i++) {
      h_data[coffset + b_i] = 0.0;
    }
    for (k = 0; k < 20; k++) {
      aoffset = k * 10;
      bkj = b_data[boffset + k];
      for (b_i = 0; b_i < 10; b_i++) {
        i = coffset + b_i;
        h_data[i] += d_y[aoffset + b_i] * bkj;
      }
    }
  }
  g_emxFree_real_T(&c_y);
  g_emxInit_real_T(&b, 1);
  b_i = 20 * factor;
  i = b->size[0];
  b->size[0] = b_i + 1;
  g_emxEnsureCapacity_real_T(b, i);
  b_data = b->data;
  for (i = 0; i <= b_i; i++) {
    b_data[i] = 0.0;
  }
  i = 10 * factor;
  g_emxInit_real_T(&b_h, 2);
  i1 = b_h->size[0] * b_h->size[1];
  b_h->size[0] = h->size[1];
  b_h->size[1] = 10;
  g_emxEnsureCapacity_real_T(b_h, i1);
  y_tmp_data = b_h->data;
  nx = h->size[1];
  for (i1 = 0; i1 < 10; i1++) {
    for (j = 0; j < nx; j++) {
      y_tmp_data[j + b_h->size[0] * i1] = h_data[i1 + 10 * j];
    }
  }
  g_emxFree_real_T(&h);
  if (i < 1) {
    nx = 0;
  } else {
    nx = i;
  }
  for (i1 = 0; i1 < nx; i1++) {
    b_data[i1] = y_tmp_data[i1];
  }
  g_emxFree_real_T(&b_h);
  bkj = 0.0;
  for (k = 0; k < 20; k++) {
    double b_d;
    y_im = 3.1415926535897931 * b_y[k];
    b_d = y_im;
    y_im = sin(y_im);
    b_y[k] = y_im;
    bkj += 0.5 * d[k + 180] * (y_im / b_d);
  }
  b_data[i] = bkj;
  if (i < 1) {
    i1 = 0;
    j = 1;
    k = -1;
  } else {
    i1 = i - 1;
    j = -1;
    k = 0;
  }
  if (i + 2 > b_i + 1) {
    coffset = -1;
  } else {
    coffset = i;
  }
  g_emxInit_real_T(&b_b, 2);
  boffset = b_b->size[0] * b_b->size[1];
  b_b->size[0] = 1;
  nx = div_s32(k - i1, j);
  b_b->size[1] = nx + 1;
  g_emxEnsureCapacity_real_T(b_b, boffset);
  y_tmp_data = b_b->data;
  for (k = 0; k <= nx; k++) {
    y_tmp_data[k] = b_data[i1 + j * k];
  }
  nx = b_b->size[1];
  for (i1 = 0; i1 < nx; i1++) {
    b_data[(coffset + i1) + 1] = y_tmp_data[i1];
  }
  g_emxFree_real_T(&b_b);
  /*  use the filter B to perform the interpolation */
  if (x->size[1] > 1) {
    aoffset = x->size[1];
  } else {
    aoffset = 1;
  }
  if (aoffset == 1) {
    i1 = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = 1;
    g_emxEnsureCapacity_creal_T(y, i1);
    b_y_data = y->data;
    b_y_data[0].re = 0.0;
    b_y_data[0].im = 0.0;
  } else {
    i1 = y->size[0] * y->size[1];
    y->size[0] = 1;
    nx = factor * aoffset;
    y->size[1] = nx;
    g_emxEnsureCapacity_creal_T(y, i1);
    b_y_data = y->data;
    for (i1 = 0; i1 < nx; i1++) {
      b_y_data[i1].re = 0.0;
      b_y_data[i1].im = 0.0;
    }
  }
  /* odata = complex(zeros(1,length(idata)*r,zeros(1,length(idata)*r))); */
  i1 = aoffset * factor;
  if ((factor == 0) || ((factor > 0) && (i1 < 1))) {
    j = 1;
  } else {
    j = factor;
  }
  nx = x->size[1];
  for (k = 0; k < nx; k++) {
    b_y_data[j * k] = x_data[k];
  }
  /*  Filter a fabricated section of data first (match initial values and first
   * derivatives by */
  /*  rotating the first data points by 180 degrees) to get guess of good
   * initial conditions */
  /*  Filter length is 2*l*r+1 so need that many points; can't duplicate first
   * point or */
  /*  guarantee a zero slope at beginning of sequence */
  g_emxInit_creal_T(&od, 1);
  j = od->size[0];
  od->size[0] = b_i;
  g_emxEnsureCapacity_creal_T(od, j);
  od_data = od->data;
  for (j = 0; j < b_i; j++) {
    od_data[j].re = 0.0;
    od_data[j].im = 0.0;
  }
  if ((factor == 0) || ((factor > 0) && (b_i < 1))) {
    j = 1;
    k = 0;
  } else {
    j = factor;
    k = b_i;
  }
  bkj = 2.0 * x_data[0].re;
  y_im = 2.0 * x_data[0].im;
  nx = div_s32(k - 1, j) + 1;
  for (k = 0; k < nx; k++) {
    coffset = j * k;
    od_data[coffset].re = bkj - x_data[20 - k].re;
    od_data[coffset].im = y_im - x_data[20 - k].im;
  }
  g_emxInit_creal_T(&b_od, 1);
  g_emxInit_creal_T(&zi, 1);
  filter(b, od, b_od, zi);
  g_emxFree_creal_T(&b_od);
  g_emxInit_creal_T(&g_y, 2);
  j = g_y->size[0] * g_y->size[1];
  g_y->size[0] = 1;
  g_y->size[1] = y->size[1];
  g_emxEnsureCapacity_creal_T(g_y, j);
  c_y_data = g_y->data;
  nx = y->size[0] * y->size[1] - 1;
  for (j = 0; j <= nx; j++) {
    c_y_data[j] = b_y_data[j];
  }
  b_filter(b, g_y, zi, y, od);
  b_y_data = y->data;
  g_emxFree_creal_T(&zi);
  if (i + 1 > i1) {
    j = 0;
    k = 0;
  } else {
    j = i;
    k = i1;
  }
  coffset = g_y->size[0] * g_y->size[1];
  g_y->size[0] = 1;
  nx = k - j;
  g_y->size[1] = nx;
  g_emxEnsureCapacity_creal_T(g_y, coffset);
  c_y_data = g_y->data;
  for (k = 0; k < nx; k++) {
    c_y_data[k] = b_y_data[j + k];
  }
  nx = g_y->size[1];
  for (j = 0; j < nx; j++) {
    b_y_data[j] = c_y_data[j];
  }
  g_emxFree_creal_T(&g_y);
  /*  make sure right hand points of data have been correctly interpolated and
   * get rid of */
  /*  transients by again matching end values and derivatives of the original
   * data */
  g_emxInit_creal_T(&c_od, 2);
  if (aoffset == 1) {
    j = c_od->size[0] * c_od->size[1];
    c_od->size[0] = b_i;
    c_od->size[1] = 1;
    g_emxEnsureCapacity_creal_T(c_od, j);
    od_data = c_od->data;
    for (j = 0; j < b_i; j++) {
      od_data[j].re = 0.0;
      od_data[j].im = 0.0;
    }
  } else {
    j = c_od->size[0] * c_od->size[1];
    c_od->size[0] = 1;
    c_od->size[1] = b_i;
    g_emxEnsureCapacity_creal_T(c_od, j);
    od_data = c_od->data;
    for (j = 0; j < b_i; j++) {
      od_data[j].re = 0.0;
      od_data[j].im = 0.0;
    }
  }
  if ((factor == 0) || ((factor > 0) && (b_i < 1))) {
    j = 1;
    b_i = 0;
  } else {
    j = factor;
  }
  bkj = 2.0 * x_data[aoffset - 1].re;
  y_im = 2.0 * x_data[aoffset - 1].im;
  b_i = div_s32(b_i - 1, j) + 1;
  for (k = 0; k < b_i; k++) {
    coffset = (aoffset - k) - 2;
    boffset = j * k;
    od_data[boffset].re = bkj - x_data[coffset].re;
    od_data[boffset].im = y_im - x_data[coffset].im;
  }
  g_emxInit_creal_T(&d_od, 2);
  j = d_od->size[0] * d_od->size[1];
  d_od->size[0] = c_od->size[0];
  d_od->size[1] = c_od->size[1];
  g_emxEnsureCapacity_creal_T(d_od, j);
  c_y_data = d_od->data;
  b_i = c_od->size[0] * c_od->size[1] - 1;
  for (j = 0; j <= b_i; j++) {
    c_y_data[j] = od_data[j];
  }
  c_filter(b, d_od, od, c_od);
  od_data = c_od->data;
  g_emxFree_creal_T(&d_od);
  g_emxFree_creal_T(&od);
  g_emxFree_real_T(&b);
  if (i < 1) {
    b_i = 0;
  } else {
    b_i = i;
  }
  i = i1 - i;
  if (i + 1 > i1) {
    i = 0;
  }
  for (i1 = 0; i1 < b_i; i1++) {
    b_y_data[i + i1] = od_data[i1];
  }
  g_emxFree_creal_T(&c_od);
}

/*
 * File trailer for g_Interp.c
 *
 * [EOF]
 */
