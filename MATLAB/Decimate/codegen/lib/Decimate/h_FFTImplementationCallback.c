/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_FFTImplementationCallback.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_FFTImplementationCallback.h"
#include "h_Decimate_emxutil.h"
#include "h_Decimate_types.h"
#include "rt_nonfinite.h"
#include <math.h>
#include <string.h>

/* Function Declarations */
static void c_FFTImplementationCallback_doH(const double x_data[], int x_size,
                                            creal_T y_data[], int *y_size,
                                            int unsigned_nRows,
                                            const double costab_data[],
                                            const int costab_size[2],
                                            const double sintab_data[]);

static void d_FFTImplementationCallback_doH(
    const double x_data[], int x_size, creal_T y_data[], int nrowsx, int nRows,
    int nfft, const emxArray_creal_T *wwc, const double costab_data[],
    const int costab_size[2], const double sintab_data[],
    const double costabinv_data[], const double sintabinv_data[]);

static void d_FFTImplementationCallback_r2b(const emxArray_creal_T *x,
                                            int n1_unsigned,
                                            const double costab_data[],
                                            const double sintab_data[],
                                            emxArray_creal_T *y);

static void e_FFTImplementationCallback_r2b(const emxArray_creal_T *x,
                                            int n1_unsigned,
                                            const double costab_data[],
                                            const double sintab_data[],
                                            emxArray_creal_T *y);

/* Function Definitions */
/*
 * Arguments    : const double x_data[]
 *                int x_size
 *                creal_T y_data[]
 *                int *y_size
 *                int unsigned_nRows
 *                const double costab_data[]
 *                const int costab_size[2]
 *                const double sintab_data[]
 * Return Type  : void
 */
