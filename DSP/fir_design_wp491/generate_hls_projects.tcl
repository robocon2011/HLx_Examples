#/************************************************
#Copyright (c) 2017, Xilinx, Inc.
#All rights reserved.
#Redistribution and use in source and binary forms, with or without modification, 
#are permitted provided that the following conditions are met:
#1. Redistributions of source code must retain the above copyright notice, 
#this list of conditions and the following disclaimer.
#2. Redistributions in binary form must reproduce the above copyright notice, 
#this list of conditions and the following disclaimer in the documentation 
#and/or other materials provided with the distribution.
#3. Neither the name of the copyright holder nor the names of its contributors 
#may be used to endorse or promote products derived from this software 
#without specific prior written permission.
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
#THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
#IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
#INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
#PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
#HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
#OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
#EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#************************************************/

set version "[exec which vivado_hls | sed -e "s:.*\\(20....\\).*:\\1:g" ]"
set system [exec vivado_hls -s]

foreach implementation [list fx fp] {

    open_project -reset proj_period_2.5_${implementation}_FIR_$version
    
    open_solution solution1 ; #or solution_$implementation


    # -unsafe_math_optimizations 
    #		The unsafe_math_optimizations option will ignore the signness of floating point zero and enable associative floating 
    #		point operations so that compiler can do aggressive optimizations on floating point operations. 
    #		The default is off.
    config_compile -unsafe_math_optimizations
    if { $system > "lnx" && $system < "win" } {
        puts "linux system"
        config_compile -name_max_length 250
    } else {
        puts "windows system"
    }

    set_top ${implementation}_FIR
    add_files     FIR.cpp
    add_files     FIR.h
    add_files -tb FIR_test.cpp
    add_files -tb result.golden.dat
    add_files -tb FIR_fp.inc
    add_files -tb FIR_fp_6digits.inc

    #set_part kintex7 ; puts "using a kintex7 part - change if necessary"
    set_part {xcvu9p-flgb2104-2-i-es2} ; puts "using a vu9p-2 part - change if necessary"

    create_clock -period 2.5 -name default
    csim_design -compiler gcc
    csynth_design
#    cosim_design
#    export_design -evaluate verilog
}
