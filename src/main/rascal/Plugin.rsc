module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Syntax;
import Checker;

PathConfig pcfg = getProjectPathConfig(|project://proyecto2|);

Language verilangLang = language(pcfg, "Verilang", "vl", "Plugin", "contribs");

set[LanguageService] contribs() = {
    parser(start[Module] (str program, loc src) {
        return parse(#start[Module], program, src);
    }),
    summarizer(Summary (loc _, start[Module] p) {
        tm = TModelFromTree(p);
        defs = getUseDef(tm);
        return summary(p.src, 
            messages = {<m.at, m> | m <- getMessages(tm), !(m is info)},
            definitions = defs
        );
    })
};

void main() {
    registerLanguage(verilangLang);
}