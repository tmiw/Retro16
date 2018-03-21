#include <cassert>
#include <string>
#include <sstream>
#include "instruction.hpp"

namespace f64_assembler
{

BranchInstruction::BranchInstruction(unsigned short prefix, std::string& branchDestination, yy::location& loc)
	: OneArgInstruction(prefix, 0, loc),
	  branchName(branchDestination)
{
	// We don't do anything here for the time being. The resolution of the branch
	// occurs during the second pass.
}

JumpDestination::JumpDestination(std::string& label, yy::location& loc)
	: ParsedInstruction(0, loc),
	  destLabel(label)
{
	// This is a placeholder so the address pass can determine where jump labels are located in RAM.
}

void JumpDestination::pushOffset(OffsetTable& offsetTable)
{
	// This version of pushOffset saves the current offset to the table for our jump label.
	// The BranchInstruction's version of resolve will later grab this value for output of the generated
	// code. If there's already a jump label defined, return an error to the user.
	if (offsetTable.find(destLabel) != offsetTable.end())
	{
		std::ostringstream ss;
		ss << "Label " << destLabel << " has already been defined.";
		throw SemanticException(fileLocation, ss.str());
	}
	else
	{
		if (destLabel == "start")
		{
			// start is special. In the current implementation of the CPU, we begin execution
			// at address 0x0100. To ensure that our generated code is positioned correctly,
			// we change our own offset to that value. If the current offset is greater than
			// 0x0100, error out as it'll be impossible to avoid overwriting previous code.
			if (offset() > 0x0100)
			{
				std::ostringstream ss;
				ss << "Some of the code at the start label will overwrite previous code. Please relocate previous code as needed to make room.";
				throw SemanticException(fileLocation, ss.str());
			}
			setOffset(0x0100);
		}
		
		offsetTable[destLabel] = offset();
	}
}

void BranchInstruction::resolve(OffsetTable& offsetTable)
{
	// Retrieve known address of jump destination. If it doesn't exist, we should return some 
	// sort of error to the user.
	if (offsetTable.find(branchName) != offsetTable.end())
	{
		short instructionOffset = offsetTable[branchName] - offset();
		if (DoesFinalArgumentOverflow(instructionOffset))
		{
			std::ostringstream ss;
			ss << "A jump to " << branchName << " would overflow the branch instruction. Rearrange code so that the branch is closer to this line.";
			throw SemanticException(fileLocation, ss.str());
		}
		instructionBytes |= (unsigned short)instructionOffset & 0x0FFF;
	}
	else
	{
		std::ostringstream ss;
		ss << "Could not find jump destination " << branchName;
		throw SemanticException(fileLocation, ss.str());
	}
}

ParsedInstruction* InstructionFactory::MakeJumpDestination(std::string label, yy::location& loc)
{
	return new JumpDestination(label, loc);
}

ParsedInstruction* InstructionFactory::MakeBranchInstruction(BranchType type, std::string label, yy::location& loc)
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
	return new BranchInstruction(prefix, label, loc);
}

ParsedInstruction* InstructionFactory::MakeLoadStoreInstruction(LoadStoreType type, short register1, short register2, short offset, yy::location& loc)
{
	unsigned short prefix = (type == LOAD) ? 0b010 : 0b011;
	
	if (ThreeArgInstruction<3, 3, 3>::DoesFinalArgumentOverflow(offset))
	{
		std::ostringstream ss;
		ss << "Constant operand " << offset << " overflows instruction.";
		throw SemanticException(loc, ss.str());
	}
	
	return new ThreeArgInstruction<3, 3, 3>(
		prefix,
		register1,
		register2,
		offset,
		loc
	);
}

ParsedInstruction* InstructionFactory::MakeAluInstructionWithConstOperand(AluInstruction type, short register1, short register2, short offset, yy::location& loc)
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
	
	if (ThreeArgInstruction<5, 3, 3>::DoesFinalArgumentOverflow(offset))
	{
		std::ostringstream ss;
		ss << "Constant operand " << offset << " overflows instruction.";
		throw SemanticException(loc, ss.str());
	}
	
	return new ThreeArgInstruction<5, 3, 3>(
		prefix,
		register1,
		register2,
		offset,
		loc
	);
}

ParsedInstruction* InstructionFactory::MakeAluInstructionWithRegOperand(AluInstruction type, short register1, short register2, short register3, yy::location& loc)
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
		register3,
		loc
	);
}

ParsedInstruction* InstructionFactory::MakeShiftInstruction(ShiftInstruction type, short register1, short register2, short offset, yy::location& loc)
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
		offset,
		loc
	);
}

ParsedInstruction* InstructionFactory::MakeRawInstruction(unsigned short instruction, yy::location& loc)
{
	return new RawInstruction(instruction, loc);
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
