module AST

import Syntax;
import ParseTree;

data AModule = aModule(str name, list[AImport] imports, list[AComponent] components);

data AImport = aImport(str moduleName);

data AComponent
  = aSpace(str spaceName, str superSpace)
  | aSpaceSimple(str spaceName)
  | aVariable(list[AVarDecl] decls)
  | aOperator(str opName, list[str] types, list[AAttribute] attrs)
  | aExpression(AExpr exprBody)
  | aEquation(AExpr eqLhs, AEquationOp eqOp, AExpr eqRhs)
  | aRelation(AExpr relLhs, ARelOp relOp, AExpr relRhs)
  | aRule(AOpApp ruleLhs, AOpApp ruleRhs);

data AVarDecl = aVarDecl(str varName, str typeName);

data AAttribute
  = aSingle(str name)
  | aPair(str attrName, str attrValue)
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

data ARuleArg
  = aArg(str name)
  | aAppArg(AOpApp app);

AModule implodeModule(start[Module] pt) = implodeModule(pt.top);

AModule implodeModule((Module)`defmodule <Identifier n> <Import* imports> <ModuleComponent* comps> end`)
  = aModule("<n>", [implodeImport(i) | i <- imports], [implodeComponent(c) | c <- comps]);

AComponent implodeComponent(start[ModuleComponent] pt) = aSpaceSimple("<component>");

AComponent implodeComponent(start[ModuleComponent] pt) = aSpaceSimple("<component>");