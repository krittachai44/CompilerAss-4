
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

	void addtoReg(string* in);
	void addtoReg(int in);

	void showDec(void);
	void headerPercentD();

	void initINloop(int count,string* regin,char oop,int val);

	char* cat(char* old,char* nw); // concast string

	int reg[26] = {0};
	int size = 0;
	int top = 0;
	int acc = 0;

	int isReg = 0;
	int inregTo = 0;
	int countString = 0;
	int lcPercentD = 0;
	char *header="";
	char *inmain="";
	char *temp="";

	int r[13]={0};//r0-r12
	int cReg = 0;
	int alreadyP = 0;
	int cLX = 0;

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
%left	NEG

%left	EXIT


%%

input:		/* empty */
| exp	{ cout << "= " << $1 << endl; cReg = 0;}
| compare {cReg= 0;}
| loop	{cReg= 0;}
| init	{cReg= 0;}
| STRING { SHOWSTRING($1);
	/*movl	$.LC0, %edi
		movl	$0, %eax
		call	printf*/ cReg= 0;}
| EXIT {printf("%s\n",header); printf("%s\n",inmain);return 4;}
;
//char* temp = (char *)malloc(strlen("\taddl\t$%d,\t%d(%%rbp)"),$1,$2);
exp:		REGISTER	{ addtoReg($1); $$ = regToInt($1); }
// movl	-8(%rbp), %eax
|INTEGER_LITERAL{ addtoReg($1); $$ = $1; cReg = 1;}
| exp PLUS exp	{ $$ = $1 + $3;
				temp = (char *)malloc(strlen("	addl	r1, r0\n"));
				sprintf(temp,"	addl	r1, r0\n\n");
				inmain = cat(inmain,temp);

				cReg = 1; r[0] = $$;
				}
| exp MINUS exp	{ $$ = $1 - $3;
				temp = (char *)malloc(strlen("	subl	r1, r0\n"));
				sprintf(temp,"	subl	r1, r0\n\n");
				inmain = cat(inmain,temp);

				cReg = 1; r[0] = $$;
				}
| exp MULT exp	{ $$ = $1 * $3;
				// 	movl	-8(%rbp), %eax
				// imull	-4(%rbp), %eax
				// movl	%eax, -8(%rbp)

				temp = (char *)malloc(strlen("\tmovl\tr0, %%eax\n\timull	r1, %%eax\n\tmovl\t%%eax, r0\n\n"));
				sprintf(temp,"\tmovl\tr0, %%eax\n\timull	r1, %%eax\n\tmovl\t%%eax, r0\n\n");
				inmain = cat(inmain,temp);

				cReg = 1; r[0] = $$;}
| exp DIV exp	{ $$ = $1 / $3;
				/*
				movl	-8(%rbp), %eax
				cltd
				idivl	-4(%rbp)
				movl	%eax, -8(%rbp)
				*/
				temp = (char *)malloc(strlen("	movl	r0, %%eax\n\tcltd\n\tidivl	r1\n\tmovl\t%%eax, r0\n"));
				sprintf(temp,"	movl	r0, %%eax\n\tcltd\n\tidivl	r1\n\tmovl\t%%eax, r0\n\n");
				inmain = cat(inmain,temp);
				cReg = 1; r[0] = $$;
				}
| exp MOD exp	{ $$ = $1 % $3;
				// 	movl	-8(%rbp), %eax
				// cltd
				// idivl	-4(%rbp)
				// movl	%edx, -8(%rbp)
				temp = (char *)malloc(strlen("	movl	r0, %%eax\n\tcltd\n\tidivl	r1\n\tmovl\t%%eax, r0\n"));
				sprintf(temp,"	movl	r0, %%eax\n\tcltd\n\tidivl	r1\n\tmovl\t%%eax, r0\n\n");
				inmain = cat(inmain,temp);
				cReg = 1; r[0] = $$;
				}
| MINUS exp  %prec NEG { 	$$ = -$2;
							cReg--;
							int tempR = r[cReg]*2;

							temp = (char *)malloc(strlen("	subl	$%d, r%d\n"));
							sprintf(temp,"	subl	$%d, r%d\n",tempR,cReg);
							inmain = cat(inmain,temp);

							cReg = 1; r[0] = $$;
						}
