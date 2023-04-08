/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_filter.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 20:42:58
 */

/* Include Files */
#include "g_filter.h"
#include "g_Interp_emxutil.h"
#include "g_Interp_types.h"

/* Function Declarations */
static void d_filter(const g_emxArray_real_T *b, const g_emxArray_creal_T *x,
                     const g_emxArray_creal_T *zi, g_emxArray_creal_T *y);

/* Function Definitions */
/*
 * Arguments    : const g_emxArray_real_T *b
 *                const g_emxArray_creal_T *x
 *                const g_emxArray_creal_T *zi
 *                g_emxArray_creal_T *y
 * Return Type  : void
 */
static void d_filter(const g_emxArray_real_T *b, const g_emxArray_creal_T *x,
                     const g_emxArray_creal_T *zi, g_emxArray_creal_T *y)
{
  const creal_T *x_data;
  const creal_T *zi_data;
  creal_T *y_data;
  const double *b_data;
  int i;
  int j;
  int k;
  int nb;
  int niccp;
  int nx;
  zi_data = zi->data;
  x_data = x->data;
  b_data = b->data;
  nb = b->size[0] - 1;
  i = y->size[0];
  y->size[0] = x->size[0];
  g_emxEnsureCapacity_creal_T(y, i);
  y_data = y->data;
  nx = x->size[0];
  if (x->size[0] < b->size[0] - 1) {
    niccp = x->size[0] + 1;
  } else {
    niccp = b->size[0];
  }
  if (zi->size[0] == b->size[0] - 1) {
    i = 1;
  } else {
    i = 2;
  }
  if (i == 2) {
    for (k = 0; k <= niccp - 2; k++) {
      y_data[k] = zi_data[k];
    }
    for (k = niccp; k <= nx; k++) {
      y_data[k - 1].re = 0.0;
      y_data[k - 1].im = 0.0;
    }
  } else {
    for (k = 0; k <= niccp - 2; k++) {
      y_data[k] = zi_data[k];
    }
    for (k = niccp; k <= nx; k++) {
      y_data[k - 1].re = 0.0;
      y_data[k - 1].im = 0.0;
    }
  }
  if (x->size[0] >= (b->size[0] << 1)) {
    for (k = 0; k <= nb; k++) {
      niccp = k + 1;
      for (j = niccp; j <= nx; j++) {
        i = (j - k) - 1;
        y_data[j - 1].re += b_data[k] * x_data[i].re;
        y_data[j - 1].im += b_data[k] * x_data[i].im;
      }
    }
  } else {
    if (x->size[0] > b->size[0]) {
      niccp = x->size[0] - b->size[0];
    } else {
      niccp = 0;
    }
    for (k = 0; k < niccp; k++) {
      for (j = 0; j <= nb; j++) {
        i = k + j;
        y_data[i].re += x_data[k].re * b_data[j];
        y_data[i].im += x_data[k].im * b_data[j];
      }
    }
    nb = x->size[0] - niccp;
    i = niccp + 1;
    for (k = i; k <= nx; k++) {
      for (j = 0; j < nb; j++) {
        niccp = (k + j) - 1;
        y_data[niccp].re += x_data[k - 1].re * b_data[j];
        y_data[niccp].im += x_data[k - 1].im * b_data[j];
      }
      nb--;
    }
  }
}

/*
 * Arguments    : const g_emxArray_real_T *b
 *                const g_emxArray_creal_T *x
 *                const g_emxArray_creal_T *zi
 *                g_emxArray_creal_T *y
 *                g_emxArray_creal_T *zf
 * Return Type  : void
 */
