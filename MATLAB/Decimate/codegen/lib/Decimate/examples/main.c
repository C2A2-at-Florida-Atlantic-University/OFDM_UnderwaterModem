/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: main.c
 *
 * MATLAB Coder version            : 5.5
 * C/C++ source code generated on  : 30-Mar-2023 23:34:55
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
#include "h_Decimate.h"
#include "h_Decimate_emxAPI.h"
#include "h_Decimate_terminate.h"
#include "h_Decimate_types.h"
#include "rt_nonfinite.h"

/* Function Declarations */
static emxArray_creal_T *argInit_1xd1638400_creal_T(void);

static creal_T argInit_creal_T(void);

static double argInit_real_T(void);

/* Function Definitions */
/*
 * Arguments    : void
 * Return Type  : emxArray_creal_T *
 */
static emxArray_creal_T *argInit_1xd1638400_creal_T(void)
{
  emxArray_creal_T *result;
  creal_T *result_data;
  int idx0;
  int idx1;
  /* Set the size of the array.
Change this size to the value that the application requires. */
  result = h_emxCreate_creal_T(1, 2);
  result_data = result->data;
  /* Loop over the array to initialize each element. */
  for (idx0 = 0; idx0 < 1; idx0++) {
    for (idx1 = 0; idx1 < result->size[1U]; idx1++) {
      /* Set the value of the array element.
Change this value to the value that the application requires. */
      result_data[idx1] = argInit_creal_T();
    }
  }
  return result;
}

/*
 * Arguments    : void
 * Return Type  : creal_T
 */
static creal_T argInit_creal_T(void)
{
  creal_T result;
  double re_tmp;
  /* Set the value of the complex variable.
Change this value to the value that the application requires. */
  re_tmp = argInit_real_T();
  result.re = re_tmp;
  result.im = re_tmp;
  return result;
}

/*
 * Arguments    : void
 * Return Type  : double
 */
static double argInit_real_T(void)
{
  return 0.0;
}

/*
 * Arguments    : int argc
 *                char **argv
 * Return Type  : int
 */
int main(int argc, char **argv)
{
  (void)argc;
  (void)argv;
  /* The initialize function is being called automatically from your entry-point
   * function. So, a call to initialize is not included here. */
  /* Invoke the entry-point functions.
You can call entry-point functions multiple times. */
  main_Decimate();
  /* Terminate the application.
You do not need to do this more than one time. */
  Decimate_terminate();
  return 0;
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void main_Decimate(void)
{
  emxArray_creal_T *x;
  emxArray_creal_T *y;
  /* Initialize function 'Decimate' input arguments. */
  /* Initialize function input argument 'x'. */
  x = argInit_1xd1638400_creal_T();
  /* Call the entry-point 'Decimate'. */
  h_emxInitArray_creal_T(&y, 2);
  Decimate(x, argInit_real_T(), y);
  h_emxDestroyArray_creal_T(x);
  h_emxDestroyArray_creal_T(y);
}

/*
 * File trailer for main.c
 *
 * [EOF]
 */
