//////////////////////////////////////////////////////////////////////////
// Jared Hermans
//////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include "log2.h"
#include "rtwtypes.h"

#define MAX 200

#define M_PI 3.1415926535897932384

/*
int log2(int N)    // function to calculate the log2(.) of int numbers
{
  int k = N, i = 0;
  while(k) {
    k >>= 1;
    i++;
  }
  return i - 1;
}
*/

int check(int n)    //checking if the number of element is a power of 2
{
  return n > 0 && (n & (n - 1)) == 0;
}

int reverse(int N, int n)    //calculating revers number
{
  int j, p = 0;
  for(j = 1; j <= (int)log2(N); j++) {
    if(n & (1 << ((int)log2(N) - j)))
      p |= 1 << (j - 1);
  }
  return p;
}

// Using the reverse order in the array
void ordina(creal_T* f1, int N) 
{
  creal_T f2[MAX];
  for(int i = 0; i < N; i++)
    f2[i] = f1[reverse(N, i)];
  for(int j = 0; j < N; j++)
    f1[j] = f2[j];
}

void transform(creal_T* f, int N) //
{
  ordina(f, N);    //first: reverse order
  creal_T *W;
  W = (creal_T *)malloc(N / 2 * sizeof(creal_T));
  W[1] = polar(1., -2. * M_PI / N);
  W[0] = 1;
  for(int i = 2; i < N / 2; i++)
    W[i] = pow(W[1], i);
  int n = 1;
  int a = N / 2;
  for(int j = 0; j < log2(N); j++) {
    for(int i = 0; i < N; i++) {
      if(!(i & n)) {
        creal_T temp = f[i];
        creal_T Temp = W[(i * a) % (n * a)] * f[i + n];
        f[i] = temp + Temp;
        f[i + n] = temp - Temp;
      }
    }
    n *= 2;
    a = a / 2;
  }
  free(W);
}

void FFT(creal_T* f, int N, double d)
{
  transform(f, N);
  for(int i = 0; i < N; i++)
    f[i] *= d; //multiplying by step
}
