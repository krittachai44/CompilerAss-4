D [0-9]
C [0-9a-zA-Z]
H [0-9a-fA-F]

%{

#include <stdlib.h>
#include <string.h>
#include "y.tab.h"


%}

%%

  "\n"    { return '\n'; }
  " "     { }
  "\t"    { }


  "SHOW"  { return SHOW; }
  "LOAD"  { return LOAD; }
  "PUSH"  { return PUSH; }
  "POP"   { return POP; }

  "$acc"  { return ACC; }
  "$top"  { return TOP; }
  "$size" { return SIZE; }

  "+"     { return '+'; }
  "-"     { return '-'; }
  "*"     { return '*'; }
  "/"     { return '/'; }
  "("     { return '('; }
  ")"     { return ')'; }
  "\\"    { return '\\'; }
  "^"     { return '^'; }

  "AND"   { return AND; }
  "OR"    { return OR; }
  "NOT"   { return NOT; }

  "IF"    { return IF; }
  "ELSE"  { return ELSE; }

  "$rA"   { return RA; }
  "$rB"   { return RB; }
  "$rC"   { return RC; }
  "$rD"   { return RD; }
  "$rE"   { return RE; }
  "$rF"   { return RF; }
  "$rG"   { return RG; }
  "$rH"   { return RH; }
  "$rI"   { return RI; }
  "$rJ"   { return RJ; }
  "$rK"   { return RK; }
  "$rL"   { return RL; }
  "$rM"   { return RM; }
  "$rN"   { return RN; }
  "$rO"   { return RO; }
  "$rP"   { return RP; }
  "$rQ"   { return RQ; }
  "$rR"   { return RR; }
  "$rS"   { return RS; }
  "$rT"   { return RT; }
  "$rU"   { return RU; }
  "$rV"   { return RV; }
  "$rW"   { return RW; }
  "$rX"   { return RX; }
  "$rY"   { return RY; }
  "$rZ"   { return RZ; }

  {D}+    { yylval = atoi(yytext);	return NUM; }
  {H}+"h" { yylval = (int)strtol(yytext, NULL, 16);  return NUM; }
  {C}+    { return str; }
  "exit"  { return EXIT; }
  .       { } // Ignore bad characters


%%

int yywrap(void){
  return 0;
}

int yyerror(void){
  printf("! ERROR\n");
}
