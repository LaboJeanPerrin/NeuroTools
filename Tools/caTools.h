/*===========================================================================*/
/* runfunc - running window functions                                        */
/* Copyright (C) 2005 Jarek Tuszynski                                        */
/* Distributed under GNU General Public License version 3                    */
/*===========================================================================*/

/*==================================================*/
/* Index:                                           */
/*  |------------------+------+------+----------|   */
/*  | function         | NaN  | Edge | Underflow|   */
/*  |------------------+------+------+----------|   */
/*  | sum_exact        | NA   | NA   | 1024     |   */
/*  | cumsum_exact     | NA   | NA   | 1024     |   */
/*  | runmean_exact    | yes  | yes  | 1024     |   */
/*  | runmean          | yes  | yes  |    2     |   */
/*  | runmean_lite     | no   | no   |    1     |   */
/*  | runmin           | yes  | yes  |   NA     |   */
/*  | runmax           | yes  | yes  |   NA     |   */
/*  | runquantile_lite | no   | no   |   NA     |   */
/*  | runquantile      | yes  | yes  |   NA     |   */
/*  | runmad_lite      | no   | no   |   NA     |   */
/*  | runmad           | yes  | yes  |   NA     |   */
/*  | runsd_lite       | no   | no   |    1     |   */
/*  | runsd            | yes  | yes  |    2     |   */
/*  |------------------+------+------+----------|   */
/*  NaN - means support for NaN and possibly Inf    */
/*  edge - means calculations are done all the way  */
/*         to the edges                             */
/*  underflow - means at maximum how many numbers   */
/*    are used to store results of addition in case */
/*    of underflow                                  */
/*==================================================*/

#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include <math.h>
#include <float.h>


/* #define DEBBUG */
#ifdef DEBBUG
  int R_finite(double x) { return ( (x)==(x) ); }
  #define Calloc(b, t)  (t*) calloc(b,sizeof(t))
  #define Free free
  #define PRINT(x) { if ((x)==(x)) printf("%04.1f ",x); else printf("NaN "); }
#else
  //#include <R.h>
  //#include <Rinternals.h>
#endif

#define notNaN(x)   ((x)==(x))
#define isNaN(x)  (!((x)==(x)))
#define MIN(y,x) ((x)<(y) && (x)==(x) ? (x) : (y))
#define MAX(y,x) ((x)>(y) && (x)==(x) ? (x) : (y))
#define SQR(x) ((x)*(x))

/*============================================================================*/
/* The following macros were inspired by msum from                            */
/* http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/393090             */
/* Quote from it:                                                             */
/* "Full precision summation using multiple doubles for intermediate values   */
/* Rounded x+y stored in hi with the round-off stored in lo.  Together        */
/* hi+lo are exactly equal to x+y.  The loop applies hi/lo summation          */
/* to each partial so that the list of partial sums remains exact.            */
/* Depends on IEEE-754 arithmetic guarantees.  See proof of correctness at:   */
/* www-2.cs.cmu.edu/afs/cs/project/quake/public/papers/robust-arithmetic.ps"  */
/*============================================================================*/

/* SumErr - macro calculating error of the summing operation */
#define SumErr(a,b,ab) ((((a)>(b)) == ((a)>-(b))) ?  (b) - ((ab)-(a)) : (a) - ((ab)-(b)) )
/* SUM_1 - macro for calculating Sum+=x; Num+=n; Which is NaN aware and have minimal (single number) overflow error correction */
#define SUM_1(x,n, Sum, Err, Num)   if (R_finite(x)){ y=Sum; Err+=x; Sum+=Err; Num+=n; Err=SumErr(y,Err,Sum);  } 
#define mpartial 1024	


void SUM_N(double x, int n, double *partial, int *npartial, int *Num);

/*========================================================================================*/
/* Each iteration of an insertion sort removes an element from the input data, inserting  */
/*  it at the correct position in the already sorted list, until no elements are left     */
/* in the input. For unsorted data is much less efficient than the more advanced          */
/* algorithms such as Quicksort, Heapsort, or Merge sort, but it is very efficient on     */
/* data sets which are already substantially sorted (almost O(n))                         */
/* Referances:                                                                            */
/*   R. Sedgewick: Algorithms. Addison-Wesley (1988) (page 99)                            */
/*   http://en.wikipedia.org/wiki/Insertion_sort                                          */
/*   http://www.cs.ubc.ca/spider/harrison/Java/sorting-demo.html                          */
/* Input:                                                                                 */
/*   V    - data array we operate on remains unchanged (we assume that no number in idx   */
/*          array is longer than V                                                        */
/*   idx  - index numbers of elements in V to be partially sorted                         */
/*   nIdx - length of idx array                                                           */
/* Output:                                                                                */
/*   idx  - index numbers of sorted elements in V w                                       */
/*========================================================================================*/

void insertion_sort(const double *V, int *idx, const int nIdx);

/*==================================================================*/
/* Array Sum without round-off errors.                              */
/* Input :                                                          */
/*   In   - array to run moving window over will remain umchanged   */
/*   Out  - empty double                                            */
/*   nIn  - size of In array                                        */
/* Output :                                                         */
/*   Out  - Array sum                                               */
/*==================================================================*/
void sum_exact(double *In, double *Out, const int *nIn);

