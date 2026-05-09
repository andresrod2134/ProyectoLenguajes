module Syntax

keyword Reserved = "defmodule" | "end" | "using" | "defspace" | "defoperator" 
                 | "defexpression" | "in" | "forall" | "exists" | "defer" 
                 | "and" | "or" | "neg" | "defrule" | "defvar"
                 | "true" | "false" | "Int" | "Bool" | "Char" | "String"; // NUEVO: palabras reservadas para tipos y literales

lexical Identifier = ([a-zA-Z][a-zA-Z0-9_\-]*) \ Reserved !>> [a-zA-Z0-9_\-]; 
lexical EmptySet = "∅";
lexical Equiv = "≡";

//literales para los tipos primitivos
lexical IntLiteral = [0-9]+ !>> [0-9];
lexical BoolLiteral = "true" | "false";
lexical CharLiteral = "\'" ![\'\n]* "\'";
lexical StringLiteral = "\"" ![\"]* "\"";

layout Layout = [\ \t\n\r]* !>> [\ \t\n\r];

start syntax Module = defmodule: "defmodule" Identifier Import* ModuleComponent* "end";

syntax Import = imported: "using" Identifier;

syntax ModuleComponent
  = rule:       Rule
  | variable:   Variable
  | expression: Expression
  | equation:   Equation
  | operator:   Operator
  | relation:   Relation
  | space:      Space
  ;

// Space ahora puede tener un tipo asociado dado por el usuario
syntax Space 
  = defspace: "defspace" Identifier spaceName "end"
  | defspace: "defspace" Identifier spaceName "\<" Identifier superSpace "end"
  | defspace: "defspace" Identifier spaceName ":" TypeAnnotation spaceType "end"
  ;

//anotacion de tipos para valores del programa
syntax TypeAnnotation
  = intType:    "Int"
  | boolType:   "Bool"
  | charType:   "Char"
  | stringType: "String"
  | userType:   Identifier
  ;

syntax VarDeclaration = varDecl: Identifier ":" TypeAnnotation;
syntax Variable = defvar: "defvar" VarDeclaration ("," VarDeclaration)* "end";

syntax AttributeElement
  = single: Identifier
  | pair:   Identifier ":" Identifier
  | empty:  Identifier ":" EmptySet
  ;
syntax Attribute = attr: "[" AttributeElement ("," AttributeElement)* "]";


syntax Type = typ: TypeAnnotation;
syntax Operator = defoperator: "defoperator" Identifier ":" Type ("-\>" Type)+ Attribute? "end";

syntax Expression = defexpression: "defexpression" LogicalExpression "end";

//LogicalExpression ahora incluye literales de tipos primitivos
syntax LogicalExpression
  = id:       Identifier
  | intVal:   IntLiteral    
  | boolVal:  BoolLiteral   
  | charVal:  CharLiteral   
  | strVal:   StringLiteral 
  | parens:   "(" LogicalExpression ")"
  | neg:      "neg" LogicalExpression
  > left inOp:     LogicalExpression "in"  LogicalExpression
  > left orOp:     LogicalExpression "or"  LogicalExpression
  > left andOp:    LogicalExpression "and" LogicalExpression
  > left equivOp:  LogicalExpression Equiv LogicalExpression
  > left binaryOp: LogicalExpression Identifier LogicalExpression
  | quant:    QuantifiedExpression
  ;

syntax QuantifiedExpression
  = quantExpr: Quantifier Identifier "in" Identifier "." "(" LogicalExpression ")";
  
syntax Quantifier
  = forall: "forall"
  | exists: "exists"
  | defer:  "defer"
  ;

syntax Equation
  = eq:    LogicalExpression "=" LogicalExpression
  | equiv: LogicalExpression Equiv LogicalExpression
  ;

syntax Relation = relation: LogicalExpression RelOp LogicalExpression;

syntax RelOp
  = lt:  "\<"
  | gt:  "\>"
  | lte: "\<="
  | gte: "\>="
  | neq: "\<\>"
  | rin: "in"
  ;

syntax Rule = defrule: "defrule" OperatorApplication ruleLhs "-\>" OperatorApplication ruleRhs "end";

syntax OperatorApplication
  = opApp: "(" Identifier RuleArgument* ")";

syntax RuleArgument
  = arg:    Identifier
  | appArg: OperatorApplication
  ;