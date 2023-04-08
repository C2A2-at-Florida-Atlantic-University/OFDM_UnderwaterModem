/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: main.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 26-Feb-2023 12:23:52
 */

/*************************************************************************/
/* This automatically generated example C main file shows how to call    */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/

/* Include Files */
#include "main.h"
#include "QamMod.h"
#include "QamMod_terminate.h"
#include "rt_nonfinite.h"

/* Function Declarations */
static int8_T argInit_int8_T(void);

/* Function Definitions */
/*
 * Arguments    : void
 * Return Type  : int8_T
 */
static int8_T argInit_int8_T(void)
{
  return 0;
}

/*
 * Arguments    : int32_T argc
 *                char **argv
 * Return Type  : int32_T
 */
int32_T main(int32_T argc, char **argv)
{
  (void)argc;
  (void)argv;
  /* The initialize function is being called automatically from your entry-point
   * function. So, a call to initialize is not included here. */
  /* Invoke the entry-point functions.
You can call entry-point functions multiple times. */
  main_QamMod();
  /* Terminate the application.
You do not need to do this more than one time. */
  QamMod_terminate();
  return 0;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void main_QamMod(void)
{
  creal_T y;
  int8_T x_tmp;
  /* Initialize function 'QamMod' input arguments. */
  x_tmp = argInit_int8_T();
  /* Call the entry-point 'QamMod'. */
  y = QamMod(x_tmp, x_tmp);
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
