/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: c_Ifft_emxAPI.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 27-Mar-2023 19:38:35
 */

/* Include Files */
#include "c_Ifft_emxAPI.h"
#include "c_Ifft_emxutil.h"
#include "c_Ifft_types.h"
#include <stdlib.h>

/* Function Definitions */
/*
 * Arguments    : int numDimensions
 *                const int *size
 * Return Type  : emxArray_creal_T *
 */
emxArray_creal_T *emxCreateND_creal_T(int numDimensions, const int *size)
{
  emxArray_creal_T *emx;
  int i;
  int numEl;
  emxInit_creal_T(&emx, numDimensions);
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
emxArray_creal_T *emxCreateWrapperND_creal_T(creal_T *data, int numDimensions,
                                             const int *size)
{
  emxArray_creal_T *emx;
  int i;
  int numEl;
  emxInit_creal_T(&emx, numDimensions);
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
emxArray_creal_T *emxCreateWrapper_creal_T(creal_T *data, int rows, int cols)
{
  emxArray_creal_T *emx;
  emxInit_creal_T(&emx, 2);
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
emxArray_creal_T *emxCreate_creal_T(int rows, int cols)
{
  emxArray_creal_T *emx;
  int numEl;
  emxInit_creal_T(&emx, 2);
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
void emxDestroyArray_creal_T(emxArray_creal_T *emxArray)
{
  emxFree_creal_T(&emxArray);
}

/*
 * Arguments    : emxArray_creal_T **pEmxArray
 *                int numDimensions
 * Return Type  : void
 */
void emxInitArray_creal_T(emxArray_creal_T **pEmxArray, int numDimensions)
{
  emxInit_creal_T(pEmxArray, numDimensions);
}

/*
 * File trailer for c_Ifft_emxAPI.c
 *
 * [EOF]
 */
