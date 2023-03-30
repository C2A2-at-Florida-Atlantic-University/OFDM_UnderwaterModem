/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: g_Interp_emxutil.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 14:28:10
 */

/* Include Files */
#include "g_Interp_emxutil.h"
#include "g_Interp_types.h"
#include <stdlib.h>
#include <string.h>

/* Function Definitions */
/*
 * Arguments    : g_emxArray_creal_T *emxArray
 *                int oldNumel
 * Return Type  : void
 */
void g_emxEnsureCapacity_creal_T(g_emxArray_creal_T *emxArray, int oldNumel)
{
  int i;
  int newNumel;
  void *newData;
  if (oldNumel < 0) {
    oldNumel = 0;
  }
  newNumel = 1;
  for (i = 0; i < emxArray->numDimensions; i++) {
    newNumel *= emxArray->size[i];
  }
  if (newNumel > emxArray->allocatedSize) {
    i = emxArray->allocatedSize;
    if (i < 16) {
      i = 16;
    }
    while (i < newNumel) {
      if (i > 1073741823) {
        i = MAX_int32_T;
      } else {
        i *= 2;
      }
    }
    newData = calloc((unsigned int)i, sizeof(creal_T));
    if (emxArray->data != NULL) {
      memcpy(newData, emxArray->data, sizeof(creal_T) * (unsigned int)oldNumel);
      if (emxArray->canFreeData) {
        free(emxArray->data);
      }
    }
    emxArray->data = (creal_T *)newData;
    emxArray->allocatedSize = i;
    emxArray->canFreeData = true;
  }
}

/*
 * Arguments    : g_emxArray_real_T *emxArray
 *                int oldNumel
 * Return Type  : void
 */
void g_emxEnsureCapacity_real_T(g_emxArray_real_T *emxArray, int oldNumel)
{
  int i;
  int newNumel;
  void *newData;
  if (oldNumel < 0) {
    oldNumel = 0;
  }
  newNumel = 1;
  for (i = 0; i < emxArray->numDimensions; i++) {
    newNumel *= emxArray->size[i];
  }
  if (newNumel > emxArray->allocatedSize) {
    i = emxArray->allocatedSize;
    if (i < 16) {
      i = 16;
    }
    while (i < newNumel) {
      if (i > 1073741823) {
        i = MAX_int32_T;
      } else {
        i *= 2;
      }
    }
    newData = calloc((unsigned int)i, sizeof(double));
    if (emxArray->data != NULL) {
      memcpy(newData, emxArray->data, sizeof(double) * (unsigned int)oldNumel);
      if (emxArray->canFreeData) {
        free(emxArray->data);
      }
    }
    emxArray->data = (double *)newData;
    emxArray->allocatedSize = i;
    emxArray->canFreeData = true;
  }
}

/*
 * Arguments    : g_emxArray_creal_T **pEmxArray
 * Return Type  : void
 */
void g_emxFree_creal_T(g_emxArray_creal_T **pEmxArray)
{
  if (*pEmxArray != (g_emxArray_creal_T *)NULL) {
    if (((*pEmxArray)->data != (creal_T *)NULL) && (*pEmxArray)->canFreeData) {
      free((*pEmxArray)->data);
    }
    free((*pEmxArray)->size);
    free(*pEmxArray);
    *pEmxArray = (g_emxArray_creal_T *)NULL;
  }
}

/*
 * Arguments    : g_emxArray_real_T **pEmxArray
 * Return Type  : void
 */
void g_emxFree_real_T(g_emxArray_real_T **pEmxArray)
{
  if (*pEmxArray != (g_emxArray_real_T *)NULL) {
    if (((*pEmxArray)->data != (double *)NULL) && (*pEmxArray)->canFreeData) {
      free((*pEmxArray)->data);
    }
    free((*pEmxArray)->size);
    free(*pEmxArray);
    *pEmxArray = (g_emxArray_real_T *)NULL;
  }
}

/*
 * Arguments    : g_emxArray_creal_T **pEmxArray
 *                int numDimensions
 * Return Type  : void
 */
void g_emxInit_creal_T(g_emxArray_creal_T **pEmxArray, int numDimensions)
{
  g_emxArray_creal_T *emxArray;
  int i;
  *pEmxArray = (g_emxArray_creal_T *)malloc(sizeof(g_emxArray_creal_T));
  emxArray = *pEmxArray;
  emxArray->data = (creal_T *)NULL;
  emxArray->numDimensions = numDimensions;
  emxArray->size = (int *)malloc(sizeof(int) * (unsigned int)numDimensions);
  emxArray->allocatedSize = 0;
  emxArray->canFreeData = true;
  for (i = 0; i < numDimensions; i++) {
    emxArray->size[i] = 0;
  }
}

/*
 * Arguments    : g_emxArray_real_T **pEmxArray
 *                int numDimensions
 * Return Type  : void
 */
void g_emxInit_real_T(g_emxArray_real_T **pEmxArray, int numDimensions)
{
  g_emxArray_real_T *emxArray;
  int i;
  *pEmxArray = (g_emxArray_real_T *)malloc(sizeof(g_emxArray_real_T));
  emxArray = *pEmxArray;
  emxArray->data = (double *)NULL;
  emxArray->numDimensions = numDimensions;
  emxArray->size = (int *)malloc(sizeof(int) * (unsigned int)numDimensions);
  emxArray->allocatedSize = 0;
  emxArray->canFreeData = true;
  for (i = 0; i < numDimensions; i++) {
    emxArray->size[i] = 0;
  }
}

/*
 * File trailer for g_Interp_emxutil.c
 *
 * [EOF]
 */
