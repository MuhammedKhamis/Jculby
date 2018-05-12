%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

%}

letter [a-zA-Z]
digit [0-9]
digits {digit}+
id {letter}({letter}|{digit})*
arithop "*"|"/"|"+"|"-"
boolop "&&"|"||"
assign "="
relop "=="|"!="|">="|"<="|"<"|">"
num "-"?{digits}
fnum "-"?{digits}.{digits}("E"{digits})?
boolval "true"|"false"



%%

"if"        { return IF_COND; }
"else"      { return ELSE_COND; }
"while"     { return WHILE_LOOP; }
"for"       { return FOR_LOOP; }
"int"       { return INT_TYPE; }
"float"     { return FLOAT_TYPE; }
";"         { return SIME_COLN; }
","         { return COLON; }
"("         { return OPEN_PRA; }
")"         { return CLOSE_PRA; }
"["         { return OPEN_SQR; }
"]"         { return CLOSE_SQR; }
"{"         { return OPEN_CUR; }
"}"         { return CLOSE_CUR; }


{assign}    { return ASSIGN; }

{relop}     { yylval.rel_op = strdup(yytext); return RELOP; }

{arithop}   { yylval.arith_op = strdup(yytext); return ARITHOP; }

{boolop}    { yylval.bool_op = strdup(yytext); return BOOLOP; }

{num}       { yylval.int_val = atoi(yytext); return NUM; }

{fnum}      { yylval.float_val = atof(yytext); return FNUM; }

{boolval}   { if(!strcmp(yytext,"true")){ yylval.bool_val = 1;} else { yylval.bool_val = 0;} return BOOLVAL; }

{id}        { yylval.id_val = strdup(yytext) ; return IDENTIFIER; }

%%


int yywrap(void){
    return 1;
}