/*==================================================================*/
/* Array cumulative sum without round-off errors.                   */
/* Input :                                                          */
/*   In   - array to run moving window over will remain umchanged   */
/*   Out  - empty space for array to store the results              */
/*   nIn  - size of In and Out arrays                               */
/* Output :                                                         */
/*   Out  - results of cumulative sum operation                     */
/*==================================================================*/
void cumsum_exact(double *In, double *Out, const int *nIn);

//void runsum_exact(double *In, double *Out, int *Size, const int *nIn, const int *nWin)
//{ /* medium size version with NaN's and round-off correction, but edge calculation*/
//  int i, j, k, n=*nIn, m=*nWin, npartial=0, count=0, *size;
//  double *in, *out, partial[mpartial], x;
//  k = m>>1;                              /* half of moving window */                           
//  for(i=0; i<=k; i++) {
//    Out [i]=Out [n-i-1]=0;
//    Size[i]=Size[n-i-1]=0;
//  }
//  if (m>=n) return;
//
//  /* step 1: sum of the first window *out = sum(x[0:(m-1)]) + err1 */
//  in=In; out=Out+k; size=Size+k;
//  for(i=0; i<m; i++, in++) {
//    x = *in;
//    if (R_finite(x)) {
//      add2partials(x, partial, npartial);
//      count++;
//    }
//  }
//  *size = count;
//  *out  = partial[0];
//  for(j=1; j<npartial; j++) *out += partial[j];
//
//  /* step 2: runsum of the rest of the vector. Inside loop is same as:   */
//  /* *out = *(out-1) + *in - *(in-m); but with round of error correction */
//  out++; size++;
//  for(i=m; i<n; i++, out++, in++, size++) { 
//    x = *in;    /* add the new value */
//    if (R_finite(x)) {
//      add2partials(x, partial, npartial);
//      count++;
//    }
//    x = -*(in-m); /* drop the value that goes out of the window */
//    if (R_finite(x)) {
//	    add2partials(x, partial, npartial);
//	    count--;
//    }
//    *size = count;
//    *out  = partial[0];
//    for(j=1; j<npartial; j++) *out += partial[j];
//  }
//}



/*==================================================================================*/
/* Mean function applied to (running) window. The fastest implementation with no    */
/* edge calculations, no NaN support, and no overflow correction                    */  
/* Input :                                                                          */
/*   In   - array to run moving window over will remain umchanged                   */
/*   Out  - empty space for array to store the results                              */
/*   nIn  - size of arrays In and Out                                               */
/*   nWin - size of the moving window                                               */
/* Output :                                                                         */
/*   Out  - results of runing moving window over array In and colecting window mean */
/*==================================================================================*/
void runmean_lite(double *In, double *Out, const int *nIn, const int *nWin);

/*==================================================================================*/
/* Mean function applied to (running) window. All additions performed using         */
/* addition algorithm which tracks and corrects addition round-off errors (see      */  
/*  http://www-2.cs.cmu.edu/afs/cs/project/quake/public/papers/robust-arithmetic.ps)*/
/* Input :                                                                          */
/*   In   - array to run moving window over will remain umchanged                   */
/*   Out  - empty space for array to store the results                              */
/*   nIn  - size of arrays In and Out                                               */
/*   nWin - size of the moving window                                               */
/* Output :                                                                         */
/*   Out  - results of runing moving window over array In and colecting window mean */
/*==================================================================================*/
void runmean(double *In, double *Out, const int *nIn, const int *nWin);


/*==================================================================================*/
/* Mean function applied to (running) window. All additions performed using         */
/* addition algorithm which tracks and corrects addition round-off errors (see      */  
/*  http://www-2.cs.cmu.edu/afs/cs/project/quake/public/papers/robust-arithmetic.ps)*/
/* Input :                                                                          */
/*   In   - array to run moving window over will remain umchanged                   */
/*   Out  - empty space for array to store the results                              */
/*   nIn  - size of arrays In and Out                                               */
/*   nWin - size of the moving window                                               */
/* Output :                                                                         */
/*   Out  - results of runing moving window over array In and colecting window mean */
/*==================================================================================*/
void runmean_exact(double *In, double *Out, const int *nIn, const int *nWin);


/*==================================================================*/
/* minimum function applied to moving (running) window              */ 
/* Input :                                                          */
/*   In   - array to run moving window over will remain umchanged   */
/*   Out  - empty space for array to store the results. Out is      */
/*          assumed to have reserved memory for nIn*nProbs elements */
/*   nIn  - size of arrays In and Out                               */
/*   nWin - size of the moving window (odd)                         */
/* Output :                                                         */
/*   Out  - results of runing moving window over array In and       */
/*          colecting window mean                                   */
/*==================================================================*/
void runmin(double *In, double *Out, const int *nIn, const int *nWin);

