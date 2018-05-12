%{

#include<stdio.h>
#include<stdlib.h>
#include<bits/stdc++.h>
#include "operation_mapper.h"

using namespace std;

/* Lex and yacc functions  */
extern int yylex();
void yyerror(const char *msg);
extern FILE *yyin;



/* enum to get semantic type */
typedef enum { INTEGER_T, FLOAT_T, ERROR_T } var_type;


/* help variables */
int label_counter = 0;
int variable_number = 1;

unordered_map<string,pair<int,var_type>> vars_table;
vector<string> res_code;

string out_file_name , in_file_name;

/* help functions */

void generate_header_java(void);
void generate_footer_java(void);

void define_variable(string id, int type);
void define_int(string id);
void define_float(string id);
void define_boolean(string id);

void write_code(string code);
void back_patch(vector<int> *list, int num);
void evaluate(int start , int end , string operation);


string get_operation_code(string operation);

bool seen(string s);
string generate_label(int current_counter);

vector<int> *merge_list(vector<int> *l1,vector<int> *l2);

%}

%code requires {
	#include <bits/stdc++.h>
	using namespace std;
}


%union{

    int int_val;
    bool bool_val;
    float float_val;

    char *id_val;
    char *arith_op;
    char *bool_op;
    char *rel_op;

    int expr_type;

    struct {
        vector<int> *true_list, *false_list;
    } bool_expr;

    struct {
        vector<int> *next_list;
    } stmt_type;

}

/*-------------------Tokens---------------------*/

%token <int_val> NUM
%token <float_val> FNUM
%token <bool_val> BOOLVAL

%token <rel_op> RELOP
%token <bool_op> BOOLOP
%token <arith_op> ARITHOP
%token <id_val> IDENTIFIER

%token IF_COND ELSE_COND WHILE_LOOP FOR_LOOP INT_TYPE FLOAT_TYPE BOOL_TYPE SIME_COLN COLON OPEN_PRA CLOSE_PRA
%token OPEN_SQR CLOSE_SQR OPEN_CUR CLOSE_CUR ASSIGN


%type <expr_type> primitive_type

%type <expr_type> expression
%type <bool_expr> bool_expression

%type <stmt_type> statement
%type <stmt_type> statement_list
%type <stmt_type> if
%type <stmt_type> while
%type <stmt_type> for

%type <int_val> generate_next
%type <int_val> goto



/*--------------Productions---------------------*/
%%


method_body : { generate_header_java(); }
              statement_list generate_next
              { back_patch($2.next_list,$3); generate_footer_java(); }
            ;


statement_list : statement                                 { $$.next_list = $1.next_list; }
               | statement_list generate_next statement    {  back_patch($1.next_list,$2);  $$.next_list = $3.next_list; }
               ;

statement : declaration    { vector<int> *v = new vector<int>(); $$.next_list = v; }
          | if             { $$.next_list = $1.next_list; }
          | while          { $$.next_list = $1.next_list; }
          | assignment     { vector<int> *v = new vector<int>(); $$.next_list = v; }
          | for            { $$.next_list = $1.next_list; }
          ;

declaration : primitive_type IDENTIFIER SIME_COLN
            {
                string id($2);

                define_variable(id,$1);

            }
            ;


for : FOR_LOOP
      OPEN_PRA
      assignment
      generate_next
      bool_expression
      SIME_COLN
      generate_next
      loop_increment
      goto
      CLOSE_PRA
      OPEN_CUR
      generate_next
      statement_list
      goto
      CLOSE_CUR
      {
         back_patch($5.true_list,$12);
         vector<int> *v = new vector<int>();
         v->push_back($9);
         back_patch(v,$4);
         v = new vector<int>();
         v->push_back($14);
         back_patch(v,$7);
         $$.next_list = $5.false_list;
         back_patch($13.next_list,$7);
      }
    ;



primitive_type : INT_TYPE   { $$ = INTEGER_T;  }
               | FLOAT_TYPE { $$ = FLOAT_T;    }
               ;

