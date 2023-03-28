/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: c_Ifft.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 27-Mar-2023 19:38:35
 */

/* Include Files */
#include "c_Ifft.h"
#include "c_FFTImplementationCallback.h"
#include "c_Ifft_emxutil.h"
#include "c_Ifft_types.h"

/* Function Definitions */
/*
 * Arguments    : const cint16_T x_data[]
 *                const int x_size[1]
 *                unsigned short nfft
 *                emxArray_creal_T *y
 * Return Type  : void
 */
void Ifft(const cint16_T x_data[], const int x_size[1], unsigned short nfft,
          emxArray_creal_T *y)
{
  emxArray_creal_T *r;
  emxArray_creal_T *x;
  emxArray_real_T *costab;
  emxArray_real_T *sintab;
  emxArray_real_T *sintabinv;
  creal_T *b_x_data;
  creal_T *y_data;
  int loop_ub;
  int pmax;
  emxInit_creal_T(&x, 1);
  pmax = x->size[0];
  x->size[0] = x_size[0];
  emxEnsureCapacity_creal_T(x, pmax);
  b_x_data = x->data;
  loop_ub = x_size[0];
  for (pmax = 0; pmax < loop_ub; pmax++) {
    b_x_data[pmax].re = x_data[pmax].re;
    b_x_data[pmax].im = x_data[pmax].im;
  }
  emxInit_real_T(&costab);
  emxInit_real_T(&sintab);
  emxInit_real_T(&sintabinv);
  emxInit_creal_T(&r, 1);
  if ((x->size[0] == 0) || (nfft == 0)) {
    pmax = y->size[0];
    y->size[0] = nfft;
    emxEnsureCapacity_creal_T(y, pmax);
    y_data = y->data;
    loop_ub = nfft;
    for (pmax = 0; pmax < loop_ub; pmax++) {
      y_data[pmax].re = 0.0;
      y_data[pmax].im = 0.0;
    }
  } else {
    boolean_T useRadix2;
    useRadix2 = ((nfft & (nfft - 1)) == 0);
    loop_ub = 1;
    if (useRadix2) {
      pmax = nfft;
    } else {
      loop_ub = (nfft + nfft) - 1;
      pmax = 31;
      if (loop_ub <= 1) {
        pmax = 0;
      } else {
        int pmin;
        boolean_T exitg1;
        pmin = 0;
        exitg1 = false;
        while ((!exitg1) && (pmax - pmin > 1)) {
          int k;
          int pow2p;
          k = (pmin + pmax) >> 1;
          pow2p = 1 << k;
          if (pow2p == loop_ub) {
            pmax = k;
            exitg1 = true;
          } else if (pow2p > loop_ub) {
            pmax = k;
          } else {
            pmin = k;
          }
        }
      }
      loop_ub = 1 << pmax;
      pmax = loop_ub;
    }
    c_FFTImplementationCallback_gen(pmax, useRadix2, costab, sintab, sintabinv);
    if (useRadix2) {
      c_FFTImplementationCallback_r2b(x, nfft, costab, sintab, r);
      b_x_data = r->data;
      pmax = y->size[0];
      y->size[0] = r->size[0];
      emxEnsureCapacity_creal_T(y, pmax);
      y_data = y->data;
      loop_ub = r->size[0];
      for (pmax = 0; pmax < loop_ub; pmax++) {
        y_data[pmax] = b_x_data[pmax];
      }
    } else {
      c_FFTImplementationCallback_dob(x, loop_ub, nfft, costab, sintab,
                                      sintabinv, y);
    }
  }
  emxFree_creal_T(&r);
  emxFree_real_T(&sintabinv);
  emxFree_real_T(&sintab);
  emxFree_real_T(&costab);
  emxFree_creal_T(&x);
}

/*
 * File trailer for c_Ifft.c
 *
 * [EOF]
 */
