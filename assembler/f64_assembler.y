%output  "f64_parser.cxx"
%defines "f64_parser.hxx"

%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.0.4"

%parse-param  {yy::f64_scanner* scanner} {std::vector<std::unique_ptr<f64_assembler::ParsedInstruction> >* output}

%code requires {
    #include <stdexcept>
    #include <string>
    #include <memory>

    #include "location.hh"
	#include "instruction.hpp"
	
    namespace yy {
        class f64_scanner;
    };
	
	namespace f64_assembler {
		class ParsedOutput;
	};
}

%code {
    #include <iostream>     // cerr, endl
    #include <utility>      // move
    #include <string>
    #include <sstream>

    #include "f64_scanner.hpp"
	
    using std::move;

    #undef yylex
    #define yylex scanner->lex
}

%defines
%define parser_class_name {f64_parser}
%define api.value.type variant
%define parse.assert
%define parse.error verbose

%locations

%token <std::string> IDENTIFIER
%token SEP_COLON
%token SEP_SEMICOLON
%token SEP_NEWLINE
%token SEP_COMMA
%token <int> NUM_VAL
%token <int> HEX_VAL
%token BR_GT		
%token BR_LT
%token BR_Z
%token BR_LE
%token BR_GE
%token BR_UNCOND
%token <std::string> REGISTER
%token LD
%token ST
%token AND
%token ADD
%token OR
%token NOT
%token SHIFT_LEFT
%token SHIFT_RIGHT
%token PSUEDO_RAW

%type <f64_assembler::ParsedInstruction*> jump_label
%type <f64_assembler::ParsedInstruction*> branch_inst
%type <f64_assembler::ParsedInstruction*> ld_st_inst
%type <f64_assembler::ParsedInstruction*> math_reg_const_inst
%type <f64_assembler::ParsedInstruction*> math_reg_reg_inst
%type <f64_assembler::ParsedInstruction*> math_shift_inst
%type <f64_assembler::ParsedInstruction*> psuedo_inst
%type <f64_assembler::ParsedInstruction*> statement
%type <f64_assembler::ParsedInstruction*> stmt_line
%type <f64_assembler::InstructionFactory::AluInstruction> alu_inst
%type <f64_assembler::InstructionFactory::ShiftInstruction> shift_direction
%type <f64_assembler::InstructionFactory::BranchType> branch_type
%type <f64_assembler::InstructionFactory::LoadStoreType> mem_direction

%%

program				:	
					| line program
					;
		
line				: jump_label				{ output->emplace_back($1); }
					| statement					{ output->emplace_back($1); }
					| line_ending
					;
		
jump_label			: IDENTIFIER SEP_COLON		{ $$ = f64_assembler::InstructionFactory::MakeJumpDestination($1, @$); }
					;
			
statement			: stmt_line line_ending		{ $$ = $1; }
					;
			
line_ending			: SEP_SEMICOLON
					| SEP_NEWLINE
					;
			
stmt_line			: branch_inst				{ $$ = $1; }
					| ld_st_inst				{ $$ = $1; }
					| math_reg_const_inst		{ $$ = $1; }
					| math_shift_inst			{ $$ = $1; }
					| math_reg_reg_inst			{ $$ = $1; }
					| psuedo_inst				{ $$ = $1; }
					;

psuedo_inst			: PSUEDO_RAW HEX_VAL		{ $$ = f64_assembler::InstructionFactory::MakeRawInstruction($2, @$); }
					;
					
branch_inst			: branch_type IDENTIFIER	{ $$ = f64_assembler::InstructionFactory::MakeBranchInstruction($1, $2, @$); }
					;

branch_type			: BR_UNCOND					{ $$ = f64_assembler::InstructionFactory::BranchType::UNCONDITIONAL; }
					| BR_GT						{ $$ = f64_assembler::InstructionFactory::BranchType::GREATER_THAN; }
					| BR_LT						{ $$ = f64_assembler::InstructionFactory::BranchType::LESS_THAN; }
					| BR_Z						{ $$ = f64_assembler::InstructionFactory::BranchType::ZERO; }
					| BR_LE						{ $$ = f64_assembler::InstructionFactory::BranchType::LESS_EQUAL; }
					| BR_GE						{ $$ = f64_assembler::InstructionFactory::BranchType::GREATER_EQUAL; }
					;

ld_st_inst			: mem_direction REGISTER SEP_COMMA REGISTER SEP_COMMA NUM_VAL
												{ $$ = f64_assembler::InstructionFactory::MakeLoadStoreInstruction(
												    $1,
													f64_assembler::InstructionFactory::RegisterNumberFromName($2),
													f64_assembler::InstructionFactory::RegisterNumberFromName($4),
													$6,
													@$); 
												}
					;

mem_direction		: LD						{ $$ = f64_assembler::InstructionFactory::LoadStoreType::LOAD; }
					| ST						{ $$ = f64_assembler::InstructionFactory::LoadStoreType::STORE; }
					;
				
math_reg_const_inst	: alu_inst REGISTER SEP_COMMA REGISTER SEP_COMMA NUM_VAL
												{ $$ = f64_assembler::InstructionFactory::MakeAluInstructionWithConstOperand(
													$1,
													f64_assembler::InstructionFactory::RegisterNumberFromName($2),
													f64_assembler::InstructionFactory::RegisterNumberFromName($4),
													$6,
													@$);
												}
					;

alu_inst			: ADD						{ $$ = f64_assembler::InstructionFactory::AluInstruction::ADD; }
					| AND						{ $$ = f64_assembler::InstructionFactory::AluInstruction::AND; }
					| OR						{ $$ = f64_assembler::InstructionFactory::AluInstruction::OR; }
					| NOT						{ $$ = f64_assembler::InstructionFactory::AluInstruction::NOT; }
					;

math_shift_inst		: shift_direction REGISTER SEP_COMMA REGISTER SEP_COMMA NUM_VAL
												{ $$ = f64_assembler::InstructionFactory::MakeShiftInstruction(
													$1,
													f64_assembler::InstructionFactory::RegisterNumberFromName($2),
													f64_assembler::InstructionFactory::RegisterNumberFromName($4),
													$6,
													@$);
												}
					;

shift_direction		: SHIFT_LEFT				{ $$ = f64_assembler::InstructionFactory::ShiftInstruction::SHIFT_LEFT; }
					| SHIFT_RIGHT				{ $$ = f64_assembler::InstructionFactory::ShiftInstruction::SHIFT_RIGHT; }
					;
					
math_reg_reg_inst	: alu_inst REGISTER SEP_COMMA REGISTER SEP_COMMA REGISTER
												{ $$ = f64_assembler::InstructionFactory::MakeAluInstructionWithConstOperand(
													$1,
													f64_assembler::InstructionFactory::RegisterNumberFromName($2),
													f64_assembler::InstructionFactory::RegisterNumberFromName($4),
													f64_assembler::InstructionFactory::RegisterNumberFromName($6),
													@$);
												}
					;
					
%%

void yy::f64_parser::error(const f64_parser::location_type& l, const std::string& m)
{
    throw yy::f64_parser::syntax_error(l, m);
}
