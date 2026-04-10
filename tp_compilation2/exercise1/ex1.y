%{
#include <stdio.h>
int yylex(void);
int yyerror(char *s);
%}

%token FIN
%token SOM
%token PROD
%token NB

%%

liste : FIN
            { printf("Syntaxe correcte !\n"); }
      | SOM listesom '.' liste
      | PROD listeprod '.' liste
      ;

listesom : NB
         | listesom ',' NB
         ;

listeprod : NB
          | listeprod ',' NB
          ;

%%

#include "lex.yy.c"

int yyerror(char *s) {
    printf("Erreur syntaxique : %s\n", s);
    return 0;
}

int main() {
    yyparse();
    return 0;
}
