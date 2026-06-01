module Checker

import Syntax;
import ParseTree;

extend analysis::typepal::TypePal;

data AType
  = intType()
  | boolType()
  | charType()
  | stringType()
  | userDefinedType(str typeName)
  ;

data IdRole
  = variableId()
  | spaceId()
  | operatorId()
  ;

AType resolveType((TypeAnnotation) `Int`)    = intType();
AType resolveType((TypeAnnotation) `Bool`)   = boolType();
AType resolveType((TypeAnnotation) `Char`)   = charType();
AType resolveType((TypeAnnotation) `String`) = stringType();
AType resolveType((TypeAnnotation) `<Identifier typeName>`) = userDefinedType("<typeName>");

void collect(current: (VarDeclaration) `<Identifier varName> : <TypeAnnotation varType>`, Collector c) {
    c.define("<varName>", variableId(), varName, defType(resolveType(varType)));
}

void collect(current: (Space) `defspace <Identifier spaceName> end`, Collector c) {
    c.define("<spaceName>", spaceId(), spaceName, defType(userDefinedType("<spaceName>")));
}

void collect(current: (Space) `defspace <Identifier spaceName> \< <Identifier superSpace> end`, Collector c) {
    c.define("<spaceName>", spaceId(), spaceName, defType(userDefinedType("<spaceName>")));
    c.use(superSpace, {spaceId()});
}

void collect(current: (Space) `defspace <Identifier spaceName> : <TypeAnnotation spaceType> end`, Collector c) {
    c.define("<spaceName>", spaceId(), spaceName, defType(resolveType(spaceType)));
}

void collect(current: (QuantifiedExpression) `<Quantifier _> <Identifier var> in <Identifier domain> . (<LogicalExpression body>)`, Collector c) {
    c.define("<var>", variableId(), var, defType(userDefinedType("<domain>")));
    c.use(domain, {spaceId(), variableId()});
    collect(body, c);
}

void collect(current: (LogicalExpression) `<Identifier varName>`, Collector c) {
    c.use(varName, {variableId(), spaceId(), operatorId()});
}

void collect(current: (LogicalExpression) `<LogicalExpression lhs> in <LogicalExpression rhs>`, Collector c) {
    collect(lhs, c); collect(rhs, c);
}

void collect(current: (LogicalExpression) `<LogicalExpression lhs> or <LogicalExpression rhs>`, Collector c) {
    collect(lhs, c); collect(rhs, c);
}

void collect(current: (LogicalExpression) `<LogicalExpression lhs> and <LogicalExpression rhs>`, Collector c) {
    collect(lhs, c); collect(rhs, c);
}

void collect(current: (LogicalExpression) `<LogicalExpression lhs> <Equiv _> <LogicalExpression rhs>`, Collector c) {
    collect(lhs, c); collect(rhs, c);
}

void collect(current: (LogicalExpression) `<LogicalExpression lhs> <Identifier _> <LogicalExpression rhs>`, Collector c) {
    collect(lhs, c); collect(rhs, c);
}

void collect(current: (LogicalExpression) `neg <LogicalExpression expr>`, Collector c) {
    collect(expr, c);
}

void collect(current: (LogicalExpression) `(<LogicalExpression expr>)`, Collector c) {
    collect(expr, c);
}

void collect(current: (LogicalExpression) `<QuantifiedExpression q>`, Collector c) {
    collect(q, c);
}

void collectOperators(Tree pt, Collector c) {
    top-down-break visit(pt) {
        case Operator opNode:
            checkSingleOperator(opNode, c);
    }
}

void checkSingleOperator(Operator opNode, Collector c) {
    bool defined = false;
    top-down visit(opNode) {
        case Identifier id: {
            if (!defined) {
                defined = true;
                c.define("<id>", operatorId(), id, defType(userDefinedType("<id>")));
            }
        }
    }
    visit(opNode) {
        case (TypeAnnotation) `<Identifier typeName>`:
            c.use(typeName, {spaceId()});
    }
    visit(opNode) {
        case (AttributeElement) `<Identifier name>`:
            c.use(name, {spaceId(), variableId(), operatorId()});
    }
}

public TModel TModelFromTree(Tree pt) {
    if (pt has top) pt = pt.top;
    col = newCollector("collectAndSolve", pt, tconfig());
    collect(pt, col);
    collectOperators(pt, col);
    return newSolver(pt, col.run()).run();
}