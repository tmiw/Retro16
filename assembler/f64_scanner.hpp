#ifndef F64_SCANNER_HPP
#define F64_SCANNER_HPP

# undef yyFlexLexer
# include <FlexLexer.h>
# include "f64_parser.hxx"

// Tell flex which function to define
# undef YY_DECL
# define YY_DECL        int yy::f64_scanner::lex(                   \
                            yy::f64_parser::semantic_type* yylval,  \
                            yy::f64_parser::location_type* yylloc)

namespace yy
{
    class f64_scanner : public yyFlexLexer
    {
    public:
        explicit f64_scanner(std::istream* in=0, std::ostream* out=0);

        int lex(f64_parser::semantic_type* yylval,
                f64_parser::location_type* yylloc);
    };
}

#endif // F64_SCANNER_HPP