static void c_FFTImplementationCallback_doH(const double x_data[], int x_size,
                                            creal_T y_data[], int *y_size,
                                            int unsigned_nRows,
                                            const double costab_data[],
                                            const int costab_size[2],
                                            const double sintab_data[])
{
  emxArray_creal_T *y;
  creal_T reconVar1_data[1032];
  creal_T reconVar2_data[1032];
  creal_T *b_y_data;
  double hcostab_data[2065];
  double hsintab_data[2065];
  double b_y_re_tmp;
  double c_y_re_tmp;
  double d_y_re_tmp;
  double temp2_im;
  double temp2_re;
  double temp_im;
  double temp_im_tmp;
  double temp_re;
  double temp_re_tmp;
  double y_re_tmp;
  double z_tmp;
  int bitrevIndex_data[1033];
  int hszCostab;
  int i;
  int istart;
  int iy;
  int j;
  int ju;
  int k;
  int nRows;
  int nRowsD2;
  int nRowsM2;
  short wrapIndex_data[1032];
  bool tst;
  nRows = (unsigned short)unsigned_nRows >> 1;
  istart = *y_size;
  if (istart > nRows) {
    istart = nRows;
  }
  nRowsM2 = nRows - 2;
  nRowsD2 = nRows / 2;
  k = nRowsD2 / 2;
  hszCostab = (int)((unsigned int)costab_size[1] >> 1);
  for (i = 0; i < hszCostab; i++) {
    iy = ((i + 1) << 1) - 2;
    hcostab_data[i] = costab_data[iy];
    hsintab_data[i] = sintab_data[iy];
  }
  for (i = 0; i < nRows; i++) {
    temp_re = sintab_data[i];
    temp2_re = costab_data[i];
    reconVar1_data[i].re = temp_re + 1.0;
    reconVar1_data[i].im = -temp2_re;
    reconVar2_data[i].re = 1.0 - temp_re;
    reconVar2_data[i].im = temp2_re;
    if (i + 1 != 1) {
      wrapIndex_data[i] = (short)((nRows - i) + 1);
    } else {
      wrapIndex_data[0] = 1;
    }
  }
  z_tmp = (double)unsigned_nRows / 2.0;
  ju = 0;
  iy = 1;
  hszCostab = (int)z_tmp;
  if (hszCostab - 1 >= 0) {
    memset(&bitrevIndex_data[0], 0, (unsigned int)hszCostab * sizeof(int));
  }
  for (j = 0; j <= istart - 2; j++) {
    bitrevIndex_data[j] = iy;
    hszCostab = (int)z_tmp;
    tst = true;
    while (tst) {
      hszCostab >>= 1;
      ju ^= hszCostab;
      tst = ((ju & hszCostab) == 0);
    }
    iy = ju + 1;
  }
  bitrevIndex_data[istart - 1] = iy;
  if ((x_size & 1) == 0) {
    tst = true;
    istart = x_size;
  } else if (x_size >= unsigned_nRows) {
    tst = true;
    istart = unsigned_nRows;
  } else {
    tst = false;
    istart = x_size - 1;
  }
  if (istart <= unsigned_nRows) {
    hszCostab = istart;
  } else {
    hszCostab = unsigned_nRows;
  }
  temp_re = (double)hszCostab / 2.0;
  if (istart > unsigned_nRows) {
    istart = unsigned_nRows;
  }
  istart = (int)((double)istart / 2.0);
  for (i = 0; i < istart; i++) {
    hszCostab = i << 1;
    iy = bitrevIndex_data[i];
    y_data[iy - 1].re = x_data[hszCostab];
    y_data[iy - 1].im = x_data[hszCostab + 1];
  }
  if (!tst) {
    istart = bitrevIndex_data[(int)temp_re] - 1;
    y_data[istart].re = x_data[(int)temp_re << 1];
    y_data[istart].im = 0.0;
  }
  h_emxInit_creal_T(&y, 1);
  istart = y->size[0];
  y->size[0] = *y_size;
  h_emxEnsureCapacity_creal_T(y, istart);
  b_y_data = y->data;
  for (istart = 0; istart < *y_size; istart++) {
    b_y_data[istart] = y_data[istart];
  }
  if (nRows > 1) {
    for (i = 0; i <= nRowsM2; i += 2) {
      temp_re_tmp = b_y_data[i + 1].re;
      temp_im_tmp = b_y_data[i + 1].im;
      temp_im = b_y_data[i].re;
      temp_re = b_y_data[i].im;
      b_y_data[i + 1].re = temp_im - temp_re_tmp;
      b_y_data[i + 1].im = temp_re - temp_im_tmp;
      b_y_data[i].re = temp_im + temp_re_tmp;
      b_y_data[i].im = temp_re + temp_im_tmp;
    }
  }
  hszCostab = 2;
  iy = 4;
  ju = ((k - 1) << 2) + 1;
  while (k > 0) {
    for (i = 0; i < ju; i += iy) {
      nRowsM2 = i + hszCostab;
      temp_re = b_y_data[nRowsM2].re;
      temp_im = b_y_data[nRowsM2].im;
      b_y_data[nRowsM2].re = b_y_data[i].re - temp_re;
      b_y_data[nRowsM2].im = b_y_data[i].im - temp_im;
      b_y_data[i].re += temp_re;
      b_y_data[i].im += temp_im;
    }
    istart = 1;
    for (j = k; j < nRowsD2; j += k) {
      temp2_re = hcostab_data[j];
      temp2_im = hsintab_data[j];
      i = istart;
      nRows = istart + ju;
      while (i < nRows) {
        nRowsM2 = i + hszCostab;
        temp_re_tmp = b_y_data[nRowsM2].im;
        y_re_tmp = b_y_data[nRowsM2].re;
        temp_re = temp2_re * y_re_tmp - temp2_im * temp_re_tmp;
        temp_im = temp2_re * temp_re_tmp + temp2_im * y_re_tmp;
        b_y_data[nRowsM2].re = b_y_data[i].re - temp_re;
        b_y_data[nRowsM2].im = b_y_data[i].im - temp_im;
        b_y_data[i].re += temp_re;
        b_y_data[i].im += temp_im;
        i += iy;
      }
      istart++;
    }
    k /= 2;
    hszCostab = iy;
    iy += iy;
    ju -= hszCostab;
  }
  *y_size = y->size[0];
  hszCostab = y->size[0];
  for (istart = 0; istart < hszCostab; istart++) {
    y_data[istart] = b_y_data[istart];
  }
  hszCostab = (unsigned short)(int)z_tmp >> 1;
  y_data[0].re = 0.5 * ((b_y_data[0].re * reconVar1_data[0].re -
                         b_y_data[0].im * reconVar1_data[0].im) +
                        (b_y_data[0].re * reconVar2_data[0].re -
                         -b_y_data[0].im * reconVar2_data[0].im));
  y_data[0].im = 0.5 * ((b_y_data[0].re * reconVar1_data[0].im +
                         b_y_data[0].im * reconVar1_data[0].re) +
                        (b_y_data[0].re * reconVar2_data[0].im +
                         -b_y_data[0].im * reconVar2_data[0].re));
  y_data[(int)z_tmp].re = 0.5 * ((b_y_data[0].re * reconVar2_data[0].re -
                                  b_y_data[0].im * reconVar2_data[0].im) +
                                 (b_y_data[0].re * reconVar1_data[0].re -
                                  -b_y_data[0].im * reconVar1_data[0].im));
  y_data[(int)z_tmp].im = 0.5 * ((b_y_data[0].re * reconVar2_data[0].im +
                                  b_y_data[0].im * reconVar2_data[0].re) +
                                 (b_y_data[0].re * reconVar1_data[0].im +
                                  -b_y_data[0].im * reconVar1_data[0].re));
  h_emxFree_creal_T(&y);
  for (i = 2; i <= hszCostab; i++) {
    double temp2_im_tmp;
    short b_i;
    temp_re_tmp = y_data[i - 1].re;
    temp_im_tmp = y_data[i - 1].im;
    b_i = wrapIndex_data[i - 1];
    temp2_im = y_data[b_i - 1].re;
    temp2_im_tmp = y_data[b_i - 1].im;
    y_re_tmp = reconVar1_data[i - 1].im;
    b_y_re_tmp = reconVar1_data[i - 1].re;
    c_y_re_tmp = reconVar2_data[i - 1].im;
    d_y_re_tmp = reconVar2_data[i - 1].re;
    y_data[i - 1].re =
        0.5 * ((temp_re_tmp * b_y_re_tmp - temp_im_tmp * y_re_tmp) +
               (temp2_im * d_y_re_tmp - -temp2_im_tmp * c_y_re_tmp));
    y_data[i - 1].im =
        0.5 * ((temp_re_tmp * y_re_tmp + temp_im_tmp * b_y_re_tmp) +
               (temp2_im * c_y_re_tmp + -temp2_im_tmp * d_y_re_tmp));
    istart = ((int)z_tmp + i) - 1;
    y_data[istart].re =
        0.5 * ((temp_re_tmp * d_y_re_tmp - temp_im_tmp * c_y_re_tmp) +
               (temp2_im * b_y_re_tmp - -temp2_im_tmp * y_re_tmp));
    y_data[istart].im =
        0.5 * ((temp_re_tmp * c_y_re_tmp + temp_im_tmp * d_y_re_tmp) +
               (temp2_im * y_re_tmp + -temp2_im_tmp * b_y_re_tmp));
    temp_im = reconVar1_data[b_i - 1].im;
    temp_re = reconVar1_data[b_i - 1].re;
    y_re_tmp = reconVar2_data[b_i - 1].im;
    temp2_re = reconVar2_data[b_i - 1].re;
    y_data[b_i - 1].re =
        0.5 * ((temp2_im * temp_re - temp2_im_tmp * temp_im) +
               (temp_re_tmp * temp2_re - -temp_im_tmp * y_re_tmp));
    y_data[b_i - 1].im =
        0.5 * ((temp2_im * temp_im + temp2_im_tmp * temp_re) +
               (temp_re_tmp * y_re_tmp + -temp_im_tmp * temp2_re));
    istart = (b_i + (int)z_tmp) - 1;
    y_data[istart].re =
        0.5 * ((temp2_im * temp2_re - temp2_im_tmp * y_re_tmp) +
               (temp_re_tmp * temp_re - -temp_im_tmp * temp_im));
    y_data[istart].im =
        0.5 * ((temp2_im * y_re_tmp + temp2_im_tmp * temp2_re) +
               (temp_re_tmp * temp_im + -temp_im_tmp * temp_re));
  }
  if (hszCostab != 0) {
    temp_re_tmp = y_data[hszCostab].re;
    temp_im_tmp = y_data[hszCostab].im;
    y_re_tmp = reconVar1_data[hszCostab].im;
    b_y_re_tmp = reconVar1_data[hszCostab].re;
    c_y_re_tmp = reconVar2_data[hszCostab].im;
    d_y_re_tmp = reconVar2_data[hszCostab].re;
    temp_re = temp_re_tmp * d_y_re_tmp;
    temp2_re = temp_re_tmp * b_y_re_tmp;
    y_data[hszCostab].re = 0.5 * ((temp2_re - temp_im_tmp * y_re_tmp) +
                                  (temp_re - -temp_im_tmp * c_y_re_tmp));
    temp2_im = temp_re_tmp * c_y_re_tmp;
    temp_im = temp_re_tmp * y_re_tmp;
    y_data[hszCostab].im = 0.5 * ((temp_im + temp_im_tmp * b_y_re_tmp) +
                                  (temp2_im + -temp_im_tmp * d_y_re_tmp));
    istart = (int)z_tmp + hszCostab;
    y_data[istart].re = 0.5 * ((temp_re - temp_im_tmp * c_y_re_tmp) +
                               (temp2_re - -temp_im_tmp * y_re_tmp));
    y_data[istart].im = 0.5 * ((temp2_im + temp_im_tmp * d_y_re_tmp) +
                               (temp_im + -temp_im_tmp * b_y_re_tmp));
  }
}

