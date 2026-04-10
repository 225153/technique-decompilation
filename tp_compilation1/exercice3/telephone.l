%{
#include <stdio.h>
%}


nom         [A-Z][a-zA-Z0-9]*


prenom      [a-z][a-z0-9]*


telephone   [0-9]{2}([ ][0-9]{2}){4}

%%

{nom}       { printf("NOM      : %s\n", yytext); }
{prenom}    { printf("PRÉNOM   : %s\n", yytext); }
@[ ]*       { printf("SÉPARATEUR @\n"); }
{telephone} { printf("TÉLÉPHONE: %s\n", yytext); }
\n          { printf("---\n"); }
[ \t]       { /* ignorer espaces simples */ }

%%

int yywrap() { return 1; }
int main() { yylex(); return 0; }
