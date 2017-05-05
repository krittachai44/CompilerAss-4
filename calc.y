
%{
	#include "heading.h"
	#include <math.h>
	#include <string.h>

	int yyerror(char *s);
	int yylex(void);
	int xtoi(char *hexstring);
	int regToInt(string* regname);

	void loadToReg(int vval, string* regname);
	void SHOWSTRING(string* str);

	void funtionIF(int con,int stat1);
	void funtionIFELSE(int con,int stat1,int stat2);
	void funtionLOOP(int con,int stat1);


	char* cat(char* old,char* nw); // concast string

	int reg[26] = {0};
	int size = 0;
	int top = 0;
	int acc = 0;

	int isReg = 0;
	int inregTo = 0;
	int countString = 0;
	char *header="";
	char *inmain="";

%}

%union{
	int		int_val;
	string*	op_val;
}

%start	input

%token	<int_val>	INTEGER_LITERAL
%token	<op_val>	REGISTER
%token	<op_val>	STRING


%type	<int_val>	exp
%type	<int_val>	condition
%type	<op_val>	loop
%type	<int_val>	compare
%type	<int_val>	init
%type	<int_val>	command


%token	IF ELSE
%token	FORWARD
%token  INIT SHOW_DEC

%left	PLUS MINUS
%left	MULT DIV MOD
%left	COMPARE
%left	OR
%left	AND
%left	NOT
%left	NEG

%left	EXIT


%%

input:		/* empty */
| exp	{ cout << "= " << $1 << endl;  }
| compare
| loop
| init
| STRING { SHOWSTRING($1); }
| EXIT {return 4;}
;
//char* temp = (char *)malloc(strlen("\taddl\t$%d,\t%d(%%rbp)"),$1,$2);
exp:		REGISTER 	{$$ = regToInt($1);}
// movl	-8(%rbp), %eax
|INTEGER_LITERAL{ $$ = $1; }
| exp PLUS exp	{ $$ = $1 + $3; }
/*
how to know exp is register or just value?????????
regis + regis

char* temp = (char *)malloc(strlen("\tmovl\t%d(%%rbp), %%eax\n
\taddl\t%%eax, %d(%%rbp)");
sprintf(temp,"\tmovl\t%d(%%rbp), %%eax\n
\taddl\t%%eax, %d(%%rbp)",);

movl	-4(%rbp), %eax
addl	%eax, -8(%rbp)
*/
/*
val + val
use loadToReg($1+$3,) end
movl	$val+val, -4(%rbp)
*/
/*
val + regis same regis + val

movl	-4(%rbp), %eax
addl	$5, %eax
movl	%eax, -4(%rbp)
*/

| exp MINUS exp	{ $$ = $1 - $3; }

/*
movl	-4(%rbp), %eax
subl	%eax, -8(%rbp)

movl	$-1, -8(%rbp)

movl	-8(%rbp), %eax
subl	$2, %eax
movl	%eax, -4(%rbp)
*/
| exp MULT exp	{ $$ = $1 * $3; }
| exp DIV exp	{ $$ = $1 / $3; }
| exp MOD exp	{ $$ = $1 % $3; }
| exp OR exp	{ $$ = $1 | $3; }
| exp AND exp	{ $$ = $1 & $3; }
| NOT exp 	{ $$ = ~$2 ; }
| MINUS exp  %prec NEG { $$ = -$2;}
| '(' exp ')'        { $$ = $2;}
| condition
| command
;

condition:	exp COMPARE exp		{ $$ = $1== $3?1:0;}
| exp '<' exp		{ $$ = $1 < $3?1:0;}
| exp '>' exp		{ $$ = $1 > $3?1:0;}
;

