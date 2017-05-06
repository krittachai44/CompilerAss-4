
%{
#include "heading.h"
#include "tok.h"

int yyerror(char *s);
int xtoi(char *hexstring);
int regToInt(char *regname);
char error=' ';

%}
alpha		[A-Z]
AA		[a-zA-Z0-9]
digit		[0-9]
hex		[a-fA-F0-9]
int_const	{digit}+
hex_const	{hex}+("h"|"H")
reg		("#reg"{alpha}|"$acc")
str		[a-zA-Z0-9.()_/*-+# ]

%%

{int_const}	{ yylval.int_val = atoi(yytext); return INTEGER_LITERAL; }
{hex_const}	{ yylval.int_val = xtoi(yytext) ; return INTEGER_LITERAL; }

"+"		{ yylval.op_val = new std::string(yytext); return PLUS; }
"-"		{ yylval.op_val = new std::string(yytext); return MINUS; }
"*"		{ yylval.op_val = new std::string(yytext); return MULT; }
"/"		{ yylval.op_val = new std::string(yytext); return DIV; }
"mod"		{ yylval.op_val = new std::string(yytext); return MOD; }

"&"		{ yylval.op_val = new std::string(yytext); return AND; }
"|"		{ yylval.op_val = new std::string(yytext); return OR; }
"NOT"		{ yylval.op_val = new std::string(yytext); return NOT; }
"=="		{ yylval.op_val = new std::string(yytext); return COMPARE; }

"SHOW_DEC"	{ yylval.op_val = new std::string(yytext); return SHOW_DEC; }

"IF"		{ yylval.op_val = new std::string(yytext); return IF; }
"ELSE"		{ yylval.op_val = new std::string(yytext); return ELSE; }

"FORWARD"	{ yylval.op_val = new std::string(yytext); return FORWARD; }

"INIT"		{ yylval.op_val = new std::string(yytext); return INIT; }

"("		{ yylval.op_val = new std::string(yytext); return '(';}
")"		{ yylval.op_val = new std::string(yytext); return ')';}

"{"		{ yylval.op_val = new std::string(yytext); return '{';}
","		{ yylval.op_val = new std::string(yytext); return ',';}
"}"		{ yylval.op_val = new std::string(yytext); return '}';}

{reg}		{ yylval.op_val = new std::string(yytext); return REGISTER; }

"STRING "{str}+ { yylval.op_val = new std::string(yytext); return STRING; }

"EX"		{ return EXIT;}
[ \t]*		{}
[\n]		{ return NULL;}

.		{ printf("%s",yytext);/*YY_FLUSH_BUFFER; printf("\r! ERROR : Unrecognise string or character\n");*/ return NULL;}
%%
