%{
	

#include <stdio.h>	
#include "GenCode.c"

int yyerror(char const *msg);	
int yylex(void);

extern int yylineno;
int nbParam = 0 ;
int nbParamExp = 0 ;
char funId[256] = "newFun" ;
char funType[10] = "void" ;

// the variable nom will stock the name of an identifier
char nom [256];
char type [10];
int intValue;
char operSymbol [10];
int index;
int codeTabIndex;
int beginOfWhile;
int calledMethodIndex;
int backToMainIndex;
char calledMethodName [50];
//------------- THIS BLOCK IS FOR METHODS HANDELING---------------------
char methodName [50];
char * mehtodArgs [50];
int nbArgs=0;
int nbCalledArgs=0;
//----------------

%}

%union {
  int ival;
  char* sval;
}

%token MC_IF 
%token MC_ELSE 
%token MC_WHILE 
%token MC_CLASS 
%token MC_EXTENDS 
%token <sval> MC_RETURN 
%token MC_NEW 
%token MC_THIS 
%token MC_PRINT 
%token MC_LENGTH 
%token MC_PUBLIC 
%token <sval> MC_VOID 
%token MC_MAIN_CLASS 
%token <ival> INTEGER_LITERAL
%token <sval> id
%token <sval> Type
%token String_Tab
%token <sval> Operation
%token Parenthese_Ouvrante
%token Parenthese_Fermante
%token ACCOLADE_Ouvrante
%token ACCOLADE_Fermante
%token Crochet_Ouvrante
%token Crochet_Fermante
%token BOOLEAN_LITERAL
%token POINT_VIRGULE
%token Op_Aff
%token POINT
%token VIRGULE

%error-verbose
%start Program

%%

param_list : param_list VIRGULE id {nbParamExp++ ; checkInitialise($3,yylineno) ;Initialiser($3,yylineno) ; yyerrok;}
           |  param_list VIRGULE INTEGER_LITERAL {nbParamExp++ ; }
           | id {nbParamExp=1 ; checkInitialise($1,yylineno) ;Initialiser($1,yylineno) ; yyerrok;}
           | INTEGER_LITERAL {nbParamExp=1 ;}
           

Expression           :  id Operation id {
                          int index =  recherche($1);
                            addCode("LDV",index,"");
                            strcpy(operSymbol,$2);
                          int index2 =  recherche($3);
                          addCode("LDV",index2,"");
                          } 
                        | INTEGER_LITERAL  {
                          addCode("LDC",$1,"");
                        }  
                        | BOOLEAN_LITERAL
                        | id Operation INTEGER_LITERAL {
                            int index =  recherche($1);
                            strcpy(operSymbol,$2);
                            addCode("LDV",index,"");
                            addCode("LDC",$3,"");
                          }
                        | INTEGER_LITERAL Operation id  {
                            addCode("LDC",$1,"");
                            strcpy(operSymbol,$2);
                            int index =  recherche(nom);
                            addCode("LDV",index,"");
                          }  
                        | Expression Operation Expression 
                           {strcpy(operSymbol,$2);}
                        | Expression Crochet_Ouvrante Expression Crochet_Fermante 
                        | Expression POINT MC_LENGTH
                        | Expression POINT id {
                              calledMethodIndex=nbCodes;
                              strcpy(calledMethodName,$3);
                              addCode("APPEL",11111,calledMethodName);
                              backToMainIndex=nbCodes;
                            } Parenthese_Ouvrante param_list Parenthese_Fermante {checkNbParameters(calledMethodName,nbParamExp,yylineno) ; nbParamExp--; nbParamExp = 0 ; yyerrok; }   
                        | Expression POINT id 
                        {
                              calledMethodIndex=nbCodes;
                              strcpy(calledMethodName,$3);
                              addCode("APPEL",11111,calledMethodName);
                              backToMainIndex=nbCodes;
                        } Parenthese_Ouvrante expression_list Parenthese_Fermante {checkNbParameters(calledMethodName,nbParamExp,yylineno) ; nbParamExp--; nbParamExp = 0 ; yyerrok; } 
                        | id {nbParamExp++ ; checkInitialise($1,yylineno) ;Initialiser($1,yylineno) ; yyerrok;
                          index= recherche($1);
                          addCode("LDV",index,"");
                        }  
                        | MC_THIS
                        | MC_NEW INTEGER_LITERAL Crochet_Ouvrante Expression Crochet_Fermante
                        | MC_NEW id Parenthese_Ouvrante Parenthese_Fermante
                        | '!' Expression
                        | Parenthese_Ouvrante Expression Parenthese_Fermante ;

