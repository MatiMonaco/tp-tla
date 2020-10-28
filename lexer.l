%{
#include "y.tab.h"
#include "parser.h"
#include <math.h>


%}

%%
([0-9]+|([0-9]*\.[0-9]+)([eE][+-]?[0-9]+)?) {
    yylval.dval = atof(yytext);
    return NUMBER;
}

[A-Za-z][A-Za-z0-9]*    { /* return symbol pointer */
    yylval.symp = symlook(yytext);
    return NAME;
}
[ \t] ; /* ignore whitespace */
; return SEMICOLON;
"$" return 0; /* EOF when running in command line */
\n  |
.   return yytext[0];
%%