/*
 * Arguments    : const double x_data[]
 *                int x_size
 *                creal_T y_data[]
 *                int nrowsx
 *                int nRows
 *                int nfft
 *                const emxArray_creal_T *wwc
 *                const double costab_data[]
 *                const int costab_size[2]
 *                const double sintab_data[]
 *                const double costabinv_data[]
 *                const double sintabinv_data[]
 * Return Type  : void
 */
static void d_FFTImplementationCallback_doH(
    const double x_data[], int x_size, creal_T y_data[], int nrowsx, int nRows,
    int nfft, const emxArray_creal_T *wwc, const double costab_data[],
    const int costab_size[2], const double sintab_data[],
    const double costabinv_data[], const double sintabinv_data[])
{
  static double b_costab_data[4131];
  static double b_sintab_data[4131];
  emxArray_creal_T *fy;
  emxArray_creal_T *r;
  emxArray_creal_T *y;
  creal_T reconVar1_data[1032];
  creal_T reconVar2_data[1032];
  creal_T ytmp_data[1032];
  const creal_T *wwc_data;
  creal_T *c_y_data;
  creal_T *fy_data;
  creal_T *r1;
  cuint8_T b_y_data[2065];
  double costab1q_data[2066];
  double hcostab_data[2065];
  double hcostabinv_data[2065];
  double hsintab_data[2065];
  double hsintabinv_data[2065];
  double b_temp_re_tmp;
  double temp_im;
  double temp_re;
  double twid_im;
  double twid_re;
  double z_tmp;
  int hnRows;
  int i;
  int ihi;
  int istart;
  int ju;
  int k;
  int n;
  int n2;
  int nRowsD2;
  int nd2;
  int temp_re_tmp;
  short wrapIndex_data[1032];
  bool tst;
  wwc_data = wwc->data;
  hnRows = (unsigned short)nRows >> 1;
  if (hnRows > nrowsx) {
    if (hnRows - 1 >= 0) {
      memset(&b_y_data[0], 0, (unsigned int)hnRows * sizeof(cuint8_T));
    }
  }
  for (ihi = 0; ihi < hnRows; ihi++) {
    ytmp_data[ihi].re = 0.0;
    ytmp_data[ihi].im = b_y_data[ihi].im;
  }
  if ((x_size & 1) == 0) {
    tst = true;
    istart = x_size;
  } else if (x_size >= nRows) {
    tst = true;
    istart = nRows;
  } else {
    tst = false;
    istart = x_size - 1;
  }
  if (istart > nRows) {
    istart = nRows;
  }
  nd2 = nRows << 1;
  temp_im = 6.2831853071795862 / (double)nd2;
  n = (unsigned short)nd2 >> 2;
  ju = n + 1;
  costab1q_data[0] = 1.0;
  nd2 = n / 2 - 1;
  for (k = 0; k <= nd2; k++) {
    costab1q_data[k + 1] = cos(temp_im * ((double)k + 1.0));
  }
  ihi = nd2 + 2;
  nd2 = n - 1;
  for (k = ihi; k <= nd2; k++) {
    costab1q_data[k] = sin(temp_im * (double)(n - k));
  }
  costab1q_data[n] = 0.0;
  n2 = n << 1;
  b_costab_data[0] = 1.0;
  b_sintab_data[0] = 0.0;
  for (k = 0; k < n; k++) {
    b_costab_data[k + 1] = costab1q_data[k + 1];
    b_sintab_data[k + 1] = -costab1q_data[(n - k) - 1];
  }
  for (k = ju; k <= n2; k++) {
    b_costab_data[k] = -costab1q_data[n2 - k];
    b_sintab_data[k] = -costab1q_data[k - n];
  }
  nd2 = (int)((unsigned int)costab_size[1] >> 1);
  for (i = 0; i < nd2; i++) {
    n2 = ((i + 1) << 1) - 2;
    hcostab_data[i] = costab_data[n2];
    hsintab_data[i] = sintab_data[n2];
    hcostabinv_data[i] = costabinv_data[n2];
    hsintabinv_data[i] = sintabinv_data[n2];
  }
  for (i = 0; i < hnRows; i++) {
    ihi = i << 1;
    temp_im = b_sintab_data[ihi];
    temp_re = b_costab_data[ihi];
    reconVar1_data[i].re = temp_im + 1.0;
    reconVar1_data[i].im = -temp_re;
    reconVar2_data[i].re = 1.0 - temp_im;
    reconVar2_data[i].im = temp_re;
    if (i + 1 != 1) {
      wrapIndex_data[i] = (short)((hnRows - i) + 1);
    } else {
      wrapIndex_data[0] = 1;
    }
  }
  z_tmp = (double)istart / 2.0;
  ihi = (int)((double)istart / 2.0);
  for (n2 = 0; n2 < ihi; n2++) {
    temp_re_tmp = (hnRows + n2) - 1;
    temp_re = wwc_data[temp_re_tmp].re;
    temp_im = wwc_data[temp_re_tmp].im;
    nd2 = n2 << 1;
    twid_re = x_data[nd2];
    twid_im = x_data[nd2 + 1];
    ytmp_data[n2].re = temp_re * twid_re + temp_im * twid_im;
    ytmp_data[n2].im = temp_re * twid_im - temp_im * twid_re;
  }
  if (!tst) {
    temp_re_tmp = (hnRows + (int)z_tmp) - 1;
    temp_re = wwc_data[temp_re_tmp].re;
    temp_im = wwc_data[temp_re_tmp].im;
    twid_re = x_data[(int)z_tmp << 1];
    ytmp_data[(int)z_tmp].re = temp_re * twid_re + temp_im * 0.0;
    ytmp_data[(int)z_tmp].im = temp_re * 0.0 - temp_im * twid_re;
    if ((int)z_tmp + 2 <= hnRows) {
      ihi = (int)((double)istart / 2.0) + 2;
      if (ihi <= hnRows) {
        memset(&ytmp_data[ihi + -1], 0,
               (unsigned int)((hnRows - ihi) + 1) * sizeof(creal_T));
      }
    }
  } else if ((int)z_tmp + 1 <= hnRows) {
    ihi = (int)((double)istart / 2.0) + 1;
    if (ihi <= hnRows) {
      memset(&ytmp_data[ihi + -1], 0,
             (unsigned int)((hnRows - ihi) + 1) * sizeof(creal_T));
    }
  }
  z_tmp = (double)nfft / 2.0;
  h_emxInit_creal_T(&y, 1);
  nd2 = (int)z_tmp;
  ihi = y->size[0];
  y->size[0] = (int)z_tmp;
  h_emxEnsureCapacity_creal_T(y, ihi);
  c_y_data = y->data;
  if ((int)z_tmp > hnRows) {
    ihi = y->size[0];
    y->size[0] = (int)z_tmp;
    h_emxEnsureCapacity_creal_T(y, ihi);
    c_y_data = y->data;
    for (ihi = 0; ihi < nd2; ihi++) {
      c_y_data[ihi].re = 0.0;
      c_y_data[ihi].im = 0.0;
    }
  }
  h_emxInit_creal_T(&fy, 1);
  ihi = fy->size[0];
  fy->size[0] = y->size[0];
  h_emxEnsureCapacity_creal_T(fy, ihi);
  fy_data = fy->data;
  nd2 = y->size[0];
  for (ihi = 0; ihi < nd2; ihi++) {
    fy_data[ihi] = c_y_data[ihi];
  }
  n2 = (int)z_tmp;
  if (hnRows <= n2) {
    n2 = hnRows;
  }
  istart = (int)z_tmp - 2;
  nRowsD2 = (unsigned short)(int)z_tmp >> 1;
  k = nRowsD2 / 2;
  nd2 = 0;
  ju = 0;
  for (i = 0; i <= n2 - 2; i++) {
    fy_data[nd2] = ytmp_data[i];
    n = (int)z_tmp;
    tst = true;
    while (tst) {
      n >>= 1;
      ju ^= n;
      tst = ((ju & n) == 0);
    }
    nd2 = ju;
  }
  fy_data[nd2] = ytmp_data[n2 - 1];
  ihi = y->size[0];
  y->size[0] = fy->size[0];
  h_emxEnsureCapacity_creal_T(y, ihi);
  c_y_data = y->data;
  nd2 = fy->size[0];
  for (ihi = 0; ihi < nd2; ihi++) {
    c_y_data[ihi] = fy_data[ihi];
  }
  if ((int)z_tmp > 1) {
    for (i = 0; i <= istart; i += 2) {
      b_temp_re_tmp = c_y_data[i + 1].re;
      temp_re = c_y_data[i + 1].im;
      temp_im = c_y_data[i].re;
      twid_re = c_y_data[i].im;
      c_y_data[i + 1].re = temp_im - b_temp_re_tmp;
      c_y_data[i + 1].im = twid_re - temp_re;
      c_y_data[i].re = temp_im + b_temp_re_tmp;
      c_y_data[i].im = twid_re + temp_re;
    }
  }
  nd2 = 2;
  n2 = 4;
  ju = ((k - 1) << 2) + 1;
  while (k > 0) {
    for (i = 0; i < ju; i += n2) {
      temp_re_tmp = i + nd2;
      temp_re = c_y_data[temp_re_tmp].re;
      temp_im = c_y_data[temp_re_tmp].im;
      c_y_data[temp_re_tmp].re = c_y_data[i].re - temp_re;
      c_y_data[temp_re_tmp].im = c_y_data[i].im - temp_im;
      c_y_data[i].re += temp_re;
      c_y_data[i].im += temp_im;
    }
    istart = 1;
    for (n = k; n < nRowsD2; n += k) {
      twid_re = hcostab_data[n];
      twid_im = hsintab_data[n];
      i = istart;
      ihi = istart + ju;
      while (i < ihi) {
        temp_re_tmp = i + nd2;
        b_temp_re_tmp = c_y_data[temp_re_tmp].im;
        temp_im = c_y_data[temp_re_tmp].re;
        temp_re = twid_re * temp_im - twid_im * b_temp_re_tmp;
        temp_im = twid_re * b_temp_re_tmp + twid_im * temp_im;
        c_y_data[temp_re_tmp].re = c_y_data[i].re - temp_re;
        c_y_data[temp_re_tmp].im = c_y_data[i].im - temp_im;
        c_y_data[i].re += temp_re;
        c_y_data[i].im += temp_im;
        i += n2;
      }
      istart++;
    }
    k /= 2;
    nd2 = n2;
    n2 += n2;
    ju -= nd2;
  }
  h_emxInit_creal_T(&r, 1);
  d_FFTImplementationCallback_r2b(wwc, (int)z_tmp, hcostab_data, hsintab_data,
                                  r);
  r1 = r->data;
  ihi = fy->size[0];
  fy->size[0] = y->size[0];
  h_emxEnsureCapacity_creal_T(fy, ihi);
  fy_data = fy->data;
  nd2 = y->size[0];
  for (ihi = 0; ihi < nd2; ihi++) {
    temp_im = c_y_data[ihi].re;
    temp_re = r1[ihi].im;
    twid_re = c_y_data[ihi].im;
    twid_im = r1[ihi].re;
    fy_data[ihi].re = temp_im * twid_im - twid_re * temp_re;
    fy_data[ihi].im = temp_im * temp_re + twid_re * twid_im;
  }
  h_emxFree_creal_T(&y);
  e_FFTImplementationCallback_r2b(fy, (int)z_tmp, hcostabinv_data,
                                  hsintabinv_data, r);
  r1 = r->data;
  ihi = fy->size[0];
  fy->size[0] = r->size[0];
  h_emxEnsureCapacity_creal_T(fy, ihi);
  fy_data = fy->data;
  nd2 = r->size[0];
  for (ihi = 0; ihi < nd2; ihi++) {
    fy_data[ihi] = r1[ihi];
  }
  h_emxFree_creal_T(&r);
  ihi = wwc->size[0];
  for (k = hnRows; k <= ihi; k++) {
    temp_im = wwc_data[k - 1].re;
    temp_re = fy_data[k - 1].im;
    twid_re = wwc_data[k - 1].im;
    twid_im = fy_data[k - 1].re;
    nd2 = k - hnRows;
    ytmp_data[nd2].re = temp_im * twid_im + twid_re * temp_re;
    ytmp_data[nd2].im = temp_im * temp_re - twid_re * twid_im;
  }
  h_emxFree_creal_T(&fy);
  for (i = 0; i < hnRows; i++) {
    double b_ytmp_re_tmp;
    double ytmp_re_tmp;
    short b_i;
    b_i = wrapIndex_data[i];
    temp_im = ytmp_data[i].re;
    temp_re = reconVar1_data[i].im;
    twid_re = ytmp_data[i].im;
    twid_im = reconVar1_data[i].re;
    b_temp_re_tmp = ytmp_data[b_i - 1].re;
    z_tmp = -ytmp_data[b_i - 1].im;
    ytmp_re_tmp = reconVar2_data[i].im;
    b_ytmp_re_tmp = reconVar2_data[i].re;
    y_data[i].re =
        0.5 * ((temp_im * twid_im - twid_re * temp_re) +
               (b_temp_re_tmp * b_ytmp_re_tmp - z_tmp * ytmp_re_tmp));
    y_data[i].im =
        0.5 * ((temp_im * temp_re + twid_re * twid_im) +
               (b_temp_re_tmp * ytmp_re_tmp + z_tmp * b_ytmp_re_tmp));
    ihi = hnRows + i;
    y_data[ihi].re = 0.5 * ((temp_im * b_ytmp_re_tmp - twid_re * ytmp_re_tmp) +
                            (b_temp_re_tmp * twid_im - z_tmp * temp_re));
    y_data[ihi].im = 0.5 * ((temp_im * ytmp_re_tmp + twid_re * b_ytmp_re_tmp) +
                            (b_temp_re_tmp * temp_re + z_tmp * twid_im));
  }
}

