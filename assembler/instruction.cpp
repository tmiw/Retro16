#include <cassert>
#include <string>
#include "instruction.hpp"

namespace f64_assembler
{
	
ParsedInstruction* InstructionFactory::MakeJumpDestination(std::string label)
{
	// TBD
	assert(0);
	return NULL;
}

ParsedInstruction* InstructionFactory::MakeBranchInstruction(BranchType type, std::string label)
{
	// TBD
	assert(0);
	return NULL;
}

ParsedInstruction* InstructionFactory::MakeLoadStoreInstruction(LoadStoreType type, short register1, short register2, short offset)
{
	unsigned short prefix = (type == LOAD) ? 0b010 : 0b011;
	return new ThreeArgInstruction<3, 3, 3>(
		prefix,
		register1,
		register2,
		offset
	);
}

ParsedInstruction* InstructionFactory::MakeAluInstructionWithConstOperand(AluInstruction type, short register1, short register2, short offset)
{
	// TBD
	assert(0);
	return NULL;
}

ParsedInstruction* InstructionFactory::MakeAluInstructionWithRegOperand(AluInstruction type, short register1, short register2, short register3)
{
	// TBD
	assert(0);
	return NULL;
}

ParsedInstruction* InstructionFactory::MakeShiftInstruction(ShiftInstruction type, short register1, short register2, short offset)
{
	// TBD
	assert(0);
	return NULL;
}

short InstructionFactory::RegisterNumberFromName(std::string& register_name)
{
	// TBD
	assert(0);
	return 0;
}
	
};