#ifndef PARSER_H
#define PARSER_H

#define MAX_SYMBOLS 50 // Maximum number of symbols

struct symtab
{
    char *name;
    double (*funcptr)();
    char *string;
    double value;
} symtab[MAX_SYMBOLS];

struct symtab *symlook(char *s);

void addFunc(char *name, double (*func)());

#endif // MACRO