/*
 * Arguments    : const emxArray_creal_T *x
 *                int n1_unsigned
 *                const double costab_data[]
 *                const double sintab_data[]
 *                emxArray_creal_T *y
 * Return Type  : void
 */
static void d_FFTImplementationCallback_r2b(const emxArray_creal_T *x,
                                            int n1_unsigned,
                                            const double costab_data[],
                                            const double sintab_data[],
                                            emxArray_creal_T *y)
{
  const creal_T *x_data;
  creal_T *y_data;
  double temp_im;
  double temp_re;
  double temp_re_tmp;
  double twid_re;
  int i;
  int iDelta2;
  int iheight;
  int iy;
  int j;
  int ju;
  int k;
  int nRowsD2;
  x_data = x->data;
  iy = y->size[0];
  y->size[0] = n1_unsigned;
  h_emxEnsureCapacity_creal_T(y, iy);
  y_data = y->data;
  if (n1_unsigned > x->size[0]) {
    iy = y->size[0];
    y->size[0] = n1_unsigned;
    h_emxEnsureCapacity_creal_T(y, iy);
    y_data = y->data;
    for (iy = 0; iy < n1_unsigned; iy++) {
      y_data[iy].re = 0.0;
      y_data[iy].im = 0.0;
    }
  }
  iDelta2 = x->size[0];
  if (iDelta2 > n1_unsigned) {
    iDelta2 = n1_unsigned;
  }
  iheight = n1_unsigned - 2;
  nRowsD2 = (unsigned short)n1_unsigned >> 1;
  k = nRowsD2 / 2;
  iy = 0;
  ju = 0;
  for (i = 0; i <= iDelta2 - 2; i++) {
    bool tst;
    y_data[iy] = x_data[i];
    iy = n1_unsigned;
    tst = true;
    while (tst) {
      iy >>= 1;
      ju ^= iy;
      tst = ((ju & iy) == 0);
    }
    iy = ju;
  }
  y_data[iy] = x_data[iDelta2 - 1];
  if (n1_unsigned > 1) {
    for (i = 0; i <= iheight; i += 2) {
      temp_re_tmp = y_data[i + 1].re;
      temp_im = y_data[i + 1].im;
      temp_re = y_data[i].re;
      twid_re = y_data[i].im;
      y_data[i + 1].re = temp_re - temp_re_tmp;
      y_data[i + 1].im = twid_re - temp_im;
      y_data[i].re = temp_re + temp_re_tmp;
      y_data[i].im = twid_re + temp_im;
    }
  }
  iy = 2;
  iDelta2 = 4;
  iheight = ((k - 1) << 2) + 1;
  while (k > 0) {
    int b_temp_re_tmp;
    for (i = 0; i < iheight; i += iDelta2) {
      b_temp_re_tmp = i + iy;
      temp_re = y_data[b_temp_re_tmp].re;
      temp_im = y_data[b_temp_re_tmp].im;
      y_data[b_temp_re_tmp].re = y_data[i].re - temp_re;
      y_data[b_temp_re_tmp].im = y_data[i].im - temp_im;
      y_data[i].re += temp_re;
      y_data[i].im += temp_im;
    }
    ju = 1;
    for (j = k; j < nRowsD2; j += k) {
      double twid_im;
      int ihi;
      twid_re = costab_data[j];
      twid_im = sintab_data[j];
      i = ju;
      ihi = ju + iheight;
      while (i < ihi) {
        b_temp_re_tmp = i + iy;
        temp_re_tmp = y_data[b_temp_re_tmp].im;
        temp_im = y_data[b_temp_re_tmp].re;
        temp_re = twid_re * temp_im - twid_im * temp_re_tmp;
        temp_im = twid_re * temp_re_tmp + twid_im * temp_im;
        y_data[b_temp_re_tmp].re = y_data[i].re - temp_re;
        y_data[b_temp_re_tmp].im = y_data[i].im - temp_im;
        y_data[i].re += temp_re;
        y_data[i].im += temp_im;
        i += iDelta2;
      }
      ju++;
    }
    k /= 2;
    iy = iDelta2;
    iDelta2 += iDelta2;
    iheight -= iy;
  }
}

