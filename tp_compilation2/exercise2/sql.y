%{
#include <stdio.h>
#include <string.h>
int yylex(void);
int yyerror(char *s);
%}

%token CREATE TABLE_KW VARCHAR INT_KW DATE_KW PRIMARY KEY_KW
%token IDENT NB

%%
requete : CREATE TABLE_KW IDENT '(' liste_col ')'
              { printf("Requete SQL syntaxiquement correcte !\n"); }
        ;

liste_col : colonne
          | liste_col ',' colonne
          ;

colonne : IDENT type
              { printf("  Colonne reconnue\n"); }
        | IDENT type PRIMARY KEY_KW
              { printf("  Colonne CLE PRIMAIRE reconnue\n"); }
        ;

type : VARCHAR '(' NB ')'
           { printf("    Type: VARCHAR(%d)\n", $3); }
     | INT_KW
           { printf("    Type: INT\n"); }
     | DATE_KW
           { printf("    Type: DATE\n"); }
     ;

%%
/* On inclut le fichier généré par Flex directement ici */
#include "lex.yy.c"

int yyerror(char *s) {
    printf("Erreur syntaxique : %s\n", s);
    return 0;
}

int main() {
    printf("Entrez votre commande SQL :\n");
    yyparse();
    return 0;
}
