/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_Interp_emxAPI.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 20:42:58
 */

/* Include Files */
#include "g_Interp_emxAPI.h"
#include "g_Interp_emxutil.h"
#include "g_Interp_types.h"
#include <stdlib.h>

/* Function Definitions */
/*
 * Arguments    : int numDimensions
 *                const int *size
 * Return Type  : g_emxArray_creal_T *
 */
g_emxArray_creal_T *g_emxCreateND_creal_T(int numDimensions, const int *size)
{
  g_emxArray_creal_T *emx;
  int i;
  int numEl;
  g_emxInit_creal_T(&emx, numDimensions);
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
 * Return Type  : g_emxArray_creal_T *
 */
g_emxArray_creal_T *
g_emxCreateWrapperND_creal_T(creal_T *data, int numDimensions, const int *size)
{
  g_emxArray_creal_T *emx;
  int i;
  int numEl;
  g_emxInit_creal_T(&emx, numDimensions);
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
 * Return Type  : g_emxArray_creal_T *
 */
g_emxArray_creal_T *g_emxCreateWrapper_creal_T(creal_T *data, int rows,
                                               int cols)
{
  g_emxArray_creal_T *emx;
  g_emxInit_creal_T(&emx, 2);
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
 * Return Type  : g_emxArray_creal_T *
 */
g_emxArray_creal_T *g_emxCreate_creal_T(int rows, int cols)
{
  g_emxArray_creal_T *emx;
  int numEl;
  g_emxInit_creal_T(&emx, 2);
  emx->size[0] = rows;
  numEl = rows * cols;
  emx->size[1] = cols;
  emx->data = (creal_T *)calloc((unsigned int)numEl, sizeof(creal_T));
  emx->numDimensions = 2;
  emx->allocatedSize = numEl;
  return emx;
}

/*
 * Arguments    : g_emxArray_creal_T *emxArray
 * Return Type  : void
 */
void g_emxDestroyArray_creal_T(g_emxArray_creal_T *emxArray)
{
  g_emxFree_creal_T(&emxArray);
}

/*
 * Arguments    : g_emxArray_creal_T **pEmxArray
 *                int numDimensions
 * Return Type  : void
 */
void g_emxInitArray_creal_T(g_emxArray_creal_T **pEmxArray, int numDimensions)
{
  g_emxInit_creal_T(pEmxArray, numDimensions);
}

/*
 * File trailer for g_Interp_emxAPI.c
 *
 * [EOF]
 */