if : IF_COND
     OPEN_PRA
     bool_expression
     CLOSE_PRA
     OPEN_CUR
     generate_next
     statement
     goto
     CLOSE_CUR
     ELSE_COND
     OPEN_CUR
     generate_next
     statement
     CLOSE_CUR
     {
        back_patch($3.true_list,$6);
        back_patch($3.false_list,$12);

        $$.next_list = merge_list($7.next_list,$13.next_list);
        $$.next_list->push_back($8);
     }
   ;


while : WHILE_LOOP
        OPEN_PRA
        generate_next
        bool_expression
        CLOSE_PRA
        OPEN_CUR
        generate_next
        statement
        CLOSE_CUR
        {
            $$.next_list = $4.false_list;
            back_patch($8.next_list,$3);
            back_patch($4.true_list,$7);
        }
      ;


loop_increment : IDENTIFIER
                 ASSIGN
                 expression
                 {
                     string var_name($1);
                     if(seen(var_name)){

                       if($3 == vars_table[var_name].second ){
                            if($3 == INTEGER_T){
                                write_code("istore " + to_string(vars_table[var_name].first));
                            }else if($3 == FLOAT_T){
                                write_code("fstore " + to_string(vars_table[var_name].first));
                            }
                        }else{
                            string err = "ERROR : Type not found \n.";
                             yyerror(err.c_str());
                        }
                     }else{
                        string err = "ERROR : " + var_name + " wasn't defined before\n.";
                        yyerror(err.c_str());
                     }

                 }

assignment : IDENTIFIER
             ASSIGN
             expression
             SIME_COLN
            {
                 string var_name($1);
                 if(seen(var_name)){

                   if($3 == vars_table[var_name].second ){
                        if($3 == INTEGER_T){
                            write_code("istore " + to_string(vars_table[var_name].first));
                        }else if($3 == FLOAT_T){
                            write_code("fstore " + to_string(vars_table[var_name].first));
                        }
                    }else{
                        string err = "ERROR : Type not found \n.";
                         yyerror(err.c_str());
                    }
                 }else{
                    string err = "ERROR : " + var_name + " wasn't defined before\n.";
                    yyerror(err.c_str());
                 }
            }
           ;


expression : NUM    { $$ = INTEGER_T; write_code("ldc "+to_string($1)); }
           | FNUM   { $$ = FLOAT_T; write_code("ldc "+to_string($1)); }
           | IDENTIFIER
           {
                string var_name($1);
                if(seen(var_name)){
                    $$ = vars_table[var_name].second;
                    if(vars_table[var_name].second == FLOAT_T){
				        write_code("fload " + to_string(vars_table[var_name].first));
                    }else if (vars_table[var_name].second == INTEGER_T) {
				        write_code("iload " + to_string(vars_table[var_name].first));
                    }
                }else{

                    string err = "ERROR : " + var_name + " wasn't defined before\n.";
                    yyerror(err.c_str());
                    $$ = ERROR_T;

                }
           }
           | expression ARITHOP expression
           {
                evaluate($1,$3,string($2));
           }
           | OPEN_PRA expression CLOSE_PRA { $$ = $2; }
           ;


bool_expression : BOOLVAL
                {
                    if($1){
                        $$.true_list = new vector<int>();
                        $$.false_list = new vector<int>();
                        $$.true_list->push_back(res_code.size());
                    }else{
                         $$.true_list = new vector<int>();
                         $$.false_list = new vector<int>();
                         $$.false_list->push_back(res_code.size());
                    }
                    write_code("goto ");
                }
                | expression RELOP expression
                {
                    string operation($2);
                    $$.true_list = new vector<int>();
                    $$.false_list = new vector<int>();

                    $$.true_list->push_back(res_code.size());
		            write_code(get_operation_code(operation)+ " ");

                    $$.false_list->push_back(res_code.size());
    		        write_code("goto ");

                }
                | bool_expression
                  BOOLOP
                  generate_next
                  bool_expression
                {
                    string operation($2);

                    if(operation == "&&"){
                        back_patch($1.true_list,$3);
                        $$.true_list = $4.true_list;
                        $$.false_list = merge_list($1.false_list,$4.false_list);
                    }else if (operation == "||"){
                        back_patch($1.false_list,$3);
                        $$.true_list = merge_list($1.true_list,$4.true_list);
                        $$.false_list = $4.false_list;
                    }
                }
                ;


