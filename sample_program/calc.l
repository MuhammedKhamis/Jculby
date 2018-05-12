%{
#include <stdio.h>
#include <stdlib.h>

#include "y.tab.h"

%}



%%

[0-9]+(\.[0-9]+)?([eE][0-9]+)?  { yylval.f = atof(yytext); return NUM; }
[-+()*/]                        { return yytext[0]; }
[ \t\f\v\n\r]                   { ; }


%%

int yywrap(void){
    return 1;
}