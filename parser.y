%{
#include "parser.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

int yylex();
void yyerror(const char *s);
%}

%union{
    double dval;
    struct symtab* symp;
}

%token <symp> NAME
%token <dval> NUMBER
%token SEMICOLON
%token NEW_LINE

//Set precedences
%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

%type <dval> expression

%%
statement_list: statement
        |       statement_list statement
        |       statement NEW_LINE
        |       statement_list statement NEW_LINE
        ;
statement: NAME '=' expression  SEMICOLON { $1->value = $3; }
        |  expression   SEMICOLON { printf("= %g\n", $1); }
        ;
expression: expression '+' expression { $$ = $1 + $3; }
        |   expression '-' expression { $$ = $1 - $3; }
        |   expression '*' expression { $$ = $1 * $3; }
        |   expression '/' expression 
                                    { if($3 == 0.0)
                                            yyerror("divide by zero");
                                        else
                                            $$ = $1 / $3;                                    
                                      }
        |   '-' expression %prec UMINUS     { $$ = -$2; }
        |   '(' expression ')'      { $$ = $2; }
        |   NUMBER
        |   NAME { $$ = $1->value; }
        ;
%%

struct symtab * symlook(char* s){
    struct symtab * sp;
    for(sp= symtab; sp <&symtab[MAX_SYMBOLS];sp++){
        /* is it alreaw here? */
        if (sp->name && !strcmp(sp->name, s) ){
            return sp;
        }
      
        /* is it free */
        if(!sp->name) {
            sp->name = strdup(s);
            
            return sp;
        }
        /* otherwise continue to next */
    }
    yyerror ( "Too many symbols " );
    exit(1); 
    
}

extern FILE* yyin;
int main(int argc, char* argv[]){
  
    if(argc == 2){
        FILE *file;
        file = fopen(argv[1],"r");
        if(!file){
            fprintf(stderr,"could not open %s\n",argv[1]);
            exit(1);
        }
        yyin = file;

        while(!feof(yyin)){
           yyparse();
        }
        fclose(file);
    }else if(argc == 1){
        yyparse();
    }
    
    return 0;
}


void yyerror(const char *s)
{
fprintf (stderr, "%s\n", s);
}

