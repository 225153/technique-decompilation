%{
#include <stdio.h>

int nb_mots = 0;
int nb_lignes = 0;
int nb_chars = 0;
int somme = 0;
%}

mot     [a-zA-Z]+
nombre  [0-9]+
espace  [ \t]+

%%

{nombre}    {
                nb_mots++;
                nb_chars += yyleng;
                somme += atoi(yytext);
            }

{mot}       {
                nb_mots++;
                nb_chars += yyleng;
            }

{espace}    {
                nb_chars += yyleng;
            }

\n          {
                nb_lignes++;
                nb_chars++;
            }

.           {
                nb_chars++;
            }

%%

int yywrap() { return 1; }

int main(int argc, char *argv[]) {
    ++argv; --argc;
    if (argc > 0)
        yyin = fopen(argv[0], "r");
    else
        yyin = stdin;

    yyout = fopen("resultat.txt", "w");

    yylex();

    fprintf(yyout, "=== Résultats ===\n");
    fprintf(yyout, "Nombre de mots     : %d\n", nb_mots);
    fprintf(yyout, "Nombre de lignes   : %d\n", nb_lignes);
    fprintf(yyout, "Nombre de caractères: %d\n", nb_chars);
    fprintf(yyout, "Somme des nombres  : %d\n", somme);

    fclose(yyout);
    printf("Résultat écrit dans resultat.txt\n");
    return 0;
}
