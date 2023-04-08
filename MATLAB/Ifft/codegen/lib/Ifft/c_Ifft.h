/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: c_Ifft.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 27-Mar-2023 19:38:35
 */

#ifndef C_IFFT_H
#define C_IFFT_H

/* Include Files */
#include "c_Ifft_types.h"
#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void Ifft(const cint16_T x_data[], const int x_size[1],
                 unsigned short nfft, emxArray_creal_T *y);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for c_Ifft.h
 *
 * [EOF]
 */
