White Paper 491 – FIR Filter design
======================================

This readme file contains these sections:

1. OVERVIEW
2. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS
3. DESIGN FILE HIERARCHY
4. INSTALLATION AND OPERATING INSTRUCTIONS
5. OTHER INFORMATION (OPTIONAL)
6. SUPPORT
7. LICENSE
8. CONTRIBUTING
9. Acknowledgements
10. REVISION HISTORY

## 1. OVERVIEW

The HLS based FIR Filter and associated scripts enables the generation 2 variants of the FIR Filter HLS project. 
One with 32-bit Single Precision Floating Point data-types and one with Fixed Point data-types. This allows the 
user to easily incorporate these 2 designs into the System Generator for DSP model included and perform a simple 
comparison of the 2 FIR designs. Evaluating resources, power and accuracy.
    
[Full Documentation]

## 2. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS

*	Vivado HLS release 2016.4
*	System Generator for DSP 2016.4
*	Matlab R2016a or later


## 3. DESIGN FILE HIERARCHY
```
	|   FIR.cpp
	|   CONTRIBUTING.md
	|   FIR.h
	|   FIR_fp.inc
	|   FIR_fp_6digits.inc
	|   FIR_test.cpp
	|   LICENSE.md
	|   README.md
	|   generate_hls_project.tcl
	|   result_golden.dat
	|	archive_me.bash
	|
	\---sysgen
			test_des_impulse_wp491.slx
	\---power_analysis
			UltraScale_Plus_XPE_2016_4_Fixed.xpe
			UltraScale_Plus_XPE_2016_4_Fixed_x10.xpe
			UltraScale_Plus_XPE_2016_4_FP32.xpe
			UltraScale_Plus_XPE_2016_4_FP32_x10.xpe
```

## 4. INSTALLATION AND OPERATING INSTRUCTIONS

The procedure to build the HLS project is as follows:
```
	vivado_hls generate_hls_project.tcl
```

## 5. OTHER INFORMATION

For more information check here: 
[Full Documentation][]
[Vivado HLS User Guide][]

## 6. SUPPORT

For questions and to get help on this project or your own projects, visit the [Vivado HLS Forums][]. 

## 7. License
The source for this project is licensed under the [3-Clause BSD License][]

## 8. Contributing code
Please refer to and read the [Contributing][] document for guidelines on how to contribute code to this open source project. The code in the `/master` branch is considered to be stable, and all pull-requests should be made against the `/develop` branch.

## 9. Acknowledgements
The Library is written by developers at [Xilinx](http://www.xilinx.com/) with other contributors listed below:

## 10. REVISION HISTORY

Date		|	Readme Version		|	Revision Description
------------|-----------------------|-------------------------
31MAR2017	|	1.0					|	Initial Xilinx release



[Contributing]: CONTRIBUTING.md 
[3-Clause BSD License]: LICENSE.md
[Full Documentation]: https://www.xilinx.com/support/documentation/white_papers/wp491-floating-to-fixed-point.pdf 
[Vivado HLS Forums]: https://forums.xilinx.com/t5/High-Level-Synthesis-HLS/bd-p/hls 
[Vivado HLS User Guide]: http://www.xilinx.com/support/documentation/sw_manuals/xilinx2015_4/ug902-vivado-high-level-synthesis.pdf