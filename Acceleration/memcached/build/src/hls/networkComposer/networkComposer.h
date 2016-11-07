#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <math.h>
#include <hls_stream.h>
#include <ap_axi_sdata.h>
#include "ap_int.h"
#include <stdint.h>
//#include "ap_cint.h"

using namespace hls;

struct ioWord {
	ap_uint<64>		data;
	ap_uint<3>		modulus;
	ap_uint<1>		EOP;
	ap_uint<1>		SOP;
	ap_uint<112>	metadata;
};

struct outWord {
	ap_uint<64>		data;
	ap_uint<3>		modulus;
	ap_uint<1>		EOP;
	ap_uint<1>		SOP;
};

void networkComposer(stream<ioWord> &inData, stream<outWord> &outData);
