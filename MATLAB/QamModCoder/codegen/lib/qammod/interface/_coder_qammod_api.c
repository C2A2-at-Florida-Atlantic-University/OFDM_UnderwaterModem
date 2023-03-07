/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_QamMod_api.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 12:23:52
 */

/* Include Files */
#include "_coder_QamMod_api.h"
#include "_coder_QamMod_mex.h"
#include "xil_host_interface.h"

/* Variable Definitions */
emlrtCTX emlrtRootTLSGlobal = NULL;

static boolean_T xilAlreadyInited;

emlrtContext emlrtContextGlobal = {
    true,                                                 /* bFirstTime */
    false,                                                /* bInitialized */
    131627U,                                              /* fVersionInfo */
    NULL,                                                 /* fErrorFunction */
    "QamMod",                                             /* fFunctionName */
    NULL,                                                 /* fRTCallStack */
    false,                                                /* bDebugMode */
    {2045744189U, 2170104910U, 2743257031U, 4284093946U}, /* fSigWrd */
    NULL                                                  /* fSigMem */
};

/* Function Declarations */
static void QamMod_once(void);

static int8_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId);

static void b_xilHostDeserializer(real_T *r);

static int8_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId);

static int8_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *x,
                               const char_T *identifier);

static const mxArray *emlrt_marshallOut(const creal_T u);

static void xilHostDeserializer(creal_T *r);

static void xilHostSerializer(const int8_T *r);

/* Function Definitions */
/*
 * Arguments    : void
 * Return Type  : void
 */
static void QamMod_once(void)
{
  xilAlreadyInited = false;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *u
 *                const emlrtMsgIdentifier *parentId
 * Return Type  : int8_T
 */
static int8_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId)
{
  int8_T y;
  y = c_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

/*
 * Arguments    : real_T *r
 * Return Type  : void
 */
static void b_xilHostDeserializer(real_T *r)
{
  xilReadData((uint8_T *)r, (size_t)1, MEM_UNIT_DOUBLE_TYPE);
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *src
 *                const emlrtMsgIdentifier *msgId
 * Return Type  : int8_T
 */
static int8_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims = 0;
  int8_T ret;
  emlrtCheckBuiltInR2012b((emlrtConstCTX)sp, msgId, src, "int8", false, 0U,
                          (const void *)&dims);
  ret = *(int8_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *x
 *                const char_T *identifier
 * Return Type  : int8_T
 */
static int8_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *x,
                               const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  int8_T y;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(sp, emlrtAlias(x), &thisId);
  emlrtDestroyArray(&x);
  return y;
}

/*
 * Arguments    : const creal_T u
 * Return Type  : const mxArray *
 */
static const mxArray *emlrt_marshallOut(const creal_T u)
{
  const mxArray *m;
  const mxArray *y;
  creal_T *r;
  y = NULL;
  m = emlrtCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxCOMPLEX);
  r = (creal_T *)emlrtMxGetData(m);
  *r = u;
  emlrtFreeImagIfZero(m);
  emlrtAssign(&y, m);
  return y;
}

/*
 * Arguments    : creal_T *r
 * Return Type  : void
 */
static void xilHostDeserializer(creal_T *r)
{
  real_T im;
  real_T re;
  b_xilHostDeserializer(&re);
  b_xilHostDeserializer(&im);
  r->re = re;
  r->im = im;
}

/*
 * Arguments    : const int8_T *r
 * Return Type  : void
 */
static void xilHostSerializer(const int8_T *r)
{
  xilWriteData((uint8_T *)r, (size_t)1, MEM_UNIT_INT8_TYPE);
}

/*
 * Arguments    : int8_T x
 *                int8_T M
 * Return Type  : creal_T
 */
creal_T QamModXilWrapper(int8_T x, int8_T M)
{
  creal_T y;
  /* Serialize function input argument x. */
  xilHostSerializer(&x);
  /* Serialize function input argument M. */
  xilHostSerializer(&M);
  /* Calling XIL to invoke target side. */
  xilEntryPointHost(1U);
  /* Deserialize function output argument y. */
  xilHostDeserializer(&y);
  return y;
}

/*
 * Arguments    : const mxArray * const prhs[2]
 *                const mxArray **plhs
 * Return Type  : void
 */
void QamMod_api(const mxArray *const prhs[2], const mxArray **plhs)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  creal_T y;
  int8_T M;
  int8_T x;
  st.tls = emlrtRootTLSGlobal;
  /* Marshall function inputs */
  x = emlrt_marshallIn(&st, emlrtAliasP(prhs[0]), "x");
  M = emlrt_marshallIn(&st, emlrtAliasP(prhs[1]), "M");
  /* Calling XIL to setup. */
  xilPreEntryPointHost(1U);
  /* Invoke the wrapper function */
  y = QamModXilWrapper(x, M);
  /* Calling Xil to clean-up. */
  xilPostEntryPointHost(1U);
  /* Marshall function outputs */
  *plhs = emlrt_marshallOut(y);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void QamMod_atexit(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  QamMod_xil_terminate();
  QamMod_xil_shutdown();
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void QamMod_initialize(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, NULL);
  emlrtEnterRtStackR2012b(&st);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    QamMod_once();
  }
  if (!xilAlreadyInited) {
    xilInitializeHost(&xil_terminate);
    xilAlreadyInited = true;
  }
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void QamMod_terminate(void)
{
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void xil_terminate(void)
{
  xilAlreadyInited = false;
  QamMod_terminate();
}

/*
 * File trailer for _coder_QamMod_api.c
 *
 * [EOF]
 */
