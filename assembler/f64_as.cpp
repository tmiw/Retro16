#include <fstream>
#include "f64_scanner.hpp"
#include "f64_parser.hxx"

int main(int argc, char **argv)
{
	// TBD
	std::fstream input(argv[0], std::ios_base::in);
	yy::f64_scanner scanner(&input);
	yy::f64_parser parser(&scanner);
	parser.parse();
	
	return 0;
}