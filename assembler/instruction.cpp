#include <cassert>
#include <string>
#include "instruction.hpp"

namespace f64_assembler
{

BranchInstruction::BranchInstruction(unsigned short prefix, std::string& branchDestination)
	: OneArgInstruction(prefix, 0),
	  branchName(branchDestination)
{
	// We don't do anything here for the time being. The resolution of the branch
	// occurs during the second pass.
}

JumpDestination::JumpDestination(std::string& label)
	: ParsedInstruction(0),
	  destLabel(label)
{
	// This is a placeholder so the address pass can determine where jump labels are located in RAM.
}

ParsedInstruction* InstructionFactory::MakeJumpDestination(std::string label)
{
	return new JumpDestination(label);
}

ParsedInstruction* InstructionFactory::MakeBranchInstruction(BranchType type, std::string label)
{
	unsigned short prefix = 0b1000;
	switch(type)
	{
		case UNCONDITIONAL:
			prefix |= 0b000;
			break;
		case GREATER_THAN:
			prefix |= 0b010;
			break;
		case GREATER_EQUAL:
			prefix |= 0b110;
			break;
		case LESS_THAN:
			prefix |= 0b001;
			break;
		case LESS_EQUAL:
			prefix |= 0b101;
			break;
		case ZERO:
			prefix |= 0b100;
			break;
		default:
			// Should not reach here.
			assert(0);
			break;
	}
	return new BranchInstruction(prefix, label);
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
	unsigned short prefix = 0b00100;
	switch (type)
	{
		case ADD:
			prefix |= 0b00;
			break;
		case AND:
			prefix |= 0b01;
			break;
		case OR:
			prefix |= 0b10;
			break;
		case NOT:
			prefix |= 0b11;
			break;
		default:
			// Should not be possible.
			assert(0);
			break;
	}
	
	return new ThreeArgInstruction<5, 3, 3>(
		prefix,
		register1,
		register2,
		offset
	);
}

ParsedInstruction* InstructionFactory::MakeAluInstructionWithRegOperand(AluInstruction type, short register1, short register2, short register3)
{
	unsigned short prefix = 0b0000100;
	switch (type)
	{
		case ADD:
			prefix |= 0b00;
			break;
		case AND:
			prefix |= 0b01;
			break;
		case OR:
			prefix |= 0b10;
			break;
		case NOT:
			prefix |= 0b11;
			break;
		default:
			// Should not be possible.
			assert(0);
			break;
	}

	return new ThreeArgInstruction<7, 3, 3>(
		prefix,
		register1,
		register2,
		register3
	);
}

ParsedInstruction* InstructionFactory::MakeShiftInstruction(ShiftInstruction type, short register1, short register2, short offset)
{
	if (type == ShiftInstruction::SHIFT_RIGHT)
	{
		// Negate the offset.
		offset = -offset;
	}
	
	unsigned short prefix = 0b00000;
	return new ThreeArgInstruction<5, 3, 3>(
		prefix,
		register1,
		register2,
		offset
	);
}

short InstructionFactory::RegisterNumberFromName(std::string& register_name)
{
	if (register_name[0] == 'r')
	{
		// R0-5; return the number after the prefix.
		return register_name[1] - '0';
	}
	else if (register_name == "pc")
	{
		// PC
		return 6;
	}
	else if (register_name == "sp")
	{
		// SP
		return 7;
	}
	else
	{
		// Should not reach here.
		assert(0);
		return 0;
	}
}
	
};