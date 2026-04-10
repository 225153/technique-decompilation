%{
#include <stdio.h>
int yylex(void);
int yyerror(char *s);
%}

%%

mot : S '$'
          { printf("mot correct !\n"); }
    ;

S : 'a' S 'a'
  | 'b' S 'b'
  | 'c'
  ;

%%

int yylex() {
    char c = getchar();

    /* Bug 1 corrigé : ignorer espaces, newlines, tabulations */
    while (c == ' ' || c == '\n' || c == '\r' || c == '\t')
        c = getchar();

    /* Bug 2 corrigé : retourner 0 à la fin du fichier */
    if (c == EOF)
        return 0;

    if (c=='a' || c=='b' || c=='c' || c=='$')
        return c;
    else {
        printf("erreur lexicale : '%c'\n", c);
        return yylex(); /* continuer au lieu de bloquer */
    }
}

int yyerror(char *s) {
    printf("%s\n", s);
    return 0;
}

int main() {
    yyparse();
    printf("\n");
    return 0;
}
