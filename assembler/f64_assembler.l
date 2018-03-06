%option c++
%option noyywrap

identifier	[A-Za-z][A-Za-z0-9_]*
number		-?[0-9]+
newline		\r?\n

%% 

{identifier}	{ 
					yylval.build<std::string>() = yytext;
					return IDENTIFIER; 
				}
":"				{ return SEP_COLON; }
";"				{ return SEP_SEMICOLON; }
{newline}		{ return SEP_NEWLINE; }
{number}		{ 
					yylval.build<int>() = atoi(yytext);
					return NUM_VAL; 
				}

"bgt"			{ return BR_GT; }
"blt"			{ return BR_LT; }
"bz"			{ return BR_Z; }
"ble"			{ return BR_LE; }
"bge"			{ return BR_GE; }
"br"			{ return BR_UNCOND; }

r[0-5]|pc|sp	{ 
					yylval.build<std::string>() = yytext;
					return REGISTER; 
				}

"ld"			{ return LD; }
"st"			{ return ST; }
"add"			{ return ADD; }
"and"			{ return AND; }
"or"			{ return OR; }
"not"			{ return NOT; }

%%