#ifndef PARSER_H
#define PARSER_H

#define MAX_SYMBOLS 50 // Maximum number of symbols

struct symtab
{
    char *name;
    double (*funcptr)();
    double value;

} symtab[MAX_SYMBOLS];

struct symtab *symLook(char *s);
void symAdd(char *name);
void addFunc(char *name, double (*func)());
char *expOp(char *exp1, char *op, char *exp2);
void appendStmList(char *dest, char *stm_list);
#endif // MACRO
