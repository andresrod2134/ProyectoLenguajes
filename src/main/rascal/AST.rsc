module AST

data Module = defmodule(str name, list[Import] imports, list[ModuleComponent] components);

data Import = imported(str name);

data ModuleComponent
  = defrule(OperatorApplication ruleLhs, OperatorApplication ruleRhs)
  | variable(list[VarDeclaration] decls)
  | expression(LogicalExpression expr)
  | equation(LogicalExpression eqLhs, LogicalExpression eqRhs)
  | operator(str opName, list[str] types, list[AttributeElement] attrs)
  | relation(LogicalExpression relLhs, RelOp relOp, LogicalExpression relRhs)
  | space(str spaceName)
  | space(str spaceName, str superSpace)
  ;
data VarDeclaration = varDecl(str name, str typeName);

data AttributeElement
  = single(str name)
  | pair(str name, str val)
  | empty(str name)
  ;

data LogicalExpression
  = id(str name)
  | parens(LogicalExpression expr)
  | neg(LogicalExpression expr)
  | inOp(LogicalExpression lhs, LogicalExpression rhs)
  | orOp(LogicalExpression lhs, LogicalExpression rhs)
  | andOp(LogicalExpression lhs, LogicalExpression rhs)
  | equivOp(LogicalExpression lhs, LogicalExpression rhs)
  | binaryOp(LogicalExpression lhs, str op, LogicalExpression rhs)
  | quantExpr(Quantifier quantifier, str var, str domain, LogicalExpression body)
  ;

data Quantifier
  = forall()
  | exists()
  | defer()
  ;

data RelOp
  = lt()
  | gt()
  | lte()
  | gte()
  | neq()
  | rin()
  ;

data OperatorApplication = opApp(str name, list[RuleArg] args);

data RuleArg
  = arg(str name)
  | appArg(OperatorApplication app)
  ;