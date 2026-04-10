%{
#include <stdio.h>
#include <string.h>

/* Convertir en majuscules pour comparaison insensible à la casse */
char upper_buf[256];
char* to_upper(const char* s) {
    int i;
    for(i = 0; s[i] && i < 255; i++)
        upper_buf[i] = toupper((unsigned char)s[i]);
    upper_buf[i] = '\0';
    return upper_buf;
}
%}

/* Mots-clés SQL (insensible à la casse) */
CREATE      [Cc][Rr][Ee][Aa][Tt][Ee]
TABLE       [Tt][Aa][Bb][Ll][Ee]
PRIMARY     [Pp][Rr][Ii][Mm][Aa][Rr][Yy]
KEY         [Kk][Ee][Yy]

/* Types de données */
INT         [Ii][Nn][Tt]
VARCHAR     [Vv][Aa][Rr][Cc][Hh][Aa][Rr]
DATE        [Dd][Aa][Tt][Ee]

/* Identifiant */
IDENT       [a-zA-Z_][a-zA-Z0-9_]*

/* Nombre */
NUMBER      [0-9]+

%%

{CREATE}                { printf("%-20s CREATE\n", yytext); }
{TABLE}                 { printf("%-20s TABLE\n", yytext); }
{PRIMARY}" "{KEY}       { printf("%-20s PRIMARY_KEY\n", yytext); }
{INT}                   { printf("%-20s DATATYPE\n", yytext); }
{VARCHAR}               { printf("%-20s DATATYPE\n", yytext); }
{DATE}                  { printf("%-20s DATATYPE\n", yytext); }  
{IDENT}                 { printf("%-20s IDENTIFIER\n", yytext); }
{NUMBER}                { printf("%-20s NUMBER\n", yytext); }
","                     { printf("%-20s COMMA\n", yytext); }
"("                     { printf("%-20s (\n", yytext); }
")"                     { printf("%-20s )\n", yytext); }
[ \t\n]                 { /* ignorer espaces */ }

%%

int yywrap() { return 1; }
int main() { yylex(); return 0; }
