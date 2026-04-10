%{
#include <stdio.h>
%}

id      [a-zA-Z][a-zA-Z0-9]*
nb      [0-9]+

%%

{id}        { printf("ID : '%s'\n", yytext); }
{nb}        { printf("NB : '%s'\n", yytext); }
[ \t\n]     { /* ignorer */ }
.           { printf("ERREUR : caractère inconnu '%s'\n", yytext); }

%%

int yywrap() { return 1; }
int main() { yylex(); return 0; }
