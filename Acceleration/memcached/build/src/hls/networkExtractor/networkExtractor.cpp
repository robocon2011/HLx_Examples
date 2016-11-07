#include "networkExtractor.h"

void networkExtractor(stream<ioWord> &inPacket, stream<ioWord> &outPacket)
{
	#pragma HLS INTERFACE ap_ctrl_none port=return // The block-level interface protocol is removed

	#pragma HLS DATA_PACK variable=inPacket
	#pragma HLS DATA_PACK variable=outPacket

	#pragma HLS RESOURCE variable=inPacket core=AXI4Stream
	#pragma HLS RESOURCE variable=outPacket core=AXI4Stream

	#pragma HLS pipeline II=1 enable_flush		// Data-flow interval=1 that is, 1 clock cycle between the start of consecutive loop iterations
	#pragma HLS INLINE off						// No function in-lining -> no function "replication" in hardware implementation

	static enum pState {IDLE, ETH, IP_1, IP_2, IP_REST, TCP, TCP_REST, UDP, STREAM_1, STREAM_2, FILTER, RESIDUE} packetState;
	static ioWord inputWord = {0, 0, 0, 0, 0};
	static ioWord firstOutputWord = {0, 0, 0, 0, 0};
	static ap_uint<64> outputTempWord;
	static ap_uint<2> tcpOrUdp = 0; 			// 0 is TCP, 1 is UDP, 2 is invalid
	static ap_uint<6> headerLength = 0;
	static ap_uint<3> wordOffset = 0;
	static ap_uint<6> tcpByteCounter = 0;

	switch(packetState)
	{
		case IDLE:																		// Wait for incoming packet
		{
			headerLength 	= 0;
			wordOffset		= 0;
			if (inPacket.empty() == false) {
				inPacket.read(inputWord);												// When packet arrives read the first word and put it on 'inputword'
				firstOutputWord.metadata.range(15, 0) = inputWord.data.range(63,48); 	// First data word contains ethernet frame header
				firstOutputWord.SOP 	= 1;
				firstOutputWord.EOP 	= 0;
				firstOutputWord.modulus = 0;
				packetState = ETH;
			}
			break;
		}
		case ETH:
		{
			if (inPacket.empty() == false) {
				inPacket.read(inputWord);
				firstOutputWord.metadata.range(47, 16) = inputWord.data.range(31, 0); 		// 2nd data word contains ethernet frame header
				if (inputWord.data.range(47, 32) == 0x0008) {
					headerLength = inputWord.data.range(51, 48);
					packetState = IP_1;
				}
				else
					packetState = FILTER;
			}
			break;
		}
		case IP_1:
		{
			if (inPacket.empty() == false) {
				inPacket.read(inputWord);
				firstOutputWord.metadata.range(111, 96) = inputWord.data.range(15, 0);		//Store IP packet length
				if (inputWord.data.range(63, 56) == 0x11) {		// UDP payload
					tcpOrUdp = 1;
					headerLength -= 2;
					packetState = IP_2;
				}
				//else if (inputWord.data.range(63, 56) == 0x06) // TCP payload
				//	tcpOrUdp = 0;
				else
					packetState = FILTER;
			}
			break;
		}
		case IP_2:
		{
			if (inPacket.empty() == false) {
				inPacket.read(inputWord);
				firstOutputWord.metadata.range(79, 48) = inputWord.data.range(47,16);	// Source IP Address
				headerLength -= 2;
				packetState = IP_REST;
			}
			break;
		}
		case IP_REST:
		{
			if (inPacket.empty() == false) {
				inPacket.read(inputWord);
				if (headerLength == 1) {
					firstOutputWord.metadata.range(95, 80) = inputWord.data.range(31, 16);		// Source Port
					wordOffset = 2;
				}
				else if (headerLength == 2)	{
					firstOutputWord.metadata.range(95, 80) = inputWord.data.range(63, 47);
					wordOffset = 6;
				}

				if (tcpOrUdp == 0) {
					tcpByteCounter = 8-wordOffset;
					packetState = TCP;
				}
				else if (tcpOrUdp == 1)
					packetState = UDP;
				else
					headerLength -= 2;
			}
			break;
		}
		case TCP:
		{
			if (inPacket.empty() == false) {
				tcpByteCounter += 8;
				inPacket.read(inputWord);		// Read the input
				if (tcpByteCounter > 11) {		// DF offset is 12B into the TCP header
					headerLength = inputWord.data.range(((9-wordOffset)*8)-1, ((8-wordOffset)*8)+4) * 4; // Total Length of the TCP Header in Bytes
					if (headerLength <= tcpByteCounter)	{
						firstOutputWord.data.range(((8-wordOffset)*8)-1, 0) = inputWord.data.range(63, (wordOffset*8));
						packetState = STREAM_1;
					}
					else
						packetState = TCP_REST;
				}
			}
			break;
		}
		case TCP_REST:
		{
			if (inPacket.empty() == false) {
				tcpByteCounter += 8;
				inPacket.read(inputWord);		// Read the input
				if (headerLength <= tcpByteCounter)
				{
					firstOutputWord.data.range((8-wordOffset)*8, 0) = inputWord.data.range(63, (wordOffset*8));
					packetState = STREAM_1;
				}
			}
			break;
		}
		case UDP:
		{
			if (inPacket.empty() == false) {
				inPacket.read(inputWord);		// Read the input
				firstOutputWord.data.range((8-wordOffset)*8, 0) = inputWord.data.range(63, (wordOffset*8));
				packetState = STREAM_1;
			}
			break;
		}
		case STREAM_1:
		{
			if (inPacket.empty() == false) {
				inPacket.read(inputWord);
				firstOutputWord.data.range(63, (8-wordOffset)*8) = inputWord.data.range((wordOffset*8)-1, 0);		// Fill the rest of the data word
				if (inputWord.EOP == 1) {
					//firstOutputWord.EOP = 1;
					if (inputWord.modulus > 0 && inputWord.modulus < 3) {
						if (inputWord.modulus == 1)
							firstOutputWord.modulus = 7;
						else if (inputWord.modulus == 2)
							firstOutputWord.modulus = 0;
						firstOutputWord.EOP = 1;
						outPacket.write(firstOutputWord);
						packetState = IDLE;
					}
					else {
						outPacket.write(firstOutputWord);
						firstOutputWord.metadata 	= 0;
						firstOutputWord.SOP 		= 0;
						firstOutputWord.data 		= 0;
						firstOutputWord.EOP 		= 0;
						firstOutputWord.modulus = wordOffset;
						firstOutputWord.data.range((8-wordOffset)*8, 0) = inputWord.data.range(63, (wordOffset*8));			// Store the first part in the output word
						packetState = RESIDUE;
					}
				}
				else {
					outPacket.write(firstOutputWord);
					firstOutputWord.data.range((8-wordOffset)*8, 0) = inputWord.data.range(63, (wordOffset*8));
					firstOutputWord.SOP = 0;
					firstOutputWord.EOP = 0;
				}
			}
			break;
		}
		case RESIDUE:
		{
			firstOutputWord.EOP = 1;
			outPacket.write(firstOutputWord);
			packetState = IDLE;
			break;
		}
		case FILTER:
		{
			if (inPacket.empty() == false) {
				inPacket.read(inputWord);	// Read the input
				if (inputWord.EOP == 1)		// Check if this is the last data word
					packetState = IDLE;		// if yes, go to the idle state and wait for the next packet
			}
			break;
		}
	}
}
