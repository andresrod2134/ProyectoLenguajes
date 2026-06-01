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
  ;

void collect(current: (VarDeclaration) `<Identifier varName> : <TypeAnnotation varType>`, Collector c) {
    c.define("<varName>", variableId(), varName, defType(resolveType(varType)));
}

void collect(current: (Space) `defspace <Identifier spaceName> : <TypeAnnotation spaceType> end`, Collector c) {
    c.define("<spaceName>", spaceId(), spaceName, defType(resolveType(spaceType)));
}

void collect(current: (LogicalExpression) `<Identifier varName>`, Collector c) {
    c.use(varName, {variableId(), spaceId()});
}

AType resolveType((TypeAnnotation) `Int`)    = intType();
AType resolveType((TypeAnnotation) `Bool`)   = boolType();
AType resolveType((TypeAnnotation) `Char`)   = charType();
AType resolveType((TypeAnnotation) `String`) = stringType();
AType resolveType((TypeAnnotation) `<Identifier typeName>`) = userDefinedType("<typeName>");

public TModel TModelFromTree(Tree pt) {
    if (pt has top) pt = pt.top;
    col = newCollector("collectAndSolve", pt, tconfig());
    collect(pt, col);
    return newSolver(pt, col.run()).run();
}