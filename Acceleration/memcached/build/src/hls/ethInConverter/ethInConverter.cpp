#include "testbench.h"

void ethInConverter(stream<my_axi<64> > &inPacket, stream<ioWord> &outPacket)
{
	#pragma HLS INTERFACE ap_ctrl_none port=return

	//#pragma HLS DATA_PACK variable=inPacket
	#pragma HLS DATA_PACK variable=outPacket

	#pragma HLS RESOURCE variable=inPacket core=AXI4Stream metadata="-bus_bundle AXI4Stream_I"	// This bundles the input variable together in an AXI4 Stream
	#pragma HLS RESOURCE variable=outPacket core=AXI4Stream

	#pragma HLS pipeline II=1 enable_flush
	#pragma HLS INLINE off

	static enum pState {IDLE, STREAM} packetState;
	my_axi<64> 			inputWord 		= {0, 0, 0};
	ioWord				outputWord 		= {0, 0, 0, 0, 0};

	switch(packetState)
	{
		case IDLE:							// Wait for incoming packet
		{
			if (!inPacket.empty() && !outPacket.full()) {
				inPacket.read(inputWord);		// When packet arrives read the first word
				outputWord.SOP = 1;
				if (inputWord.last != 1)	// Check if this is NOT the last word of the packet
					packetState = STREAM;	// in that case go to the stream state and continue to output the packet data words
				else {
					outputWord.EOP = 1;
					outputWord.modulus = inputWord.keep;
				}
				outputWord.data = inputWord.data;
				outPacket.write(outputWord);
			}
			break;
		}
		case STREAM:						// Output state for all data words except the 1st one
		{
			if (!inPacket.empty() && !outPacket.full()) {
				inPacket.read(inputWord);		// Read the input
				if (inputWord.last == 1) {		// Check if this is the last data word
					outputWord.EOP = 1;
					uint8_t counter = 0;
					for (uint8_t i=0;i<8;++i) {
						if (inputWord.keep.bit(i) == 1)
							counter++;
					}
					outputWord.modulus = counter;
					packetState = IDLE;			// if yes, go to the idle state and wait for the next packet
				}
				outputWord.data = inputWord.data;
				outPacket.write(outputWord);		// Write it immediately into the output
			}
			break;
		}
	}
}
