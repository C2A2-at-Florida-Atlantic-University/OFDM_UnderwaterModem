/*
 * File: coder_assumptions.h
 *
 * Abstract: Coder assumptions header file
 */

#ifndef CODER_ASSUMPTIONS_H
#define CODER_ASSUMPTIONS_H

/* include model specific checks */
#include "QamMod_ca.h"

/* global results variable mapping for static code */
#define CA_Expected_HWImpl             CA_QamMod_ExpHW
#define CA_Actual_HWImpl               CA_QamMod_ActHW
#define CA_HWImpl_Results              CA_QamMod_HWRes
#define CA_PortableWordSizes_Results   CA_QamMod_PWSRes

/* entry point function mapping for static code */
#define CA_Run_Tests                   QamMod_caRunTests
#endif                                 /* CODER_ASSUMPTIONS_H */
