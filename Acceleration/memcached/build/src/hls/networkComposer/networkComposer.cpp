#include "networkComposer.h"

void checksumInjection(stream<outWord> &stackCreation2checksumInjection, stream<ap_uint<16> > &checksumCalculation2checksumInjection, stream<outWord> &outPacket) {
	#pragma HLS INLINE off
	#pragma HLS pipeline II=1 enable_flush

	static enum ciState {IDLE = 0, STREAM, INJECT, STREAMREST} injectionState;
	static ap_uint<2> injectionWordCounter = 0;
	
	switch(injectionState) {
		case IDLE:
			if (!stackCreation2checksumInjection.empty()) {	
				injectionWordCounter = 0;
				outPacket.write(stackCreation2checksumInjection.read());
				injectionState = STREAM;
			}
			break;
		case STREAM:
			if (!stackCreation2checksumInjection.empty()) {	
				if (injectionWordCounter == 1)
					injectionState = INJECT;
				else
					injectionWordCounter++;
				outPacket.write(stackCreation2checksumInjection.read());
			}
			break;
		case INJECT:
			if (!stackCreation2checksumInjection.empty() && !checksumCalculation2checksumInjection.empty()) {	
				outWord tempWord = stackCreation2checksumInjection.read();
				ap_uint<16> tempChecksum = checksumCalculation2checksumInjection.read();
				tempWord.data.range(15, 0) = (tempChecksum.range(7, 0), tempChecksum.range(15, 8));
				outPacket.write(tempWord);
				injectionState = STREAMREST;
			}
			break;
		case STREAMREST:
			if (!stackCreation2checksumInjection.empty()) {	
				outWord tempWord = stackCreation2checksumInjection.read();
				outPacket.write(tempWord);
				if (tempWord.EOP == 1)
					injectionState = IDLE;			
			}
			break;
	}

}

void ipChecksumCalculation(stream<ap_uint<64> >&	dataIn,
						   stream<ap_uint<16> >&	ipChecksumFifoOut)
{
#pragma HLS INLINE off
#pragma HLS pipeline II=1 enable_flush

	static ap_uint<20> 	ipChecksum = 0;
	ap_uint<64>			inputWord = 0;
	static enum ipcsState {IPCS_IDLE = 0, IPCS_1, IPCS_2} ipChecksumState;
			
	switch (ipChecksumState) {
	case IPCS_IDLE:
		if (!dataIn.empty()) {
			inputWord = dataIn.read();
			ipChecksum = (((inputWord.range(63, 48) + inputWord.range(47, 32)) + inputWord.range(31, 16)) + inputWord.range(15, 0));
			ipChecksumState = IPCS_1;
		}
		break;
	case IPCS_1:
		if (!dataIn.empty()) {
			inputWord = dataIn.read();
			ipChecksum = ((((ipChecksum + inputWord.range(63, 48)) + inputWord.range(47, 32)) + inputWord.range(31, 16)) + inputWord.range(15, 0));
			ipChecksumState = IPCS_2;
		}
		break;
	case IPCS_2:
		if (!dataIn.empty() && !ipChecksumFifoOut.full()) {
			inputWord = dataIn.read();
			ipChecksum = (ipChecksum + inputWord.range(63, 48)) + inputWord.range(47, 32);
			ipChecksum = ipChecksum.range(15, 0) + ipChecksum.range(19, 16);
			ipChecksum = ~ipChecksum;
			ipChecksumFifoOut.write(ipChecksum);
			ipChecksumState = IPCS_IDLE;
		}
		break;
	}
}

