module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;
import Syntax;

PathConfig pcfg = getProjectPathConfig(|project://proyecto2|);

//vl es la extension de los archivos para verilang - start[Module] es asi ya que module es el S0 
Language verilangLang = language(pcfg, "Verilang", "vl", "Plugin", "contribs");

set[LanguageService] contribs() = {
    parser(start[Module] (str program, loc src) {
        return parse(#start[Module], program, src);
    })
};

void main() {
    registerLanguage(verilangLang);
}