/*
 * Arguments    : const emxArray_creal_T *x
 *                int n1_unsigned
 *                const double costab_data[]
 *                const double sintab_data[]
 *                emxArray_creal_T *y
 * Return Type  : void
 */
static void e_FFTImplementationCallback_r2b(const emxArray_creal_T *x,
                                            int n1_unsigned,
                                            const double costab_data[],
                                            const double sintab_data[],
                                            emxArray_creal_T *y)
{
  const creal_T *x_data;
  creal_T *y_data;
  double temp_im;
  double temp_re;
  double temp_re_tmp;
  double twid_re;
  int i;
  int iDelta2;
  int iheight;
  int iy;
  int j;
  int ju;
  int k;
  int nRowsD2;
  x_data = x->data;
  iDelta2 = y->size[0];
  y->size[0] = n1_unsigned;
  h_emxEnsureCapacity_creal_T(y, iDelta2);
  y_data = y->data;
  if (n1_unsigned > x->size[0]) {
    iDelta2 = y->size[0];
    y->size[0] = n1_unsigned;
    h_emxEnsureCapacity_creal_T(y, iDelta2);
    y_data = y->data;
    for (iDelta2 = 0; iDelta2 < n1_unsigned; iDelta2++) {
      y_data[iDelta2].re = 0.0;
      y_data[iDelta2].im = 0.0;
    }
  }
  iDelta2 = x->size[0];
  if (iDelta2 > n1_unsigned) {
    iDelta2 = n1_unsigned;
  }
  iheight = n1_unsigned - 2;
  nRowsD2 = (unsigned short)n1_unsigned >> 1;
  k = nRowsD2 / 2;
  iy = 0;
  ju = 0;
  for (i = 0; i <= iDelta2 - 2; i++) {
    bool tst;
    y_data[iy] = x_data[i];
    iy = n1_unsigned;
    tst = true;
    while (tst) {
      iy >>= 1;
      ju ^= iy;
      tst = ((ju & iy) == 0);
    }
    iy = ju;
  }
  y_data[iy] = x_data[iDelta2 - 1];
  if (n1_unsigned > 1) {
    for (i = 0; i <= iheight; i += 2) {
      temp_re_tmp = y_data[i + 1].re;
      temp_im = y_data[i + 1].im;
      temp_re = y_data[i].re;
      twid_re = y_data[i].im;
      y_data[i + 1].re = temp_re - temp_re_tmp;
      y_data[i + 1].im = twid_re - temp_im;
      y_data[i].re = temp_re + temp_re_tmp;
      y_data[i].im = twid_re + temp_im;
    }
  }
  iy = 2;
  iDelta2 = 4;
  iheight = ((k - 1) << 2) + 1;
  while (k > 0) {
    int b_temp_re_tmp;
    for (i = 0; i < iheight; i += iDelta2) {
      b_temp_re_tmp = i + iy;
      temp_re = y_data[b_temp_re_tmp].re;
      temp_im = y_data[b_temp_re_tmp].im;
      y_data[b_temp_re_tmp].re = y_data[i].re - temp_re;
      y_data[b_temp_re_tmp].im = y_data[i].im - temp_im;
      y_data[i].re += temp_re;
      y_data[i].im += temp_im;
    }
    ju = 1;
    for (j = k; j < nRowsD2; j += k) {
      double twid_im;
      int ihi;
      twid_re = costab_data[j];
      twid_im = sintab_data[j];
      i = ju;
      ihi = ju + iheight;
      while (i < ihi) {
        b_temp_re_tmp = i + iy;
        temp_re_tmp = y_data[b_temp_re_tmp].im;
        temp_im = y_data[b_temp_re_tmp].re;
        temp_re = twid_re * temp_im - twid_im * temp_re_tmp;
        temp_im = twid_re * temp_re_tmp + twid_im * temp_im;
        y_data[b_temp_re_tmp].re = y_data[i].re - temp_re;
        y_data[b_temp_re_tmp].im = y_data[i].im - temp_im;
        y_data[i].re += temp_re;
        y_data[i].im += temp_im;
        i += iDelta2;
      }
      ju++;
    }
    k /= 2;
    iy = iDelta2;
    iDelta2 += iDelta2;
    iheight -= iy;
  }
  if (y->size[0] > 1) {
    temp_im = 1.0 / (double)y->size[0];
    iy = y->size[0];
    for (iDelta2 = 0; iDelta2 < iy; iDelta2++) {
      y_data[iDelta2].re *= temp_im;
      y_data[iDelta2].im *= temp_im;
    }
  }
}