void stackCreation(stream<ioWord> &inPacket, stream<ap_uint<64> > &stackCreation2checksumCalculation, stream<outWord> &stackCreation2checksumInjection) {
	
	#pragma HLS pipeline II=1	enable_flush		// Data-flow interval=1 that is, 1 clock cycle between the start of consecutive loop iterations
	#pragma HLS INLINE off							// No function in-lining -> no function "replication" in hardware implementation

	static enum pState {IDLE = 0, ETH, IP_1, IP_2, IP_REST, UDP, STREAM_1, RESIDUE} packetState;
	outWord outputWord 						= {0, 0, 0, 0};
	static ioWord firstInputWord 			= {0, 0, 0, 0, 0};
	static ap_uint<64> ipHeaderWord	= 0;
	static ap_uint<2> tcpOrUdp 				= 0; // 0 is TCP, 1 is UDP, 2 is invalid
	static ap_uint<6> headerLength 			= 0;
	static ap_uint<3> wordOffset 			= 0;
	static ap_uint<6> tcpByteCounter 		= 0;
	static ap_uint<16> payloadLength		= 0;

	switch(packetState)	{
		case IDLE:							// Wait for incoming packet
		{
			headerLength 	= 0;
			wordOffset		= 0;
			if (!inPacket.empty() && !stackCreation2checksumInjection.full()) {
				inPacket.read(firstInputWord);		// When packet arrives read the first word and put it on 'inputword'
				if (firstInputWord.SOP == 1) {
					outputWord.data.range(47, 0) = firstInputWord.metadata.range(47,0); // First data word contains ethernet frame header
					//outputWord.data.range(63, 48) = 0xE290;
					outputWord.data.range(63, 48) = 0x0A00;
					outputWord.SOP = 1;
					outputWord.EOP = 0;
					packetState = ETH;
					stackCreation2checksumInjection.write(outputWord);
				}
			}
			break;
		}
		case ETH:
		{
			if (!stackCreation2checksumInjection.full()) {
				//outputWord.data.range(31, 0) = 0xD0270CBA;	// Remaining Source MAC
				outputWord.data.range(31, 0) = 0xE59D0235;	// Remaining Source MAC
				outputWord.data.range(47, 32) = 0x0008;		// Ethertype (IP)
				outputWord.data.range(55, 52) = 4;			// IP Version
				outputWord.data.range(51, 48) = 5;			// Header length in 32-bit words
				ipHeaderWord.range(63, 48) = 0x4500;
				stackCreation2checksumInjection.write(outputWord);
				packetState = IP_1;
			}
			break;
		}
		case IP_1:
		{
			if (!stackCreation2checksumInjection.full() && !stackCreation2checksumCalculation.full()) {
				//ap_uint<16> ipLength 				= firstInputWord.metadata.range(111, 96);
				payloadLength	= firstInputWord.metadata.range(111, 96);
				//ipLength += 28;
				payloadLength += 28;
				//outputWord.data.range(15, 8)		=  ipLength.range(7, 0);
				outputWord.data.range(15, 8)		=  payloadLength.range(7, 0);
				//outputWord.data.range(7, 0)			=  ipLength.range(15, 8);
				outputWord.data.range(7, 0)			=  payloadLength.range(15, 8);
				outputWord.data.range(63, 56) 		= 0x11;			// Set protocol to UDP
				outputWord.data.range(55, 48) 		= 0xFF;			// Set TTL to 1
				//ipHeaderWord.range(47, 32)	= ipLength;
				ipHeaderWord.range(47, 32)	= payloadLength;
				ipHeaderWord.range(31, 0) 	= 0x00000000;
				stackCreation2checksumCalculation.write(ipHeaderWord);
				ipHeaderWord.range(63, 32)	= 0xFF110000;	// Set the TTL to 255 and the protocol to UDP for the checksum calculation header
				stackCreation2checksumInjection.write(outputWord);
				packetState = IP_2;
			}
			break;
		}
		case IP_2:
		{
			if (!stackCreation2checksumInjection.full()&& !stackCreation2checksumCalculation.full()) {
				outputWord.data.range(47,16) 		= 0x01010101;								// Source IP Address
				ipHeaderWord.range(31, 0)			= 0x01010101;								// Source IP Address for the checksum calculation header
				stackCreation2checksumCalculation.write(ipHeaderWord);				
				outputWord.data.range(63, 48) 		= firstInputWord.metadata.range(63, 48);    // Destination IP part 1
				stackCreation2checksumInjection.write(outputWord);
				packetState = IP_REST;
			}
			break;
		}
		case IP_REST:
		{
			if (!stackCreation2checksumInjection.full()) {
				outputWord.data.range(15, 0)		= firstInputWord.metadata.range(79, 64);		// IP - Destination IP part 2
				outputWord.data.range(31, 16) 		= 0xCB2B;										// UDP - Source Port
				outputWord.data.range(47, 32) 		= firstInputWord.metadata.range(95, 80);		// UDP - Destination Port
				//ap_uint<16> udpLength 				= firstInputWord.metadata.range(111, 96);
				//udpLength += 8;
				payloadLength -= 20;
				outputWord.data.range(63, 56)		=  payloadLength.range(7, 0);
				//outputWord.data.range(63, 56)		=  udpLength.range(7, 0);
				outputWord.data.range(55, 48)		=  payloadLength.range(15, 8);						// UDP - UDP Length
				//outputWord.data.range(55, 48)		=  udpLength.range(15, 8);						// UDP - UDP Length
				stackCreation2checksumInjection.write(outputWord);
				ipHeaderWord = (firstInputWord.metadata.range(55, 48), firstInputWord.metadata.range(63, 56), firstInputWord.metadata.range(71, 64), firstInputWord.metadata.range(79, 72), 0x00000000);
				stackCreation2checksumCalculation.write(ipHeaderWord);	
				packetState = UDP;																	// Only UDP support for now
			}
			break;
		}
		case UDP:
		{
			if (!stackCreation2checksumInjection.full()) {
				outputWord.data.range(63, 16) = firstInputWord.data.range(47, 0);
				if (firstInputWord.EOP == 1) {
					outputWord.EOP = 1;
					packetState = IDLE;
				}
				else
					packetState = STREAM_1;
				stackCreation2checksumInjection.write(outputWord);
			}
			break;
		}
		case STREAM_1:
		{
			if (!inPacket.empty() && !stackCreation2checksumInjection.full()) {
				outputWord.SOP 			= 0;
				outputWord.data.range(15, 0) = firstInputWord.data.range(63, 48);
				inPacket.read(firstInputWord);
				outputWord.data.range(63, 16) = firstInputWord.data.range(47, 0);		// Fill the rest of the data word

				if (firstInputWord.EOP == 1) {
					if (firstInputWord.modulus > 0 && firstInputWord.modulus < 7) {
						outputWord.EOP = 1;
						outputWord.modulus = firstInputWord.modulus + 2;
						packetState = IDLE;
					}
					else if (firstInputWord.modulus == 0 || firstInputWord.modulus == 7)
						packetState = RESIDUE;
				}
				stackCreation2checksumInjection.write(outputWord); // Write it into the output
			}
			break;
		}
		case RESIDUE:
		{
			if (!stackCreation2checksumInjection.full()) {
				outputWord.data.range(15, 0) = firstInputWord.data.range(63, 48);
				outputWord.EOP = 1;
				outputWord.modulus = firstInputWord.modulus + 2;
				stackCreation2checksumInjection.write(outputWord); // Write it into the output
				packetState = IDLE;
			}
			break;
		}
	}
}

