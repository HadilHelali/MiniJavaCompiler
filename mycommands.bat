flex Lexical.lex
bison Syntaxique.y -d
gcc -o Compilateur lex.yy.c Syntaxique.tab.c