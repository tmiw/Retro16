%output  "f64_parser.cxx"
%defines "f64_parser.hxx"

%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.0.4"

%parse-param  {yy::f64_scanner* scanner}

%code requires {
    #include <stdexcept>
    #include <string>

    #include "location.hh"

    namespace yy {
        class f64_scanner;
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
%token <int> NUM_VAL
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
%token <unsigned int> POS_NUM

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

math_shift_inst		: shift_direction REGISTER REGISTER POS_NUM
					;

shift_direction		: SHIFT_LEFT
					| SHIFT_RIGHT
					;
					
math_reg_reg_inst	: alu_inst REGISTER REGISTER REGISTER
					;
					
%%

void yy::f64_parser::error(const f64_parser::location_type& l, const std::string& m)
{
    throw yy::f64_parser::syntax_error(l, m);
}