void b_filter(const g_emxArray_real_T *b, const g_emxArray_creal_T *x,
              const g_emxArray_creal_T *zi, g_emxArray_creal_T *y,
              g_emxArray_creal_T *zf)
{
  g_emxArray_creal_T *b_b;
  g_emxArray_creal_T *b_y1;
  const creal_T *x_data;
  const creal_T *zi_data;
  creal_T *b_b_data;
  creal_T *y1_data;
  creal_T *zf_data;
  const double *b_data;
  int i;
  int j;
  int k;
  int naxpy;
  int nb;
  int niccp;
  int nx;
  signed char zicase;
  zi_data = zi->data;
  x_data = x->data;
  b_data = b->data;
  g_emxInit_creal_T(&b_b, 1);
  i = b_b->size[0];
  b_b->size[0] = x->size[1];
  g_emxEnsureCapacity_creal_T(b_b, i);
  b_b_data = b_b->data;
  niccp = x->size[1];
  for (i = 0; i < niccp; i++) {
    b_b_data[i] = x_data[i];
  }
  nb = b->size[0] - 1;
  if (zi->size[0] == b->size[0] - 1) {
    zicase = 1;
  } else {
    zicase = 2;
  }
  g_emxInit_creal_T(&b_y1, 1);
  i = b_y1->size[0];
  b_y1->size[0] = b_b->size[0];
  g_emxEnsureCapacity_creal_T(b_y1, i);
  y1_data = b_y1->data;
  nx = b_b->size[0];
  i = zf->size[0];
  zf->size[0] = b->size[0] - 1;
  g_emxEnsureCapacity_creal_T(zf, i);
  zf_data = zf->data;
  niccp = b->size[0] - 1;
  for (i = 0; i < niccp; i++) {
    zf_data[i].re = 0.0;
    zf_data[i].im = 0.0;
  }
  if (b_b->size[0] < b->size[0] - 1) {
    niccp = b_b->size[0] + 1;
  } else {
    niccp = b->size[0];
  }
  if (zicase == 2) {
    for (k = 0; k <= niccp - 2; k++) {
      y1_data[k] = zi_data[k];
    }
    for (k = niccp; k <= nx; k++) {
      y1_data[k - 1].re = 0.0;
      y1_data[k - 1].im = 0.0;
    }
  } else {
    for (k = 0; k <= niccp - 2; k++) {
      y1_data[k] = zi_data[k];
    }
    for (k = niccp; k <= nx; k++) {
      y1_data[k - 1].re = 0.0;
      y1_data[k - 1].im = 0.0;
    }
  }
  if (b_b->size[0] >= (b->size[0] << 1)) {
    for (k = 0; k <= nb; k++) {
      niccp = k + 1;
      for (j = niccp; j <= nx; j++) {
        i = (j - k) - 1;
        y1_data[j - 1].re += b_data[k] * b_b_data[i].re;
        y1_data[j - 1].im += b_data[k] * b_b_data[i].im;
      }
    }
  } else {
    if (b_b->size[0] > b->size[0]) {
      niccp = b_b->size[0] - b->size[0];
    } else {
      niccp = 0;
    }
    for (k = 0; k < niccp; k++) {
      for (j = 0; j <= nb; j++) {
        i = k + j;
        y1_data[i].re += b_b_data[k].re * b_data[j];
        y1_data[i].im += b_b_data[k].im * b_data[j];
      }
    }
    naxpy = b_b->size[0] - niccp;
    i = niccp + 1;
    for (k = i; k <= nx; k++) {
      for (j = 0; j < naxpy; j++) {
        niccp = (k + j) - 1;
        y1_data[niccp].re += b_b_data[k - 1].re * b_data[j];
        y1_data[niccp].im += b_b_data[k - 1].im * b_data[j];
      }
      naxpy--;
    }
  }
  if (b_b->size[0] < b->size[0] - 1) {
    niccp = (b->size[0] - b_b->size[0]) - 2;
    if (zicase == 2) {
      for (k = 0; k <= niccp; k++) {
        zf_data[k] = zi_data[k + nx];
      }
    } else {
      for (k = 0; k <= niccp; k++) {
        zf_data[k] = zi_data[k + nx];
      }
    }
  }
  if (b_b->size[0] >= b->size[0]) {
    niccp = (b_b->size[0] - b->size[0]) + 1;
  } else {
    niccp = 0;
  }
  i = b_b->size[0] - 1;
  for (k = niccp; k <= i; k++) {
    int boffset;
    boffset = nx - k;
    naxpy = (nb - nx) + k;
    for (j = 0; j <= naxpy; j++) {
      double d;
      d = b_data[boffset + j];
      zf_data[j].re += b_b_data[k].re * d;
      zf_data[j].im += b_b_data[k].im * d;
    }
  }
  g_emxFree_creal_T(&b_b);
  i = y->size[0] * y->size[1];
  y->size[0] = 1;
  y->size[1] = b_y1->size[0];
  g_emxEnsureCapacity_creal_T(y, i);
  zf_data = y->data;
  niccp = b_y1->size[0];
  for (i = 0; i < niccp; i++) {
    zf_data[i] = y1_data[i];
  }
  g_emxFree_creal_T(&b_y1);
}

/*
 * Arguments    : const g_emxArray_real_T *b
 *                const g_emxArray_creal_T *x
 *                const g_emxArray_creal_T *zi
 *                g_emxArray_creal_T *y
 * Return Type  : void
 */
