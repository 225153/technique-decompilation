%{
#include <stdio.h>
#include "ex1.tab.h"
%}

%%

[0-9]+      { yylval = atoi(yytext); return NB; }
"somme"     { return SOM; }
"produit"   { return PROD; }
[,]         { return yytext[0]; }
[.]         { return yytext[0]; }
[$]         { return FIN; }
[ \t\n]     { /* ignorer */ }
.           { printf("Erreur lexicale : %s\n", yytext); }

%%

int yywrap() { return 1; }
