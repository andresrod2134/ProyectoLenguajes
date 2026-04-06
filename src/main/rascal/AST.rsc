module AST

import Syntax;

// ── Data Types ───────────────────────────────────────────────────────────────

data AModule = aModule(str name, list[AImport] imports, list[AComponent] components);

data AImport = aImport(str moduleName);

data AComponent
  = aSpace(str name, str superSpace)
  | aSpaceSimple(str name)
  | aVariable(list[AVarDecl] decls)
  | aOperator(str name, list[str] types, list[AAttribute] attrs)
  | aExpression(AExpr expr)
  | aEquation(AExpr lhs, AEquationOp op, AExpr rhs)
  | aRelation(AExpr lhs, ARelOp op, AExpr rhs)
  | aRule(AOpApp lhs, AOpApp rhs);

data AVarDecl = aVarDecl(str varName, str typeName);

data AAttribute
  = aSingle(str name)
  | aPair(str name, str value)
  | aEmpty(str name);

data AEquationOp = aEq() | aEquiv();

data ARelOp = aLt() | aGt() | aLte() | aGte() | aNeq() | aRin();

data AExpr
  = aId(str name)
  | aNeg(AExpr expr)
  | aInOp(AExpr lhs, AExpr rhs)
  | aOr(AExpr lhs, AExpr rhs)
  | aAnd(AExpr lhs, AExpr rhs)
  | aEquivOp(AExpr lhs, AExpr rhs)
  | aBinaryOp(AExpr lhs, str op, AExpr rhs)
  | aQuant(AQuantifier quant, str var, str domain, AExpr body);

data AQuantifier = aForall() | aExists() | aDefer();

data AOpApp = aOpApp(str opName, list[ARuleArg] args);

data ARuleArg = aArg(str name) | aAppArg(AOpApp app);

// ── Implode ───────────────────────────────────────────────────────────────────

AModule implodeModule(start[Module] pt) = implodeModule(pt.top);

AModule implodeModule((Module)`defmodule <Identifier n> <Import* imports> <ModuleComponent* comps> end`)
  = aModule("<n>", [implodeImport(i) | i <- imports], [implodeComponent(c) | c <- comps]);

// Import

AImport implodeImport((Import)`using <Identifier n>`) = aImport("<n>");

// ModuleComponent — usando el label del constructor para hacer dispatch

AComponent implodeComponent(ModuleComponent mc) {
  switch (mc) {
    case (ModuleComponent)`<Space s>`:      return implodeSpace(s);
    case (ModuleComponent)`<Variable v>`:   return implodeVariable(v);
    case (ModuleComponent)`<Operator o>`:   return implodeOperator(o);
    case (ModuleComponent)`<Expression e>`: return implodeExpression(e);
    case (ModuleComponent)`<Equation eq>`:  return implodeEquation(eq);
    case (ModuleComponent)`<Relation r>`:   return implodeRelation(r);
    case (ModuleComponent)`<Rule r>`:       return implodeRule(r);
    default: fail implodeComponent;
  }
}

// Space
// Syntax: "defspace" Identifier ("<" Identifier)? "end"

AComponent implodeSpace((Space)`defspace <Identifier n> \< <Identifier sup> end`)
  = aSpace("<n>", "<sup>");

AComponent implodeSpace((Space)`defspace <Identifier n> end`)
  = aSpaceSimple("<n>");

// Variable
// Syntax: "defvar" VarDeclaration ("," VarDeclaration)* "end"

AComponent implodeVariable((Variable)`defvar <VarDeclaration first> end`)
  = aVariable([implodeVarDecl(first)]);

AComponent implodeVariable((Variable)`defvar <VarDeclaration first> , <VarDeclaration second> end`)
  = aVariable([implodeVarDecl(first), implodeVarDecl(second)]);

AComponent implodeVariable((Variable)`defvar <VarDeclaration first> , <VarDeclaration second> , <VarDeclaration third> end`)
  = aVariable([implodeVarDecl(first), implodeVarDecl(second), implodeVarDecl(third)]);

