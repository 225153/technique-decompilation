%{
#include <stdio.h>
int num_ligne = 1;
%}

/* Définitions */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
ENTIER      [+-]?{DIGIT}+
REEL        [+-]?{DIGIT}+\.{DIGIT}*([eE][+-]?{DIGIT}+)?|[+-]?\.{DIGIT}+([eE][+-]?{DIGIT}+)?
IDENT       {LETTER}({LETTER}|{DIGIT})*
CHAINE      \"[^"\n]*\"
COMMENTAIRE #[^\n]*

%%

"if"        { printf("MOTCLE   : %s\n", yytext); }
"else"      { printf("MOTCLE   : %s\n", yytext); }
"while"     { printf("MOTCLE   : %s\n", yytext); }

{REEL}      { printf("REEL     : %s\n", yytext); }
{ENTIER}    { printf("ENTIER   : %s\n", yytext); }

{IDENT}     { printf("IDENT    : %s\n", yytext); }

"+"         { printf("OP-ARTHM : +\n"); }
"-"         { printf("OP-ARTHM : -\n"); }
"*"         { printf("OP-ARTHM : *\n"); }
"/"         { printf("OP-ARTHM : /\n"); }

"<="        { printf("OP-REL   : <=\n"); }
">="        { printf("OP-REL   : >=\n"); }
"=="        { printf("OP-REL   : ==\n"); }
"!="        { printf("OP-REL   : !=\n"); }
"<"         { printf("OP-REL   : <\n"); }
">"         { printf("OP-REL   : >\n"); }

"="         { printf("AFFECT   : =\n"); }

{CHAINE}    { printf("CHAINE   : %s\n", yytext); }

{COMMENTAIRE}   { printf("COMMENT  : %s\n", yytext); }


\"[^"\n]*$  {
    printf("** Erreur ligne %d : fin de chaîne attendue pour %s\n",
           num_ligne, yytext);
}

\n          { num_ligne++; }
[ \t]+      { /* ignorer */ }


{DIGIT}+{LETTER}({LETTER}|{DIGIT})* {
    printf("** Erreur ligne %d : identificateur mal formé '%s'\n",
           num_ligne, yytext);
}

.           {
    printf("** Erreur ligne %d : caractère inconnu '%s'\n",
           num_ligne, yytext);
}

%%

int yywrap() { return 1; }

int main(int argc, char *argv[]) {
    ++argv; --argc;
    if (argc > 0)
        yyin = fopen(argv[0], "r");
    else
        yyin = stdin;
    yylex();
    return 0;
}
