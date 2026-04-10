%{
#include <stdio.h>
/* On inclut le header généré par Bison pour connaître les tokens */
#include "sql.tab.h"
%}

%%
[Cc][Rr][Ee][Aa][Tt][Ee]           { return CREATE; }
[Tt][Aa][Bb][Ll][Ee]               { return TABLE_KW; }
[Vv][Aa][Rr][Cc][Hh][Aa][Rr]      { return VARCHAR; }
[Ii][Nn][Tt]                        { return INT_KW; }
[Dd][Aa][Tt][Ee]                    { return DATE_KW; }
[Pp][Rr][Ii][Mm][Aa][Rr][Yy]      { return PRIMARY; }
[Kk][Ee][Yy]                        { return KEY_KW; }
[0-9]+                              { yylval = atoi(yytext); return NB; }
[a-zA-Z_][a-zA-Z0-9_]* { return IDENT; }
[,()]                               { return yytext[0]; }
[ \t\n\r]+                          { /* ON IGNORE LES ESPACES, TABS ET NEWLINES */ }
.                                   { printf("Erreur lexicale : %s\n", yytext); }
%%

int yywrap() { return 1; }
