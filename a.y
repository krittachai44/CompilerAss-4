/* Infix notation calculator.  */

%{
  #include <math.h>
  #include <stdio.h>
  int yylex (void);
  void push (int data);
  int pop (void);
  int bitwistop(int num1, int num2, char *op);
  int hextodec();
  int showTop();
  int temp;
  int temp2;
  int acc;
  int r[26];
  int top;
  int size;
  int stack[1000];
  int topStack;
  int hex[10];
%}
/* Bison declarations.  */

%token SHOW
%token LOAD
%token POP
%token PUSH
%token ACC

%token RA
%token RB
%token RC
%token RD
%token RE
%token RF
%token RG
%token RH
%token RI
%token RJ
%token RK
%token RL
%token RM
%token RN
%token RO
%token RP
%token RQ
%token RR
%token RS
%token RT
%token RU
%token RV
%token RW
%token RX
%token RY
%token RZ

%token TOP
%token SIZE
%token NUM
%token HEX

%token AND
%token OR
%token NOT

%token IF
%token ELSE

%token EXIT
%token str
%define api.value.type {double}
%left '-' '+'
%left '*' '/' '\\'
%precedence NEG   /* negation--unary minus */
%right '^'        /* exponentiation */



%% /* The grammar follows.  */
input: %empty
  | input line  { printf ("> "); }
  | error       { yyerror(); }
  ;

line: '\n'
  | exp '\n'                { acc = $1; printf ("= %.10g\n", $1); }
  | SHOW show '\n'          { printf("\n");}
  | LOAD load '\n'
  | PUSH reg '\n'           { temp = $2; push(r[temp-263]); }
  | PUSH nonEditReg '\n'    { temp = $2; push(temp); }
  | POP reg '\n'            { temp = $2; r[temp-263] = pop(); }
  | EXIT '\n'               { exit(0); }
  | str '\n'                { yyerror(); }
 ;

exp:  NUM     { $$ = $1; }
  | HEX       { $$ = $1; }
  | reg       { temp = $1;
                $$ = r[temp-263];
              }
  | nonEditReg  { temp = $1;
                  $$ = temp;
                }
  | exp '+' exp   { $$ = $1 + $3; }
  | exp '-' exp   { $$ = $1 - $3; }
  | exp '*' exp     { $$ = $1 * $3; }
  | exp '/' exp     { $$ = $1 / $3; }
  | exp '\\' exp      { $$ = fmod ($1, $3); }
  | '-' exp  %prec NEG  { $$ = -$2; }
  | exp '^' exp     { $$ = pow ($1, $3); }
  | '(' exp ')'     { $$ = $2;
                acc = $$;
              }
  | exp AND exp {
      temp = $1;
      temp2 = $3;
      $$ = bitwistop(temp, temp2, "and"); }
  | exp OR exp {
      temp = $1;
      temp2 = $3;
      $$ = bitwistop(temp, temp2, "or"); }
  | NOT exp {
      temp = $2;
      $$ = bitwistop(temp, 0, "not"); }
  | IF ( exp )
;

show: reg     { temp = $1;  printf("= %d",r[temp-263]); }
  | nonEditReg { temp = $1;  printf("= %d",temp); }
;

load: reg reg      { temp=$1; temp2=$2; r[temp2-263] = r[temp-263]; }
  | nonEditReg reg  { temp=$2; r[temp-263] = $1; }
  | reg nonEditReg { yyerror(); }
;

nonEditReg: ACC   { $$ = acc; }
  | TOP     { $$ = showTop();   }
  | SIZE    { $$ = size;  }
;

reg: RA      { $$ = RA; }
  | RB      { $$ = RB; }
  | RC      { $$ = RC; }
  | RD      { $$ = RD; }
  | RE      { $$ = RE; }
  | RF      { $$ = RF; }
  | RG      { $$ = RG; }
  | RH      { $$ = RH; }
  | RI      { $$ = RI; }
  | RJ      { $$ = RJ; }
  | RK      { $$ = RK; }
  | RL      { $$ = RL; }
  | RM      { $$ = RM; }
  | RN      { $$ = RN; }
  | RO      { $$ = RO; }
  | RP      { $$ = RP; }
  | RQ      { $$ = RQ; }
  | RR      { $$ = RR; }
  | RS      { $$ = RS; }
  | RT      { $$ = RT; }
  | RU      { $$ = RU; }
  | RV      { $$ = RV; }
  | RW      { $$ = RW; }
  | RX      { $$ = RX; }
  | RY      { $$ = RY; }
  | RZ      { $$ = RZ; }
;

%%
#include <ctype.h>

void
push (int data)
{
  stack[topStack++] = data;
  top = data;
  size++;
}

int
pop (void)
{
  if(topStack>0){
    acc = stack[--topStack];
    top = stack[topStack];
    size--;
    return acc;
  }else{
    yyerror();
    return 0;
  }
}
int showTop()
{
  if(topStack>0){
    return top;
  }else{
    yyerror();
    return 0;
  }
}
int bitwistop(int num1, int num2, char *op){
  int ret;
  if(op == "and"){
    ret = num1 & num2;
  }
  else if(op == "or"){
    ret = num1 | num2;
  }
  else if(op == "not"){
    ret = ~num1;
  }
  return ret;
}

int hextodec(char *hex){
  int ret;
  return ret;
}

int
main (void)
{
  while(1){
  	printf("> ");
  	return yyparse ();
  }
}
