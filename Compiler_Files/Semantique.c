#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// definition des types :
#define INT 0
#define BOOL 1
#define STRING 2
#define INT_TAB 3
#define STRING_TAB 4
#define ID_TYPE 5

// taille du dictionnaire :
#define TAILLE_INITIALE_DICO 50
#define INCREMENT_TAILLE_DICO 25

// Construire la table des symboles
 typedef enum {
    TOK_VARIABLE,
    TOK_FUNCTION,
    TOK_PARAMETER
} classe;

typedef
struct {
char *identif;
classe Classe;
int Type ; 
int Is_Init ;
int Is_used ;
int Nb_param ;
} ENTREE_DICO;

ENTREE_DICO * dico ;
int maxDico, sommet, base;

// Gestion d'erreurs
void erreurFatale(char * message, int ligne)
{if (ligne != 0)
{fprintf(stderr, "%s à la ligne %d\n", message, ligne);}
else
{fprintf(stderr, "%s\n", message);}
exit(-1);}

// Gestion des warnings
void warning(char *message, int ligne)
{fprintf(stderr, "%s à la ligne %d\n", message, ligne);}

// Creation d'un dictionnaire local :
void CreateLocalDic()
{
base = sommet;
}

// Destruction d'un dictionnaire local : base = sommet
void DestroyLocalDic()
{
sommet = base;
base = 0;
}

// Creation du dictionnaire
void creerDico() {
maxDico = TAILLE_INITIALE_DICO;
dico = malloc(maxDico * sizeof(ENTREE_DICO));
if (dico == NULL)
erreurFatale("Erreur interne (pas assez de memoire)",0);
sommet = base = 0;
}

// Augmentation du dictionnaire 
void agrandirDico() {
maxDico = maxDico + INCREMENT_TAILLE_DICO;
dico = realloc(dico, maxDico);
if (dico == NULL)
erreurFatale("Erreur interne (pas assez de memoire)",0);
}

// Ajout d'une variable au dictionnaire 
void ajouterEntree(char *identif, classe Classe , char* Type, int Is_Init, int Is_used, int Nb_param,int ligne) {
if (sommet >= maxDico)
agrandirDico();
dico[sommet].identif = malloc(strlen(identif) + 1);
if (dico[sommet].identif == NULL)
erreurFatale("Erreur interne (pas assez de mémoire)",ligne);
if (dico[sommet].Classe == TOK_FUNCTION)
CreateLocalDic();
strcpy(dico[sommet].identif, identif);
dico[sommet].Classe = Classe;

if ( strcmp(Type, "int") == 0)
dico[sommet].Type = INT ;
else if (strcmp(Type, "boolean") == 0) 
dico[sommet].Type = BOOL ;
else if (strcmp(Type, "String") == 0) 
dico[sommet].Type = STRING ;
else if (strcmp(Type, "int[]") == 0) 
dico[sommet].Type = INT_TAB ;
else 
dico[sommet].Type = ID_TYPE ;

dico[sommet].Is_Init = Is_Init;
dico[sommet].Is_used = Is_used;
dico[sommet].Nb_param = Nb_param;
sommet++;
}

// recherche d'un id 
// * pendant le traitement d'une déclaration : base <> 0
// * pendant le traitement d'une expression exécutable : base == 0
int recherche (char *identif){
    int i = sommet - 1;
    while (i >= base){
        if (identif == dico[i].identif)
        return i ;
    }
    return -1 ;
}



// * Contrainte 1 : Vérifier la redéfinition des variables déjà déclarées
void checkIdentifier(char *identif, classe Classe, char *Type, int Is_Init, int Is_used, int Nb_param, int ligne)
{
    int index = recherche(identif);
    if (index == -1)
        ajouterEntree(identif, Classe, Type, Is_Init, Is_used, Nb_param, ligne);
    else 
    erreurFatale("variable dejà declaree",ligne);
}

// * Contrainte 2 : Vérifier l’appel des procédures avec les bons arguments
void checkNbParameters (char *identif, int Nb_param,int ligne) {
    int index = recherche (identif) ;
    if (index == -1) 
    erreurFatale("fonction non declaree",ligne);
    else 
    {
        if (Nb_param != dico[index].Nb_param) 
                erreurFatale("fonction non declaree",ligne);
    }
}

// * Contrainte 3 : Vérifier qu’une variable utilisée est bien déclarée.
void checkUtilise(char *identif,int ligne) {
    int b1 = base ;
    int index = recherche(identif) ;
    if (index == -1)
        {base = 0 ;
        int index2 = recherche(identif) ;
        if (index2 == -1)
            erreurFatale("variable non declaree",ligne);
        else 
            dico[index2].Is_used = 1 ;}
    else
        dico[index].Is_used = 1 ;
    base = b1 ;
}

// * Contrainte 4 : Vérifier que les variables déclarées sont bien initialisées.

void Initialiser(char *identif , int ligne ) {
    int index = recherche(identif) ;
     if (index == -1)
     {erreurFatale("variable non declaree",ligne);}
     else {
        if (dico[index].Classe == TOK_VARIABLE)
        {
            dico[index].Is_Init = 1;}}
}

void checkInitialise(char *identif,int ligne) {
    int b1 = base ;
    int index = recherche(identif) ;
    if (index == -1)
        {base = 0 ;
        int index2 = recherche(identif) ;
        if (index2 == -1)
            erreurFatale("variable non declaree",ligne);
        else 
        {
            if ((dico[index2].Is_Init != 1) && (dico[index2].Classe == TOK_VARIABLE))
                warning("variable non initialisee", ligne);}
         }
    else
        {
        if ((dico[index].Is_Init != 1) && (dico[index].Classe == TOK_VARIABLE))
            warning("variable non initialisee",ligne) ;}
    base = b1 ;
}

// * Contrainte 5 : Vérifier qu’une variable déclarée est bien utilisée.

void Utiliser(char *identif , int ligne ) {
    int index = recherche(identif) ;
     if (index == -1)
     {erreurFatale("variable non declaree",ligne);}
     else {
        if (dico[index].Classe == TOK_VARIABLE)
        {
            dico[index].Is_used = 1;}}
}

void checkUtiliseWar(char* identif,int ligne) {
    int b1 = base ;
    int index = recherche(identif) ;
    if (index == -1)
        {base = 0 ;
        int index2 = recherche(identif) ;
        if (index2 == -1)
            erreurFatale("variable non declaree",ligne);
        else 
        {
            if ((dico[index2].Is_used != 1) && (dico[index2].Classe == TOK_VARIABLE))
                warning("variable non utilisee", ligne);}
         }
    else
        {
        if ((dico[index].Is_used != 1) && (dico[index].Classe == TOK_VARIABLE))
            warning("variable non utilisee",ligne) ;}
    base = b1 ;
}

// * Contrainte supplémentaire : Vérifier qu'une fonction qui retourne un type contient return

void checkReturn(char * type , char * return_char , int ligne){
    if (strcmp(type, "void") != 0)
        {
        if (strcmp(return_char, "return") != 0)
            erreurFatale("missing return", ligne);}
    else 
        {
        if (strcmp(return_char, "return") == 0)
            erreurFatale("unnecessary return", ligne);}
}