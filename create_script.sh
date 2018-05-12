#!/usr/bin/env bash
flex lexical.l
bison -y -d parser.y
g++ -std=c++11 lex.yy.c y.tab.c