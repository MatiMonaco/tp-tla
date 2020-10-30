%{
#include "parser.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#define YYDEBUG 1
#define DEFAULT_OUTFILE "a.out"
int yylex();
void yyerror(const char *s);
%}

%union{
    double dval;
    char* string;
    int boolean;
    struct symtab* symp;
}

%token <symp> NAME
%token <dval> NUMBER
%token <string>QSTRING
%token SEMICOLON NEW_LINE PRINT IF ELSE WHILE COMPARISON OR AND 




//Set precedences
%left '-' '+'
%left '*' '/'

%nonassoc UMINUS
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%type <dval> num_var
%type <boolean> condition
%%
statement_list: /* empty */
        |       statement_list statement
      
        ;
statement: NAME '=' num_var  ';' { $1->value = $3; }
        |  num_var   ';' { printf("= %g\n", $1); }
        | print_func ';'
        | NEW_LINE
        | IF '(' condition ')' '{' statement_list '}' %prec LOWER_THAN_ELSE 
        | IF '(' condition ')' '{' statement_list '}' ELSE '{' statement_list '}'
        | WHILE '(' condition ')' '{' statement_list '}'

        ;

condition:  num_var {$$ = (int)$1;}
        |   condition COMPARISON num_var 

        

        ;
      

num_var: num_var '+' num_var { $$ = $1 + $3; }
        |   num_var '-' num_var { $$ = $1 - $3; }
        |   num_var '*' num_var { $$ = $1 * $3; }
        |   num_var '/' num_var 
                                    { if($3 == 0.0)
                                            yyerror("divide by zero");
                                        else
                                            $$ = $1 / $3;                                    
                                      }
        |   '-' num_var %prec UMINUS     { $$ = -$2; }
        |   '(' num_var ')'      { $$ = $2; }
        |   NUMBER
        |   NAME { $$ = $1->value; }
        | NAME '(' num_var ')' {
            if($1->funcptr){
                $$ = ($1->funcptr)($3);
            }else{
                 printf("%s is not a function\n",$1->name);
                $$ = 0;
            }
        }
        ;

print_func:  PRINT '(' num_var ')' { 
                                        printf("%g",$3);
                                    }
        |    PRINT '(' QSTRING ')' {
                                    char *s = $3;
                                    for(int i = 0;s[i] != '\0';i++){
                                        char c = s[i];
                                        if(c == '\\'){
                                            char next = s[i+1];
                                            switch(next){
                                                case 'n':
                                                    putchar('\n');
                                                    i++;
                                                    break;
                                                case 't':
                                                    putchar('\t');
                                                    i++;
                                                default:
                                                    putchar(c);
                                                }
                                        }else{
                                            putchar(c);
                                        }
                                    }
           }
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

void addFunc(char *name,double(*func)()){
    struct symtab *sp = symlook(name);
    sp->funcptr = func;
}
int main(int argc, char* argv[]){
    
    extern double sqrt(),exp(),log();
    extern FILE *yyin, *yyout;
    addFunc("sqrt",sqrt);
    addFunc("exp",exp);
    addFunc("log",log);
    char * infile;
    char * outfile;
    char * progname = argv[0];
    if(argc == 1){
        yyparse();
    }else if(argc > 1){
        infile = argv[1];
        yyin = fopen(infile,"r");
        if(yyin == NULL){
            fprintf(stderr,"%s: cannot open %s\n",progname,infile);
            exit(1);
        }
      
    }
    if(argc > 2){
        outfile = argv[2];
    }else{
        outfile = DEFAULT_OUTFILE;
    }
    yyout = fopen(outfile,"w");
    if(yyout == NULL){
        fprintf(stderr,"%s: cannot open %s\n",progname,outfile);
        exit(1);
    }
    yyparse();
  
    fclose(yyin);
    fclose(yyout);
    exit(0);
    // while(!feof(yyin)){
    //     yyparse();
    // }
  
    return 0;
}


void yyerror(const char *s)
{
    fprintf (stderr, "%s\n", s);
}

