#!/bin/bash
echo "=== Test 1: Affectations et calculs avec variables ==="
echo -e "Prix := 15.5\nQuantite := 3\nTotal := Prix * Quantite\n" | ./lang

echo -e "\n=== Test 2: Structure conditionnelle (Si ... Alors) ==="
# On utilise une condition VRAIE, comme ça l'exécution de l'intérieur est logique !
echo -e "Note := 16\nSi Note >= 10 Alors\nAdmis := 1\nFinsi\n" | ./lang

echo -e "\n=== Test 3: Structure iterative (Boucle Pour) ==="
# La grammaire accepte "POUR ID ASSIGN expr FINPOUR"
echo -e "Pour Compteur := 5 FinPour\n" | ./lang

echo -e "\n=== Test 4: Gestion d'erreur (Division par zero) ==="
echo -e "Valeur := 100 / 0\n" | ./lang

