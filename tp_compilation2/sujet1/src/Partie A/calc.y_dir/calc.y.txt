%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

%union {
    double reel;
}

%token <reel> NUMBER
%token PLUS MINUS TIMES DIV LPAREN RPAREN

%type <reel> expr

%left PLUS MINUS
%left TIMES DIV
%right UMINUS

%%

programme :
    programme expr '\n'  { printf("= %g\n\n", $2); }
  | programme '\n'
  | /* vide */
  ;

expr :
    expr PLUS expr   { $$ = $1 + $3; }
  | expr MINUS expr  { $$ = $1 - $3; }
  | expr TIMES expr  { $$ = $1 * $3; }
  | expr DIV expr    {
        if ($3 == 0.0) {
            fprintf(stderr, "Erreur : division par zero\n");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
  | LPAREN expr RPAREN      { $$ = $2; }
  | MINUS expr %prec UMINUS { $$ = -$2; }
  | NUMBER                  { $$ = $1; }
  ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erreur syntaxique : %s\n", s);
}

int main(void) {
    printf("Interpreteur d'expressions mathematiques\n");
    printf("Tapez une expression et appuyez sur Entree.\n");
    printf("Ctrl+D pour quitter.\n\n");

    yyparse();
    return 0;
}