| '(' exp ')'        { $$ = $2;}
| condition			{ cReg= 0; }
| command
;

condition:	exp COMPARE exp		{
						// 		cmpl	$1, -8(%rbp)
						// 		jne		.L2
								temp = (char *)malloc(strlen("\tcmpl\tr%d, r%d\n"));
								sprintf(temp,"\tcmpl\tr%d, r%d\n",cReg,cReg-1);
								inmain = cat(inmain,temp);

								temp = (char *)malloc(strlen("\tjne\t.L%d\n"));
								sprintf(temp,"\tjne\t.L%d\n",2+cLX);
								inmain = cat(inmain,temp);

								$$=$1==$3?1:0; cReg=0;}
;

compare:	IF '(' condition ')' '{' exp '}'  		{ funtionIF($3,$6);}
| IF '(' condition ')' '{' REGISTER INIT exp '}'  	{ 	if($3){loadToReg($8,$6);}

														temp = (char *)malloc(strlen("	movl	r0, %d(%%rbp)\n\n"));
														char a[100];
														strcpy(a,(*$6).c_str());
														sprintf(temp,"	movl	r0, %d(%%rbp)\n\n",((a[4]-'A')*8)+200);
														inmain = cat(inmain,temp);

														temp = (char *)malloc(strlen(".L%d\n"));
														sprintf(temp,".L%d\n",2+cLX);
														inmain = cat(inmain,temp);
														cLX += 1;
													}
| IF '(' condition ')' '{' exp '}' ELSE '{' SHOW_DEC exp '}'	{ funtionIFELSE($3,$6,$11);}
| IF '(' condition ')' '{' exp '}' ELSE '{' REGISTER INIT exp '}'
{
	if($3==0)loadToReg($12,$10);

	temp = (char *)malloc(strlen(".L%d\n"));
	sprintf(temp,".L%d\n",2+cLX);
	inmain = cat(inmain,temp);

	temp = (char *)malloc(strlen("	movl	%d,r0\n\n"));
	sprintf(temp,"	movl	%d,r0\n",$12);
	inmain = cat(inmain,temp);

	temp = (char *)malloc(strlen("	movl	r0, %d(%%rbp)\n\n"));
	char a[100];
	strcpy(a,(*$10).c_str());
	sprintf(temp,"	movl	r0, %d(%%rbp)\n\n",((a[4]-'A')*8)+200);
	inmain = cat(inmain,temp);

	cLX += 1;

}
| IF '(' condition ')' '{' REGISTER INIT exp '}' ELSE '{' SHOW_DEC exp '}'
{

		if($3){loadToReg($8,$6);}else{printf("%d",$13);}

	 //INIT IN IF
		 temp = (char *)malloc(strlen("	movl	r0, %d(%%rbp)\n\n"));
		 char a[100];
		 strcpy(a,(*$6).c_str());
		 sprintf(temp,"	movl	r0, %d(%%rbp)\n\n",((a[4]-'A')*8)+200);
		 inmain = cat(inmain,temp);

	//FIND ELSE
		temp = (char *)malloc(strlen(".L%d\n"));
		sprintf(temp,".L%d\n",2+cLX);
		inmain = cat(inmain,temp);

	//print IN ELSE
			temp = (char *)malloc(strlen("	movl	%d,r1\n\n"));
			sprintf(temp,"	movl	%d,r1\n",$13);
			inmain = cat(inmain,temp);

		showDec();
		cLX += 1;

}
| IF '(' condition ')' '{' REGISTER INIT exp '}' ELSE '{' REGISTER INIT exp '}'
{
	if($3){loadToReg($8,$6);}else{loadToReg($14,$12);}
 //INIT IN IF
	 temp = (char *)malloc(strlen("	movl	r0, %d(%%rbp)\n\n"));
	 char a[100];
	 strcpy(a,(*$6).c_str());
	 sprintf(temp,"	movl	r0, %d(%%rbp)\n\n",((a[4]-'A')*8)+200);
	 inmain = cat(inmain,temp);

//FIND ELSE
	temp = (char *)malloc(strlen(".L%d\n"));
	sprintf(temp,".L%d\n",2+cLX);
	inmain = cat(inmain,temp);

//INIT IN ELSE
	temp = (char *)malloc(strlen("	movl	%d,r1\n\n"));
	sprintf(temp,"	movl	%d,r1\n",$14);
	inmain = cat(inmain,temp);

	temp = (char *)malloc(strlen("\tmovl\tr1,r%d\n"));
	sprintf(temp,"\tmovl\tr1,r%d\n",cReg);
	inmain = cat(inmain,temp);

	cLX += 1;
}
;

