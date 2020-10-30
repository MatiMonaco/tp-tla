%{
#include "y.tab.h"
#include "parser.h"
#include <math.h>
#include <stdio.h>

%}
ws [ \t]+
nl (\n|\r\n|\r)
qstring \"[^\"\n]*[\"\n"]
%%
([0-9]+|([0-9]*\.[0-9]+)([eE][+-]?[0-9]+)?) {
    yylval.dval = atof(yytext);
    return NUMBER;
}

[A-Za-z][A-Za-z0-9]*    { /* return symbol pointer */
    if(!strcmp(yytext,"print")){
        return PRINT;
    }else if(!strcmp(yytext,"if")){
        return IF;
    }else if(!strcmp(yytext,"else")){
        return ELSE;
    }else if(!strcmp(yytext,"while")){
        return WHILE;
    }
    yylval.symp = symlook(yytext);
  
    return NAME;
}
{ws} ; /* ignore whitespace */

"$" return 0; /* EOF when running in command line */
{nl} return NEW_LINE;
{qstring} {yylval.string = strdup(yytext+1);
         
            if(yylval.string[yyleng-2] != '"'){
                fprintf(stderr,"Unterminated character string\n");
            }else{
                yylval.string[yyleng-2] = 0;
                return QSTRING;
            }
}

"=="    |
"!="    |
"<"     |
">"     |
"<="    |
">="    { return COMPARISON;}   

"&&" {return AND;}
"||"  {return OR;}

[-+*/:(){},.;] {return yytext[0];}

.   return yytext[0];
%%


