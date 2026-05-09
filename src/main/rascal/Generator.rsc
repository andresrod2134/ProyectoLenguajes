module Generator

import IO;
import Set;
import List;
import String;
import ParseTree;
import Syntax;
import Parser;

void main() {
    pt = parseModule(|project://proyecto2/instance/spec1.vl|);
    rVal = generator(pt);
    println(rVal);
}

str generator(start[Module] pt) {
    rVal = "";
    visit(pt) {
        case (Module) `defmodule <Identifier name> <Import* imports> <ModuleComponent* components> end`:
            rVal = "=== Module: <name> ===\n" + generateImports(imports) + generateComponents(components);
    }
    return rVal;
}

str generateImports(Import* imports) {
    rVal = "Imports:\n";
    for ((Import) `using <Identifier name>` <- imports) {
        rVal += "  - <name>\n";
    }
    return rVal;
}

str generateComponents(ModuleComponent* components) {
    rVal = "Components:\n";
    for (comp <- components) {
        rVal += generateComponent(comp);
    }
    return rVal;
}

str generateComponent(ModuleComponent comp) {
    visit(comp) {
        case (ModuleComponent) `<Space s>`: return generateSpace(s);
        case (ModuleComponent) `<Variable v>`: return generateVariable(v);
        case (ModuleComponent) `<Operator op>`: return generateOperator(op);
        case (ModuleComponent) `<Expression e>`: return generateExpression(e);
        case (ModuleComponent) `<Rule r>`: return generateRule(r);
    }
    return "";
}

str generateSpace((Space) `defspace <Identifier name> end`) {
    return "  [Space] <name>\n";
}

str generateSpace((Space) `defspace <Identifier name> \< <Identifier superSpace> end`) {
    return "  [Space] <name> \< <superSpace>\n";
}

str generateVariable(Variable v) {
    rVal = "";
    visit(v) {
        case (VarDeclaration) `<Identifier name> : <Identifier typeName>`:
            rVal += "  [Variable] <name>: <typeName>\n";
    }
    return rVal;
}

str generateOperator(Operator op) {
    rVal = "  [Operator] ";
    visit(op) {
        case (Type) `<Identifier typeName>`: rVal += "<typeName> -\> ";
    }
    return rVal + "\n";
}

str generateExpression((Expression) `defexpression <LogicalExpression expr> end`) {
    return "  [Expression] " + generateExpr(expr) + "\n";
}

str generateRule((Rule) `defrule <OperatorApplication ruleLhs> -\> <OperatorApplication ruleRhs> end`) {
    return "  [Rule] " + generateOpApp(ruleLhs) + " -\> " + generateOpApp(ruleRhs) + "\n";
}

str generateExpr(LogicalExpression expr) {
    visit(expr) {
        case (LogicalExpression) `<Identifier name>`: return "<name>";
        case (LogicalExpression) `neg <LogicalExpression e>`: return "neg " + generateExpr(e);
        case (LogicalExpression) `(<LogicalExpression e>)`: return "(" + generateExpr(e) + ")";
        case (LogicalExpression) `<LogicalExpression l> in <LogicalExpression r>`: return generateExpr(l) + " in " + generateExpr(r);
        case (LogicalExpression) `<LogicalExpression l> <Identifier binOp> <LogicalExpression r>`: return generateExpr(l) + " " + "<binOp>" + " " + generateExpr(r);
        case (LogicalExpression) `<QuantifiedExpression q>`: return generateQuant(q);
    }
    return "<expr>";
}

str generateQuant((QuantifiedExpression) `<Quantifier q> <Identifier var> in <Identifier domain> . (<LogicalExpression body>)`) {
    return "<q> <var> in <domain> . (" + generateExpr(body) + ")";
}

str generateOpApp((OperatorApplication) `(<Identifier name> <RuleArgument* args>)`) {
    rVal = "(<name>";
    visit(args) {
        case (RuleArgument) `<Identifier argName>`: rVal += " <argName>";
    }
    return rVal + ")";
}