%{
#include <stdio.h>
%}

pairpair (aa|bb)*((ab|ba)(aa|bb)*(ab|ba)(aa|bb)*)*

%%

a*b*          { printf("[%s]: des a d'abord et des b ensuite\n", yytext); }
{pairpair}    { printf("[%s]: nombre pair de a et de b\n", yytext); }

.             { /* ignorer autres */ }
%%

int yywrap() { return 1; }
int main() { yylex(); return 0; }
