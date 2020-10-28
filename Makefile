
all: parser lexer link

parser: parser.y
	yacc -d  parser.y

lexer: lexer.l
	lex lexer.l

link: lex.yy.c y.tab.c
	gcc  -Wall -c lex.yy.c y.tab.c -lm
	gcc -Wall -o compile lex.yy.o y.tab.o -ll -lm
clean:
	find . -type f | xargs touch
	rm -rf lex.yy.c y.tab.c y.tab.o lex.yy.o y.tab.h

.PHONY: all clean