loop:		FORWARD'('exp','REGISTER PLUS INTEGER_LITERAL ')' 	{ initINloop($3,$5,'+',$7); }
			| FORWARD'('exp','REGISTER MINUS INTEGER_LITERAL ')' 	{ initINloop($3,$5,'-',$7); }
			| FORWARD'('exp','REGISTER MULT INTEGER_LITERAL ')' 	{ initINloop($3,$5,'*',$7); }
			| FORWARD'('exp','REGISTER DIV INTEGER_LITERAL ')' 	{ initINloop($3,$5,'/',$7); }
			| FORWARD'('exp','REGISTER MOD INTEGER_LITERAL ')' 	{ initINloop($3,$5,'M',$7); }
			| FORWARD'(' exp ',' exp ')' 				{ funtionLOOP($3,$5); cReg = 1;}
			| FORWARD'('exp','SHOW_DEC exp')'			{ funtionLOOP($3,$6); cReg = 1;}
			| FORWARD'('exp ',' FORWARD'('exp','exp')'')' 		{ int i = 0 ; for(;i<$3;i++) funtionLOOP($7,$9);  }
			| FORWARD'('exp ',' FORWARD'('exp','SHOW_DEC exp')'')'	{ int i = 0 ; for(;i<$3;i++) funtionLOOP($7,$10); }

command:	SHOW_DEC exp 	{ showDec(); $$=$2;}
;

init:		REGISTER INIT exp 	{ 	loadToReg($3,$1);
									temp = (char *)malloc(strlen("	movl	r0, %d(%%rbp)\n\n"));
									char a[100];
									strcpy(a,(*$1).c_str());
									sprintf(temp,"	movl	r0, %d(%%rbp)\n\n",((a[4]-'A')*8)+200);
									inmain = cat(inmain,temp);

									cReg = 1; r[0] = $$;
								}
;

%%

char* cat(char* old,char* nw){
	int a = strlen(old);
	int b = strlen(nw);
	int sum = a + b + 1;
	char *tmp = (char *)malloc(sum);
	strcpy(tmp,old);
	strcat(tmp,nw);
	return tmp;
}

void addtoReg(string* in){
	char a[100];
	strcpy(a,(*in).c_str());
	r[cReg]=reg[a[4]-'A'];

	temp = (char *)malloc(strlen("	movl	%d(%%rbp), r%d\n"));
	sprintf(temp,"	movl	%d(%%rbp), r%d\n",((a[4]-'A')*8)+200,cReg);
	inmain = cat(inmain,temp);
	cReg++;
}

void addtoReg(int in){
	r[cReg] = in;

	temp = (char *)malloc(strlen("	movl	$%d, r%d\n"));
	sprintf(temp,"	movl	$%d, r%d\n",r[cReg],cReg);
	inmain = cat(inmain,temp);
	cReg++;
}




