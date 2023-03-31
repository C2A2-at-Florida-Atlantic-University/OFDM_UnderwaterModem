/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: h_Decimate_emxAPI.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
 */

/* Include Files */
#include "h_Decimate_emxAPI.h"
#include "h_Decimate_emxutil.h"
#include "h_Decimate_types.h"
#include "rt_nonfinite.h"
#include <stdlib.h>

/* Function Definitions */
/*
 * Arguments    : int numDimensions
 *                const int *size
 * Return Type  : emxArray_creal_T *
 */
emxArray_creal_T *h_emxCreateND_creal_T(int numDimensions, const int *size)
{
  emxArray_creal_T *emx;
  int i;
  int numEl;
  h_emxInit_creal_T(&emx, numDimensions);
  numEl = 1;
  for (i = 0; i < numDimensions; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }
  emx->data = (creal_T *)calloc((unsigned int)numEl, sizeof(creal_T));
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  return emx;
}

/*
 * Arguments    : creal_T *data
 *                int numDimensions
 *                const int *size
 * Return Type  : emxArray_creal_T *
 */
emxArray_creal_T *h_emxCreateWrapperND_creal_T(creal_T *data, int numDimensions,
                                               const int *size)
{
  emxArray_creal_T *emx;
  int i;
  int numEl;
  h_emxInit_creal_T(&emx, numDimensions);
  numEl = 1;
  for (i = 0; i < numDimensions; i++) {
    numEl *= size[i];
    emx->size[i] = size[i];
  }
  emx->data = data;
  emx->numDimensions = numDimensions;
  emx->allocatedSize = numEl;
  emx->canFreeData = false;
  return emx;
}

/*
 * Arguments    : creal_T *data
 *                int rows
 *                int cols
 * Return Type  : emxArray_creal_T *
 */
emxArray_creal_T *h_emxCreateWrapper_creal_T(creal_T *data, int rows, int cols)
{
  emxArray_creal_T *emx;
  h_emxInit_creal_T(&emx, 2);
  emx->size[0] = rows;
  emx->size[1] = cols;
  emx->data = data;
  emx->numDimensions = 2;
  emx->allocatedSize = rows * cols;
  emx->canFreeData = false;
  return emx;
}

/*
 * Arguments    : int rows
 *                int cols
 * Return Type  : emxArray_creal_T *
 */
emxArray_creal_T *h_emxCreate_creal_T(int rows, int cols)
{
  emxArray_creal_T *emx;
  int numEl;
  h_emxInit_creal_T(&emx, 2);
  emx->size[0] = rows;
  numEl = rows * cols;
  emx->size[1] = cols;
  emx->data = (creal_T *)calloc((unsigned int)numEl, sizeof(creal_T));
  emx->numDimensions = 2;
  emx->allocatedSize = numEl;
  return emx;
}

/*
 * Arguments    : emxArray_creal_T *emxArray
 * Return Type  : void
 */
void h_emxDestroyArray_creal_T(emxArray_creal_T *emxArray)
{
  h_emxFree_creal_T(&emxArray);
}

/*
 * Arguments    : emxArray_creal_T **pEmxArray
 *                int numDimensions
 * Return Type  : void
 */
void h_emxInitArray_creal_T(emxArray_creal_T **pEmxArray, int numDimensions)
{
  h_emxInit_creal_T(pEmxArray, numDimensions);
}

/*
 * File trailer for h_Decimate_emxAPI.c
 *
 * [EOF]
 */