/*
 * Arguments    : const double x_data[]
 *                int x_size
 *                int n2blue
 *                int nfft
 *                const double costab_data[]
 *                const int costab_size[2]
 *                const double sintab_data[]
 *                const double sintabinv_data[]
 *                creal_T y_data[]
 *                int *y_size
 * Return Type  : void
 */
void c_FFTImplementationCallback_dob(const double x_data[], int x_size,
                                     int n2blue, int nfft,
                                     const double costab_data[],
                                     const int costab_size[2],
                                     const double sintab_data[],
                                     const double sintabinv_data[],
                                     creal_T y_data[], int *y_size)
{
  emxArray_creal_T *fv;
  emxArray_creal_T *fy;
  emxArray_creal_T *wwc;
  creal_T *fv_data;
  creal_T *fy_data;
  creal_T *wwc_data;
  double nt_im;
  double nt_re;
  int i;
  int ihi;
  int istart;
  int j;
  int k;
  int nInt2;
  int nInt2m1;
  int rt;
  h_emxInit_creal_T(&wwc, 1);
  if ((nfft != 1) && ((nfft & 1) == 0)) {
    j = (unsigned short)nfft >> 1;
    nInt2m1 = (j + j) - 1;
    ihi = wwc->size[0];
    wwc->size[0] = nInt2m1;
    h_emxEnsureCapacity_creal_T(wwc, ihi);
    wwc_data = wwc->data;
    rt = 0;
    wwc_data[j - 1].re = 1.0;
    wwc_data[j - 1].im = 0.0;
    nInt2 = j << 1;
    ihi = (unsigned short)(j - 1);
    for (k = 0; k < ihi; k++) {
      istart = ((k + 1) << 1) - 1;
      if (nInt2 - rt <= istart) {
        rt += istart - nInt2;
      } else {
        rt += istart;
      }
      nt_im = -3.1415926535897931 * (double)rt / (double)j;
      if (nt_im == 0.0) {
        nt_re = 1.0;
        nt_im = 0.0;
      } else {
        nt_re = cos(nt_im);
        nt_im = sin(nt_im);
      }
      istart = (j - k) - 2;
      wwc_data[istart].re = nt_re;
      wwc_data[istart].im = -nt_im;
    }
    ihi = nInt2m1 - 1;
    for (k = ihi; k >= j; k--) {
      wwc_data[k] = wwc_data[(nInt2m1 - k) - 1];
    }
  } else {
    nInt2m1 = (nfft + nfft) - 1;
    ihi = wwc->size[0];
    wwc->size[0] = nInt2m1;
    h_emxEnsureCapacity_creal_T(wwc, ihi);
    wwc_data = wwc->data;
    rt = 0;
    wwc_data[nfft - 1].re = 1.0;
    wwc_data[nfft - 1].im = 0.0;
    nInt2 = nfft << 1;
    ihi = (unsigned short)(nfft - 1);
    for (k = 0; k < ihi; k++) {
      istart = ((k + 1) << 1) - 1;
      if (nInt2 - rt <= istart) {
        rt += istart - nInt2;
      } else {
        rt += istart;
      }
      nt_im = -3.1415926535897931 * (double)rt / (double)nfft;
      if (nt_im == 0.0) {
        nt_re = 1.0;
        nt_im = 0.0;
      } else {
        nt_re = cos(nt_im);
        nt_im = sin(nt_im);
      }
      istart = (nfft - k) - 2;
      wwc_data[istart].re = nt_re;
      wwc_data[istart].im = -nt_im;
    }
    ihi = nInt2m1 - 1;
    for (k = ihi; k >= nfft; k--) {
      wwc_data[k] = wwc_data[(nInt2m1 - k) - 1];
    }
  }
  *y_size = nfft;
  if (nfft > x_size) {
    memset(&y_data[0], 0, (unsigned int)nfft * sizeof(creal_T));
  }
  h_emxInit_creal_T(&fy, 1);
  h_emxInit_creal_T(&fv, 1);
  if ((n2blue != 1) && ((nfft & 1) == 0)) {
    d_FFTImplementationCallback_doH(x_data, x_size, y_data, x_size, nfft,
                                    n2blue, wwc, costab_data, costab_size,
                                    sintab_data, costab_data, sintabinv_data);
  } else {
    double b_nt_re_tmp;
    double twid_im;
    double twid_re;
    int nRowsD2;
    int nt_re_tmp;
    if (nfft <= x_size) {
      nInt2m1 = nfft;
    } else {
      nInt2m1 = x_size;
    }
    ihi = (unsigned short)nInt2m1;
    for (k = 0; k < ihi; k++) {
      nt_re_tmp = (nfft + k) - 1;
      nt_im = x_data[k];
      y_data[k].re = wwc_data[nt_re_tmp].re * nt_im;
      y_data[k].im = wwc_data[nt_re_tmp].im * -nt_im;
    }
    ihi = nInt2m1 + 1;
    if (ihi <= nfft) {
      memset(&y_data[ihi + -1], 0,
             (unsigned int)((nfft - ihi) + 1) * sizeof(creal_T));
    }
    ihi = fy->size[0];
    fy->size[0] = n2blue;
    h_emxEnsureCapacity_creal_T(fy, ihi);
    fy_data = fy->data;
    if (n2blue > nfft) {
      ihi = fy->size[0];
      fy->size[0] = n2blue;
      h_emxEnsureCapacity_creal_T(fy, ihi);
      fy_data = fy->data;
      for (ihi = 0; ihi < n2blue; ihi++) {
        fy_data[ihi].re = 0.0;
        fy_data[ihi].im = 0.0;
      }
    }
    if (nfft <= n2blue) {
      istart = nfft;
    } else {
      istart = n2blue;
    }
    rt = n2blue - 2;
    nRowsD2 = (unsigned short)n2blue >> 1;
    k = nRowsD2 / 2;
    nInt2m1 = 0;
    nInt2 = 0;
    for (i = 0; i <= istart - 2; i++) {
      bool tst;
      fy_data[nInt2m1] = y_data[i];
      nInt2m1 = n2blue;
      tst = true;
      while (tst) {
        nInt2m1 >>= 1;
        nInt2 ^= nInt2m1;
        tst = ((nInt2 & nInt2m1) == 0);
      }
      nInt2m1 = nInt2;
    }
    fy_data[nInt2m1] = y_data[istart - 1];
    if (n2blue > 1) {
      for (i = 0; i <= rt; i += 2) {
        b_nt_re_tmp = fy_data[i + 1].re;
        nt_im = fy_data[i + 1].im;
        twid_im = fy_data[i].re;
        nt_re = fy_data[i].im;
        fy_data[i + 1].re = twid_im - b_nt_re_tmp;
        fy_data[i + 1].im = nt_re - nt_im;
        fy_data[i].re = twid_im + b_nt_re_tmp;
        fy_data[i].im = nt_re + nt_im;
      }
    }
    nInt2m1 = 2;
    rt = 4;
    nInt2 = ((k - 1) << 2) + 1;
    while (k > 0) {
      for (i = 0; i < nInt2; i += rt) {
        nt_re_tmp = i + nInt2m1;
        nt_re = fy_data[nt_re_tmp].re;
        nt_im = fy_data[nt_re_tmp].im;
        fy_data[nt_re_tmp].re = fy_data[i].re - nt_re;
        fy_data[nt_re_tmp].im = fy_data[i].im - nt_im;
        fy_data[i].re += nt_re;
        fy_data[i].im += nt_im;
      }
      istart = 1;
      for (j = k; j < nRowsD2; j += k) {
        twid_re = costab_data[j];
        twid_im = sintab_data[j];
        i = istart;
        ihi = istart + nInt2;
        while (i < ihi) {
          nt_re_tmp = i + nInt2m1;
          b_nt_re_tmp = fy_data[nt_re_tmp].im;
          nt_im = fy_data[nt_re_tmp].re;
          nt_re = twid_re * nt_im - twid_im * b_nt_re_tmp;
          nt_im = twid_re * b_nt_re_tmp + twid_im * nt_im;
          fy_data[nt_re_tmp].re = fy_data[i].re - nt_re;
          fy_data[nt_re_tmp].im = fy_data[i].im - nt_im;
          fy_data[i].re += nt_re;
          fy_data[i].im += nt_im;
          i += rt;
        }
        istart++;
      }
      k /= 2;
      nInt2m1 = rt;
      rt += rt;
      nInt2 -= nInt2m1;
    }
    d_FFTImplementationCallback_r2b(wwc, n2blue, costab_data, sintab_data, fv);
    fv_data = fv->data;
    nInt2m1 = fy->size[0];
    for (ihi = 0; ihi < nInt2m1; ihi++) {
      twid_im = fy_data[ihi].re;
      nt_im = fv_data[ihi].im;
      nt_re = fy_data[ihi].im;
      twid_re = fv_data[ihi].re;
      fy_data[ihi].re = twid_im * twid_re - nt_re * nt_im;
      fy_data[ihi].im = twid_im * nt_im + nt_re * twid_re;
    }
    e_FFTImplementationCallback_r2b(fy, n2blue, costab_data, sintabinv_data,
                                    fv);
    fv_data = fv->data;
    ihi = wwc->size[0];
    for (k = nfft; k <= ihi; k++) {
      nt_im = wwc_data[k - 1].re;
      nt_re = fv_data[k - 1].im;
      twid_re = wwc_data[k - 1].im;
      twid_im = fv_data[k - 1].re;
      istart = k - nfft;
      y_data[istart].re = nt_im * twid_im + twid_re * nt_re;
      y_data[istart].im = nt_im * nt_re - twid_re * twid_im;
    }
  }
  h_emxFree_creal_T(&fv);
  h_emxFree_creal_T(&fy);
  h_emxFree_creal_T(&wwc);
}

