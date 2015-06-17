Letter = a ... z | A ... Z;
Digit = 0 ... 9;
Iden = Letter | Digit | "_";

Literal = Digit | Iden | String | Char;
BinaryExpr = Expr Op Expr;
UnaryExpr = Op Expr;
Expr = BinaryExpr | UnaryExpr | Literal;

Attribute = "#" Iden

Param = Iden
Var = "var" Iden [ "=" Expr ];
Func = "func" iden [ "->" { Param "," } ] Block;
Call = [ Attribute ] Iden { Expr ", " } [ "->" Iden ]

Stat = Var | Func | Call | Expr