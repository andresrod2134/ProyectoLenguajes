module Syntax

keyword Reserved = "defmodule" | "end" | "using" | "defspace" | "defoperator" | "defexpression" | "in" | "forall" | "exists" | "defer" | "and" | "or" | "neg" | "defrule" | "defvar";

lexical Identifier = [a-zA-Z][a-zA-Z0-9_]* \ Reserved;

layout Layout = [\ \t\n\r]*;

start syntax Program = program: Module;

syntax Module = defmodule: "defmodule" Identifier Import* ModuleComponent* "end";

syntax Import = importModule: "using" Identifier;

syntax ModuleComponent
  = compRule:       Rule
  | compVariable:   Variable
  | compExpression: Expression
  | compEquation:   Equation
  | compOperator:   Operator
  | compRelation:   Relation
  | compSpace:      Space
  | compAttribute:  Attribute
  ;

syntax Space = defspace: "defspace" Identifier ("\<" Identifier)? "end";

syntax Type = tp: Identifier;

syntax VarDeclaration = varDecl: Identifier ":" Identifier;
syntax Variable = defvar: "defvar" VarDeclaration ("," VarDeclaration)* "end";

syntax AttributeElement
  = attrSingle: Identifier
  | attrPair:   Identifier ":" Identifier
  ;
syntax Attribute = attr: "[" AttributeElement ("," AttributeElement)* "]";

syntax Operator = defoperator: "defoperator" Identifier ":" Type ("-\>" Type)+ Attribute? "end";

syntax Expression = defexpression: "defexpression" LogicalExpression "end";

syntax LogicalExpression
  = lexpr:      Identifier
  | quantified: QuantifiedExpression
  | parens:     "(" LogicalExpression ")"
  | binary:     LogicalExpression Identifier LogicalExpression
  ;

syntax QuantifiedExpression = quantExpr: Quantifier Identifier "in" Identifier "." LogicalExpression;

syntax Quantifier
  = forall: "forall"
  | exists: "exists"
  | defer:  "defer"
  ;

syntax Equation
  = equationEq:  LogicalExpression "=" LogicalExpression
  | equationEqv: LogicalExpression "≡"  LogicalExpression
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

syntax OperatorApplication = opApp: "(" Identifier RuleArgument* ")";

syntax RuleArgument
  = argId:  Identifier
  | argApp: OperatorApplication
  ;