compare:	IF '(' exp ')' '{' exp '}'  					{funtionIF($3,$6);}
| IF '(' exp ')' '{' REGISTER INIT exp '}'  			{if($3){loadToReg($8,$6);}}
| IF '(' exp ')' '{' exp '}' ELSE '{' exp '}'			{funtionIFELSE($3,$6,$10);}
| IF '(' exp ')' '{' exp '}' ELSE '{' REGISTER INIT exp '}'
{ if($3) printf("%d\n",$6); else loadToReg($12,$10); }
| IF '(' exp ')' '{' REGISTER INIT exp '}' ELSE '{' exp '}'
{ if($3) loadToReg($8,$6); else printf("%d\n",$12); }
| IF '(' exp ')' '{' REGISTER INIT exp '}' ELSE '{' REGISTER INIT exp '}'	{if($3){loadToReg($8,$6);}else{loadToReg($14,$12);}}
;

loop:		FORWARD '(' exp ',' exp ')' 			{funtionLOOP($3,$5);}
//| FORWARD'('exp ',' FORWARD'('exp','exp')'')'
;

command:	SHOW_DEC exp 				{
	/*

	movl	-4(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC0, %edi
	movl	$0, %eax
	call	printf
	if(exp == val){

	}
	if(exp == register){

	}
*/
$$=$2;
}
;

init:		REGISTER INIT exp 			{loadToReg($3,$1);}
;

%%

void funtionIF(int con,int stat1)
{
	if(con) printf("%d\n",stat1);
}
void funtionIFELSE(int con,int stat1,int stat2)
{
	if(con) printf("%d\n",stat1);
	else printf("%d\n",stat2);
}

void funtionLOOP(int con,int stat1)
{
	/*
	movl	$0, -8(%rbp)
	jmp	.L2
	.L3:
	addl	$1, -12(%rbp)
	addl	$1, -8(%rbp)
	.L2:
	cmpl	$4, -8(%rbp)
	jle	.L3
	*/
	//char *temp = (char *)malloc(strlen("/tmov/t"));

	int i=0;
	for(;i<con;i++)
	{
		printf("%d\n",stat1);
	}
}


char* cat(char* old,char* nw){
	int a = strlen(old);
	int b = strlen(nw);
	int sum = a + b + 1;
	char *tmp = (char *)malloc(sum);
	strcpy(tmp,old);
	strcat(tmp,nw);
	return tmp;
}

void SHOWSTRING(string* str)
{
	char a[100];
	strcpy(a,(*str).c_str());
	int notNum = 0;
	int len = strlen((*str).c_str());
	int i;
	for (i = 7; i < len; i++)
    {
        if (!isdigit(a[i])) {
			notNum = 1;
			break;
		}
    }

	a[(*str).length()+1] = '^';

	/*
	header	.LCCountString:
	.string	"xxx"

	*/
	char* temp = (char *)malloc(strlen("\n\tmovl\t$.LC%d, %%edi\n"));
	sprintf(temp,"\tmovl\t$.LC%d, %%edi\n",countString);
	inmain = cat(inmain,temp);

	temp = (char *)malloc(strlen("\tmovl\t$%d, %%eax\n\tcall\tprintf\n"));
	sprintf(temp,"\tmovl\t$0, %%eax\n\tcall\tprintf\n");
	inmain = cat(inmain,temp);

	//header
	temp = (char *)malloc(strlen("\n.LC%d\n\t.string\t\""));
	sprintf(temp,".LC%d\n\t.string\t\"",countString);
	header = cat(header,temp);

	/*movl	-4(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC0, %edi
	movl	$0, %eax
	call	printf*/

	i = 7;
	while(a[i] != '^')
	{
		if(a[i]=='N'&&a[i+1]=='E'&&a[i+2]=='W'&&a[i+3]=='L'&&a[i+4]=='I'&&a[i+5]=='N'&&a[i+6]=='E'){
			//header
			temp = (char *)malloc(strlen("\n"));
			sprintf(temp,"\n");
			header = cat(header,temp);
			i+=6;
		}
		else if( a[i]=='#'&&a[i+1]=='r'&&a[i+2]=='e'&&a[i+3]=='g'&&a[i+4]>='A'&&a[i+4]<='Z'){
			//header
			temp = (char *)malloc(2);
			sprintf(temp,"%%d");
			header = cat(header,temp);
			//inmain
			temp = (char *)malloc(strlen("\tmovl\t%d(%%rbp), %%eax\n\tmovl\t%%eax, %%esi\n"));
			sprintf(temp,"\tmovl\t%d(%%rbp), %%eax\n\tmovl\t%%eax, %%esi\n",((a[i+4]-'A')*7)+100);
			inmain = cat(inmain,temp);
			i+=4;
		}
		else{
			if(notNum){
				temp = (char *)malloc(strlen("%%d")); // malloc for any character
				//header
				sprintf(temp,"%%d");
				header = cat(header,temp);
			}
			else{
				temp = (char *)malloc(2);
				sprintf(temp,"%%d");
				header = cat(header,temp);
			}
		}
		i++;
	}
	//header
	temp = (char *)malloc(strlen("\"\n"));
	sprintf(temp,"\"\n");
	header = cat(header,temp);

	printf("%s",header);
	printf("%s",inmain);
	/*
	main	movl	$.LC0, %edi
	movl	$0, %eax
	call	printf
	*/

	countString++;
	/*
	/*i=7;
	while(a[i] != '^')
	{
	if(a[i]=='N'&&a[i+1]=='E'&&a[i+2]=='W'&&a[i+3]=='L'&&a[i+4]=='I'&&a[i+5]=='N'&&a[i+6]=='E')
	{
	printf("\n");
	i+=6;
}
else if( a[i]=='#'&&a[i+1]=='r'&&a[i+2]=='e'&&a[i+3]=='g'&&a[i+4]>='A'&&a[i+4]<='Z')
{ printf("%d",reg[a[i+4]-'A']); i+=4; }
else
printf("%c",a[i]);
i++;
}
printf("\n");*/
}



