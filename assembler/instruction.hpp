#ifndef PARSED_OUTPUT_HPP
#define PARSED_OUTPUT_HPP

#include <vector>

namespace f64_assembler
{
	class ParsedInstruction
	{
	public:
		enum { INSTRUCTION_BITS = 16 };
		
	protected:
		ParsedInstruction(unsigned short data)
			: instruction_bytes(data)
		{
			// empty
		}
		
		unsigned short instruction_bytes;
	};
	
	class JumpDestination : public ParsedInstruction
	{
	public:
		JumpDestination(std::string &label);
		
	private:
		std::string &destLabel;
	};
	
	// One argument instruction
	template<int prefix_len>
	class OneArgInstruction : public ParsedInstruction
	{
	public:
		OneArgInstruction(unsigned short prefix, unsigned short param1)
			: ParsedInstruction(
				(prefix << PREFIX_SHIFT) | 
				(param1 & PARAM1_MASK)
			  )
		{
			// empty
		}
		
	private:
		enum 
		{
			PREFIX_SHIFT = INSTRUCTION_BITS - prefix_len,
			PARAM1_MASK = ~(0xFFFF << PREFIX_SHIFT)
		};
	};
	
	class BranchInstruction : public OneArgInstruction<4>
	{
	public:
		BranchInstruction(unsigned short prefix, std::string& branchDestination);
		
	private:
		std::string &branchName;
	};
	
	// Three argument instruction
	template<int prefix_len, int param1_len, int param2_len>
	class ThreeArgInstruction : public ParsedInstruction
	{
	public:
		ThreeArgInstruction(unsigned short prefix, unsigned short param1, unsigned short param2, unsigned short param3)
			: ParsedInstruction(
				(prefix << PREFIX_SHIFT) | 
				((param1 << PARAM1_SHIFT) & PARAM1_MASK) | 
				((param2 << PARAM2_SHIFT) & PARAM2_MASK) |
				(param3 & PARAM3_MASK)
			  )
		{
			// empty
		}
		
	private:
		enum
		{
			PREFIX_SHIFT = INSTRUCTION_BITS - prefix_len,
			PARAM1_SHIFT = PREFIX_SHIFT - param1_len,
			PARAM1_MASK = ~(0xFFFF << PREFIX_SHIFT) & (0xFFFF << (PREFIX_SHIFT - param2_len)),
			PARAM2_SHIFT = PARAM1_SHIFT - param2_len,
			PARAM2_MASK = ~(0xFFFF << PARAM1_SHIFT) & (0xFFFF << (PARAM1_SHIFT - param2_len)),
			PARAM3_MASK = ~(0xFFFF << PARAM2_SHIFT)
		};
	};
	
	class InstructionFactory
	{
	public:
		enum BranchType
		{
			UNCONDITIONAL,
			GREATER_THAN,
			GREATER_EQUAL,
			LESS_THAN,
			LESS_EQUAL,
			ZERO
		};
		
		enum LoadStoreType
		{
			LOAD,
			STORE
		};
		
		enum AluInstruction
		{
			ADD,
			AND,
			OR,
			NOT
		};
		
		enum ShiftInstruction
		{
			SHIFT_LEFT,
			SHIFT_RIGHT
		};
		
		static ParsedInstruction* MakeJumpDestination(std::string label);
		static ParsedInstruction* MakeBranchInstruction(BranchType type, std::string label);
		static ParsedInstruction* MakeLoadStoreInstruction(LoadStoreType type, short register1, short register2, short offset);
		static ParsedInstruction* MakeAluInstructionWithConstOperand(AluInstruction type, short register1, short register2, short offset);
		static ParsedInstruction* MakeAluInstructionWithRegOperand(AluInstruction type, short register1, short register2, short register3);
		static ParsedInstruction* MakeShiftInstruction(ShiftInstruction type, short register1, short register2, short offset);
		
		static short RegisterNumberFromName(std::string& register_name);
	};
};

#endif // PARSED_OUTPUT_HPP