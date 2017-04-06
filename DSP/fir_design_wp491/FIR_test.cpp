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

#include "FIR.h"

int main() {
    std::ifstream gold_ifs;
    int outside_range=0;

    gold_ifs.open("result.golden.dat");
    bool eof=false,use_golden=true;
    double input;
    const double errorpc=1;
    const int total_test_values=10000;

    // Apply stimuli, call the top-level function and save the results
    for (int i = 0; i < total_test_values; i++) {
        int gold_intref;
        if(!eof) {
            int index_unused;
            gold_ifs >> index_unused >> gold_intref;
            eof = gold_ifs.eof();
        }
        if (use_golden) {
            input=i;
        } else {
            input = 100. * (1.+sin(i/10.)) - 50. * cos(i/15.);
        }
        //precision of input set to 5 digits
        input=double(int(input*1024*16))/1024/16;
        
        /** DUTs: one is reference one is DUT **/
        fp_acc_t fp_output = fp_FIR(input);
        fx_acc_t fx_output = fx_FIR(input);
        
        if (use_golden) {
            double gold_ref = (double)gold_intref / (1<<15);
            float fp_error_percent = i>0 ? (fp_output-gold_ref)/gold_ref*100 : 0;
            float fx_error_percent = i>0 ? (fx_output.to_double()-gold_ref)/gold_ref*100 : 0;

            if(fx_error_percent>errorpc || fx_error_percent<-errorpc || fp_error_percent>errorpc || fp_error_percent<-errorpc) {
            std::cout << " idx:" << std::setw( 5) << i;
            std::cout << " input"<< std::setw(10) << input;
            std::cout << " ref:" << std::setw(10) << gold_ref;
            std::cout << " fp:"  << std::setw(10) << fp_output;
            std::cout << " e%:"  << std::setw( 3) << fp_error_percent;
            std::cout << " fx:"  << std::setw(10) << fx_output;
            std::cout << " e%:"  << std::setw( 3) << fx_error_percent;
                std::cout << "  <--- outside "<<errorpc<<"%";
                std::cout << std::endl;
                outside_range++;
            }
        } else {
            float fp_fx_error_percent = i>0 ? (fx_output.to_double()-fp_output)/fp_output*100 : 0;
            if(fp_fx_error_percent>errorpc || fp_fx_error_percent<-errorpc) {
            std::cout << " idx:" << std::setw( 5) << i;
            std::cout << " input"<< std::setw(10) << input;
            std::cout << " fp:"  << std::setw(10) << fp_output;
            std::cout << " fx:"  << std::setw(10) << fx_output;
            std::cout << " e%:"  << std::setw( 3) << fp_fx_error_percent;
                std::cout << "  <--- outside "<<errorpc<<"%";
                std::cout << std::endl;
                outside_range++;
            }
        }

        use_golden = !eof;

    }
    gold_ifs.close();

    std::cout << "* "<<total_test_values<<" values tested, "<<outside_range<<" values outside an arbitrary range of "<<errorpc<<"%"<<std::endl;
    std::cout << "* overall error rate "<<(double)outside_range/total_test_values<<std::endl;
    return 0;
}

// XSIP watermark, do not delete 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689
