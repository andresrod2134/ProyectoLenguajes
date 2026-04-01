module Syntax

keyword Reserved = "defmodule" | "end" | "using" | "defspace" | "defoperator" 
                 | "defexpression" | "in" | "forall" | "exists" | "defer" 
                 | "and" | "or" | "neg" | "defrule" | "defvar";

lexical Identifier = ([a-zA-Z][a-zA-Z0-9_\-]*) \ Reserved !>> [a-zA-Z0-9_\-]; 
lexical EmptySet = "∅";
lexical Equiv = "≡";

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

syntax Space = defspace: "defspace" Identifier ("\<" Identifier)? "end";

syntax VarDeclaration = varDecl: Identifier ":" Identifier;
syntax Variable = defvar: "defvar" VarDeclaration ("," VarDeclaration)* "end";

syntax AttributeElement
  = single: Identifier
  | pair:   Identifier ":" Identifier
  | empty:  Identifier ":" EmptySet
  ;
syntax Attribute = attr: "[" AttributeElement ("," AttributeElement)* "]";

syntax Type = typ: Identifier;
syntax Operator = defoperator: "defoperator" Identifier ":" Type ("-\>" Type)+ Attribute? "end";

syntax Expression = defexpression: "defexpression" LogicalExpression "end";

syntax LogicalExpression
  = id:       Identifier
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

syntax Rule = defrule: "defrule" OperatorApplication "-\>" OperatorApplication "end";

syntax OperatorApplication
  = opApp: "(" Identifier RuleArgument* ")";

syntax RuleArgument
  = arg:    Identifier
  | appArg: OperatorApplication
  ;