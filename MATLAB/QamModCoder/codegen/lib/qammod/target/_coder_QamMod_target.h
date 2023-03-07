/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_QamMod_target.h
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 12:23:52
 */

#ifndef _CODER_QAMMOD_TARGET_H
#define _CODER_QAMMOD_TARGET_H

/* Include Files */
#include "QamMod_types.h"
#include "rtwtypes.h"
#include "xil_interface_common.h"
#include "xil_target_interface.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern void XILTarget_initialize(uint32_T fcnId);

extern void XILTarget_terminate(uint32_T fcnId);

extern XIL_PROCESSDATA_ERROR_CODE xilTarget_QamMod(uint32_T fcnId);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_QamMod_target.h
 *
 * [EOF]
 */