generate_next  : { $$ = label_counter; write_code(generate_label(label_counter) + ":"); label_counter++; }
               ;

goto : { $$ = res_code.size(); write_code("goto "); }
     ;

%%
/*----------------C++ Code---------------------------*/


void generate_header_java(){


	write_code(".source " + out_file_name);
	write_code(".class public "+ in_file_name +"\n.super java/lang/Object\n");
	write_code(".method public <init>()V");
	write_code("aload_0");
	write_code("invokenonvirtual java/lang/Object/<init>()V");
	write_code("return");
	write_code(".end method\n");
	write_code(".method public static main([Ljava/lang/String;)V");
	write_code(".limit locals 100\n.limit stack 100");


	define_int("1syso_int_var");
	define_float("1syso_float_var");

}
void generate_footer_java(){

    write_code("return");
	write_code(".end method");
}

string get_operation_code(string operation){

    if(op_to_code.find(operation) == op_to_code.end()){
        return "";
    }
    return op_to_code[operation];
}

void define_variable(string id, int type){

        if(seen(id)){
            //error
            string err = "variable " + id + " found before.\n";
            yyerror(err.c_str());
            return;
        }
        if(type == INTEGER_T){
            define_int(id);
        }else if(type == FLOAT_T){
            define_float(id);
        }

}


void define_int(string id){

    write_code("iconst_0\nistore " + to_string(variable_number));
    vars_table[id] = make_pair(variable_number,INTEGER_T);
    variable_number++;

}

void define_float(string id){
    write_code("fconst_0\nfstore " + to_string(variable_number));
    vars_table[id] = make_pair(variable_number,FLOAT_T);
    variable_number++;
}


void evaluate(int start , int end , string operation){
    if (start == end){
        if(start == INTEGER_T){
            write_code("i" + get_operation_code(operation) );
        }else if(end == FLOAT_T){
            write_code("f" + get_operation_code(operation) );
        }
    }else{
        string err = "ERROR: 2 expressions don't have the same type.\n";
        yyerror(err.c_str());
    }
}

vector<int> *merge_list(vector<int> *l1,vector<int> *l2){
        vector<int> *res = new vector<int>();

        if(l1){
            res->insert(res->end(),l1->begin(),l1->end());
        }
        if(l2){
            res->insert(res->end(),l2->begin(),l2->end());
        }
        return res;
}




void back_patch(vector<int> *list, int num){
    if(list){
        for(int i = 0 ; i < list->size() ; i++){
            res_code[(*list)[i]] = res_code[(*list)[i]] + generate_label(num);
        }
    }
}

bool seen(string s){

    return vars_table.find(s) != vars_table.end();

}

void write_code(string code){
    res_code.push_back(code);
}


string generate_label(int current_counter){
    return "L"+ to_string(current_counter);
}

void yyerror(const char *msg){
    fprintf(stderr, "%s\n", msg);
    exit(1);
}


int main(int argc , char *argv[]){

    if(argc == 1){
        //no file given
        cout << "NO File Given\n";
        exit(1);
    }
    FILE *myfile = fopen(argv[1], "r");

    in_file_name = string(argv[1]);
    out_file_name = "output.j";

    if(!myfile){
        cout << "FILE NOT FOUND\n";
        exit(1);
    }

    yyin = myfile;

    yyparse();

    freopen(out_file_name.c_str(),"w",stdout);

    for(int i = 0 ; i < res_code.size();i++){
        cout << res_code[i] << endl;
    }

    fclose(stdout);

    return 0;
}