void c_filter(const g_emxArray_real_T *b, const g_emxArray_creal_T *x,
              const g_emxArray_creal_T *zi, g_emxArray_creal_T *y)
{
  g_emxArray_creal_T *b_b;
  g_emxArray_creal_T *b_y1;
  g_emxArray_creal_T *b_zi;
  g_emxArray_creal_T *c_b;
  g_emxArray_creal_T *r;
  const creal_T *x_data;
  const creal_T *zi_data;
  creal_T *b_b_data;
  creal_T *y1_data;
  creal_T *y_data;
  const double *b_data;
  int c;
  int i;
  int j;
  int k;
  int naxpy;
  int nb;
  int nc;
  int niccp;
  int nx;
  signed char zicase;
  zi_data = zi->data;
  x_data = x->data;
  b_data = b->data;
  g_emxInit_creal_T(&b_b, 2);
  i = b_b->size[0] * b_b->size[1];
  b_b->size[0] = x->size[1];
  b_b->size[1] = x->size[0];
  g_emxEnsureCapacity_creal_T(b_b, i);
  b_b_data = b_b->data;
  naxpy = x->size[0];
  for (i = 0; i < naxpy; i++) {
    nb = x->size[1];
    for (niccp = 0; niccp < nb; niccp++) {
      b_b_data[niccp + b_b->size[0] * i] = x_data[i + x->size[0] * niccp];
    }
  }
  nb = b->size[0];
  if (zi->size[0] == b->size[0] - 1) {
    zicase = 1;
  } else {
    zicase = 2;
  }
  g_emxInit_creal_T(&b_y1, 2);
  i = b_y1->size[0] * b_y1->size[1];
  b_y1->size[0] = b_b->size[0];
  b_y1->size[1] = b_b->size[1];
  g_emxEnsureCapacity_creal_T(b_y1, i);
  y1_data = b_y1->data;
  nx = b_b->size[0];
  nc = b_b->size[1] - 1;
  if (b_b->size[1] >= 2) {
    g_emxInit_creal_T(&c_b, 1);
    g_emxInit_creal_T(&r, 1);
    if (zicase == 2) {
      naxpy = b_b->size[0];
      nb = zi->size[0];
      g_emxInit_creal_T(&b_zi, 1);
      for (c = 0; c <= nc; c++) {
        i = c_b->size[0];
        c_b->size[0] = b_b->size[0];
        g_emxEnsureCapacity_creal_T(c_b, i);
        y_data = c_b->data;
        for (i = 0; i < naxpy; i++) {
          y_data[i] = b_b_data[i + b_b->size[0] * c];
        }
        i = b_zi->size[0];
        b_zi->size[0] = zi->size[0];
        g_emxEnsureCapacity_creal_T(b_zi, i);
        y_data = b_zi->data;
        for (i = 0; i < nb; i++) {
          y_data[i] = zi_data[i];
        }
        d_filter(b, c_b, b_zi, r);
        y_data = r->data;
        niccp = r->size[0];
        for (i = 0; i < niccp; i++) {
          y1_data[i + b_y1->size[0] * c] = y_data[i];
        }
      }
      g_emxFree_creal_T(&b_zi);
    } else {
      naxpy = b_b->size[0];
      for (c = 0; c <= nc; c++) {
        i = c_b->size[0];
        c_b->size[0] = b_b->size[0];
        g_emxEnsureCapacity_creal_T(c_b, i);
        y_data = c_b->data;
        for (i = 0; i < naxpy; i++) {
          y_data[i] = b_b_data[i + b_b->size[0] * c];
        }
        d_filter(b, c_b, zi, r);
        y_data = r->data;
        nb = r->size[0];
        for (i = 0; i < nb; i++) {
          y1_data[i + b_y1->size[0] * c] = y_data[i];
        }
      }
    }
    g_emxFree_creal_T(&r);
    g_emxFree_creal_T(&c_b);
  } else {
    if (b_b->size[0] < b->size[0] - 1) {
      niccp = b_b->size[0] + 1;
    } else {
      niccp = b->size[0];
    }
    for (c = 0; c <= nc; c++) {
      if (zicase == 2) {
        for (k = 0; k <= niccp - 2; k++) {
          y1_data[k] = zi_data[k];
        }
        for (k = niccp; k <= nx; k++) {
          y1_data[k - 1].re = 0.0;
          y1_data[k - 1].im = 0.0;
        }
      } else {
        for (k = 0; k <= niccp - 2; k++) {
          y1_data[k] = zi_data[k];
        }
        for (k = niccp; k <= nx; k++) {
          y1_data[k - 1].re = 0.0;
          y1_data[k - 1].im = 0.0;
        }
      }
    }
    for (c = 0; c <= nc; c++) {
      if (nx >= (nb << 1)) {
        for (k = 0; k < nb; k++) {
          niccp = k + 1;
          for (j = niccp; j <= nx; j++) {
            i = (j - k) - 1;
            y1_data[j - 1].re += b_data[k] * b_b_data[i].re;
            y1_data[j - 1].im += b_data[k] * b_b_data[i].im;
          }
        }
      } else {
        if (nx > nb) {
          niccp = nx - nb;
        } else {
          niccp = 0;
        }
        for (k = 0; k < niccp; k++) {
          for (j = 0; j < nb; j++) {
            i = k + j;
            y1_data[i].re += b_b_data[k].re * b_data[j];
            y1_data[i].im += b_b_data[k].im * b_data[j];
          }
        }
        naxpy = nx - niccp;
        i = niccp + 1;
        for (k = i; k <= nx; k++) {
          for (j = 0; j < naxpy; j++) {
            niccp = (k + j) - 1;
            y1_data[niccp].re += b_b_data[k - 1].re * b_data[j];
            y1_data[niccp].im += b_b_data[k - 1].im * b_data[j];
          }
          naxpy--;
        }
      }
    }
  }
  g_emxFree_creal_T(&b_b);
  i = y->size[0] * y->size[1];
  y->size[0] = b_y1->size[1];
  y->size[1] = b_y1->size[0];
  g_emxEnsureCapacity_creal_T(y, i);
  y_data = y->data;
  naxpy = b_y1->size[0];
  for (i = 0; i < naxpy; i++) {
    nb = b_y1->size[1];
    for (niccp = 0; niccp < nb; niccp++) {
      y_data[niccp + y->size[0] * i] = y1_data[i + b_y1->size[0] * niccp];
    }
  }
  g_emxFree_creal_T(&b_y1);
}

