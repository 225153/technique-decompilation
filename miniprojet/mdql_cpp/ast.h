#ifndef AST_H
#define AST_H

#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <fstream>
#include <sstream>
#include <cstdlib>

using namespace std;

// Structure pour stocker un fichier CSV
struct CSVTable {
    vector<string> headers;
    vector<map<string, string>> rows;
};

// Environnement Global
extern map<string, CSVTable> databases;
extern map<string, map<string, string>> iterators; // Variables d'itérations (ex: "row" -> col:valeur)

// --- Expressions (Calculs et Accès aux données) ---
class Expr {
public:
    virtual ~Expr() {}
    virtual double evalNum() = 0;
    virtual string evalStr() = 0;
};

// Nombre direct (ex: 1300)
class NumExpr : public Expr {
    double val;
public:
    NumExpr(double v) : val(v) {}
    double evalNum() { return val; }
    string evalStr() { char buf[32]; snprintf(buf, sizeof(buf), "%g", val); return string(buf); }
};

// Accès à une propriété (ex: row.salary)
class PropExpr : public Expr {
    string obj, prop;
public:
    PropExpr(string o, string p) : obj(o), prop(p) {}
    string evalStr() { return iterators[obj][prop]; }
    double evalNum() { 
        try { return stod(iterators[obj][prop]); } 
        catch(...) { return 0; } 
    }
};

// Opérations Binaires (>, <, ==, +, -, *, /)
class BinOpExpr : public Expr {
    Expr *left, *right;
    string op;
public:
    BinOpExpr(Expr* l, string o, Expr* r) : left(l), op(o), right(r) {}
    ~BinOpExpr() { delete left; delete right; }
    double evalNum() {
        if (op == ">") return left->evalNum() > right->evalNum();
        if (op == "<") return left->evalNum() < right->evalNum();
        if (op == "==") return left->evalStr() == right->evalStr(); // Comparaison de textes
        if (op == "+") return left->evalNum() + right->evalNum();
        if (op == "-") return left->evalNum() - right->evalNum();
        if (op == "*") return left->evalNum() * right->evalNum();
        if (op == "/") {
            double r = right->evalNum();
            return r != 0 ? left->evalNum() / r : 0;
        }
        return 0;
    }
    string evalStr() { 
        if (op == "==" || op == ">" || op == "<") return evalNum() ? "true" : "false";
        char buf[64]; snprintf(buf, sizeof(buf), "%g", evalNum()); return string(buf);
    }
};

// Chaîne de caractères directe (ex: "Sara")
class StringExpr : public Expr {
    string val;
public:
    StringExpr(string v) : val(v) {}
    double evalNum() { 
        try { return stod(val); } catch(...) { return 0; } 
    }
    string evalStr() { return val; }
};

// --- Instructions (Statements) ---
class Stmt {
public:
    virtual ~Stmt() {}
    virtual void execute() = 0;
};

// Bloc d'instructions (entre { })
class Block : public Stmt {
    vector<Stmt*> stmts;
public:
    void add(Stmt* s) { stmts.push_back(s); }
    ~Block() { for(auto s : stmts) delete s; }
    void execute() {
        for(auto s : stmts) s->execute();
    }
};

// Chargement CSV
class LoadStmt : public Stmt {
    string filename, alias;
public:
    LoadStmt(string f, string a) : filename(f), alias(a) {}
    void execute() {
        ifstream file(filename);
        if(!file.is_open()) { 
            cout << "[ERREUR] Impossible d'ouvrir le fichier " << filename << "\n"; 
            return; 
        }
        
        string line, word;
        CSVTable table;
        
        // Lire la première ligne (headers)
        if(getline(file, line)) {
            for(char& c : line) if(c == ',') c = ' '; // Convertir les virgules en espaces
            stringstream ss(line);
            while(ss >> word) { // ss >> word ignore automatiquement les multi-espaces
                if (!word.empty() && word.back() == '\r') word.pop_back();
                table.headers.push_back(word);
            }
        }
        
        // Lire les données
        while(getline(file, line)) {
            if(line.empty()) continue;
            for(char& c : line) if(c == ',') c = ' '; // Convertir les virgules en espaces
            stringstream ss2(line);
            map<string, string> row;
            int i = 0;
            while(ss2 >> word) {
                if (!word.empty() && word.back() == '\r') word.pop_back();
                if (i < table.headers.size()) row[table.headers[i]] = word;
                i++;
            }
            table.rows.push_back(row);
        }
        
        databases[alias] = table;
        cout << "[MDQL] Fichier '" << filename << "' charge avec succes sous l'alias '" << alias << "' (" << table.rows.size() << " lignes).\n";
    }
};

// Affichage (PRINT)
class PrintStmt : public Stmt {
    Expr* expr;
public:
    PrintStmt(Expr* e) : expr(e) {}
    ~PrintStmt() { delete expr; }
    void execute() {
        cout << "> " << expr->evalStr() << "\n";
    }
};

// Condition (IF)
class IfStmt : public Stmt {
    Expr* cond;
    Block* body;
public:
    IfStmt(Expr* c, Block* b) : cond(c), body(b) {}
    ~IfStmt() { delete cond; delete body; }
    void execute() {
        if(cond->evalNum() > 0) {
            body->execute();
        }
    }
};

// Boucle (FOR EACH)
class ForStmt : public Stmt {
    string iter_var, alias;
    Block* body;
public:
    ForStmt(string i, string a, Block* b) : iter_var(i), alias(a), body(b) {}
    ~ForStmt() { delete body; }
    void execute() {
        if (databases.find(alias) == databases.end()) {
            cout << "[ERREUR] La table mémoire '" << alias << "' n'existe pas.\n";
            return;
        }
        CSVTable& table = databases[alias];
        for (auto& row : table.rows) {
            iterators[iter_var] = row; // Met à jour la variable d'itération pour ce tour
            body->execute();           // Exécute l'intérieur de la boucle
        }
    }
};

#endif