AComponent implodeVariable((Variable)`defvar <VarDeclaration first> , <VarDeclaration second> , <VarDeclaration third> , <VarDeclaration fourth> end`)
  = aVariable([implodeVarDecl(first), implodeVarDecl(second), implodeVarDecl(third), implodeVarDecl(fourth)]);

AVarDecl implodeVarDecl((VarDeclaration)`<Identifier n> : <Identifier t>`)
  = aVarDecl("<n>", "<t>");

// Operator
// Syntax: "defoperator" Identifier ":" Type ("->" Type)+ Attribute? "end"

AComponent implodeOperator((Operator)`defoperator <Identifier n> : <Type t0> end`)
  = aOperator("<n>", ["<t0>"], []);
AComponent implodeOperator((Operator)`defoperator <Identifier n> : <Type t0> -\> <Type t1> end`)
  = aOperator("<n>", ["<t0>","<t1>"], []);
AComponent implodeOperator((Operator)`defoperator <Identifier n> : <Type t0> -\> <Type t1> -\> <Type t2> end`)
  = aOperator("<n>", ["<t0>","<t1>","<t2>"], []);
AComponent implodeOperator((Operator)`defoperator <Identifier n> : <Type t0> -\> <Type t1> -\> <Type t2> -\> <Type t3> end`)
  = aOperator("<n>", ["<t0>","<t1>","<t2>","<t3>"], []);

AComponent implodeOperator((Operator)`defoperator <Identifier n> : <Type t0> <Attribute attr> end`)
  = aOperator("<n>", ["<t0>"], implodeAttribute(attr));
AComponent implodeOperator((Operator)`defoperator <Identifier n> : <Type t0> -\> <Type t1> <Attribute attr> end`)
  = aOperator("<n>", ["<t0>","<t1>"], implodeAttribute(attr));
AComponent implodeOperator((Operator)`defoperator <Identifier n> : <Type t0> -\> <Type t1> -\> <Type t2> <Attribute attr> end`)
  = aOperator("<n>", ["<t0>","<t1>","<t2>"], implodeAttribute(attr));
AComponent implodeOperator((Operator)`defoperator <Identifier n> : <Type t0> -\> <Type t1> -\> <Type t2> -\> <Type t3> <Attribute attr> end`)
  = aOperator("<n>", ["<t0>","<t1>","<t2>","<t3>"], implodeAttribute(attr));

// Attribute
// Syntax: "[" AttributeElement ("," AttributeElement)* "]"

list[AAttribute] implodeAttribute((Attribute)`[ <AttributeElement e0> ]`)
  = [implodeAttrElem(e0)];
list[AAttribute] implodeAttribute((Attribute)`[ <AttributeElement e0> , <AttributeElement e1> ]`)
  = [implodeAttrElem(e0), implodeAttrElem(e1)];
list[AAttribute] implodeAttribute((Attribute)`[ <AttributeElement e0> , <AttributeElement e1> , <AttributeElement e2> ]`)
  = [implodeAttrElem(e0), implodeAttrElem(e1), implodeAttrElem(e2)];

AAttribute implodeAttrElem((AttributeElement)`<Identifier n>`)
  = aSingle("<n>");
AAttribute implodeAttrElem((AttributeElement)`<Identifier n> : <Identifier v>`)
  = aPair("<n>", "<v>");
AAttribute implodeAttrElem((AttributeElement)`<Identifier n> : <EmptySet _>`)
  = aEmpty("<n>");

// Expression

AComponent implodeExpression((Expression)`defexpression <LogicalExpression e> end`)
  = aExpression(implodeLogicalExpr(e));

// Equation

AComponent implodeEquation((Equation)`<LogicalExpression l> = <LogicalExpression r>`)
  = aEquation(implodeLogicalExpr(l), aEq(), implodeLogicalExpr(r));
