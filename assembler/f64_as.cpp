#include <fstream>
#include <iostream>
#include "f64_scanner.hpp"
#include "f64_parser.hxx"

int main(int argc, char **argv)
{
	// TBD
	std::fstream input(argv[1], std::ios_base::in);
	std::vector<std::unique_ptr<f64_assembler::ParsedInstruction> > instructionList;
	yy::f64_scanner scanner(&input);
	yy::f64_parser parser(&scanner, &instructionList);
	
	try
	{
		parser.parse();
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