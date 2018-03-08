%option c++
%option noyywrap
%option 8bit warn nodefault
%option outfile="f64_scanner.cxx"
%option header-file="f64_scanner.hxx"

%{
    #include <stdexcept>
    #include <cstdlib>
    #include "f64_parser.hxx"
    #include "f64_scanner.hpp"
	
	// before executing an action, set the length of the location from
	// the length of the matched pattern:
	#define YY_USER_ACTION          yylloc->columns(yyleng);
	
	using token = yy::f64_parser::token;
%}

identifier	[A-Za-z][A-Za-z0-9_]*
pos_number	[0-9]+
number		-?[0-9]+
newline		\r?\n
comment		#.*

%% 

%{
    // before matching any pattern, update the the current location
    yylloc->step();
%}

{comment}		{ /* ignore comments */ }

"bgt"			{ return token::BR_GT; }
"blt"			{ return token::BR_LT; }
"bz"			{ return token::BR_Z; }
"ble"			{ return token::BR_LE; }
"bge"			{ return token::BR_GE; }
"br"			{ return token::BR_UNCOND; }

"ld"			{ return token::LD; }
"st"			{ return token::ST; }
"add"			{ return token::ADD; }
"and"			{ return token::AND; }
"or"			{ return token::OR; }
"not"			{ return token::NOT; }
"shl"			{ return token::SHIFT_LEFT; }
"shr"			{ return token::SHIFT_RIGHT; }

r[0-5]|pc|sp	{ 
					yylval->build<std::string>() = yytext;
					return token::REGISTER; 
				}
				
{identifier}	{ 
					yylval->build<std::string>() = yytext;
					return token::IDENTIFIER; 
				}
				
":"				{ return token::SEP_COLON; }
";"				{ return token::SEP_SEMICOLON; }
{newline}		{ 
					yylloc->lines(1);
					return token::SEP_NEWLINE; 
				}

{pos_number}	{
					yylval->build<unsigned int>() = atoi(yytext);
					return token::POS_NUM;
				}
				
{number}		{ 
					yylval->build<int>() = atoi(yytext);
					return token::NUM_VAL; 
				}

.               {
					// Default fall-through rule.
					return yytext[0];
				}
%%

yy::f64_scanner::f64_scanner(std::istream* in, std::ostream* out)
    : yyFlexLexer(in, out)
{
	// empty
}

// This must be defined manually to prevent linker errors:
int yyFlexLexer::yylex()
{
    throw std::logic_error(
        "The yylex() exists for technical reasons and must not be used.");
}