void initINloop(int count,string* regin,char oop,int val){
	int c = count;
	//	 	movl	$0, -4(%rbp)
	// 		jmp	.L2
	// .L3:
	// 		xxx
	//		movl	%d(%rbp), r%d cReg+1
	//		movl	%d, r%d		cReg+2
	// 		addl	r*cReg+2, r*cReg+1
	// .L2:
	// 		cmpl	$4, -4(%rbp)
	// 		jle	.L3
	temp = (char *)malloc(strlen("\tmovl\t$0, r%d\n\tjmp\t.L%d\n.L%d\n"));
	sprintf(temp,"\tmovl\t$0, r%d\n\tjmp\t.L%d\n.L%d\n",cReg,2+cLX,3+cLX);
	cReg+=1;
	inmain = cat(inmain,temp);
	char a[6];

	strcpy(a,(*regin).c_str());

	temp = (char *)malloc(strlen("	movl	%d(%%rbp), r%d\n"));
	sprintf(temp,"	movl	%d(%%rbp), r%d\n",((a[4]-'A')*8)+200,cReg);
	cReg+=1;
	inmain = cat(inmain,temp);

	temp = (char *)malloc(strlen("\tmovl	%d, r%d\n"));
	sprintf(temp,"\tmovl	%d, r%d\n",val,cReg);
	cReg+=1;
	inmain = cat(inmain,temp);

	if(oop == '+'){
		temp = (char *)malloc(strlen("	addl	r%d, r%d\n"));
		sprintf(temp,"	addl	r%d, r%d\n\n",cReg-1,cReg-2);
		cReg = 1;
		inmain = cat(inmain,temp);

	}
	else if(oop == '-'){
		temp = (char *)malloc(strlen("	subl	r1, r0\n"));
		sprintf(temp,"	subl	r%d, r%d\n\n",cReg-1,cReg-2);
		inmain = cat(inmain,temp);

		cReg = 1;
	}
	else if(oop == '*')	{
		temp = (char *)malloc(strlen("	imull	r1, r0\n"));
		sprintf(temp,"	imull	r%d, r%d\n\n",cReg-1,cReg-2);
		inmain = cat(inmain,temp);

		cReg = 1;
	}
	else if(oop == '/')	{
		temp = (char *)malloc(strlen("	idivl	r1, r0\n"));
		sprintf(temp,"	idivl	r%d, r%d\n\n",cReg-1,cReg-2);
		inmain = cat(inmain,temp);

		cReg = 1;
	}

	for(;count>0;count--)
	{
		if(oop == '+'){
			reg[a[4]-'A'] = reg[a[4]-'A'] + val;
		}
		else if(oop == '-'){
			reg[a[4]-'A'] = reg[a[4]-'A'] - val;
		}
		else if(oop == '*')	{
			reg[a[4]-'A'] = reg[a[4]-'A'] * val;
		}
		else if(oop == '/')	{
			reg[a[4]-'A'] = reg[a[4]-'A'] / val;
		}
		else if(oop == 'M')	{
			reg[a[4]-'A'] = reg[a[4]-'A'] % val;
		}
	}
	//	.L2:
	// 		cmpl	$4, -4(%rbp)
	// 		jle	.L3
	temp = (char *)malloc(strlen(".L%d\n\tcmpl\t$%d, %d(%%rbp)\n\tjle\t.L%d\n"));
	sprintf(temp,".L%d\n\tcmpl\t$%d, %d(%%rbp)\n\tjle\t.L%d\n",2+cLX,c-1,((a[4]-'A')*8)+200,3+cLX);
	inmain = cat(inmain,temp);
}

// #regA INIT 1
// SHOW_DEC #regA
// FORWARD(10,SHOW_DEC #regA + 2)
// 1
// 3
// 5
// 7
// 9



void showDec(void){
	headerPercentD();
	temp = (char *)malloc(strlen("\tmovl\tr%d, %%esi\n\tmovl\t$.LC%d, %%edi\n\tmovl\t$0, %%eax\n\tcall\tprintf\n\n"));
	sprintf(temp,"\tmovl\tr%d, %%esi\n\tmovl\t$.LC%d, %%edi\n\tmovl\t$0, %%eax\n\tcall\tprintf\n\n",cReg-1,lcPercentD);
	inmain = cat(inmain,temp);

}

void headerPercentD(){
	if(!alreadyP){
		temp = (char *)malloc(strlen("\n.LC%d\n\t.string\t\"%%d\"\n"));
		sprintf(temp,".LC%d\n\t.string\t\"%%d\"\n",countString);
		header = cat(header,temp);
		alreadyP = 1;
		lcPercentD = countString;
		countString++;
	}
}