expression_list : expression_list VIRGULE Expression 
                | Expression ;
                 

Statement : ACCOLADE_Ouvrante Statement_list ACCOLADE_Fermante
          | ACCOLADE_Ouvrante VarDeclaration_list Statement_list ACCOLADE_Fermante
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

          | MC_PRINT Parenthese_Ouvrante Expression Parenthese_Fermante POINT_VIRGULE 
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
          | id Crochet_Ouvrante Expression Crochet_Fermante Op_Aff Expression POINT_VIRGULE {checkUtilise($1,yylineno); Initialiser($1,yylineno) ; yyerrok;}

Statement_list : | Statement_list Statement     

type_list :  Type id { nbParam = 1 ; ajouterEntree(funId,TOK_FUNCTION,funType,0,0,nbParam,yylineno); checkIdentifier($2,TOK_PARAMETER,$1,0,0,0,yylineno); yyerrok; }
          | type_list VIRGULE Type id {nbParam++ ; checkIdentifier($4,TOK_PARAMETER,$3,0,0,0,yylineno); modifNbParam(funId,nbParam) ; yyerrok; }
          
type_function : | type_list
VarDeclaration : Type id POINT_VIRGULE VarDeclaration_list { checkIdentifier($2, TOK_VARIABLE, $1, 0, 0, 0, yylineno); checkUtiliseWar($2,yylineno) ; yyerrok;}
               | Type id  {yyerror (" Missing ; on line : "); YYABORT}
               | Type POINT_VIRGULE {yyerror (" Missing id on line : "); YYABORT}

VarDeclaration_list :  VarDeclaration |


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

MethodDeclaration_list :   MethodDeclaration |

class_extend : | MC_EXTENDS id
               | MC_EXTENDS {yyerror (" Missing id on line : "); YYABORT}
               |  id {yyerror (" Missing 'extends' on line : "); YYABORT}

ClassDeclaration : MC_CLASS id class_extend ACCOLADE_Ouvrante VarDeclaration_list MethodDeclaration_list ACCOLADE_Fermante ClassDeclaration_list
               | MC_CLASS class_extend ACCOLADE_Ouvrante VarDeclaration_list MethodDeclaration_list ACCOLADE_Fermante ClassDeclaration_list {yyerror (" Missing class id on line : "); YYABORT ; }
               | id class_extend ACCOLADE_Ouvrante VarDeclaration_list MethodDeclaration_list ACCOLADE_Fermante ClassDeclaration_list {yyerror (" Missing 'class' on line : "); YYABORT ; }
               | MC_CLASS id class_extend ACCOLADE_Ouvrante VarDeclaration_list MethodDeclaration_list ClassDeclaration_list  {yyerror (" Missing '}' on line : "); YYABORT ; }
               | MC_CLASS id class_extend VarDeclaration_list MethodDeclaration_list ACCOLADE_Fermante ClassDeclaration_list {yyerror (" Missing '{' on line : "); YYABORT ;}

ClassDeclaration_list :   ClassDeclaration |

MainClass : MC_CLASS id ACCOLADE_Ouvrante MC_MAIN_CLASS Parenthese_Ouvrante String_Tab id {checkIdentifier($7, TOK_PARAMETER,"String[]", 0, 0, 0, yylineno);}
Parenthese_Fermante ACCOLADE_Ouvrante {  addCode("ENTREE",-1,"main");  } 
VarDeclaration_list Statement ACCOLADE_Fermante ACCOLADE_Fermante { checkUtiliseWar($7,yylineno) ; yyerrok;  addCode("SORTIE",-1,"main"); }

Program	  :  MainClass  ClassDeclaration { printCodeTab(); }


%% 

int yyerror(char const *msg) {
       
	
	fprintf(stderr, "%s %d\n", msg,yylineno);
	return 0;
	
	
}

extern FILE *yyin;

int main()
{
 yyparse();
 
 
}

  
                   
