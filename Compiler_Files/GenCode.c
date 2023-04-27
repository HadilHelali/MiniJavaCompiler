#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "Semantique.c"

    typedef struct
{
    char code_op[50]; // nom de la commande par exemple STORE, LDC, LDV…
    int operande;  // soit  une valeur constante à charger soit l’adresse dans ka table de symbole
    char nomFct[50]; // le nom d’une fonction / procédure.
} ENTREE_CODE;

// Table contenant l'ensemble des instructions générées :
ENTREE_CODE codeTabInt[100];

int nbCodes = 0 ;

/******* Implémentation de la table de code machine *******/

// Fonction genCode :
void addCode(char code_op[], int operande, char nomFct[]){
        
        // Ajout à la table :
        strcpy(codeTabInt[nbCodes].code_op, code_op);
        codeTabInt[nbCodes].operande = operande ;
        strcpy(codeTabInt[nbCodes].nomFct, nomFct);
        nbCodes++;
}
/******* /Implémentation de la table de code machine *****/

// Affichage du tableau :

void printCodeTab()
{
        printf("%5s %10s %10s %10s\n", "Nb", "Op_Code", "Operand", "Function");
        printf("---------------------------------------------\n");
        for (int i = 0; i < nbCodes; i++)
        {
            printf("%5d %10s %10d %10s\n", i, codeTabInt[i].code_op, codeTabInt[i].operande, codeTabInt[i].nomFct);
        }
        printf("---------------------------------------------\n\n\n");
}

// Ajout d'opérande :

void addOperator(char operSymbol[])
{
        if (!strcmp(operSymbol, "*"))
        {
            addCode("MUL", -1, "");
        }
        else if (!strcmp(operSymbol, "+"))
        {
            addCode("ADD", -1, "");
        }
        else if (!strcmp(operSymbol, "-"))
        {
            addCode("SUB", -1, "");
        }
        else if (!strcmp(operSymbol, "<"))
        {
            addCode("INF", -1, "");
        }
        else if (!strcmp(operSymbol, "=="))
        {
            addCode("EGAL", -1, "");
        }
        else if (!strcmp(operSymbol, "!="))
        {
            addCode("DIF", -1, "");
        }
}