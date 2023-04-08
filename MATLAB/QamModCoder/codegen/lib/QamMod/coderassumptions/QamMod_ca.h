/*
 * File: QamMod_ca.h
 *
 * Abstract: Tests assumptions in the generated code.
 */

#ifndef QAMMOD_CA_H
#define QAMMOD_CA_H

/* preprocessor validation checks */
#include "QamMod_ca_preproc.h"
#include "coder_assumptions_hwimpl.h"

/* variables holding test results */
extern CA_HWImpl_TestResults CA_QamMod_HWRes;
extern CA_PWS_TestResults CA_QamMod_PWSRes;

/* variables holding "expected" and "actual" hardware implementation */
extern const CA_HWImpl CA_QamMod_ExpHW;
extern CA_HWImpl CA_QamMod_ActHW;

/* entry point function to run tests */
void QamMod_caRunTests(void);

#endif                                 /* QAMMOD_CA_H */
