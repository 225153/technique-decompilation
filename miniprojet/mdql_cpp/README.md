# MDQL - Mini Data Query Language 🚀

**MDQL** est un interpréteur de langage spécifique au domaine (DSL) conçu pour la manipulation et le requêtage de données CSV. Ce projet a été réalisé dans le cadre du module **Techniques de Compilation** en utilisant **Flex** et **Bison** avec un moteur d'exécution en **C++**.

---

## 🌟 Fonctionnalités principales

- **Analyse Lexicale (Flex)** : Découpage intelligent du code en tokens, gestion des identifiants, nombres, chaînes de caractères et opérateurs.
- **Analyse Syntaxique (Bison)** : Validation de la structure du code selon une grammaire formelle et construction d'un **Arbre de Syntaxe Abstrait (AST)**.
- **Moteur d'Exécution C++** : Interprétation récursive de l'AST pour une exécution ultra-rapide.
- **Manipulation CSV** : Chargement dynamique de fichiers `.csv` en mémoire (Hash Tables).
- **Structures de Contrôle** : Support des boucles `FOR EACH` et des conditions `IF`.
- **Opérations Arithmétiques** : Support des calculs en temps réel (`+`, `-`, `*`, `/`) avec gestion des priorités.
- **Interface Graphique (Qt)** : Un IDE complet avec éditeur de code, prévisualisation CSV et console intégrée.

---

## 🛠️ Structure du Langage

Le langage MDQL permet d'écrire des requêtes puissantes et lisibles :

```sql
-- Chargement des données
LOAD employees.csv AS staff;

/* 
   Boucle sur chaque ligne pour filtrer 
   les salaires supérieurs à 1500 
*/
FOR EACH row IN staff {
  IF row.salary > 1500 {
    PRINT row.name;
    PRINT row.salary * 1.05; -- Calcul de bonus de 5%
  }
}
```

---

## 🖥️ Installation et Utilisation

### Prérequis
- GCC (g++)
- Flex
- Bison
- Qt5 (pour l'interface graphique)

### 1. Mode Terminal (Compilateur Natif)
Pour compiler le noyau en ligne de commande :
```bash
cd miniprojet/mdql_cpp
make
./mdql programme.mds
```

### 2. Mode IDE Graphique (Qt)
Pour lancer l'interface utilisateur professionnelle :
```bash
cd miniprojet/mdql_cpp/qt_gui
qmake mdql_gui.pro
make
./mdql_gui
```

---

## 📂 Architecture du Projet

- `mdql.l` : Analyseur lexical (lex).
- `mdql.y` : Grammaire et analyseur syntaxique (yacc/bison).
- `ast.h` : Définition des classes C++ de l'Arbre de Syntaxe Abstrait.
- `qt_gui/` : Code source de l'interface graphique Qt5.
- `employees.csv` : Exemple de source de données.
- `programme.mds` : Exemple de script MDQL.

---

## 🎓 Auteur
Projet réalisé par **Omar** (GitHub: **225153**) dans le cadre du cours sur les techniques de décompilation et de compilation.