AComponent implodeEquation((Equation)`<LogicalExpression l> <Equiv _> <LogicalExpression r>`)
  = aEquation(implodeLogicalExpr(l), aEquiv(), implodeLogicalExpr(r));

// Relation

AComponent implodeRelation((Relation)`<LogicalExpression l> <RelOp op> <LogicalExpression r>`)
  = aRelation(implodeLogicalExpr(l), implodeRelOp(op), implodeLogicalExpr(r));

ARelOp implodeRelOp((RelOp)`\<`)   = aLt();
ARelOp implodeRelOp((RelOp)`\>`)   = aGt();
ARelOp implodeRelOp((RelOp)`\<=`)  = aLte();
ARelOp implodeRelOp((RelOp)`\>=`)  = aGte();
ARelOp implodeRelOp((RelOp)`\<\>`) = aNeq();
ARelOp implodeRelOp((RelOp)`in`)   = aRin();

// Rule
// Syntax: "defrule" OperatorApplication "->" OperatorApplication "end"

AComponent implodeRule((Rule)`defrule <OperatorApplication l> -\> <OperatorApplication r> end`)
  = aRule(implodeOpApp(l), implodeOpApp(r));

AOpApp implodeOpApp((OperatorApplication)`( <Identifier n> <RuleArgument* args> )`)
  = aOpApp("<n>", [implodeRuleArg(a) | a <- args]);

ARuleArg implodeRuleArg((RuleArgument)`<Identifier n>`)
  = aArg("<n>");
ARuleArg implodeRuleArg((RuleArgument)`<OperatorApplication app>`)
  = aAppArg(implodeOpApp(app));

// LogicalExpression

AExpr implodeLogicalExpr((LogicalExpression)`<Identifier n>`)
  = aId("<n>");
AExpr implodeLogicalExpr((LogicalExpression)`( <LogicalExpression e> )`)
  = implodeLogicalExpr(e);
AExpr implodeLogicalExpr((LogicalExpression)`neg <LogicalExpression e>`)
  = aNeg(implodeLogicalExpr(e));
AExpr implodeLogicalExpr((LogicalExpression)`<LogicalExpression l> in <LogicalExpression r>`)
  = aInOp(implodeLogicalExpr(l), implodeLogicalExpr(r));
AExpr implodeLogicalExpr((LogicalExpression)`<LogicalExpression l> or <LogicalExpression r>`)
  = aOr(implodeLogicalExpr(l), implodeLogicalExpr(r));
AExpr implodeLogicalExpr((LogicalExpression)`<LogicalExpression l> and <LogicalExpression r>`)
  = aAnd(implodeLogicalExpr(l), implodeLogicalExpr(r));
AExpr implodeLogicalExpr((LogicalExpression)`<LogicalExpression l> <Equiv _> <LogicalExpression r>`)
  = aEquivOp(implodeLogicalExpr(l), implodeLogicalExpr(r));
AExpr implodeLogicalExpr((LogicalExpression)`<LogicalExpression l> <Identifier op> <LogicalExpression r>`)
  = aBinaryOp(implodeLogicalExpr(l), "<op>", implodeLogicalExpr(r));
AExpr implodeLogicalExpr((LogicalExpression)`<QuantifiedExpression q>`)
  = implodeQuant(q);

// QuantifiedExpression
// Syntax: Quantifier Identifier "in" Identifier "." "(" LogicalExpression ")"

AExpr implodeQuant((QuantifiedExpression)`<Quantifier q> <Identifier var> in <Identifier domain> . ( <LogicalExpression body> )`)
  = aQuant(implodeQuantifier(q), "<var>", "<domain>", implodeLogicalExpr(body));

AQuantifier implodeQuantifier(Quantifier q) {
  switch (q) {
    case (Quantifier)`forall`: return aForall();
    case (Quantifier)`exists`: return aExists();
    case (Quantifier)`defer`:  return aDefer();
    default: fail implodeQuantifier;
  }
}
