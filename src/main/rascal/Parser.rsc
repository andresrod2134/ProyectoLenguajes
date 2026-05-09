module Parser

import Syntax;
import ParseTree;

public start[Module] parseModule(str src, loc origin) = parse(#start[Module], src, origin);
public start[Module] parseModule(loc origin) = parse(#start[Module], origin);