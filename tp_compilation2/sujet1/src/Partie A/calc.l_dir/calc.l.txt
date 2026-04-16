%{
#include "calc.tab.h"
#include <stdlib.h>
#include <stdio.h>
%}

%%

[0-9]+"."[0-9]+   { yylval.reel = atof(yytext); return NUMBER; }
[0-9]+            { yylval.reel = atof(yytext); return NUMBER; }

"+"               { return PLUS;   }
"-"               { return MINUS;  }
"*"               { return TIMES;  }
"/"               { return DIV;    }

"("               { return LPAREN; }
")"               { return RPAREN; }

"\n"              { return '\n';   }

[ \t]             { /* ignorer */ }

. {
    fprintf(stderr, "Erreur lexicale : caractere illegal '%s'\n", yytext);
}

%%

int yywrap(void) { return 1; }