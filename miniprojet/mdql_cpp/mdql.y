%{
#include "ast.h"
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);

// Déclaration de notre AST principal
Block* rootBlock = nullptr;

// La mémoire globale où on va stocker les variables et les données du CSV
map<string, CSVTable> databases;
map<string, map<string, string>> iterators;
extern void yyrestart(FILE *input_file);
%}

/* Définition des types C++ renvoyés par Bison */
%union {
    double num;
    char* str;
    class Stmt* stmt;
    class Block* block;
    class Expr* expr;
}

/* Tokens venus de Flex */
%token LOAD AS FOR EACH IN IF PRINT LBRACE RBRACE LPAREN RPAREN DOT SEMI
%token <str> ID FILENAME GT LT EQ PLUS MINUS MUL DIV STRING
%token <num> NUMBER

/* Priorités mathématiques */
%left GT LT EQ
%left PLUS MINUS
%left MUL DIV

/* Types des règles de la grammaire */
%type <block> programme stmts
%type <stmt> stmt
%type <expr> expr

%%

programme :
    stmts { rootBlock = $1; }
  ;

stmts :
    stmts stmt { $$ = $1; $$->add($2); }
  | stmt       { $$ = new Block(); $$->add($1); }
  ;

stmt :
    LOAD FILENAME AS ID SEMI {
        $$ = new LoadStmt($2, $4);
        free($2); free($4);
    }
  | FOR EACH ID IN ID LBRACE stmts RBRACE {
        $$ = new ForStmt($3, $5, $7);
        free($3); free($5);
    }
  | IF expr LBRACE stmts RBRACE {
        $$ = new IfStmt($2, $4);
    }
  | PRINT expr SEMI {
        $$ = new PrintStmt($2);
    }
  ;

expr :
    ID DOT ID { // Accès à une colonne ex: row.salary
        $$ = new PropExpr($1, $3); 
        free($1); free($3);
    }
  | NUMBER { // Nombre réel
        $$ = new NumExpr($1);
    }
  | STRING { // Chaine de caractères
        $$ = new StringExpr($1);
        free($1);
    }
  | expr GT expr {
        $$ = new BinOpExpr($1, ">", $3);
    }
  | expr LT expr {
        $$ = new BinOpExpr($1, "<", $3);
    }
  | expr EQ expr {
        $$ = new BinOpExpr($1, "==", $3);
    }
  | expr PLUS expr {
        $$ = new BinOpExpr($1, "+", $3);
    }
  | expr MINUS expr {
        $$ = new BinOpExpr($1, "-", $3);
    }
  | expr MUL expr {
        $$ = new BinOpExpr($1, "*", $3);
    }
  | expr DIV expr {
        $$ = new BinOpExpr($1, "/", $3);
    }
  ;

%%

void yyrestart(FILE *input_file);

void yyerror(const char *s) {
    fprintf(stderr, "\033[1;31m[ERREUR SYNTAXIQUE]\033[0m %s\n", s);
}

int main(int argc, char** argv) {
    extern FILE* yyin;

    if(argc > 1) {
        // Mode Fichier (si exécuté avec ./mdql programme.mds)
        yyin = fopen(argv[1], "r");
        if(!yyin) {
            printf("\033[1;31mErreur d'ouverture du fichier source.\033[0m\n");
            return 1;
        }

        printf("\033[1;34m--- [Analyse Syntactique et Lexicale] ---\033[0m\n");
        yyparse(); 

        if(rootBlock) {
            printf("\n\033[1;32m--- [Interpretation (Execution AST)] ---\033[0m\n");
            rootBlock->execute();
            delete rootBlock;
            printf("\033[1;34m--- [Fin d'Execution] ---\033[0m\n\n");
        }

        fclose(yyin);
    } else {
        // Mode Console Interactive (REPL Professionnel)
        printf("\033[1;36m============================================================\033[0m\n");
        printf("\033[1;36m||               MDQL INTERACTIVE SHELL (C++)             ||\033[0m\n");
        printf("\033[1;36m============================================================\033[0m\n");
        printf("Tapez votre code MDQL.\n");
        printf("Tapez \033[1;33mRUN\033[0m sur une nouvelle ligne pour executer.\n");
        printf("Tapez \033[1;31mEXIT\033[0m pour quitter le terminal.\n\n");

        while(true) {
            printf("\n\033[1;36mMDQL >\033[0m ");
            string code;
            string line;
            bool executer = false;
            char buffer[1024];

            while(fgets(buffer, sizeof(buffer), stdin)) {
                line = string(buffer);
                // Si la ligne commence par EXIT ou RUN
                if(line.find("EXIT") == 0) {
                    printf("\033[1;35mAurevoir!\033[0m\n");
                    return 0;
                }
                if(line.find("RUN") == 0) { 
                    executer = true; 
                    break; 
                }
                
                code += line;
                printf("\033[1;36m     | \033[0m ");
            }

            if(!executer) break;

            // Ignorer si le code est completement vide (que des espaces/sauts de ligne)
            if(code.find_first_not_of(" \t\n\r") == string::npos) {
                continue;
            }

            // Ecriture du code temporaire
            FILE* tmp = fopen(".tmp_query.mds", "w");
            fprintf(tmp, "%s\n", code.c_str());
            fclose(tmp);

            // Re-initialisation du parseur Flex pour lire de zero
            yyin = fopen(".tmp_query.mds", "r");
            if(yyin) {
                yyrestart(yyin);
                rootBlock = nullptr;
                
                // Si l'analyse se passe bien (yyparse() == 0)
                if(yyparse() == 0 && rootBlock) {
                    printf("\n\033[1;32m> Resultat :\033[0m\n");
                    rootBlock->execute();
                    delete rootBlock;
                    rootBlock = nullptr;
                }
                fclose(yyin);
            }
        }
    }

    return 0;
}