void networkComposer(stream<ioWord> &inPacket, stream<outWord> &outPacket) {
	#pragma HLS INTERFACE ap_ctrl_none port=return // The block-level interface protocol is removed

	#pragma HLS DATA_PACK variable=inPacket
	#pragma HLS DATA_PACK variable=outPacket

	#pragma HLS RESOURCE variable=inPacket core=AXI4Stream
	#pragma HLS RESOURCE variable=outPacket core=AXI4Stream
	
	#pragma HLS DATAFLOW interval=1
	
	static stream<ap_uint<64> > stackCreation2checksumCalculation("stackCreation2checksumCalculation");
	static stream<outWord> 		stackCreation2checksumInjection("stackCreation2checksumInjection");
	static stream<ap_uint<16> > checksumCalculation2checksumInjection("checksumCalculation2checksumInjection");
	
	#pragma HLS DATA_PACK variable=stackCreation2checksumInjection
	
	#pragma HLS STREAM variable=stackCreation2checksumCalculation 		depth=16
	#pragma HLS STREAM variable=stackCreation2checksumInjection			depth=16
	#pragma HLS STREAM variable=checksumCalculation2checksumInjection	depth=16
	
	stackCreation(inPacket, stackCreation2checksumCalculation, stackCreation2checksumInjection);				// This modules creates the whole stack and prepends it to the packet data. It also send the IP header to the checksum calculation module.
	ipChecksumCalculation(stackCreation2checksumCalculation, checksumCalculation2checksumInjection);			// Receives the aligned header and calculates the checksum.
	checksumInjection(stackCreation2checksumInjection, checksumCalculation2checksumInjection, outPacket);		// Injects the received checksum into the header stack created by the stackCreation module.
}
