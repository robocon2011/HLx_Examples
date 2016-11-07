#include "testbench.h"

void ethOutConverter(stream<ioWord> &inPacket, stream<my_axi<64> > &outPacket)
{
	#pragma HLS INTERFACE ap_ctrl_none port=return

	#pragma HLS DATA_PACK variable=inPacket
	//#pragma HLS DATA_PACK variable=outPacket
	//#pragma HLS RESOURCE variable=inPacket core=AXI4Stream metadata="-bus_bundle AXI4Stream_I" port_map={{inPacket_data TDATA} {inPacket_keep TKEEP} {inPacket_last TLAST}}
	//#pragma HLS RESOURCE variable=outPacket core=AXI4Stream metadata="-bus_bundle AXI4Stream_O" port_map={{outPacket_data TDATA} {outPacket_keep TKEEP} {outPacket_last TLAST}}

	//#pragma HLS RESOURCE variable=inPacket core=AXI4Stream metadata="-bus_bundle AXI4Stream_I"	// This bundles the input variable together in an AXI4 Stream
	#pragma HLS RESOURCE variable=outPacket core=AXI4Stream metadata="-bus_bundle AXI4Stream_O" // Same for the output variable
	#pragma HLS RESOURCE variable=inPacket core=AXI4Stream

	//#pragma HLS DATAFLOW interval=1
	#pragma HLS pipeline II=1 enable_flush
	#pragma HLS INLINE off

	static enum pState {IDLE, STREAM} packetState;
	//my_axi<128> inputWord = {0, 0, 0};
	my_axi<64> 	outputWord	= {0, 0 ,0};
	ioWord		inputWord 	= {0, 0, 0, 0};

	switch(packetState)
	{
		case IDLE:							// Wait for incoming packet
		{
			inPacket.read(inputWord);		// When packet arrives read the first word
			if (inputWord.EOP != 1)	// Check if this is NOT the last word of the packet
			{
				outputWord.keep = 0xFF;
				packetState = STREAM;	// in that case go to the stream state and continue to output the packet data words
			}
			else
			{
				outputWord.last = 1;
				switch(inputWord.modulus)
				{
					case 0:
					{
						outputWord.keep = 0xFF;
						break;
					}
					case 1:
					{
						outputWord.keep = 0x01;
						break;
					}
					case 2:
					{
						outputWord.keep = 0x03;
						break;
					}
					case 3:
					{
						outputWord.keep = 0x07;
						break;
					}
					case 4:
					{
						outputWord.keep = 0x0F;
						break;
					}
					case 5:
					{
						outputWord.keep = 0x1F;
						break;
					}
					case 6:
					{
						outputWord.keep = 0x3F;
						break;
					}
					case 7:
					{
						outputWord.keep = 0x7F;
						break;
					}
				}
			}
			outputWord.data = inputWord.data;
			outPacket.write(outputWord);
			break;
		}
		case STREAM:						// Output state for all data words except the 1st one
		{
			inPacket.read(inputWord);		// Read the input
			if (inputWord.EOP == 1)		// Check if this is tha last data word
			{
				outputWord.last = 1;
				switch(inputWord.modulus)
				{
				case 0:
				{
					outputWord.keep = 0xFF;
					break;
				}
				case 1:
				{
					outputWord.keep = 0x01;
					break;
				}
				case 2:
				{
					outputWord.keep = 0x03;
					break;
				}
				case 3:
				{
					outputWord.keep = 0x07;
					break;
				}
				case 4:
				{
					outputWord.keep = 0x0F;
					break;
				}
				case 5:
				{
					outputWord.keep = 0x1F;
					break;
				}
				case 6:
				{
					outputWord.keep = 0x3F;
					break;
				}
				case 7:
				{
					outputWord.keep = 0x7F;
					break;
				}
				}
				packetState = IDLE;			// if yes, go to the idle state and wait for the next packet
			}
			else
				outputWord.keep = 0xFF;
			outputWord.data = inputWord.data;
			outPacket.write(outputWord);		// Write it immediately into the output
			break;
		}
	}
}
