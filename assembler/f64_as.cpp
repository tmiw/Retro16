#include <fstream>
#include <iostream>
#include <arpa/inet.h>
#include "f64_scanner.hpp"
#include "f64_parser.hxx"

typedef std::vector<std::unique_ptr<f64_assembler::ParsedInstruction> > InstructionListType;

int main(int argc, char **argv)
{
	// TBD
	std::fstream input(argv[1], std::ios_base::in);
	InstructionListType instructionList;
	yy::f64_scanner scanner(&input);
	yy::f64_parser parser(&scanner, &instructionList);
	
	try
	{
		parser.parse();
		
		// This assembler operates in two passes:
		// a) Offset: determines the addresses of each instruction/label
		// b) Resolve/code generation: resolves branch destinations and outputs instructions.
		unsigned short currentOffset = 0x0000;
		f64_assembler::ParsedInstruction::OffsetTable offsetTable;
		for (auto&& i : instructionList)
		{
			// For the first pass, we set the instruction/label to what we think the offset should
			// be. Then we allow the instruction to push that to the jump table and/or manipulate as needed.
			i->setOffset(currentOffset);
			i->pushOffset(offsetTable);
			currentOffset = i->offset() + (i->instructionLength() / f64_assembler::ParsedInstruction::INSTRUCTION_BITS);
		}
		
		// In the current implementation of the loader, every file should be 96K in length + 
		// a few extra bytes to ensure that the FPGA recognizes the end of the file.
		// TODO: figure out why the FPGA needs more than 96K of data to exit out of the loader.
		unsigned char* output = new unsigned char[96*1024 + 16];
		
		for (auto&& i : instructionList)
		{
			// For the second pass, we resolve any jump destinations and then output the
			// instruction to the in-memory representation of the file. We also ensure
			// that the instruction is written MSB first.
			// NOTE: we assume that instructions are either 0 or 2 bytes. This may not be a good assumption
			// in the future.
			i->resolve(offsetTable);
			if (i->instructionLength() > 0)
			{
				unsigned short compiledInstruction = htons(i->instruction());
				output[i->offset() * 2] = *(unsigned char*)(&compiledInstruction);
				output[i->offset() * 2 + 1] = *((unsigned char*)(&compiledInstruction) + 1);
			}
		}
		
		std::ofstream outFile;
		std::string inFileName(argv[1]);
		std::string outFileName(inFileName.substr(0, inFileName.find_last_of(".")) + ".bin");
		outFile.open(outFileName.c_str(), std::ios_base::out);
		outFile.write((char*)output, 96*1024 + 16);
		outFile.close();
		
		delete[] output;
		
		return 0;
	}
	catch (yy::f64_parser::syntax_error& e)
	{
		// improve error messages by adding location information:
		int row = e.location.begin.line;
        int col = e.location.begin.column;
        std::cerr << argv[1] << ":" << row << "." << col << ": " << e.what() << std::endl;
		return -1;
	}
}
