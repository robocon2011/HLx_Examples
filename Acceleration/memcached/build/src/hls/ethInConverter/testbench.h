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

template <uint8_t D>
struct my_axi
{
	ap_uint<D>		data;
	ap_uint<D/8> 	keep;		// Shows which bytes contain valid data in this data word. Valid only when last is also asserted
	ap_uint<1>		last;		// Signals the last data word in a packet
};

struct ioWord
{
	ap_uint<64>		data;
	ap_uint<3>		modulus;
	ap_uint<1>		EOP;
	ap_uint<1>		SOP;
	ap_uint<108>	metadata;
};

void ethInConverter(stream<my_axi<64> > &inData, stream<ioWord> &outData, stream<ap_uint<32> > &counterOut);