/*
 * Arguments    : int nRows
 *                bool useRadix2
 *                double costab_data[]
 *                int costab_size[2]
 *                double sintab_data[]
 *                int sintab_size[2]
 *                double sintabinv_data[]
 *                int sintabinv_size[2]
 * Return Type  : void
 */
void c_FFTImplementationCallback_gen(int nRows, bool useRadix2,
                                     double costab_data[], int costab_size[2],
                                     double sintab_data[], int sintab_size[2],
                                     double sintabinv_data[],
                                     int sintabinv_size[2])
{
  double costab1q_data[2066];
  double e;
  int costab1q_size_idx_1;
  int k;
  int n;
  int n2;
  int nd2;
  e = 6.2831853071795862 / (double)nRows;
  n = (unsigned short)nRows >> 2;
  costab1q_size_idx_1 = n + 1;
  costab1q_data[0] = 1.0;
  nd2 = n / 2 - 1;
  for (k = 0; k <= nd2; k++) {
    costab1q_data[k + 1] = cos(e * ((double)k + 1.0));
  }
  nd2 += 2;
  n2 = n - 1;
  for (k = nd2; k <= n2; k++) {
    costab1q_data[k] = sin(e * (double)(n - k));
  }
  costab1q_data[n] = 0.0;
  if (!useRadix2) {
    n2 = n << 1;
    costab_size[0] = 1;
    costab_size[1] = n2 + 1;
    sintab_size[0] = 1;
    sintab_size[1] = n2 + 1;
    costab_data[0] = 1.0;
    sintab_data[0] = 0.0;
    sintabinv_size[0] = 1;
    sintabinv_size[1] = n2 + 1;
    for (k = 0; k < n; k++) {
      sintabinv_data[k + 1] = costab1q_data[(n - k) - 1];
    }
    for (k = costab1q_size_idx_1; k <= n2; k++) {
      sintabinv_data[k] = costab1q_data[k - n];
    }
    for (k = 0; k < n; k++) {
      costab_data[k + 1] = costab1q_data[k + 1];
      sintab_data[k + 1] = -costab1q_data[(n - k) - 1];
    }
    for (k = costab1q_size_idx_1; k <= n2; k++) {
      costab_data[k] = -costab1q_data[n2 - k];
      sintab_data[k] = -costab1q_data[k - n];
    }
  } else {
    n2 = n << 1;
    costab_size[0] = 1;
    costab_size[1] = n2 + 1;
    sintab_size[0] = 1;
    sintab_size[1] = n2 + 1;
    costab_data[0] = 1.0;
    sintab_data[0] = 0.0;
    for (k = 0; k < n; k++) {
      costab_data[k + 1] = costab1q_data[k + 1];
      sintab_data[k + 1] = -costab1q_data[(n - k) - 1];
    }
    for (k = costab1q_size_idx_1; k <= n2; k++) {
      costab_data[k] = -costab1q_data[n2 - k];
      sintab_data[k] = -costab1q_data[k - n];
    }
    sintabinv_size[0] = 1;
    sintabinv_size[1] = 0;
  }
}

