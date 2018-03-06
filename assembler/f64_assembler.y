%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.0.4"
%defines
%define parser_class_name {f64_parser}

%define api.token.constructor
%define api.value.type variant
%define parse.assert

%%

program				:	
					| line program
					;
		
line				: jump_label
					| statement
					;
		
jump_label			: IDENTIFIER SEP_COLON
					;
			
statement			: stmt_line line_ending
					;
			
line_ending			: SEP_SEMICOLON
					| SEP_NEWLINE
					;
			
stmt_line			: branch_inst
					| ld_st_inst
					| math_reg_const_inst
					| math_shift_inst
					| math_reg_reg_inst
					;
			
branch_inst			: branch_type IDENTIFIER
					;

branch_type			: BR_UNCOND
					| BR_GT
					| BR_LT
					| BR_Z
					| BR_LE
					| BR_GE
					;

ld_st_inst			: mem_direction REGISTER REGISTER NUM_VAL
					;

mem_direction		: LD
					| ST
					;
				
math_reg_const_inst	: alu_inst REGISTER REGISTER NUM_VAL
					;

alu_inst			: ADD
					| AND
					| OR
					| NOT
					;

math_shift_inst		: SHIFT REGISTER REGISTER NUM_VAL
					;

math_reg_reg_inst	: alu_inst REGISTER REGISTER REGISTER
					;
					
%%