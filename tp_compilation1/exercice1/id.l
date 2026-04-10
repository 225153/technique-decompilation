%{
#include <stdio.h>
%}

id      [a-zA-Z][a-zA-Z0-9]*

%%

{id}        { printf("IDENT reconnu : '%s'\n", yytext); }
[0-9]+      { printf("'%s' : commence par un chiffre -> PAS un id\n", yytext); }
[ \t\n]     { /* ignorer espaces */ }
.           { printf("'%s' : caractère invalide\n", yytext); }

%%

int yywrap() { return 1; }
int main() { yylex(); return 0; }
