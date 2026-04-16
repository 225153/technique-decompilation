%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

#define MAX_VARS 100
#define MAX_ITER 100000

typedef struct {
    char   nom[64];
    double valeur;
} Variable;

Variable table[MAX_VARS];
int nb_vars = 0;
int erreur_division = 0;

double get_var(char *nom) {
    for (int i = 0; i < nb_vars; i++)
        if (strcmp(table[i].nom, nom) == 0)
            return table[i].valeur;
    fprintf(stderr, "Erreur : variable '%s' non declaree\n", nom);
    return 0;
}

void set_var(char *nom, double valeur) {
    for (int i = 0; i < nb_vars; i++) {
        if (strcmp(table[i].nom, nom) == 0) {
            table[i].valeur = valeur;
            return;
        }
    }
    strcpy(table[nb_vars].nom, nom);
    table[nb_vars].valeur = valeur;
    nb_vars++;
}
%}

%union {
    double reel;
    char  *nom;
    int    entier;
}

%token <reel>   NUMBER
%token <nom>    ID
%token PLUS MINUS TIMES DIV LPAREN RPAREN
%token ASSIGN
%token EQ LT GT LE GE NEQ
%token SI ALORS SINON FINSI
%token POUR FINPOUR
%token TANTQUE FINTANTQUE
%token REPETER JUSQUA

%type <reel>   expr
%type <entier> condition

%left  PLUS MINUS
%left  TIMES DIV
%right UMINUS

%%

programme :
    programme instruction '\n'
  | programme '\n'
  | /* vide */
  ;

instruction :
    ID ASSIGN expr {
        set_var($1, $3);
        printf("%s := %.2f\n", $1, $3);
        free($1);
    }
  | SI condition ALORS '\n' programme FINSI {
        if (!$2)
            printf("condition fausse, bloc Si ignore\n");
    }
  | SI condition ALORS '\n' programme SINON '\n' programme FINSI {
        if ($2)
            printf("condition vraie, bloc Alors execute\n");
        else
            printf("condition fausse, bloc Sinon execute\n");
    }
  | TANTQUE condition '\n' programme FINTANTQUE {
        int iter = 0;
        while ($2) {
            if (iter >= MAX_ITER) {
                fprintf(stderr, "Erreur : boucle infinie detectee\n");
                break;
            }
            iter++;
        }
    }
  | POUR ID ASSIGN expr FINPOUR {
        printf("Boucle Pour sur %s\n", $2);
        free($2);
    }
  | REPETER '\n' programme JUSQUA condition {
        int iter = 0;
        if (iter >= MAX_ITER)
            fprintf(stderr, "Erreur : boucle infinie detectee\n");
    }
  ;

condition :
    expr EQ  expr  { $$ = ($1 == $3); }
  | expr LT  expr  { $$ = ($1 <  $3); }
  | expr GT  expr  { $$ = ($1 >  $3); }
  | expr LE  expr  { $$ = ($1 <= $3); }
  | expr GE  expr  { $$ = ($1 >= $3); }
  | expr NEQ expr  { $$ = ($1 != $3); }
  ;

expr :
    expr PLUS  expr         { $$ = $1 + $3; }
  | expr MINUS expr         { $$ = $1 - $3; }
  | expr TIMES expr         { $$ = $1 * $3; }
  | expr DIV   expr         {
                                if ($3 == 0.0) {
                                    fprintf(stderr, "Erreur : division par zero\n");
                                    erreur_division = 1;
                                    $$ = 0;
                                } else {
                                    $$ = $1 / $3;
                                }
                            }
  | LPAREN expr RPAREN      { $$ = $2;  }
  | MINUS expr %prec UMINUS { $$ = -$2; }
  | NUMBER                  { $$ = $1;  }
  | ID                      { $$ = get_var($1); free($1); }
  ;

%%

void yyerror(const char *s) {
    if (strstr(s, "syntax error") != NULL)
        fprintf(stderr, "Erreur syntaxique : Finsi / FinPour / FinTantque manquant\n");
    else
        fprintf(stderr, "Erreur syntaxique : %s\n", s);
}

int main(void) {
    printf("Interpreteur de langage simple\n");
    printf("Ctrl+D pour quitter.\n\n");
    yyparse();
    return 0;
}