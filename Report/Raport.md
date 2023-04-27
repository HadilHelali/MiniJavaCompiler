### GenCode.c 
1. on définit la structure `ENTREE_CODE` comme suit : 
``` C
    typedef struct
{
    char code_op[50]; // nom de la commande par exemple STORE, LDC, LDV…
    int operande;  // soit  une valeur constante à charger soit l’adresse dans ka table de symbole
    char nomFct[50]; // le nom d’une fonction / procédure.
} ENTREE_CODE;
```
Et on construit la table `codeTabInt` de `ENTREE_CODE` <br/>
Pour manipuler cette table on impléménte : 
* **La méthode** `addCode` qui permet d’ajouter le code générer dans la table 
*	**La méthode** `printCodeTab` pour afficher le contenu de la table 
*	**La méthode** `addOperator` pour traduire le code entré en code machine pour les opérations 

### Semantique.c
En parcourant le programme du fichier yacc , on injecte les fonctions générant le code machine au niveau des différents déclarations de fonctions , de variables , des expressions , des statements et des classes.
* Pour le bloc **IF** et **IF .. ELSE** : 
``` yacc
          | MC_IF Parenthese_Ouvrante Expression Parenthese_Fermante 
          {
              addOperator(operSymbol);
              addCode("SIFAUX",9999,"");
              codeTabIndex=nbCodes-1;
            } Statement MC_ELSE 
            {
              addCode("SAUT",3333,"");
              codeTabInt[codeTabIndex].operande=nbCodes;
              codeTabIndex=nbCodes-1;
              }
               Statement
              {
              codeTabInt[codeTabIndex].operande=nbCodes;
               }
          | MC_IF Parenthese_Ouvrante Expression Parenthese_Fermante 
          {
              addOperator(operSymbol);
              addCode("SIFAUX",9999,"");
              codeTabIndex=nbCodes-1;
            } Statement 
```
* Pour le bloc **WHILE ..** : 
``` yacc
| MC_WHILE Parenthese_Ouvrante 
           {
              beginOfWhile=nbCodes;
            } 
            Expression Parenthese_Fermante {
              addCode("TANTQUEFAUX",2000,"");
              codeTabIndex=nbCodes-1;
            }
            Statement
            {
              addCode("TANTQUE",2000,"");
              codeTabInt[codeTabIndex].operande=nbCodes;
              codeTabInt[nbCodes-1].operande= beginOfWhile ;
            }
```

* Pour le bloc de **fonction** : 
``` yacc
MethodDeclaration : MC_PUBLIC MC_VOID id {
                        strcpy(funType,$2);
                        codeTabInt[calledMethodIndex].operande = nbCodes;
                        strcpy(methodName,$3);
                        strcpy(funId,methodName);
                        addCode("ENTREE",-1,methodName);
                    } 
                    Parenthese_Ouvrante type_function Parenthese_Fermante ACCOLADE_Ouvrante VarDeclaration_list Statement_list ACCOLADE_Fermante MethodDeclaration_list { if (nbParam == 0) ajouterEntree(methodName,TOK_FUNCTION,"void",0,0,nbParam,yylineno); /*AfficherTab() ;*/ DestroyLocalDic(); nbParam = 0 ;yyerrok;
                      addCode("SORTIE",-1,methodName);
                      addCode("RETOUR",backToMainIndex,"");}
                    | MC_PUBLIC Type id
                    {   
                        strcpy(funType,$2);
                        codeTabInt[calledMethodIndex].operande = nbCodes;
                        strcpy(methodName,$3);
                        strcpy(funId,methodName);
                        addCode("ENTREE",-1,methodName);
                      } 
                    Parenthese_Ouvrante type_function Parenthese_Fermante ACCOLADE_Ouvrante VarDeclaration_list Statement_list MC_RETURN Expression POINT_VIRGULE ACCOLADE_Fermante MethodDeclaration_list { if (nbParam == 0) ajouterEntree(methodName,TOK_FUNCTION,funType,0,0,nbParam,yylineno); /*AfficherTab();*/ DestroyLocalDic(); nbParam = 0 ;yyerrok;
                      addCode("SORTIE",-1,methodName);
                      addCode("RETOUR",backToMainIndex,"");}
```
* Pour ajouter les **opérations** : (Au niveau de la règle **Statement**)
``` yacc
          | id 
          {
              index= recherche($1);
          }
            Op_Aff Expression POINT_VIRGULE { checkUtilise($1,yylineno); Initialiser($1,yylineno) ; yyerrok;

              if (!strcmp(operSymbol,"*")){
                addCode("MUL",-1,"");                
              }
              else if (!strcmp(operSymbol,"+")){
                addCode("ADD",-1,""); 
              }
              else if (!strcmp(operSymbol,"-")){
                addCode("SUB",-1,""); 

              }
              else if (!strcmp(operSymbol,"<")){
                addCode("INF",-1,""); 

              }
              addCode("STORE ",index,"");
             }
```
A la fin du programme , on fait appel à la fonction `printCodeTab()` pour afficher le code machine généré :
``` yacc
Program	  :  MainClass  ClassDeclaration { printCodeTab(); }
```
