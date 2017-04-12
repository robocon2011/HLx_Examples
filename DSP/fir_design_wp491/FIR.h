/************************************************
Copyright (c) 2017, Xilinx, Inc.
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software 
without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
************************************************/

#ifndef _FIR_H_
#define _FIR_H_

#include <fstream>
#include <iostream>
#include <iomanip>
//#include <cstdlib>
//using namespace std;

#define PASTE(x,y) x##y
#define ARRNAME(N) PASTE(check_line_,N)
#define COMPILE_ASSERT(x) extern char ARRNAME(__LINE__)[x ? 1 : -1];

#define N 85

// float
typedef float fp_coef_t;
typedef float fp_data_t;
typedef float fp_acc_t;

// fixed points
#include <ap_fixed.h> 
// relationship for (W)idth, (I)nteger, (F)raction bits
// ap_fixed<W=I+F,I>
const int coef_F=17;
const int data_F=12;
const int acc_I=19;

COMPILE_ASSERT(1+coef_F<=18); // assert to match one input of DSP48E2 multiplier
typedef ap_fixed< 1+coef_F, 1> fx_coef_t;

COMPILE_ASSERT(15+data_F<=27); // assert to match the other input of DSP48E2 multiplier
typedef ap_fixed<15+data_F,15> fx_data_t;

COMPILE_ASSERT(coef_F+data_F+acc_I<=48); // assert to match the DSP48E2 accumulator 
typedef ap_fixed<acc_I+coef_F+data_F,acc_I> fx_acc_t;


// Class CFir definition
template<class coef_T, class data_T, class acc_T>
class CFir {
protected:

  static const coef_T c[];

  data_T shift_reg[N-1];
private:
public:
  acc_T operator()(data_T x);
};

// Load FIR coefficients
template<class coef_T, class data_T, class acc_T>
const coef_T CFir<coef_T, data_T, acc_T>::c[] = {
	#include "FIR_fp_6digits.inc" // those coefficients are more imprecise values as the coef has only 6 digits
//	#include "FIR_fp.inc"  // those coefficients are more precise as they are chosen exact binary representation.
};

// FIR main algorithm
// changed the return type from data_t to acc_t as that's the real return value. Caller can manipulate as needed
template<class coef_T, class data_T, class acc_T>
acc_T CFir<coef_T, data_T, acc_T>::operator()(data_T x) {
//caller uses #pragma HLS PIPELINE which makes this function pipelined as needed.
#pragma HLS ARRAY_PARTITION variable=c complete dim=1
#pragma HLS ARRAY_PARTITION variable=shift_reg complete dim=1
    int i;
    acc_T acc = 0;
    data_T m;

    loop: for (i = N-1; i >= 0; i--) {
        if (i == 0) {
          m = x;
          shift_reg[0] = x;
        } else {
          m = shift_reg[i-1];
          if (i != (N-1)) {
            shift_reg[i] = shift_reg[i - 1];
          }
        }
        acc += m * c[i];
    }
    return acc;
}

fp_acc_t fp_FIR(fp_data_t x);
fx_acc_t fx_FIR(fx_data_t x);

#endif

// XSIP watermark, do not delete 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689