/*
 * Arguments    : int nfft
 *                bool useRadix2
 *                int *n2blue
 *                int *nRows
 * Return Type  : void
 */
void c_FFTImplementationCallback_get(int nfft, bool useRadix2, int *n2blue,
                                     int *nRows)
{
  *n2blue = 1;
  if (useRadix2) {
    *nRows = nfft;
  } else {
    if (nfft > 0) {
      int n;
      int pmax;
      n = (nfft + nfft) - 1;
      pmax = 31;
      if (n <= 1) {
        pmax = 0;
      } else {
        int pmin;
        bool exitg1;
        pmin = 0;
        exitg1 = false;
        while ((!exitg1) && (pmax - pmin > 1)) {
          int k;
          int pow2p;
          k = (pmin + pmax) >> 1;
          pow2p = 1 << k;
          if (pow2p == n) {
            pmax = k;
            exitg1 = true;
          } else if (pow2p > n) {
            pmax = k;
          } else {
            pmin = k;
          }
        }
      }
      *n2blue = 1 << pmax;
    }
    *nRows = *n2blue;
  }
}

/*
 * Arguments    : const double x_data[]
 *                int x_size
 *                int n1_unsigned
 *                const double costab_data[]
 *                const int costab_size[2]
 *                const double sintab_data[]
 *                creal_T y_data[]
 *                int *y_size
 * Return Type  : void
 */
void c_FFTImplementationCallback_r2b(const double x_data[], int x_size,
                                     int n1_unsigned,
                                     const double costab_data[],
                                     const int costab_size[2],
                                     const double sintab_data[],
                                     creal_T y_data[], int *y_size)
{
  emxArray_creal_T *b_y;
  creal_T *b_y_data;
  int i;
  *y_size = n1_unsigned;
  if (n1_unsigned > x_size) {
    memset(&y_data[0], 0, (unsigned int)n1_unsigned * sizeof(creal_T));
  }
  if (n1_unsigned != 1) {
    c_FFTImplementationCallback_doH(x_data, x_size, y_data, y_size, n1_unsigned,
                                    costab_data, costab_size, sintab_data);
  } else {
    int y;
    if (x_size <= 1) {
      y = x_size;
    } else {
      y = 1;
    }
    y_data[0].re = x_data[y - 1];
    y_data[0].im = 0.0;
    h_emxInit_creal_T(&b_y, 1);
    i = b_y->size[0];
    b_y->size[0] = n1_unsigned;
    h_emxEnsureCapacity_creal_T(b_y, i);
    b_y_data = b_y->data;
    for (i = 0; i < n1_unsigned; i++) {
      b_y_data[i] = y_data[i];
    }
    *y_size = b_y->size[0];
    y = b_y->size[0];
    for (i = 0; i < y; i++) {
      y_data[i] = b_y_data[i];
    }
    h_emxFree_creal_T(&b_y);
  }
}

/*
 * File trailer for h_FFTImplementationCallback.c
 *
 * [EOF]
 */