/*==================================================================*/
/* Maximum function applied to moving (running) window              */ 
/* Input :                                                          */
/*   In   - array to run moving window over will remain umchanged   */
/*   Out  - empty space for array to store the results. Out is      */
/*          assumed to have reserved memory for nIn*nProbs elements */
/*   nIn  - size of arrays In and Out                               */
/*   nWin - size of the moving window (odd)                         */
/* Output :                                                         */
/*   Out  - results of runing moving window over array In and       */
/*          colecting window mean                                   */
/*==================================================================*/
void runmax(double *In, double *Out, const int *nIn, const int *nWin);

/*==========================================================================*/
/* Calculate element in the sorted array of nWin elements that corresponds  */
/*          to a quantile of 'type' and 'prob'                              */ 
/* Input :                                                                  */
/*   prob - Quantile probability from 0 to 1                                */
/*   nWin - how many elements in dataset the quantile will be calculated on */
/*   type - integer between 1 and 9 indicating type of quantile             */
/*          See http://mathworld.wolfram.com/Quantile.html                  */
/* Output :                                                                 */
/*   return  - which element in the sorted array of nWin elements correspond*/
/*          to the prob.  If non-integer than split into intger (i) and     */
/*          real(r) parts, then quantile = v[i]*(1-r) + v[i+1]*r            */
/*==========================================================================*/
double QuantilePosition(double prob, int nWin, int type);


/*==================================================================*/
/* quantile function applied to (running) window                    */ 
/* Input :                                                          */
/*   In   - array to run moving window over will remain umchanged   */
/*   Out  - empty space for array to store the results. Out is      */
/*          assumed to have reserved memory for nIn*nProbs elements */
/*   nIn  - size of arrays In and Out                               */
/*   nWin - size of the moving window                               */
/*   Prob - Array of probabilities from 0 to 1                      */
/*   nProb - How many elements in Probs array?                      */
/*   type - integer between 1 and 9 indicating type of quantile     */
/*          See http://mathworld.wolfram.com/Quantile.html          */
/* Output :                                                         */
/*   Out  - results of runing moving window over array In and       */
/*          colecting window mean                                   */
/*==================================================================*/
void runquantile_lite(double *In, double *Out, const int *nIn, const int *nWin, const double *Prob, const int *nProb, const int *Type);

void runquantile(double *In, double *Out, const int *nIn, const int *nWin, const double *Prob, const int *nProb, const int *Type);


/*==================================================================================*/
/* MAD function applied to moving (running) window                                  */ 
/* No edge calculations and no NAN support                                          */ 
/* Input :                                                                          */
/*   In   - array to run moving window over will remain umchanged                   */
/*   Ctr  - array storing results of runmed or other running average function       */
/*   Out  - empty space for array to store the results                              */
/*   nIn  - size of arrays In and Out                                               */
/*   nWin - size of the moving window                                               */
/* Output :                                                                         */
/*   Out  - results of runing moving window over array In and colecting window mean */
/*==================================================================================*/

void runmad_lite(double *In, double *Ctr, double *Out, const int *nIn, const int *nWin);


/*==================================================================================*/
/* MAD function applied to moving (running) window                                  */ 
/* with edge calculations and NAN support                                           */ 
/* Input :                                                                          */
/*   In   - array to run moving window over will remain umchanged                   */
/*   Ctr  - array storing results of runmed or other running average function       */
/*   Out  - empty space for array to store the results                              */
/*   nIn  - size of arrays In and Out                                               */
/*   nWin - size of the moving window                                               */
/* Output :                                                                         */
/*   Out  - results of runing moving window over array In and colecting window mean */
/*==================================================================================*/
void runmad(double *In, double *Ctr, double *Out, const int *nIn, const int *nWin);

/*==================================================================================*/
/* Standard Deviation function applied to moving (running) window                   */ 
/* No edge calculations and no NAN support                                          */ 
/* Input :                                                                          */
/*   In   - array to run moving window over will remain umchanged                   */
/*   Ctr  - array storing results of runmed or other running average function       */
/*   Out  - empty space for array to store the results                              */
/*   nIn  - size of arrays In and Out                                               */
/*   nWin - size of the moving window                                               */
/* Output :                                                                         */
/*   Out  - results of runing moving window over array In and colecting window mean */
/*==================================================================================*/
void runsd_lite(double *In, double *Ctr, double *Out, const int *nIn, const int *nWin);
/*==================================================================================*/
/* Standard Deviation function applied to moving (running) window                   */ 
/* With edge calculations and NAN support                                           */ 
/* Input :                                                                          */
/*   In   - array to run moving window over will remain umchanged                   */
/*   Ctr  - array storing results of runmed or other running average function       */
/*   Out  - empty space for array to store the results                              */
/*   nIn  - size of arrays In and Out                                               */
/*   nWin - size of the moving window                                               */
/* Output :                                                                         */
/*   Out  - results of runing moving window over array In and colecting window mean */
/*==================================================================================*/
void runsd(double *In, double *Ctr, double *Out, const int *nIn, const int *nWin);

#undef MIN
#undef MAX
#undef SQR
#undef SUM_1
#undef SumErr
#undef mpartial

#ifdef DEBBUG


#endif