void funtionIF(int con,int stat1)
{

// 		xxx
// .L2:
	temp = (char *)malloc(strlen(".L%d\n"));
	sprintf(temp,".L%d\n",2+cLX);
	inmain = cat(inmain,temp);
	cLX += 1;
	if(con) printf("%d\n",stat1);
}
void funtionIFELSE(int con,int stat1,int stat2)
{
	temp = (char *)malloc(strlen(".L%d\n"));
	sprintf(temp,".L%d\n",2+cLX);
	inmain = cat(inmain,temp);

	temp = (char *)malloc(strlen("	movl	%d,r1\n\n"));
	sprintf(temp,"	movl	%d,r1\n",stat2);
	inmain = cat(inmain,temp);

	showDec();

	if(con) printf("%d\n",stat1);
	else printf("%d\n",stat2);
}

void funtionLOOP(int con,int stat1)
{
	/*
	movl	$0, -4(%rbp)
	jmp	.L2
.L3:
	xxxx
	xxxx
	xxxx
	addl	$1, -4(%rbp)
.L2:
	cmpl	$4, -4(%rbp)
	jle	.L3

	*/

	temp = (char *)malloc(strlen("\tmovl\t$0, r%d\n\tjmp .L2\n.L3:"));
	sprintf(temp,"\tmovl\t$0, r%d\n\tjmp .L%d\n.L%d:\n",cReg,2+cLX,3+cLX);
	inmain = cat(inmain,temp);
	//value what  want to print
	/////
	showDec();
	/*int i=0;
	for(;i<con;i++)
	{

		printf("%d\n",stat1);
	}*/
	temp = (char *)malloc(strlen("\n\taddl\t$1, r%d\n.L2:\n\tcmpl\t$%d, r%d\n\tjle .L3\n\n"));
	sprintf(temp,"\n\taddl\t$1, r%d\n.L%d:\n\tcmpl\t$%d, r%d\n\tjle .L%d\n\n",cReg,2+cLX,con-1,cReg,3+cLX);
	inmain = cat(inmain,temp);
	cReg++;
	countString++;
	cLX += 2;
}

void SHOWSTRING(string* str)
{
	char a[100];
	strcpy(a,(*str).c_str());
	a[(*str).length()+1] = '^';

	/*
	header	.LCCountString:
	.string	"xxx"
	//header

	/*movl	-4(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC0, %edi
	movl	$0, %eax
	call	printf*/

	temp = (char *)malloc(strlen("\n.LC%d\n\t.string\t\""));
	sprintf(temp,".LC%d\n\t.string\t\"",countString);
	header = cat(header,temp);

	int i = 7;
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
			/*
			movl	-4(%rbp), %esi
			movl	$.LC0, %edi
			movl	$0, %eax
			call	printf
			*/
			temp = (char *)malloc(strlen("\tmovl\t%d(%%rbp), %%esi\n"));
			sprintf(temp,"\tmovl\t%d(%%rbp), %%esi\n",((a[i+4]-'A')*8)+200);
			inmain = cat(inmain,temp);
			i+=4;
		}
		else{
			temp = (char *)malloc(1);
			sprintf(temp,"%c",a[i]);
			header = cat(header,temp);
		}
		i++;
	}

	temp = (char *)malloc(strlen("\"\n"));
	sprintf(temp,"\"\n\n");
	header = cat(header,temp);

	temp = (char *)malloc(strlen("\tmovl\t$.LC%d, %%edi\n\tmovl\t$0, %%eax\n\tcall\tprintf\n"));
	sprintf(temp,"\tmovl\t$.LC%d, %%edi\n\tmovl\t$0, %%eax\n\tcall\tprintf\n\n",countString);
	inmain = cat(inmain,temp);

	countString++;
	printf("\n");
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

	return reg[cregname[4]-'A'];
}

void loadToReg(int vval, string* regname)
{

	char cregname[10];
	strcpy(cregname, (*regname).c_str());
	int regVal;
	regVal = cregname[4]-'A';
	reg[cregname[4]-'A'] = vval;

}
