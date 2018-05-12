//
// Created by muhammed on 11/05/18.
//

#ifndef COMPILER_PROJECT_OPERATION_MAPPER_H
#define COMPILER_PROJECT_OPERATION_MAPPER_H


#include <unordered_map>

using namespace std;

unordered_map<string,string> op_to_code = {

	{"+", "add"},
	{"-", "sub"},
	{"/", "div"},
	{"*", "mul"},

	{"==", "if_icmpeq"},
	{"<=", "if_icmple"},
	{">=", "if_icmpge"},
	{"!=", "if_icmpne"},
	{">",  "if_icmpgt"},
	{"<",  "if_icmplt"}

};


#endif //COMPILER_PROJECT_OPERATION_MAPPER_H
