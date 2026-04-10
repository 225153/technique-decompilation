%{
#include <stdio.h>
#include "ex1_calc.tab.h"
%}

%%

[0-9]+      { yylval = atoi(yytext); return NB; }
"somme"     { return SOM; }
"produit"   { return PROD; }
[,]         { return yytext[0]; }
[.]         { return yytext[0]; }
[$]         { return FIN; }
[ \t\n]     { }
.           { printf("Erreur lexicale\n"); }

%%

int yywrap() { return 1; }