/*
 * Arguments    : const g_emxArray_real_T *b
 *                const g_emxArray_creal_T *x
 *                g_emxArray_creal_T *y
 *                g_emxArray_creal_T *zf
 * Return Type  : void
 */
void filter(const g_emxArray_real_T *b, const g_emxArray_creal_T *x,
            g_emxArray_creal_T *y, g_emxArray_creal_T *zf)
{
  const creal_T *x_data;
  creal_T *y_data;
  creal_T *zf_data;
  const double *b_data;
  int i;
  int j;
  int k;
  int naxpy;
  int nb;
  int nx;
  int nx_m_nb;
  x_data = x->data;
  b_data = b->data;
  nb = b->size[0] - 1;
  nx = x->size[0];
  i = zf->size[0];
  zf->size[0] = b->size[0] - 1;
  g_emxEnsureCapacity_creal_T(zf, i);
  zf_data = zf->data;
  nx_m_nb = b->size[0] - 1;
  for (i = 0; i < nx_m_nb; i++) {
    zf_data[i].re = 0.0;
    zf_data[i].im = 0.0;
  }
  i = y->size[0];
  y->size[0] = x->size[0];
  g_emxEnsureCapacity_creal_T(y, i);
  y_data = y->data;
  nx_m_nb = x->size[0];
  for (i = 0; i < nx_m_nb; i++) {
    y_data[i].re = 0.0;
    y_data[i].im = 0.0;
  }
  if (x->size[0] >= (b->size[0] << 1)) {
    for (k = 0; k <= nb; k++) {
      nx_m_nb = k + 1;
      for (j = nx_m_nb; j <= nx; j++) {
        i = (j - k) - 1;
        y_data[j - 1].re += b_data[k] * x_data[i].re;
        y_data[j - 1].im += b_data[k] * x_data[i].im;
      }
    }
  } else {
    if (x->size[0] > b->size[0]) {
      nx_m_nb = x->size[0] - b->size[0];
    } else {
      nx_m_nb = 0;
    }
    for (k = 0; k < nx_m_nb; k++) {
      for (j = 0; j <= nb; j++) {
        i = k + j;
        y_data[i].re += x_data[k].re * b_data[j];
        y_data[i].im += x_data[k].im * b_data[j];
      }
    }
    naxpy = x->size[0] - nx_m_nb;
    i = nx_m_nb + 1;
    for (k = i; k <= nx; k++) {
      for (j = 0; j < naxpy; j++) {
        nx_m_nb = (k + j) - 1;
        y_data[nx_m_nb].re += x_data[k - 1].re * b_data[j];
        y_data[nx_m_nb].im += x_data[k - 1].im * b_data[j];
      }
      naxpy--;
    }
  }
  if (x->size[0] >= b->size[0]) {
    nx_m_nb = (x->size[0] - b->size[0]) + 1;
  } else {
    nx_m_nb = 0;
  }
  i = x->size[0] - 1;
  for (k = nx_m_nb; k <= i; k++) {
    int boffset;
    boffset = nx - k;
    naxpy = (nb - nx) + k;
    for (j = 0; j <= naxpy; j++) {
      double d;
      d = b_data[boffset + j];
      zf_data[j].re += x_data[k].re * d;
      zf_data[j].im += x_data[k].im * d;
    }
  }
}

/*
 * File trailer for g_filter.c
 *
 * [EOF]
 */
