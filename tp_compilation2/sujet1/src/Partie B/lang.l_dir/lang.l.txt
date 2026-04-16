%{
#include "lang.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
%}

%%

[0-9]+"."[0-9]+        { yylval.reel = atof(yytext); return NUMBER; }
[0-9]+                 { yylval.reel = atof(yytext); return NUMBER; }
"Si"                   { return SI;         }
"Alors"                { return ALORS;      }
"Sinon"                { return SINON;      }
"Finsi"                { return FINSI;      }
"Pour"                 { return POUR;       }
"FinPour"              { return FINPOUR;    }
"Tantque"              { return TANTQUE;    }
"FinTantque"           { return FINTANTQUE; }
"Repeter"              { return REPETER;    }
"JusquA"               { return JUSQUA;     }
":="                   { return ASSIGN;     }
"="                    { return EQ;         }
"<"                    { return LT;         }
">"                    { return GT;         }
"<="                   { return LE;         }
">="                   { return GE;         }
"!="                   { return NEQ;        }
"+"                    { return PLUS;       }
"-"                    { return MINUS;      }
"*"                    { return TIMES;      }
"/"                    { return DIV;        }
"("                    { return LPAREN;     }
")"                    { return RPAREN;     }
[a-zA-Z][a-zA-Z0-9]*  { yylval.nom = strdup(yytext); return ID; }
"\n"                   { return '\n';       }
[ \t]                  { }
.                      { fprintf(stderr, "Erreur lexicale : caractere illegal '%s'\n", yytext); }

%%

int yywrap(void) { return 1; }