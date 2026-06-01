module RunnerJson

import Syntax;
import Parser;
import Checker;
import ParseTree;
import Message;
import IO;
import Set;
import List;
import String;

str esc(str s) =
    replaceAll(replaceAll(replaceAll(replaceAll(
        s, "\\", "\\\\"), "\"", "\\\""), "\n", "\\n"), "\t", "\\t");

str jsonArr(list[str] items) =
    "[<intercalate(", ", [ "\"<esc(i)>\"" | i <- items ])>]";

str jsonResult(
    bool success,
    str modName,
    list[str] moduleImports,
    list[str] moduleComponents,
    bool parseOk,
    bool tcOk,
    list[str] tcErrs,
    str err,
    str resumen
) =
    "{"
    + "\"success\":<success>,"
    + "\"parseOk\":<parseOk>,"
    + "\"typeCheckOk\":<tcOk>,"
    + "\"semanticOk\":<tcOk>,"
    + "\"module\":\"<esc(modName)>\","
    + "\"moduleImports\":<jsonArr(moduleImports)>,"
    + "\"moduleComponents\":<jsonArr(moduleComponents)>,"
    + "\"typeErrors\":<jsonArr(tcErrs)>,"
    + "\"semanticErrors\":[],"
    + "\"output\":[],"
    + "\"error\":\"<esc(err)>\","
    + "\"codigoFormateado\":\"\","
    + "\"resumen\":\"<esc(resumen)>\""
    + "}";

str extractModuleName(start[Module] pt) {
    visit(pt) {
        case (Module) `defmodule <Identifier name> <Import* _> <ModuleComponent* _> end`:
            return "<name>";
    }
    return "";
}

list[str] extractImports(start[Module] pt) {
    list[str] result = [];
    visit(pt) {
        case (Import) `using <Identifier name>`:
            result += ["<name>"];
    }
    return result;
}

str spaceToStr(Space s) {
    switch(s) {
        case (Space) `defspace <Identifier name> end`:
            return "space: <name>";
        case (Space) `defspace <Identifier name> \< <Identifier sup> end`:
            return "space: <name> \< <sup>";
        default: return "space";
    }
}

str getName(Tree t) {
    visit(t) {
        case Identifier name: return "<name>";
    }
    return "?";
}

list[str] extractComponents(start[Module] pt) {
    list[str] result = [];
    visit(pt) {
        case Space s:
            result += [spaceToStr(s)];
        case Operator op:
            result += ["operator: <getName(op)>"];
        case Variable v:
            result += ["variable"];
        case Rule r:
            result += ["rule"];
        case Expression e:
            result += ["expression"];
    }
    return result;
}

str buildResumen(str modName, list[str] imports, list[str] components) {
    str r = "Modulo: <modName>\\n";
    if (!isEmpty(imports))
        r += "Imports (<size(imports)>): <intercalate(", ", imports)>\\n";
    r += "Componentes (<size(components)>):\\n";
    for (c <- components)
        r += "  - <c>\\n";
    return r;
}

void main(list[str] args) {

    str src;
    loc file;
    try {
        file = isEmpty(args)
            ? |project://proyecto2/instance/spec1.vl|
            : toLocation("file:///" + replaceAll(args[0], "\\", "/"));
        src = readFile(file);
    } catch e: {
        println(jsonResult(false, "", [], [], false, false, [],
            "No se pudo leer el archivo: <e>", ""));
        return;
    }

    start[Module] pt;
    try {
        pt = parseModule(src, file);
    } catch ParseError(loc at): {
        println(jsonResult(false, "", [], [], false, false, [],
            "Error de parsing en linea <at.begin.line>, columna <at.begin.column>", ""));
        return;
    } catch e: {
        println(jsonResult(false, "", [], [], false, false, [],
            "Error de parsing: <e>", ""));
        return;
    }

    str modName       = extractModuleName(pt);
    list[str] imports = extractImports(pt);
    list[str] comps   = extractComponents(pt);
    str resumen       = buildResumen(modName, imports, comps);

    list[str] tcErrs = [];
    bool tcOk = true;
    try {
        TModel tm = TModelFromTree(pt);
        list[Message] msgs = getMessages(tm);
        tcErrs = [ "<m.msg> @ <m.at>" | m <- msgs, m is error ];
        tcOk   = isEmpty(tcErrs);
    } catch e: {
        tcErrs = ["Error en type checking: <e>"];
        tcOk   = false;
    }

    println(jsonResult(true, modName, imports, comps, true, tcOk, tcErrs, "", resumen));
}