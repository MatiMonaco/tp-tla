
all: parser lexer link

parser: parser.y
	yacc -d -Wyacc -Wconflicts-sr parser.y

lexer: lexer.l
	lex lexer.l

link: lex.yy.c y.tab.c
	gcc  -Wall -c lex.yy.c y.tab.c
	gcc -Wall -o exp lex.yy.o y.tab.o -ll
clean:
	rm -rf lex.yy.c y.tab.c y.tab.o lex.yy.o y.tab.h

.PHONY: all clean