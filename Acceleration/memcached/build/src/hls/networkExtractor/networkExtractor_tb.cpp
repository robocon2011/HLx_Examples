//#include "networkExtractor.h"
#include "../../globals.h"

using namespace hls;

template <uint8_t D>
struct my_axi
{
	ap_uint<D>		data;
	ap_uint<D/8> 	keep;		// Shows which bytes contain valid data in this data word. Valid only when last is also asserted
	ap_uint<1>		last;		// Signals the last data word in a packet
};

void ethInConverter(stream<my_axi<64> > &inPacket, stream<ioWord> &extOutPacket);
void networkExtractor(stream<ioWord> &inPacket, stream<ioWord> &outPacket);
void binaryParser(stream<ioWord> &inData, stream<pipelineWord> &outData);
void ht_inputLogic(stream<pipelineWord> &inData, stream<ap_uint<64> > &in2key, stream<ap_uint<64> > &in2value, stream<ap_uint<128> > &in2md, stream<hashTableInternalWord> &in2hash, stream<ap_uint<8> > &in2hashKeyLength, stream<hashTableInternalWord> &in2cc, stream<internalMdWord> &in2ccMd);

int main()
{
	stream<my_axi<64> > inPacket;
	stream<ioWord> converterPacket;
	stream<ioWord> extOutPacket;
	stream<pipelineWord> bpOutPacket;

	stream<ap_uint<64> >	  hashKeyBuffer;
	stream<ap_uint<64> >	  hashValueBuffer;
	stream<ap_uint<128> >  hashMdBuffer;

	stream<hashTableInternalWord>	in2cc;
	stream<internalMdWord>			in2ccMd;
	stream<hashTableInternalWord>	in2hash;
	stream<ap_uint<8> >				in2hashKeyLength;

	my_axi<64> netWord;
	ioWord converterOut, extractorOut;
	pipelineWord bpOut;

	ap_uint<64>	  hashKeyBuffer_word;
	ap_uint<64>	  hashValueBuffer_word;
	ap_uint<128>  hashMdBuffer_word;

	hashTableInternalWord	in2cc_word;
	internalMdWord			in2ccMd_word;
	hashTableInternalWord	in2hash_word;
	ap_uint<8>				in2hashKeyLength_word;

    int count = 0;
    while (count < 500 )
    {
    	ethInConverter(inPacket, converterPacket);
    	networkExtractor(converterPacket, extOutPacket);
    	binaryParser(extOutPacket, bpOutPacket);

    	//hash table
    	ht_inputLogic(bpOutPacket, hashKeyBuffer, hashValueBuffer, hashMdBuffer, in2hash, in2hashKeyLength, in2cc, in2ccMd);

    	switch(count)
    	{
    		//Set packet in
			case 91:
				netWord.data = 0x6000d0270cbae290;
				netWord.keep = 0xff;
				netWord.last = 0;
				inPacket.write(netWord); break;
			case 92:
				netWord.data = 0x00450008699a45dd;
				netWord.keep = 0xff;
				netWord.last = 0;
				inPacket.write(netWord); break;
			case 93:
				netWord.data = 0x1140000000003e00;
				netWord.keep = 0xff;
				netWord.last = 0;
				inPacket.write(netWord); break;
			case 94:
				netWord.data = 0x01010a010101A376;
				netWord.keep = 0xff;
				netWord.last = 0;
				inPacket.write(netWord); break;
			case 95:
				netWord.data = 0x2A00cb2b83e80101;
				netWord.keep = 0xff;
				netWord.last = 0;
				inPacket.write(netWord); break;
			case 96:
				netWord.data = 0x0008010001800000;
				netWord.keep = 0xff;
				netWord.last = 0;
				inPacket.write(netWord); break;
			case 97:
				netWord.data = 0x23010A0000000000;
				netWord.keep = 0xff;
				netWord.last = 0;
				inPacket.write(netWord); break;
			case 98:
				netWord.data = 0x0000000000006745;
				netWord.keep = 0xff;
				netWord.last = 0;
				inPacket.write (netWord); break;
			case 99:
				netWord.data = 0xeeeeeeeeeeee0000;
				netWord.keep = 0xff;
				netWord.last = 0;
				inPacket.write(netWord); break;
			case 100:
				netWord.data = 0xf4c3dc127611eeee;
				netWord.keep = 0x0f;
				netWord.last = 1;
				inPacket.write(netWord); break;

    		//GET packet in
    		case 101:
    			netWord.data = 0x6000d0270cbae290;
    			netWord.keep = 0xff;
    			netWord.last = 0;
    			inPacket.write(netWord); break;
    		case 102:
    			netWord.data = 0x00450008699a45dd;
    			netWord.keep = 0xff;
    			netWord.last = 0;
    			inPacket.write(netWord); break;
    		case 103:
    			netWord.data = 0x11400000c42e3500;
    			netWord.keep = 0xff;
    			netWord.last = 0;
    			inPacket.write(netWord); break;
    		case 104:
    			netWord.data = 0x01010a010101E847;
    			netWord.keep = 0xff;
    			netWord.last = 0;
    			inPacket.write(netWord); break;
    		case 105:
    			netWord.data = 0x2100cb2b83e80101;
    			netWord.keep = 0xff;
    			netWord.last = 0;
    			inPacket.write(netWord); break;
    		case 106:
    			netWord.data = 0x0000010000800000;
    			netWord.keep = 0xff;
    			netWord.last = 0;
    			inPacket.write(netWord); break;
    		case 107:
    			netWord.data = 0x2301010000000000;
    			netWord.keep = 0xff;
    			netWord.last = 0;
    			inPacket.write(netWord); break;
    		case 108:
    			netWord.data = 0x0000000000006745;
    			netWord.keep = 0xff;
    			netWord.last = 0;
    			inPacket.write (netWord); break;
    		case 109:
    			netWord.data = 0xfde24d684a110000;
    			netWord.keep = 0x07;
    			netWord.last = 1;
    			inPacket.write(netWord); break;

    	}
    	/*if (!converterPacket.empty())
    	{
			converterPacket.read(converterOut);
			std::cout << std::dec;
			std::cout << count << std::endl;
			std::cout << std::hex;
			std::cout << std::setfill('0');
			std::cout << "converterOut.data = "  << std::setw(16) << converterOut.data << std::endl;
			std::cout << "converterOut.modulus = " << std::setw(1) << converterOut.modulus << std::endl;
			std::cout << "converterOut.metaData = " << std::setw(28) << converterOut.metadata << std::endl;
			std::cout << "converterOut.SOP = " << std::setw(1)  << converterOut.SOP << std::endl;
			std::cout << "converterOut.EOP = " << std::setw(1)  << converterOut.EOP << std::endl;
			std::cout << std::endl;
    	}*/

    	if (!extOutPacket.empty())
    	{
    		extOutPacket.read(extractorOut);
    		std::cout << std::dec;
    		std::cout << count << std::endl;
    		std::cout << std::hex;
    		std::cout << std::setfill('0');
    		std::cout << "extractorOut.data = "  << std::setw(16) << extractorOut.data << std::endl;
    		std::cout << "extractorOut.modulus = " << std::setw(1) << extractorOut.modulus << std::endl;
    		std::cout << "extractorOut.metaData = " << std::setw(28) << extractorOut.metadata << std::endl;
    		std::cout << "extractorOut.SOP = " << std::setw(1)  << extractorOut.SOP << std::endl;
    		std::cout << "extractorOut.EOP = " << std::setw(1)  << extractorOut.EOP << std::endl;
    		std::cout << std::endl;
    	}

    	if (!bpOutPacket.empty())
    	{
    		bpOutPacket.read(bpOut);
    		std::cout << std::dec;
    		std::cout << count << std::endl;
    		std::cout << std::hex;
    		std::cout << std::setfill('0');
    		std::cout << "bpOut.SOP = " << std::setw(1) << bpOut.SOP << std::endl;
    		std::cout << "bpOut.EOP = " << std::setw(1) << bpOut.EOP << std::endl;
    		std::cout << "bpOut.key = " << std::setw(16) <<  bpOut.key << std::endl;
    		std::cout << "bpOut.keyValid = " << std::setw(1) << bpOut.keyValid << std::endl;
    		std::cout << "bpOut.metadata = " << std::setw(31) << bpOut.metadata << std::endl;
    		std::cout << "bpOut.value = " << std::setw(16) << bpOut.value << std::endl;
    		std::cout << "bpOut.valueValid = " << std::setw(1) << bpOut.valueValid << std::endl;
    	}

    	if (!hashKeyBuffer.empty() || !hashValueBuffer.empty() || !hashMdBuffer.empty() || !in2cc.empty() || !in2ccMd.empty() || !in2hash.empty() || !in2hashKeyLength.empty())
    	{
    		if (!hashKeyBuffer.empty())
    		{
    			hashKeyBuffer.read(hashKeyBuffer_word);
    			std::cout << std::dec;
    			std::cout << count << std::endl;
    			std::cout << std::hex;
    			std::cout << std::setfill('0');
    			std::cout << "hashKeyBuffer_word = " << std::setw(16) << hashKeyBuffer_word << std::endl;
    		}
    		if (!hashValueBuffer.empty())
			{
				hashKeyBuffer.read(hashValueBuffer_word);
				std::cout << std::dec;
				std::cout << count << std::endl;
				std::cout << std::hex;
				std::cout << std::setfill('0');
				std::cout << "hashValueBuffer_word = " << std::setw(16) << hashValueBuffer_word << std::endl;
			}
    		if (!hashMdBuffer.empty())
			{
				hashMdBuffer.read(hashMdBuffer_word);
				std::cout << std::dec;
				std::cout << count << std::endl;
				std::cout << std::hex;
				std::cout << std::setfill('0');
				std::cout << "hashMdBuffer_word = " << std::setw(32) << hashMdBuffer_word << std::endl;
			}
    		if (!in2cc.empty())
    		{
    			in2cc.read(in2cc_word);
    			std::cout << std::dec;
    			std::cout << count << std::endl;
    			std::cout << std::hex;
    			std::cout << std::setfill('0');
    			std::cout << "in2cc_word.EOP = " << std::setw(1) << in2cc_word.EOP << std::endl;
    			std::cout << "in2cc_word.SOP = " << std::setw(1) << in2cc_word.SOP << std::endl;
    			std::cout << "in2cc_word.data = " << std::setw(32) << in2cc_word.data << std::endl;
    		}

    		if (!in2ccMd.empty())
    		{
    			in2ccMd.read(in2ccMd_word);
    			std::cout << std::dec;
    			std::cout << count << std::endl;
    			std::cout << std::hex;
    			std::cout << std::setfill('0');
    			std::cout << "in2ccMd_word.keyLength = " << std::setw(2) << in2ccMd_word.keyLength << std::endl;
    			std::cout << "in2ccMd_word.metadata = " << std::setw(8) << in2ccMd_word.metadata << std::endl;
    			std::cout << "in2ccMd_word.operation = " << std::setw(2) << in2ccMd_word.operation << std::endl;
    			std::cout << "in2ccMd_word.valueLength = " << std::setw(4) << in2ccMd_word.valueLength << std::endl;
    		}
    		if (!in2hash.empty())
    		{
    			in2hash.read(in2hash_word);
    			std::cout << std::dec;
    			std::cout << count << std::endl;
    			std::cout << std::hex;
    			std::cout << std::setfill('0');
    			std::cout << "in2hash_word.EOP = " << std::setw(1) << in2hash_word.EOP << std::endl;
    			std::cout << "in2hash_word.SOP = " << std::setw(1) << in2hash_word.SOP << std::endl;
    			std::cout << "in2hash_word.data = " << std::setw(32) << in2hash_word.data << std::endl;
    		}
    		if (in2hashKeyLength.empty())
    		{
    			in2hashKeyLength.read(in2hashKeyLength_word);
    			std::cout << std::dec;
    			std::cout << count << std::endl;
    			std::cout << std::hex;
    			std::cout << std::setfill('0');
    			std::cout << "in2hashKeyLength_word = " << std::setw(2) << in2hashKeyLength_word << std::endl;
    		}
    	}
    	count++;
    }
    return 0;
}
