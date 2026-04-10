%{
#include <stdio.h>
#include <stdlib.h>
%}

%%
(0|1)+      { printf("'%s' est un nombre binaire\n", yytext); }
.+          { printf("'%s' n'est PAS un nombre binaire\n", yytext); }
\n          { /* ignorer */ }
%%

int yywrap() { return 1; }

int main(int argc, char *argv[]) {
    /* 1. Gestion du fichier d'entrée */
    ++argv; --argc;
    if (argc > 0) {
        yyin = fopen(argv[0], "r");
        if (!yyin) {
            printf("Erreur de lecture du fichier.\n");
            return 1;
        }
    } else {
        yyin = stdin;
    }

    /* 2. LA LIGNE CLÉ : Redirection de la sortie standard (stdout) vers le fichier */
    freopen("resultat.txt", "w", stdout);

    /* 3. Lancement de l'analyse */
    yylex();

    /* 4. Fermeture propre du fichier d'entrée (pas besoin de fermer stdout) */
    if (yyin != stdin) {
        fclose(yyin);
    }
    
    return 0;
}