int yyerror(string s)
{
	extern char *yytext;
	printf("\r! ERROR : SYNTAX ERROR\n");

	yyparse();
}

int yyerror(char *s)
{
	return yyerror(string(s));
}

int xtoi(char *hexstring)
{
	int	i = 0;

	while (*hexstring)
	{
		char c = toupper(*hexstring++);

		if ((c=='H') && ((c < '0') || (c > 'F') || ((c > '9') && (c < 'A'))))
		break;

		c -= '0';

		if (c > 9)
		c -= 7;

		i = (i << 4) + c;
	}
	return i;
}

int regToInt(string* regname)
{
	char cregname[10];
	strcpy(cregname, (*regname).c_str());

	// movl	-8(%rbp), %eax
	char* temp = (char *)malloc(strlen("\tmovl\t%d(%%rbp), %%eax\n"));
	sprintf(temp,"\tmovl\t%d(%%rbp), %%eax\n",((cregname[4]-'A')*7)+100);
	inmain = cat(inmain,temp);
	//printf("%s",inmain);
	isReg = 1;
	inregTo = 1;
	return reg[cregname[4]-'A'];
}

void loadToReg(int vval, string* regname)
{
	char cregname[10];
	strcpy(cregname, (*regname).c_str());
	int regVal;
	regVal = cregname[4]-'A';

	if(inregTo){
		// movl	%eax, -4(%rbp)
		char* temp = (char *)malloc(strlen("\tmovl\t%%eax, %d(%%rbp)\n"));
		sprintf(temp,"\tmovl\t%%eax, %d(%%rbp)\n",((cregname[4]-'A')*7)+100);
		inmain = cat(inmain,temp);
	}
	else{
		//movl	$2, -4(%rbp)  // #regA INIT 2
		char* temp = (char *)malloc(strlen("\tmovl\t$%d, %d(%%rbp)\n"));
		sprintf(temp,"\tmovl\t$%d, %d(%%rbp)\n",vval,((cregname[4]-'A')*7)+100);
		inmain = cat(inmain,temp);
	}
	isReg = 0;
	inregTo = 0;
	printf("%s",inmain);

	//	printf("\tmovl\t$%d, %d(%rbp)\n",vval,(regVal*7)+100);
	reg[cregname[4]-'A'] = vval;

}
