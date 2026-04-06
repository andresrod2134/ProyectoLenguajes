module AST

data Module = amodule(str name, list[Import] imports, list[Component] components);

data Import = imported(str name);

data Component
  = aSpace(str spaceName, str superSpace)
  | aSpace(str spaceName)
  | aVariable(list[VarDecl] decls)
  | aOperator(str opName, list[str] types, list[AttrElement] attrs)
  | aExpression(Expr exprBody)
  | aEquation(Expr eqLhs, str eqOp, Expr eqRhs)
  | aRelation(Expr relLhs, RelOp relOp, Expr relRhs)
  | aRule(OpApp ruleLhs, OpApp ruleRhs)
  ;

data VarDecl = varDecl(str name, str typeName);

data AttrElement
  = single(str name)
  | apair(str name, str val)
  ;

data Quantifier = aForall() | aExists() | aDefer();

data RelOp = aLt() | aGt() | aLte() | aGte() | aNeq() | aRin();

data Expr
  = id(str name)
  | parens(Expr expr)
  | neg(Expr expr)
  | inOp(Expr lhs, Expr rhs)
  | orOp(Expr lhs, Expr rhs)
  | andOp(Expr lhs, Expr rhs)
  | equivOp(Expr lhs, Expr rhs)
  | binaryOp(Expr lhs, str op, Expr rhs)
  | quant(Quantifier quantifier, str var, str domain, Expr body)
  ;

data OpApp = opApp(str name, list[Arg] args);

data Arg
  = arg(str name)
  | appArg(OpApp app)
  ;