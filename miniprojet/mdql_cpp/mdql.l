%{
#include "ast.h"
#include "mdql.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%option noyywrap

%%
"LOAD"      { return LOAD; }
"AS"        { return AS; }
"FOR"       { return FOR; }
"EACH"      { return EACH; }
"IN"        { return IN; }
"IF"        { return IF; }
"PRINT"     { return PRINT; }

\"[^\"]*\"  { yytext[yyleng-1] = '\0'; yylval.str = strdup(yytext+1); return STRING; }
"//"[^\n]*  { /* ignorer les commentaires sur une ligne */ }
"--"[^\n]*  { /* ignorer les commentaires SQL */ }

[a-zA-Z_][a-zA-Z0-9_]*\.csv { yylval.str = strdup(yytext); return FILENAME; }
[a-zA-Z_][a-zA-Z0-9_]*      { yylval.str = strdup(yytext); return ID; }
[0-9]+(\.[0-9]+)?           { yylval.num = atof(yytext); return NUMBER; }

">"         { yylval.str = strdup(yytext); return GT; }
"<"         { yylval.str = strdup(yytext); return LT; }
"=="        { yylval.str = strdup(yytext); return EQ; }
"+"         { yylval.str = strdup(yytext); return PLUS; }
"-"         { yylval.str = strdup(yytext); return MINUS; }
"*"         { yylval.str = strdup(yytext); return MUL; }
"/"         { yylval.str = strdup(yytext); return DIV; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"."         { return DOT; }
";"         { return SEMI; }

[ \t\n\r]+  { /* ignore les espaces et sauts de ligne */ }
.           { printf("Erreur lexicale: %s\n", yytext); }
%%
